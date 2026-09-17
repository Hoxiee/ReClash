use super::hub;
use anyhow::{bail, Context, Result};
use hyper::server::conn::Http;
use sha2::{Digest, Sha256};
use std::fs::{self, File, OpenOptions};
use std::io::{self, Read, Seek, Write};
use std::os::fd::AsRawFd;
use std::os::unix::fs::{FileTypeExt, MetadataExt, OpenOptionsExt, PermissionsExt};
use std::path::{Component, Path, PathBuf};
use std::process::Command;
use std::time::Duration;
use tokio::net::UnixListener;
use tokio::signal::unix::{signal, SignalKind};
use tokio::sync::Semaphore;
use tokio::task::JoinSet;

const HELPER_NAME: &str = "ReClashHelperService";
const CORE_NAME: &str = "ReClashCore";
const INSTALL_ROOT: &str = "/opt/reclash-helper";
const UNIT_ROOT: &str = "/etc/systemd/system";
const UNIT_MARKER: &str = "# ReClash managed Linux Helper v1";
const REQUEST_TIMEOUT: Duration = Duration::from_secs(30);

pub fn main() -> Result<()> {
    let args: Vec<_> = std::env::args_os().skip(1).collect();
    match args.as_slice() {
        [] => tokio::runtime::Runtime::new()?.block_on(run()),
        [command] if command == "install" => install(),
        [command] if command == "uninstall" => uninstall(),
        _ => bail!("expected no arguments, install, or uninstall"),
    }
}

fn uid() -> u32 {
    unsafe { libc::geteuid() }
}

fn invoking_uid() -> Result<u32> {
    if uid() != 0 {
        bail!("installation requires polkit authorization");
    }
    let value = std::env::var("PKEXEC_UID").context("PKEXEC_UID is missing")?;
    let owner: u32 = value.parse().context("invalid PKEXEC_UID")?;
    if owner == 0 {
        bail!("Helper owner must not be root");
    }
    Ok(owner)
}

fn owner_gid(owner: u32) -> Result<u32> {
    let mut buffer = vec![0u8; 16384];
    let mut record = std::mem::MaybeUninit::<libc::passwd>::uninit();
    let mut result = std::ptr::null_mut();
    let code = unsafe {
        libc::getpwuid_r(
            owner,
            record.as_mut_ptr(),
            buffer.as_mut_ptr().cast(),
            buffer.len(),
            &mut result,
        )
    };
    if code != 0 || result.is_null() {
        bail!("cannot resolve Helper owner's primary group");
    }
    let group = unsafe { record.assume_init().pw_gid };
    if group == 0 {
        bail!("Helper owner's group must not be root");
    }
    Ok(group)
}

fn unit_name(owner: u32) -> String {
    format!("reclash-helper-{owner}.service")
}
fn runtime_dir(owner: u32) -> PathBuf {
    PathBuf::from(format!("/run/reclash-helper-{owner}"))
}
fn unit_path(owner: u32) -> PathBuf {
    Path::new(UNIT_ROOT).join(unit_name(owner))
}

fn regular_file(path: &Path) -> Result<File> {
    let file = OpenOptions::new()
        .read(true)
        .custom_flags(libc::O_NOFOLLOW | libc::O_NONBLOCK)
        .open(path)?;
    if !file.metadata()?.is_file() {
        bail!("{} is not a regular file", path.display());
    }
    Ok(file)
}

fn digest(file: &mut File) -> Result<String> {
    file.rewind()?;
    let mut hash = Sha256::new();
    let mut buffer = [0u8; 65536];
    loop {
        let length = file.read(&mut buffer)?;
        if length == 0 {
            break;
        }
        hash.update(&buffer[..length]);
    }
    file.rewind()?;
    Ok(format!("{:x}", hash.finalize()))
}

fn secure_metadata(path: &Path, directory: bool) -> Result<()> {
    let info = fs::symlink_metadata(path)?;
    if info.uid() != 0
        || info.mode() & 0o022 != 0
        || if directory {
            !info.is_dir()
        } else {
            !info.is_file()
        }
    {
        bail!(
            "{} must be root-owned, non-writable by other users, and not a symlink",
            path.display()
        );
    }
    Ok(())
}

