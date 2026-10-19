use super::linux::Owner;
use anyhow::{bail, Context, Result};
use serde::{Deserialize, Serialize};
use sha2::{Digest, Sha256};
use std::ffi::CString;
use std::fs::{self, File, OpenOptions};
use std::io::{Read, Seek, SeekFrom, Write};
use std::os::fd::{AsRawFd, FromRawFd};
use std::os::unix::fs::{MetadataExt, OpenOptionsExt, PermissionsExt};
use std::path::{Component, Path, PathBuf};
use std::process::Command;
use std::time::{SystemTime, UNIX_EPOCH};

pub(super) const HELPER_NAME: &str = "ReClashHelperService";
pub(super) const CORE_NAME: &str = "ReClashCore";
const MANIFEST_NAME: &str = "manifest.json";
const STATE_ROOT: &str = "/var/lib/reclash-helper";
const UNIT_ROOT: &str = "/etc/systemd/system";
const PROTOCOL: &str = "9";

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, Eq)]
#[serde(rename_all = "camelCase", deny_unknown_fields)]
struct Manifest {
    core_sha256: String,
    helper_sha256: String,
    helper_protocol_version: String,
}

impl Manifest {
    fn validate(&self) -> Result<()> {
        if !valid_hash(&self.core_sha256)
            || !valid_hash(&self.helper_sha256)
            || self.helper_protocol_version != PROTOCOL
        {
            bail!("invalid Helper bundle manifest");
        }
        Ok(())
    }

    fn id(&self) -> String {
        format!("{}-{}", self.core_sha256, self.helper_sha256)
    }
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(deny_unknown_fields)]
struct Registration {
    uid: u32,
    gid: u32,
    bundle: Manifest,
}

pub(super) struct Layout {
    state: PathBuf,
    units: PathBuf,
    root_uid: u32,
}

impl Layout {
    pub(super) fn system() -> Self {
        Self {
            state: STATE_ROOT.into(),
            units: UNIT_ROOT.into(),
            root_uid: 0,
        }
    }

    fn owner_dir(&self, owner: Owner) -> PathBuf {
        self.state.join(owner.uid.to_string())
    }

    fn bundles(&self, owner: Owner) -> PathBuf {
        self.owner_dir(owner).join("bundles")
    }

    fn bundle(&self, owner: Owner, manifest: &Manifest) -> PathBuf {
        self.bundles(owner).join(manifest.id())
    }

    fn unit(&self, owner: Owner) -> PathBuf {
        self.units.join(service_name(owner))
    }

    fn registration(&self, owner: Owner) -> PathBuf {
        self.owner_dir(owner).join("active.json")
    }

    fn prepare(&self, owner: Owner) -> Result<File> {
        secure_directory(
            self.state.parent().context("state root has no parent")?,
            self.root_uid,
        )?;
        secure_directory(&self.units, self.root_uid)?;
        for path in [&self.state, &self.owner_dir(owner), &self.bundles(owner)] {
            match fs::create_dir(path) {
                Ok(()) => fs::set_permissions(path, fs::Permissions::from_mode(0o755))?,
                Err(error) if error.kind() == std::io::ErrorKind::AlreadyExists => {}
                Err(error) => return Err(error.into()),
            }
            secure_directory(path, self.root_uid)?;
        }
        let lock_path = self.owner_dir(owner).join("install.lock");
        let lock = OpenOptions::new()
            .read(true)
            .write(true)
            .create(true)
            .truncate(false)
            .mode(0o600)
            .custom_flags(libc::O_NOFOLLOW | libc::O_CLOEXEC | libc::O_NONBLOCK)
            .open(lock_path)?;
        secure_file(&lock, self.root_uid, false)?;
        if lock.metadata()?.mode() & 0o077 != 0 {
            bail!("installer lock must be private");
        }
        // SAFETY: flock operates on the owned, verified lock descriptor.
        if unsafe { libc::flock(lock.as_raw_fd(), libc::LOCK_EX | libc::LOCK_NB) } != 0 {
            bail!("another installer owns this account's Helper transaction");
        }
        Ok(lock)
    }
}

pub(super) fn service_name(owner: Owner) -> String {
    format!("reclash-helper-{}.service", owner.uid)
}

pub(super) fn runtime_path(owner: Owner) -> PathBuf {
    PathBuf::from(format!("/run/reclash-helper-{}", owner.uid))
}

pub(super) fn unit_contents(executable: &Path, owner: Owner) -> String {
    format!(
        "# ReClash Helper owner={} protocol=9\n\
         [Unit]\n\
         Description=ReClash network Helper for UID {}\n\
         After=network-online.target nftables.service iptables.service\n\
         StartLimitIntervalSec=60\n\
         StartLimitBurst=5\n\n\
         [Service]\n\
         Type=notify\n\
         NotifyAccess=main\n\
         User={}\n\
         Group={}\n\
         ExecStart={}\n\
         Environment=RECLASH_HELPER_OWNER_UID={}\n\
         Environment=RECLASH_HELPER_OWNER_GID={}\n\
         AmbientCapabilities=CAP_NET_ADMIN CAP_NET_RAW\n\
         CapabilityBoundingSet=CAP_NET_ADMIN CAP_NET_RAW\n\
         NoNewPrivileges=yes\n\
         RestrictSUIDSGID=yes\n\
         LockPersonality=yes\n\
         ProtectSystem=full\n\
         ProtectKernelModules=yes\n\
         ProtectKernelTunables=yes\n\
         ProtectControlGroups=yes\n\
         RestrictAddressFamilies=AF_UNIX AF_INET AF_INET6 AF_NETLINK AF_PACKET\n\
         RuntimeDirectory=reclash-helper-{}\n\
         RuntimeDirectoryMode=0700\n\
         UMask=0077\n\
         KillMode=control-group\n\
         TimeoutStartSec=15\n\
         TimeoutStopSec=10\n\
         Restart=on-failure\n\
         RestartSec=5\n\n\
         [Install]\n\
         WantedBy=multi-user.target\n",
        owner.uid,
        owner.uid,
        owner.uid,
        owner.gid,
        quoted_unit_argument(executable),
        owner.uid,
        owner.gid,
        owner.uid,
    )
}

fn quoted_unit_argument(path: &Path) -> String {
    let mut result = String::from("\"");
    for character in path.to_string_lossy().chars() {
        match character {
            '"' | '\\' => {
                result.push('\\');
                result.push(character);
            }
            '%' => result.push_str("%%"),
            _ => result.push(character),
        }
    }
    result.push('"');
    result
}

fn valid_hash(value: &str) -> bool {
    value.len() == 64
        && value
            .bytes()
            .all(|byte| byte.is_ascii_digit() || (b'a'..=b'f').contains(&byte))
}

pub(super) fn open_directory(path: &Path) -> Result<File> {
    if !path.is_absolute() {
        bail!("bundle directories must be absolute");
    }
    let mut directory = File::open("/")?;
    for component in path.components() {
        let Component::Normal(name) = component else {
            if matches!(component, Component::RootDir) {
                continue;
            }
            bail!("invalid directory component");
        };
        use std::os::unix::ffi::OsStrExt;
        let name = CString::new(name.as_bytes())?;
        // SAFETY: both the parent descriptor and NUL-terminated name are valid.
        let fd = unsafe {
            libc::openat(
                directory.as_raw_fd(),
                name.as_ptr(),
                libc::O_RDONLY | libc::O_DIRECTORY | libc::O_NOFOLLOW | libc::O_CLOEXEC,
            )
        };
        if fd < 0 {
            return Err(std::io::Error::last_os_error()).context("open directory without symlinks");
        }
        // SAFETY: openat returned a new descriptor now exclusively owned here.
        directory = unsafe { File::from_raw_fd(fd) };
    }
    Ok(directory)
}

fn open_member(directory: &File, name: &str) -> Result<File> {
    let name = CString::new(name)?;
    // SAFETY: the directory is held open and the file name is a fixed leaf.
    let fd = unsafe {
        libc::openat(
            directory.as_raw_fd(),
            name.as_ptr(),
            libc::O_RDONLY | libc::O_NOFOLLOW | libc::O_CLOEXEC | libc::O_NONBLOCK,
        )
    };
    if fd < 0 {
        return Err(std::io::Error::last_os_error()).context("open bundle file without symlinks");
    }
    // SAFETY: the newly opened descriptor has no other Rust owner.
    let file = unsafe { File::from_raw_fd(fd) };
    let metadata = file.metadata()?;
    if !metadata.is_file() || metadata.nlink() != 1 || metadata.mode() & 0o7000 != 0 {
        bail!("bundle members must be regular, unlinked, non-setuid files");
    }
    Ok(file)
}

fn secure_directory(path: &Path, uid: u32) -> Result<File> {
    let directory = open_directory(path)?;
    let metadata = directory.metadata()?;
    if metadata.uid() != uid || metadata.mode() & 0o022 != 0 {
        bail!("{} is not a trusted root-owned directory", path.display());
    }
    Ok(directory)
}

fn secure_file(file: &File, uid: u32, immutable: bool) -> Result<()> {
    let metadata = file.metadata()?;
    let writable = if immutable { 0o222 } else { 0o022 };
    if !metadata.is_file()
        || metadata.uid() != uid
        || metadata.nlink() != 1
        || metadata.mode() & (writable | 0o7000) != 0
    {
        bail!("untrusted installed file");
    }
    Ok(())
}