pub(super) fn verify_installed_file(path: &Path) -> Result<()> {
    secure_metadata(path, false)?;
    for ancestor in path.ancestors().skip(1) {
        secure_metadata(ancestor, true)?;
    }
    Ok(())
}

fn ensure_directory(path: &Path) -> Result<()> {
    if let Some(parent) = path.parent() {
        if parent != path {
            ensure_directory(parent)?;
        }
    }
    match fs::create_dir(path) {
        Ok(()) => fs::set_permissions(path, fs::Permissions::from_mode(0o755))?,
        Err(error) if error.kind() == io::ErrorKind::AlreadyExists => (),
        Err(error) => return Err(error.into()),
    }
    secure_metadata(path, true)
}

fn lock_install(owner: u32) -> Result<File> {
    ensure_directory(Path::new(INSTALL_ROOT))?;
    let path = Path::new(INSTALL_ROOT).join(format!(".{owner}.lock"));
    let file = OpenOptions::new()
        .read(true)
        .write(true)
        .create(true)
        .truncate(false)
        .mode(0o600)
        .custom_flags(libc::O_NOFOLLOW | libc::O_NONBLOCK)
        .open(&path)?;
    verify_installed_file(&path)?;
    if unsafe { libc::flock(file.as_raw_fd(), libc::LOCK_EX | libc::LOCK_NB) } != 0 {
        bail!("another Helper installation is in progress");
    }
    Ok(file)
}

fn copy_binary(source: &mut File, destination: &Path, hash: &str) -> Result<()> {
    source.rewind()?;
    let mut output = OpenOptions::new()
        .write(true)
        .read(true)
        .create_new(true)
        .mode(0o700)
        .custom_flags(libc::O_NOFOLLOW)
        .open(destination)?;
    io::copy(source, &mut output)?;
    if digest(&mut output)? != hash {
        bail!("binary changed during installation");
    }
    output.set_permissions(fs::Permissions::from_mode(0o755))?;
    output.sync_all()?;
    Ok(())
}

fn install_bundle(owner: u32) -> Result<PathBuf> {
    let source = std::env::current_exe()?;
    let mut helper = File::open("/proc/self/exe")?;
    let mut core = regular_file(
        &source
            .parent()
            .context("missing bundle directory")?
            .join(CORE_NAME),
    )?;
    let expected = env!("CORE_SHA256");
    if expected.len() != 64 || digest(&mut core)? != expected {
        bail!("Core SHA256 does not match this Helper");
    }
    let bundle_id = digest(&mut helper)?;
    let owner_dir = Path::new(INSTALL_ROOT).join(owner.to_string());
    ensure_directory(&owner_dir)?;
    let destination = owner_dir.join(&bundle_id);
    if destination.exists() || fs::symlink_metadata(&destination).is_ok() {
        secure_metadata(&destination, true)?;
        for (name, hash) in [(HELPER_NAME, bundle_id.as_str()), (CORE_NAME, expected)] {
            let file = destination.join(name);
            verify_installed_file(&file)?;
            if digest(&mut regular_file(&file)?)? != hash {
                bail!("installed bundle has unexpected content");
            }
        }
        return Ok(destination.join(HELPER_NAME));
    }
    let staging = owner_dir.join(format!(".install-{}", std::process::id()));
    fs::create_dir(&staging).context("create protected staging directory")?;
    fs::set_permissions(&staging, fs::Permissions::from_mode(0o700))?;
    let result = (|| {
        copy_binary(&mut helper, &staging.join(HELPER_NAME), &bundle_id)?;
        copy_binary(&mut core, &staging.join(CORE_NAME), expected)?;
        fs::set_permissions(&staging, fs::Permissions::from_mode(0o755))?;
        fs::rename(&staging, &destination)?;
        File::open(&owner_dir)?.sync_all()?;
        Ok(destination.join(HELPER_NAME))
    })();
    if result.is_err() {
        let _ = fs::remove_file(staging.join(HELPER_NAME));
        let _ = fs::remove_file(staging.join(CORE_NAME));
        let _ = fs::remove_dir(staging);
    }
    result
}