pub(super) fn verify_installed_executable(path: &Path) -> Result<File> {
    let parent = path.parent().context("executable has no bundle")?;
    let directory = secure_directory(parent, 0)?;
    if directory.metadata()?.mode() & 0o222 != 0 {
        bail!("installed bundle is mutable");
    }
    for ancestor in parent.ancestors().skip(1) {
        secure_directory(ancestor, 0)?;
    }
    let leaf = path
        .file_name()
        .and_then(|value| value.to_str())
        .context("invalid executable name")?;
    if ![HELPER_NAME, CORE_NAME].contains(&leaf) {
        bail!("unknown installed executable");
    }
    let file = open_member(&directory, leaf)?;
    secure_file(&file, 0, true)?;
    if file.metadata()?.mode() & 0o111 != 0o111 {
        bail!("installed executable is not executable");
    }
    Ok(file)
}

pub(super) fn verify_runtime_bundle(owner: Owner) -> Result<()> {
    let helper = std::env::current_exe()?;
    let bundle = helper.parent().context("Helper bundle path is missing")?;
    let manifest = installed_manifest(bundle, 0)?;
    if helper != Layout::system().bundle(owner, &manifest).join(HELPER_NAME)
        || manifest.core_sha256 != env!("CORE_SHA256")
    {
        bail!("Helper must run from its owner's verified installed bundle");
    }
    verify_installed_executable(&helper)?;
    Ok(())
}

fn hash_file(file: &mut File) -> Result<String> {
    file.seek(SeekFrom::Start(0))?;
    let mut hash = Sha256::new();
    let mut buffer = [0; 65536];
    loop {
        let size = file.read(&mut buffer)?;
        if size == 0 {
            break;
        }
        hash.update(&buffer[..size]);
    }
    file.seek(SeekFrom::Start(0))?;
    Ok(format!("{:x}", hash.finalize()))
}

fn verify_elf(file: &mut File) -> Result<()> {
    let mut magic = [0; 4];
    file.seek(SeekFrom::Start(0))?;
    file.read_exact(&mut magic)?;
    file.seek(SeekFrom::Start(0))?;
    if magic != *b"\x7fELF" {
        bail!("bundle executables must be native ELF binaries");
    }
    Ok(())
}

struct SourceBundle {
    manifest: Manifest,
    helper: File,
    core: File,
}

impl SourceBundle {
    fn open(path: &Path, owner: Owner, expected_core: &str, running_helper: &File) -> Result<Self> {
        let directory = open_directory(path)?;
        let metadata = directory.metadata()?;
        if metadata.uid() != owner.uid || metadata.mode() & 0o077 != 0 {
            bail!("staged bundle must be a private directory owned by the invoking user");
        }
        let manifest_file = open_member(&directory, MANIFEST_NAME)?;
        if manifest_file.metadata()?.len() > 4096 {
            bail!("bundle manifest is too large");
        }
        let manifest: Manifest = serde_json::from_reader(manifest_file)?;
        manifest.validate()?;
        if manifest.core_sha256 != expected_core {
            bail!("manifest does not match the Helper's embedded Core hash");
        }
        let mut helper = open_member(&directory, HELPER_NAME)?;
        let mut core = open_member(&directory, CORE_NAME)?;
        for file in [&helper, &core] {
            let metadata = file.metadata()?;
            if metadata.uid() != owner.uid || metadata.mode() & 0o022 != 0 {
                bail!("staged executable ownership is invalid");
            }
        }
        let self_metadata = running_helper.metadata()?;
        let source_metadata = helper.metadata()?;
        if self_metadata.dev() != source_metadata.dev()
            || self_metadata.ino() != source_metadata.ino()
        {
            bail!("installer must execute the exact staged Helper");
        }
        verify_elf(&mut helper)?;
        verify_elf(&mut core)?;
        if hash_file(&mut helper)? != manifest.helper_sha256
            || hash_file(&mut core)? != manifest.core_sha256
        {
            bail!("staged Helper/Core integrity check failed");
        }
        Ok(Self {
            manifest,
            helper,
            core,
        })
    }
}

fn copy_verified(source: &mut File, path: &Path, expected: &str) -> Result<()> {
    source.seek(SeekFrom::Start(0))?;
    let mut destination = OpenOptions::new()
        .write(true)
        .create_new(true)
        .mode(0o600)
        .custom_flags(libc::O_NOFOLLOW | libc::O_CLOEXEC)
        .open(path)?;
    let mut hash = Sha256::new();
    let mut buffer = [0; 65536];
    loop {
        let size = source.read(&mut buffer)?;
        if size == 0 {
            break;
        }
        destination.write_all(&buffer[..size])?;
        hash.update(&buffer[..size]);
    }
    if format!("{:x}", hash.finalize()) != expected {
        bail!("bundle changed during installation");
    }
    destination.set_permissions(fs::Permissions::from_mode(0o555))?;
    destination.sync_all()?;
    Ok(())
}

fn temporary_path(parent: &Path, name: &str) -> PathBuf {
    let stamp = SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .unwrap_or_default()
        .as_nanos();
    parent.join(format!(".{name}-{}-{stamp}", std::process::id()))
}

fn atomic_write(path: &Path, value: &[u8], mode: u32, uid: u32) -> Result<()> {
    let parent = path.parent().context("file has no parent")?;
    let directory = secure_directory(parent, uid)?;
    let temporary = temporary_path(parent, "reclash-install");
    let result = (|| {
        let mut file = OpenOptions::new()
            .write(true)
            .create_new(true)
            .mode(0o600)
            .custom_flags(libc::O_NOFOLLOW | libc::O_CLOEXEC)
            .open(&temporary)?;
        file.write_all(value)?;
        file.set_permissions(fs::Permissions::from_mode(mode))?;
        file.sync_all()?;
        fs::rename(&temporary, path)?;
        directory.sync_all()?;
        Ok(())
    })();
    if result.is_err() {
        let _ = fs::remove_file(&temporary);
    }
    result
}

fn installed_manifest(path: &Path, uid: u32) -> Result<Manifest> {
    let directory = secure_directory(path, uid)?;
    if directory.metadata()?.mode() & 0o222 != 0 {
        bail!("installed bundle must be immutable");
    }
    let entries = fs::read_dir(path)?
        .map(|entry| entry.map(|entry| entry.file_name()))
        .collect::<std::io::Result<Vec<_>>>()?;
    if entries.len() != 3
        || ![HELPER_NAME, CORE_NAME, MANIFEST_NAME].iter().all(|name| {
            entries
                .iter()
                .any(|entry| entry == std::ffi::OsStr::new(name))
        })
    {
        bail!("installed bundle contains unexpected entries");
    }
    let manifest_file = open_member(&directory, MANIFEST_NAME)?;
    secure_file(&manifest_file, uid, true)?;
    if manifest_file.metadata()?.len() > 4096 {
        bail!("installed manifest is too large");
    }
    let manifest: Manifest = serde_json::from_reader(manifest_file)?;
    manifest.validate()?;
    if path.file_name().and_then(|name| name.to_str()) != Some(manifest.id().as_str()) {
        bail!("bundle hash-address does not match its manifest");
    }
    for (name, expected) in [
        (HELPER_NAME, &manifest.helper_sha256),
        (CORE_NAME, &manifest.core_sha256),
    ] {
        let mut file = open_member(&directory, name)?;
        secure_file(&file, uid, true)?;
        verify_elf(&mut file)?;
        if file.metadata()?.mode() & 0o111 != 0o111 || hash_file(&mut file)? != *expected {
            bail!("installed executable integrity check failed");
        }
    }
    Ok(manifest)
}

fn stage_install(layout: &Layout, owner: Owner, source: &mut SourceBundle) -> Result<PathBuf> {
    let destination = layout.bundle(owner, &source.manifest);
    if fs::symlink_metadata(&destination).is_ok() {
        if installed_manifest(&destination, layout.root_uid)? != source.manifest {
            bail!("hash-addressed bundle already exists with different contents");
        }
        return Ok(destination);
    }
    let staging = temporary_path(&layout.bundles(owner), "staging");
    fs::create_dir(&staging)?;
    fs::set_permissions(&staging, fs::Permissions::from_mode(0o700))?;
    let result = (|| {
        copy_verified(
            &mut source.helper,
            &staging.join(HELPER_NAME),
            &source.manifest.helper_sha256,
        )?;
        copy_verified(
            &mut source.core,
            &staging.join(CORE_NAME),
            &source.manifest.core_sha256,
        )?;
        atomic_write(
            &staging.join(MANIFEST_NAME),
            &serde_json::to_vec(&source.manifest)?,
            0o444,
            layout.root_uid,
        )?;
        let directory = open_directory(&staging)?;
        directory.set_permissions(fs::Permissions::from_mode(0o555))?;
        directory.sync_all()?;
        fs::rename(&staging, &destination)?;
        open_directory(&layout.bundles(owner))?.sync_all()?;
        Ok(destination)
    })();
    if result.is_err() {
        remove_staging(&staging);
    }
    result
}

fn remove_staging(path: &Path) {
    if let Ok(directory) = open_directory(path) {
        let _ = directory.set_permissions(fs::Permissions::from_mode(0o700));
        for name in [HELPER_NAME, CORE_NAME, MANIFEST_NAME] {
            let _ = fs::remove_file(path.join(name));
        }
        let _ = fs::remove_dir(path);
    }
}

pub(super) trait Systemd {
    fn run(&mut self, arguments: &[&str]) -> Result<()>;
    fn query(&mut self, action: &str, name: &str) -> Result<bool>;
}

pub(super) struct Systemctl;

impl Systemd for Systemctl {
    fn run(&mut self, arguments: &[&str]) -> Result<()> {
        let status = Command::new("/usr/bin/systemctl")
            .env_clear()
            .env("PATH", "/usr/bin:/bin")
            .args(arguments)
            .status()
            .context("run systemctl")?;
        if !status.success() {
            bail!("systemctl {} failed with {status}", arguments.join(" "));
        }
        Ok(())
    }