fn unit_contents(executable: &Path, owner: u32, group: u32) -> String {
    format!("{UNIT_MARKER}\n# OwnerUID={owner}\n[Unit]\nDescription=ReClash Linux network helper\nAfter=network.target\n\n[Service]\nType=notify\nNotifyAccess=main\nTimeoutStartSec=15\nUser={owner}\nGroup={group}\nExecStart={}\nRuntimeDirectory=reclash-helper-{owner}\nRuntimeDirectoryMode=0700\nUMask=0077\nAmbientCapabilities=CAP_NET_ADMIN CAP_NET_RAW\nCapabilityBoundingSet=CAP_NET_ADMIN CAP_NET_RAW\nNoNewPrivileges=yes\nProtectSystem=full\nRestrictSUIDSGID=yes\nKillMode=control-group\nTimeoutStopSec=8\nRestart=on-failure\nRestartSec=2\n\n[Install]\nWantedBy=multi-user.target\n", executable.display())
}

fn read_existing_unit(path: &Path, owner: u32) -> Result<Option<Vec<u8>>> {
    match fs::symlink_metadata(path) {
        Err(error) if error.kind() == io::ErrorKind::NotFound => return Ok(None),
        Err(error) => return Err(error.into()),
        Ok(_) => verify_installed_file(path)?,
    }
    let bytes = fs::read(path)?;
    if !is_owned_unit(&bytes, owner) {
        bail!("refusing to replace a foreign systemd unit");
    }
    Ok(Some(bytes))
}

fn is_owned_unit(bytes: &[u8], owner: u32) -> bool {
    std::str::from_utf8(bytes)
        .is_ok_and(|text| text.starts_with(&format!("{UNIT_MARKER}\n# OwnerUID={owner}\n")))
}

fn atomic_unit(path: &Path, contents: &[u8]) -> Result<()> {
    let temp = path.with_extension(format!("new-{}", std::process::id()));
    let mut output = OpenOptions::new()
        .write(true)
        .create_new(true)
        .mode(0o644)
        .custom_flags(libc::O_NOFOLLOW)
        .open(&temp)?;
    let result = (|| {
        output.write_all(contents)?;
        output.sync_all()?;
        fs::rename(&temp, path)?;
        File::open(path.parent().context("unit directory missing")?)?.sync_all()?;
        Ok(())
    })();
    if result.is_err() {
        let _ = fs::remove_file(temp);
    }
    result
}

fn systemctl(args: &[&str]) -> Result<()> {
    let status = Command::new("/usr/bin/systemctl")
        .env_clear()
        .env("PATH", "/usr/bin:/bin")
        .args(args)
        .status()?;
    if !status.success() {
        bail!("systemctl {} failed: {status}", args.join(" "));
    }
    Ok(())
}

fn notify_ready() -> Result<()> {
    let address =
        std::env::var_os("NOTIFY_SOCKET").context("systemd notification socket is missing")?;
    let socket = std::os::unix::net::UnixDatagram::unbound()?;
    use std::os::unix::ffi::OsStrExt;
    if let Some(name) = address.as_bytes().strip_prefix(b"@") {
        use std::os::linux::net::SocketAddrExt;
        let address = std::os::unix::net::SocketAddr::from_abstract_name(name)?;
        socket.connect_addr(&address)?;
    } else {
        socket.connect(Path::new(&address))?;
    }
    socket.send(b"READY=1")?;
    Ok(())
}