    fn query(&mut self, action: &str, name: &str) -> Result<bool> {
        let status = Command::new("/usr/bin/systemctl")
            .env_clear()
            .env("PATH", "/usr/bin:/bin")
            .args([action, "--quiet", name])
            .status()
            .context("query systemd state")?;
        match status.code() {
            Some(0) => Ok(true),
            Some(1 | 3 | 4) => Ok(false),
            _ => bail!("systemctl state query failed with {status}"),
        }
    }
}

struct Snapshot {
    unit: Option<Vec<u8>>,
    registration: Option<Registration>,
    active: bool,
    enabled: bool,
}

fn read_optional(path: &Path, uid: u32) -> Result<Option<Vec<u8>>> {
    let directory = secure_directory(path.parent().context("file has no parent")?, uid)?;
    let name = path
        .file_name()
        .and_then(|name| name.to_str())
        .context("invalid file name")?;
    let mut file = match open_member(&directory, name) {
        Ok(file) => file,
        Err(error)
            if error
                .downcast_ref::<std::io::Error>()
                .is_some_and(|error| error.kind() == std::io::ErrorKind::NotFound) =>
        {
            return Ok(None)
        }
        Err(error) => return Err(error),
    };
    secure_file(&file, uid, false)?;
    if file.metadata()?.len() > 16384 {
        bail!("installed registration is too large");
    }
    let mut value = Vec::new();
    file.read_to_end(&mut value)?;
    Ok(Some(value))
}

fn snapshot(layout: &Layout, owner: Owner, systemd: &mut impl Systemd) -> Result<Snapshot> {
    let unit = read_optional(&layout.unit(owner), layout.root_uid)?;
    let registration = read_optional(&layout.registration(owner), layout.root_uid)?
        .map(|value| serde_json::from_slice::<Registration>(&value))
        .transpose()?;
    if let Some(registration) = &registration {
        registration.bundle.validate()?;
        if registration.uid != owner.uid || registration.gid == 0 {
            bail!("registration belongs to another account");
        }
        let previous_owner = Owner {
            uid: registration.uid,
            gid: registration.gid,
        };
        let expected = unit_contents(
            &layout.bundle(owner, &registration.bundle).join(HELPER_NAME),
            previous_owner,
        );
        if unit.as_deref() != Some(expected.as_bytes()) {
            bail!("refusing to overwrite an unrecognized systemd unit");
        }
        installed_manifest(&layout.bundle(owner, &registration.bundle), layout.root_uid)?;
    } else if unit.is_some() {
        bail!("refusing to overwrite a systemd unit without an owned registration");
    }
    let name = service_name(owner);
    let active = systemd.query("is-active", &name)?;
    let enabled = systemd.query("is-enabled", &name)?;
    if registration.is_none() && (active || enabled) {
        bail!("an unrecognized service already owns this account's unit name");
    }
    Ok(Snapshot {
        unit,
        registration,
        active,
        enabled,
    })
}

fn stop_confirmed(systemd: &mut impl Systemd, name: &str) -> Result<()> {
    systemd.run(&["stop", name])?;
    if systemd.query("is-active", name)? {
        bail!("Helper shutdown was not confirmed; replacement is blocked");
    }
    Ok(())
}

fn restore(
    layout: &Layout,
    owner: Owner,
    previous: &Snapshot,
    systemd: &mut impl Systemd,
) -> Result<()> {
    let name = service_name(owner);
    stop_confirmed(systemd, &name)?;
    if let Some(unit) = &previous.unit {
        atomic_write(&layout.unit(owner), unit, 0o644, layout.root_uid)?;
        atomic_write(
            &layout.registration(owner),
            &serde_json::to_vec(
                previous
                    .registration
                    .as_ref()
                    .context("missing previous registration")?,
            )?,
            0o644,
            layout.root_uid,
        )?;
        systemd.run(&["daemon-reload"])?;
        systemd.run(&[
            if previous.enabled {
                "enable"
            } else {
                "disable"
            },
            &name,
        ])?;
        if previous.active {
            systemd.run(&["start", &name])?;
        }
    } else {
        systemd.run(&["disable", &name])?;
        for path in [layout.unit(owner), layout.registration(owner)] {
            match fs::remove_file(path) {
                Ok(()) => {}
                Err(error) if error.kind() == std::io::ErrorKind::NotFound => {}
                Err(error) => return Err(error.into()),
            }
        }
        systemd.run(&["daemon-reload"])?;
    }
    Ok(())
}

fn prune(layout: &Layout, owner: Owner, keep: &[String]) -> Result<()> {
    for entry in fs::read_dir(layout.bundles(owner))? {
        let entry = entry?;
        let name = entry.file_name().to_string_lossy().into_owned();
        if keep.contains(&name)
            || name.len() != 129
            || !name.is_ascii()
            || !valid_hash(&name[..64])
            || name.as_bytes()[64] != b'-'
            || !valid_hash(&name[65..])
        {
            continue;
        }
        let path = entry.path();
        if installed_manifest(&path, layout.root_uid).is_err() {
            continue;
        }
        fs::set_permissions(&path, fs::Permissions::from_mode(0o700))?;
        for name in [HELPER_NAME, CORE_NAME, MANIFEST_NAME] {
            fs::remove_file(path.join(name))?;
        }
        fs::remove_dir(path)?;
    }
    Ok(())
}

pub(super) fn install(owner: Owner, source_path: &Path) -> Result<()> {
    if unsafe { libc::getuid() } != 0 || unsafe { libc::geteuid() } != 0 {
        bail!("installation must run through pkexec");
    }
    for path in [
        Path::new("/var"),
        Path::new("/var/lib"),
        Path::new("/etc"),
        Path::new("/etc/systemd"),
        Path::new(UNIT_ROOT),
    ] {
        secure_directory(path, 0)?;
    }
    let running_helper = File::open("/proc/self/exe")?;
    let source = SourceBundle::open(source_path, owner, env!("CORE_SHA256"), &running_helper)?;
    install_bundle(&Layout::system(), owner, source, &mut Systemctl)
}

fn install_bundle(
    layout: &Layout,
    owner: Owner,
    mut source: SourceBundle,
    systemd: &mut impl Systemd,
) -> Result<()> {
    let _lock = layout.prepare(owner)?;
    let previous = snapshot(layout, owner, systemd)?;
    let bundle = stage_install(layout, owner, &mut source)?;
    let name = service_name(owner);
    if previous.registration.is_some() {
        stop_confirmed(systemd, &name)?;
    }
    let registration = Registration {
        uid: owner.uid,
        gid: owner.gid,
        bundle: source.manifest.clone(),
    };
    let result = (|| {
        atomic_write(
            &layout.unit(owner),
            unit_contents(&bundle.join(HELPER_NAME), owner).as_bytes(),
            0o644,
            layout.root_uid,
        )?;
        atomic_write(
            &layout.registration(owner),
            &serde_json::to_vec(&registration)?,
            0o644,
            layout.root_uid,
        )?;
        systemd.run(&["daemon-reload"])?;
        systemd.run(&["enable", &name])?;
        systemd.run(&["start", &name])?;
        if !systemd.query("is-active", &name)? {
            bail!("systemd did not confirm Helper readiness");
        }
        Ok(())
    })();
    if let Err(error) = result {
        if let Err(rollback) = restore(layout, owner, &previous, systemd) {
            bail!("installation failed: {error}; rollback blocked: {rollback}");
        }
        return Err(error).context("Helper installation rolled back");
    }
    let mut keep = vec![source.manifest.id()];
    if let Some(previous) = previous.registration {
        keep.push(previous.bundle.id());
    }
    if let Err(error) = prune(layout, owner, &keep) {
        eprintln!("Helper installed; inactive bundle pruning skipped: {error}");
    }
    Ok(())
}

pub(super) fn uninstall(owner: Owner) -> Result<()> {
    if unsafe { libc::getuid() } != 0 || unsafe { libc::geteuid() } != 0 {
        bail!("uninstallation must run through pkexec");
    }
    let layout = Layout::system();
    let _lock = layout.prepare(owner)?;
    let mut systemd = Systemctl;
    let previous = snapshot(&layout, owner, &mut systemd)?;
    if previous.registration.is_none() {
        return Ok(());
    }
    let name = service_name(owner);
    stop_confirmed(&mut systemd, &name)?;
    systemd.run(&["disable", &name])?;
    fs::remove_file(layout.unit(owner))?;
    fs::remove_file(layout.registration(owner))?;
    systemd.run(&["daemon-reload"])?;
    prune(&layout, owner, &[])
}

#[cfg(test)]
mod tests {
    use super::*;
    use std::os::unix::fs::symlink;

    struct Fixture {
        root: PathBuf,
        layout: Layout,
        owner: Owner,
    }

    impl Fixture {
        fn new() -> Self {
            let root = temporary_path(&std::env::temp_dir(), "reclash-linux-test");
            fs::create_dir(&root).unwrap();
            fs::set_permissions(&root, fs::Permissions::from_mode(0o700)).unwrap();
            let units = root.join("units");
            fs::create_dir(&units).unwrap();
            let uid = unsafe { libc::geteuid() };
            Self {
                layout: Layout {
                    state: root.join("state"),
                    units,
                    root_uid: uid,
                },
                owner: Owner {
                    uid,
                    gid: unsafe { libc::getegid() },
                },
                root,
            }
        }