fn install() -> Result<()> {
    let owner = invoking_uid()?;
    let group = owner_gid(owner)?;
    let _lock = lock_install(owner)?;
    ensure_directory(Path::new(UNIT_ROOT))?;
    let path = unit_path(owner);
    let previous = read_existing_unit(&path, owner)?;
    for root in [
        "/etc/systemd/system",
        "/run/systemd/system",
        "/usr/lib/systemd/system",
    ] {
        if root != UNIT_ROOT && fs::symlink_metadata(Path::new(root).join(unit_name(owner))).is_ok()
        {
            bail!("refusing to shadow an external Helper unit");
        }
        if fs::symlink_metadata(Path::new(root).join(format!("{}.d", unit_name(owner)))).is_ok() {
            bail!("refusing to replace a Helper unit with external drop-ins");
        }
    }
    let executable = install_bundle(owner)?;
    atomic_unit(&path, unit_contents(&executable, owner, group).as_bytes())?;
    let name = unit_name(owner);
    let result = (|| {
        systemctl(&["daemon-reload"])?;
        systemctl(&["restart", &name])?;
        systemctl(&["enable", &name])
    })();
    if let Err(error) = result {
        let rollback = (|| -> Result<()> {
            systemctl(&["stop", &name])?;
            match previous {
                Some(bytes) => {
                    atomic_unit(&path, &bytes)?;
                    systemctl(&["daemon-reload"])?;
                    systemctl(&["start", &name])?;
                }
                None => {
                    systemctl(&["disable", &name])?;
                    fs::remove_file(&path)?;
                    systemctl(&["daemon-reload"])?;
                }
            }
            Ok(())
        })();
        return Err(error.context(format!("installation failed; rollback: {rollback:?}")));
    }
    Ok(())
}

fn uninstall() -> Result<()> {
    let owner = invoking_uid()?;
    let _lock = lock_install(owner)?;
    let path = unit_path(owner);
    if read_existing_unit(&path, owner)?.is_none() {
        return Ok(());
    }
    systemctl(&["disable", "--now", &unit_name(owner)])?;
    fs::remove_file(path)?;
    systemctl(&["daemon-reload"])
}

pub(super) fn ensure_owner_socket(address: &str) -> io::Result<()> {
    let path = Path::new(address);
    if !path.is_absolute()
        || path
            .components()
            .any(|part| !matches!(part, Component::RootDir | Component::Normal(_)))
    {
        return Err(io::Error::other(
            "Core address must be an absolute Unix socket path",
        ));
    }
    let metadata = fs::symlink_metadata(path)?;
    if !metadata.file_type().is_socket() || metadata.uid() != uid() || metadata.mode() & 0o077 != 0
    {
        return Err(io::Error::other(
            "Core socket must be private and owned by the Helper user",
        ));
    }
    Ok(())
}

fn verify_network_capabilities(status: &str) -> Result<()> {
    for name in ["CapEff", "CapPrm", "CapAmb", "CapBnd"] {
        let value = status
            .lines()
            .find_map(|line| line.strip_prefix(&format!("{name}:")))
            .context("process capabilities are unavailable")?;
        if u64::from_str_radix(value.trim(), 16)? != (1 << 12) | (1 << 13) {
            bail!("Helper requires exactly CAP_NET_ADMIN and CAP_NET_RAW ({name})");
        }
    }
    Ok(())
}

fn ensure_service_identity() -> Result<()> {
    verify_network_capabilities(&fs::read_to_string("/proc/self/status")?)?;
    if uid() == 0 || unsafe { libc::getuid() } != uid() {
        bail!("Helper service must run as its non-root owner");
    }
    let executable = std::env::current_exe()?;
    verify_installed_file(&executable)?;
    let expected_root = Path::new(INSTALL_ROOT).join(uid().to_string());
    if executable.parent().and_then(Path::parent) != Some(expected_root.as_path()) {
        bail!("Helper is not running from its installed bundle");
    }
    let directory = executable.parent().context("missing bundle directory")?;
    if directory.file_name().and_then(|name| name.to_str())
        != Some(digest(&mut regular_file(&executable)?)?.as_str())
    {
        bail!("installed Helper SHA256 mismatch");
    }
    let core_path = directory.join(CORE_NAME);
    verify_installed_file(&core_path)?;
    if env!("CORE_SHA256").len() != 64
        || digest(&mut regular_file(&core_path)?)? != env!("CORE_SHA256")
    {
        bail!("installed Core SHA256 mismatch");
    }
    Ok(())
}

fn permitted_peer(peer: u32, owner: u32) -> bool {
    owner != 0 && peer == owner
}