        fn source(&self, label: &str) -> SourceBundle {
            let path = self.root.join(label);
            fs::create_dir(&path).unwrap();
            fs::set_permissions(&path, fs::Permissions::from_mode(0o700)).unwrap();
            let helper = [b"\x7fELFhelper".as_slice(), label.as_bytes()].concat();
            let core = [b"\x7fELFcore".as_slice(), label.as_bytes()].concat();
            let manifest = Manifest {
                core_sha256: format!("{:x}", Sha256::digest(&core)),
                helper_sha256: format!("{:x}", Sha256::digest(&helper)),
                helper_protocol_version: PROTOCOL.to_string(),
            };
            fs::write(path.join(HELPER_NAME), helper).unwrap();
            fs::write(path.join(CORE_NAME), core).unwrap();
            fs::write(
                path.join(MANIFEST_NAME),
                serde_json::to_vec(&manifest).unwrap(),
            )
            .unwrap();
            let running = File::open(path.join(HELPER_NAME)).unwrap();
            SourceBundle::open(&path, self.owner, &manifest.core_sha256, &running).unwrap()
        }
    }

    impl Drop for Fixture {
        fn drop(&mut self) {
            if let Ok(owners) = fs::read_dir(&self.layout.state) {
                for owner in owners.flatten() {
                    if let Ok(bundles) = fs::read_dir(owner.path().join("bundles")) {
                        for bundle in bundles.flatten() {
                            if bundle.file_type().is_ok_and(|kind| kind.is_dir()) {
                                let _ = fs::set_permissions(
                                    bundle.path(),
                                    fs::Permissions::from_mode(0o700),
                                );
                            }
                        }
                    }
                }
            }
            let _ = fs::remove_dir_all(&self.root);
        }
    }

    #[derive(Default)]
    struct FakeSystemd {
        active: bool,
        enabled: bool,
        fail_start: bool,
        fail_stop: bool,
        calls: Vec<Vec<String>>,
    }

    impl Systemd for FakeSystemd {
        fn run(&mut self, arguments: &[&str]) -> Result<()> {
            self.calls
                .push(arguments.iter().map(|value| value.to_string()).collect());
            match arguments[0] {
                "stop" if self.fail_stop => bail!("unconfirmed stop"),
                "stop" => self.active = false,
                "start" if self.fail_start => {
                    self.fail_start = false;
                    bail!("notify timeout");
                }
                "start" => self.active = true,
                "enable" => self.enabled = true,
                "disable" => self.enabled = false,
                _ => {}
            }
            Ok(())
        }

        fn query(&mut self, action: &str, _: &str) -> Result<bool> {
            Ok(if action == "is-active" {
                self.active
            } else {
                self.enabled
            })
        }
    }

    #[test]
    fn manifest_protocol_is_exact_string_nine() {
        let fixture = Fixture::new();
        let source = fixture.source("protocol");
        let manifest = source.manifest.clone();
        let mut value = serde_json::to_value(&manifest).unwrap();
        assert_eq!(value["helperProtocolVersion"], "9");
        let parsed: Manifest = serde_json::from_value(value.clone()).unwrap();
        parsed.validate().unwrap();
        for invalid in [
            serde_json::json!(9),
            serde_json::json!("8"),
            serde_json::json!("6"),
            serde_json::Value::Null,
        ] {
            value["helperProtocolVersion"] = invalid;
            assert!(serde_json::from_value::<Manifest>(value.clone())
                .and_then(|manifest| manifest.validate().map_err(serde::de::Error::custom))
                .is_err());
        }
        value
            .as_object_mut()
            .unwrap()
            .remove("helperProtocolVersion");
        assert!(serde_json::from_value::<Manifest>(value).is_err());
        install_bundle(
            &fixture.layout,
            fixture.owner,
            source,
            &mut FakeSystemd::default(),
        )
        .unwrap();
        let installed: serde_json::Value = serde_json::from_slice(
            &fs::read(
                fixture
                    .layout
                    .bundle(fixture.owner, &manifest)
                    .join(MANIFEST_NAME),
            )
            .unwrap(),
        )
        .unwrap();
        assert_eq!(installed["helperProtocolVersion"], "9");
    }

    #[test]
    fn unit_runs_as_owner_with_only_network_caps_and_notify() {
        let owner = Owner {
            uid: 1000,
            gid: 1001,
        };
        let unit = unit_contents(
            Path::new("/var/lib/reclash-helper/1000/bundles/pair/ReClashHelperService"),
            owner,
        );
        for line in [
            "Type=notify\n",
            "User=1000\n",
            "Group=1001\n",
            "NoNewPrivileges=yes\n",
            "AmbientCapabilities=CAP_NET_ADMIN CAP_NET_RAW\n",
            "CapabilityBoundingSet=CAP_NET_ADMIN CAP_NET_RAW\n",
            "RuntimeDirectoryMode=0700\n",
            "KillMode=control-group\n",
        ] {
            assert!(unit.contains(line), "missing {line}");
        }
        assert_eq!(service_name(owner), "reclash-helper-1000.service");
        assert_eq!(runtime_path(owner), Path::new("/run/reclash-helper-1000"));
        assert_eq!(
            quoted_unit_argument(Path::new("/a b/100%/a\"b\\c")),
            "\"/a b/100%%/a\\\"b\\\\c\""
        );
    }

    #[test]
    fn immutable_pair_install_is_hash_addressed() {
        let fixture = Fixture::new();
        let source = fixture.source("first");
        let manifest = source.manifest.clone();
        let mut systemd = FakeSystemd::default();
        install_bundle(&fixture.layout, fixture.owner, source, &mut systemd).unwrap();
        let bundle = fixture.layout.bundle(fixture.owner, &manifest);
        assert_eq!(
            installed_manifest(&bundle, fixture.layout.root_uid).unwrap(),
            manifest
        );
        assert_eq!(
            fs::metadata(bundle.join(CORE_NAME)).unwrap().mode() & 0o777,
            0o555
        );
        assert!(systemd.active && systemd.enabled);
    }

    #[test]
    fn failed_notify_rolls_back_to_previous_pair_and_unit() {
        let fixture = Fixture::new();
        let mut systemd = FakeSystemd::default();
        install_bundle(
            &fixture.layout,
            fixture.owner,
            fixture.source("first"),
            &mut systemd,
        )
        .unwrap();
        let before = fs::read(fixture.layout.unit(fixture.owner)).unwrap();
        systemd.fail_start = true;
        assert!(install_bundle(
            &fixture.layout,
            fixture.owner,
            fixture.source("second"),
            &mut systemd
        )
        .is_err());
        assert_eq!(
            fs::read(fixture.layout.unit(fixture.owner)).unwrap(),
            before
        );
        assert!(systemd.active && systemd.enabled);
    }

    #[test]
    fn unconfirmed_exit_does_not_change_registration_or_launch_replacement() {
        let fixture = Fixture::new();
        let mut systemd = FakeSystemd::default();
        install_bundle(
            &fixture.layout,
            fixture.owner,
            fixture.source("first"),
            &mut systemd,
        )
        .unwrap();
        let before = fs::read(fixture.layout.registration(fixture.owner)).unwrap();
        systemd.calls.clear();
        systemd.fail_stop = true;
        assert!(install_bundle(
            &fixture.layout,
            fixture.owner,
            fixture.source("second"),
            &mut systemd
        )
        .is_err());
        assert_eq!(
            fs::read(fixture.layout.registration(fixture.owner)).unwrap(),
            before
        );
        assert!(!systemd.calls.iter().any(|call| call[0] == "start"));
    }

    #[test]
    fn source_symlinks_and_modified_core_are_rejected() {
        let fixture = Fixture::new();
        let source = fixture.source("first");
        let path = fixture.root.join("first");
        let running = File::open(path.join(HELPER_NAME)).unwrap();
        fs::remove_file(path.join(CORE_NAME)).unwrap();
        symlink(path.join(HELPER_NAME), path.join(CORE_NAME)).unwrap();
        assert!(
            SourceBundle::open(&path, fixture.owner, &source.manifest.core_sha256, &running)
                .is_err()
        );
        fs::remove_file(path.join(CORE_NAME)).unwrap();
        fs::write(path.join(CORE_NAME), b"\x7fELFchanged").unwrap();
        assert!(
            SourceBundle::open(&path, fixture.owner, &source.manifest.core_sha256, &running)
                .is_err()
        );
    }

    #[test]
    fn pruning_keeps_other_owners_unknown_entries_and_symlink_targets() {
        let fixture = Fixture::new();
        let mut systemd = FakeSystemd::default();
        let first = fixture.source("first");
        let first_path = fixture.layout.bundle(fixture.owner, &first.manifest);
        install_bundle(&fixture.layout, fixture.owner, first, &mut systemd).unwrap();
        install_bundle(
            &fixture.layout,
            fixture.owner,
            fixture.source("second"),
            &mut systemd,
        )
        .unwrap();
        let bundles = fixture.layout.bundles(fixture.owner);
        let unknown = bundles.join("unrecognized");
        fs::create_dir(&unknown).unwrap();
        fs::write(unknown.join("keep"), b"keep").unwrap();
        let outside = fixture.root.join("outside");
        fs::create_dir(&outside).unwrap();
        fs::write(outside.join("keep"), b"keep").unwrap();
        symlink(
            &outside,
            bundles.join(format!("{}-{}", "0".repeat(64), "1".repeat(64))),
        )
        .unwrap();
        install_bundle(
            &fixture.layout,
            fixture.owner,
            fixture.source("third"),
            &mut systemd,
        )
        .unwrap();
        assert!(!first_path.exists());
        assert!(unknown.join("keep").exists());
        assert!(outside.join("keep").exists());
    }

    #[test]
    fn install_lock_rejects_concurrent_staging() {
        let fixture = Fixture::new();
        let _lock = fixture.layout.prepare(fixture.owner).unwrap();
        assert!(fixture.layout.prepare(fixture.owner).is_err());
    }
}