async fn run() -> Result<()> {
    ensure_service_identity()?;
    let directory = runtime_dir(uid());
    let metadata = fs::symlink_metadata(&directory)?;
    if !metadata.is_dir() || metadata.uid() != uid() || metadata.mode() & 0o077 != 0 {
        bail!("Helper runtime directory is not private");
    }
    let lock_path = directory.join("service.lock");
    let lock = OpenOptions::new()
        .read(true)
        .write(true)
        .create(true)
        .truncate(false)
        .mode(0o600)
        .custom_flags(libc::O_NOFOLLOW | libc::O_NONBLOCK)
        .open(&lock_path)?;
    if !lock.metadata()?.is_file()
        || unsafe { libc::flock(lock.as_raw_fd(), libc::LOCK_EX | libc::LOCK_NB) } != 0
    {
        bail!("Helper runtime is already owned by another process");
    }
    let socket = directory.join("helper.sock");
    match fs::symlink_metadata(&socket) {
        Ok(metadata) if metadata.file_type().is_socket() && metadata.uid() == uid() => {
            fs::remove_file(&socket)?
        }
        Ok(_) => bail!("refusing to replace a foreign Helper socket"),
        Err(error) if error.kind() == io::ErrorKind::NotFound => (),
        Err(error) => return Err(error.into()),
    }
    let listener = UnixListener::bind(&socket)?;
    fs::set_permissions(&socket, fs::Permissions::from_mode(0o600))?;
    let mut terminate = signal(SignalKind::terminate())?;
    let mut interrupt = signal(SignalKind::interrupt())?;
    notify_ready()?;
    let semaphore = std::sync::Arc::new(Semaphore::new(16));
    let mut connections = JoinSet::new();
    loop {
        tokio::select! {
            _ = terminate.recv() => break,
            _ = interrupt.recv() => break,
            Some(_) = connections.join_next(), if !connections.is_empty() => (),
            accepted = listener.accept() => {
                let (stream, _) = accepted?;
                if !permitted_peer(stream.peer_cred()?.uid(), uid()) { continue; }
                let Ok(permit) = semaphore.clone().try_acquire_owned() else { continue; };
                connections.spawn(async move {
                    let _permit = permit;
                    let service = warp::service(hub::routes());
                    let mut http = Http::new();
                    http.http1_only(true).http1_keep_alive(false).max_buf_size(8192);
                    let _ = tokio::time::timeout(REQUEST_TIMEOUT, http.serve_connection(stream, service)).await;
                });
            }
        }
    }
    connections.abort_all();
    while connections.join_next().await.is_some() {}
    hub::shutdown_managed_core()?;
    fs::remove_file(socket)?;
    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;
    use std::os::unix::fs::symlink;
    use std::os::unix::net::UnixListener as StdListener;

    fn sandbox() -> PathBuf {
        let path = std::env::temp_dir().join(format!(
            "reclash-helper-test-{}-{}",
            std::process::id(),
            std::time::SystemTime::now()
                .duration_since(std::time::UNIX_EPOCH)
                .unwrap()
                .as_nanos()
        ));
        fs::create_dir(&path).unwrap();
        path
    }

    #[test]
    fn unit_keeps_user_identity_and_only_network_capabilities() {
        let unit = unit_contents(
            Path::new("/opt/reclash-helper/1000/abcdef/ReClashHelperService"),
            1000,
            1000,
        );
        assert!(unit.contains("User=1000\nGroup=1000\n"));
        assert!(unit.contains("AmbientCapabilities=CAP_NET_ADMIN CAP_NET_RAW\n"));
        assert!(unit.contains("CapabilityBoundingSet=CAP_NET_ADMIN CAP_NET_RAW\n"));
        assert!(unit.contains("KillMode=control-group\n"));
        assert!(!unit.contains("PrivateNetwork="));
        assert!(!unit.contains("/tmp/.mount"));
    }

    #[test]
    fn copy_validates_bytes_and_rejects_replacement() {
        let dir = sandbox();
        let source = dir.join("source");
        fs::write(&source, b"bundle bytes").unwrap();
        let mut file = regular_file(&source).unwrap();
        let hash = digest(&mut file).unwrap();
        let target = dir.join("target");
        copy_binary(&mut file, &target, &hash).unwrap();
        assert!(copy_binary(&mut file, &target, &hash).is_err());
        assert_eq!(fs::metadata(&target).unwrap().mode() & 0o777, 0o755);
        assert!(copy_binary(&mut file, &dir.join("wrong"), "wrong").is_err());
        fs::remove_dir_all(dir).unwrap();
    }

    #[test]
    fn regular_file_rejects_symlinks_and_directories() {
        let dir = sandbox();
        fs::write(dir.join("file"), b"data").unwrap();
        symlink(dir.join("file"), dir.join("link")).unwrap();
        assert!(regular_file(&dir.join("link")).is_err());
        assert!(regular_file(&dir).is_err());
        fs::remove_dir_all(dir).unwrap();
    }

    #[test]
    fn core_address_requires_private_owned_socket() {
        let dir = sandbox();
        let path = dir.join("core.sock");
        let _listener = StdListener::bind(&path).unwrap();
        fs::set_permissions(&path, fs::Permissions::from_mode(0o600)).unwrap();
        assert!(ensure_owner_socket(path.to_str().unwrap()).is_ok());
        fs::set_permissions(&path, fs::Permissions::from_mode(0o666)).unwrap();
        assert!(ensure_owner_socket(path.to_str().unwrap()).is_err());
        assert!(ensure_owner_socket("127.0.0.1:12345").is_err());
        symlink(&path, dir.join("alias")).unwrap();
        assert!(ensure_owner_socket(dir.join("alias").to_str().unwrap()).is_err());
        fs::remove_dir_all(dir).unwrap();
    }
    #[test]
    fn capabilities_reject_missing_or_excess_privileges() {
        let expected = "CapEff:\t0000000000003000\nCapPrm:\t0000000000003000\nCapAmb:\t0000000000003000\nCapBnd:\t0000000000003000\n";
        assert!(verify_network_capabilities(expected).is_ok());
        assert!(verify_network_capabilities(&expected.replace("3000", "3001")).is_err());
        assert!(verify_network_capabilities(&expected.replace("3000", "1000")).is_err());
        assert!(verify_network_capabilities("").is_err());
    }

    #[test]
    fn peer_identity_never_accepts_root_or_another_user() {
        assert!(permitted_peer(1000, 1000));
        assert!(!permitted_peer(0, 1000));
        assert!(!permitted_peer(1001, 1000));
        assert!(!permitted_peer(0, 0));
    }

    #[test]
    fn unit_ownership_rejects_foreign_or_malformed_records() {
        let unit = unit_contents(
            Path::new("/opt/reclash-helper/1000/hash/ReClashHelperService"),
            1000,
            1000,
        );
        assert!(is_owned_unit(unit.as_bytes(), 1000));
        assert!(!is_owned_unit(unit.as_bytes(), 1001));
        assert!(!is_owned_unit(
            b"[Service]\nExecStart=/usr/bin/other\n",
            1000
        ));
        assert!(!is_owned_unit(&[255], 1000));
    }

    #[test]
    fn atomic_unit_replaces_only_the_named_entry() {
        let dir = sandbox();
        let target = dir.join("unit.service");
        fs::write(&target, b"old").unwrap();
        atomic_unit(&target, b"new").unwrap();
        assert_eq!(fs::read(&target).unwrap(), b"new");
        atomic_unit(&target, b"old").unwrap();
        assert_eq!(fs::read(&target).unwrap(), b"old");
        let blocker = target.with_extension(format!("new-{}", std::process::id()));
        symlink(&target, &blocker).unwrap();
        assert!(atomic_unit(&target, b"forbidden").is_err());
        assert_eq!(fs::read(&target).unwrap(), b"old");
        fs::remove_dir_all(dir).unwrap();
    }

    #[test]
    fn installed_binary_rejects_user_owned_ancestors() {
        let dir = sandbox();
        let target = dir.join("core");
        fs::write(&target, b"core").unwrap();
        assert!(verify_installed_file(&target).is_err());
        symlink("/usr/bin/true", dir.join("link")).unwrap();
        assert!(verify_installed_file(&dir.join("link")).is_err());
        fs::remove_dir_all(dir).unwrap();
    }
}
