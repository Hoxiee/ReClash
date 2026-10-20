use super::linux_install;
use crate::service::hub::{
    begin_shutdown, ensure_core_sha256_configured, log_message,
    release_managed_core_on_shutdown_confirmed, routes,
};
use anyhow::{bail, Context, Result};
use std::ffi::{OsStr, OsString};
use std::fs::{self, File, OpenOptions};
use std::future::Future;
use std::io::{Error, ErrorKind};
use std::os::fd::AsRawFd;
use std::os::unix::fs::{FileTypeExt, MetadataExt, OpenOptionsExt, PermissionsExt};
use std::os::unix::net::UnixDatagram;
use std::path::{Path, PathBuf};
use std::pin::Pin;
use std::task::{Context as TaskContext, Poll};
use std::time::Duration;
use tokio::net::{UnixListener, UnixStream};
use tokio::runtime::Runtime;
use tokio::signal::unix::{signal, SignalKind};
use tokio::time::Sleep;
use tokio_stream::Stream;

const OWNER_UID_ENV: &str = "RECLASH_HELPER_OWNER_UID";
const OWNER_GID_ENV: &str = "RECLASH_HELPER_OWNER_GID";
const NETWORK_CAPABILITIES: u64 = (1 << 12) | (1 << 13);
const ACCEPT_RETRY_DELAY: Duration = Duration::from_secs(1);

#[derive(Debug, PartialEq, Eq)]
enum ServiceCommand {
    Run,
    Install {
        bundle: PathBuf,
        replace_owned: bool,
        package: Option<linux_install::LinuxPackage>,
    },
    Uninstall,
    PackageUninstall(linux_install::LinuxPackage),
}

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub(super) struct Owner {
    pub(super) uid: u32,
    pub(super) gid: u32,
}

pub fn main() -> Result<()> {
    let result = match service_command(std::env::args_os().skip(1))? {
        ServiceCommand::Run => run_service(),
        ServiceCommand::Install {
            bundle,
            replace_owned,
            package,
        } => linux_install::install(invoking_owner()?, &bundle, replace_owned, package),
        ServiceCommand::Uninstall => linux_install::uninstall(invoking_owner()?),
        ServiceCommand::PackageUninstall(package) => linux_install::package_uninstall(package),
    };
    if let Err(error) = &result {
        if let Some(failure) = error.downcast_ref::<linux_install::InstallFailure>() {
            eprintln!("reclash-helper-error: {}", failure.code());
        }
    }
    result
}

fn service_command(args: impl IntoIterator<Item = OsString>) -> Result<ServiceCommand> {
    let mut args = args.into_iter();
    let command = match args.next().as_deref() {
        None => ServiceCommand::Run,
        Some(value) if value == OsStr::new("install") => {
            if args.next().as_deref() != Some(OsStr::new("--bundle")) {
                bail!("installation requires --bundle and a verified staged pair");
            }
            let path = PathBuf::from(args.next().context("staged bundle path is missing")?);
            if !path.is_absolute()
                || path
                    .components()
                    .any(|part| matches!(part, std::path::Component::ParentDir))
            {
                bail!("invalid staged bundle path");
            }
            let mut replace_owned = false;
            let mut package = None;
            while let Some(option) = args.next() {
                if option == OsStr::new("--replace-owned") && !replace_owned {
                    replace_owned = true;
                } else if option == OsStr::new("--package") && package.is_none() {
                    package = Some(linux_install::LinuxPackage::parse(
                        args.next()
                            .and_then(|value| value.into_string().ok())
                            .context("package format is missing")?
                            .as_str(),
                    )?);
                } else {
                    bail!("unexpected installation option");
                }
            }
            ServiceCommand::Install {
                bundle: path,
                replace_owned,
                package,
            }
        }
        Some(value) if value == OsStr::new("uninstall") => ServiceCommand::Uninstall,
        Some(value) if value == OsStr::new("package-uninstall") => {
            if args.next().as_deref() != Some(OsStr::new("--package")) {
                bail!("package removal requires --package");
            }
            ServiceCommand::PackageUninstall(linux_install::LinuxPackage::parse(
                args.next()
                    .and_then(|value| value.into_string().ok())
                    .context("package format is missing")?
                    .as_str(),
            )?)
        }
        Some(value) => bail!("unknown helper command: {}", value.to_string_lossy()),
    };
    if args.next().is_some() {
        bail!("unexpected helper command arguments");
    }
    Ok(command)
}

fn parse_owner_id(value: &str) -> Result<u32> {
    if value.is_empty() || !value.bytes().all(|byte| byte.is_ascii_digit()) {
        bail!("expected a non-root numeric ID");
    }
    let id = value.parse::<u32>()?;
    if id == 0 || id == u32::MAX {
        bail!("expected a non-root ID");
    }
    Ok(id)
}

fn owner_from_env() -> Result<Owner> {
    Ok(Owner {
        uid: parse_owner_id(&std::env::var(OWNER_UID_ENV).context("Helper owner UID is missing")?)?,
        gid: parse_owner_id(&std::env::var(OWNER_GID_ENV).context("Helper owner GID is missing")?)?,
    })
}

fn invoking_owner() -> Result<Owner> {
    let uid = parse_owner_id(
        &std::env::var("PKEXEC_UID").context("installation requires pkexec owner identity")?,
    )?;
    let mut entry: libc::passwd = unsafe { std::mem::zeroed() };
    let mut found = std::ptr::null_mut();
    let mut buffer = vec![0u8; 65536];
    // SAFETY: the caller supplies valid storage for getpwuid_r and its result.
    let result = unsafe {
        libc::getpwuid_r(
            uid,
            &mut entry,
            buffer.as_mut_ptr().cast(),
            buffer.len(),
            &mut found,
        )
    };
    if result != 0 || found.is_null() || entry.pw_uid != uid || entry.pw_gid == 0 {
        bail!("cannot resolve the pkexec invoking account");
    }
    Ok(Owner {
        uid,
        gid: entry.pw_gid,
    })
}

pub(super) fn ensure_core_owner() -> Result<(), Error> {
    let owner = owner_from_env().map_err(Error::other)?;
    if unsafe { libc::getuid() } != owner.uid
        || unsafe { libc::geteuid() } != owner.uid
        || unsafe { libc::getgid() } != owner.gid
        || unsafe { libc::getegid() } != owner.gid
    {
        return Err(Error::other(
            "Helper and Core must run as the non-root owner",
        ));
    }
    Ok(())
}

pub(super) fn ensure_owner_socket(address: &str) -> Result<(), Error> {
    let owner = owner_from_env().map_err(Error::other)?;
    let metadata = fs::symlink_metadata(address)?;
    if !metadata.file_type().is_socket()
        || metadata.uid() != owner.uid
        || metadata.mode() & 0o077 != 0
    {
        return Err(Error::other(
            "Core address is not a private socket owned by the Helper owner",
        ));
    }
    Ok(())
}

fn validate_capabilities(status: &str) -> Result<()> {
    for field in ["CapInh:", "CapPrm:", "CapEff:", "CapBnd:", "CapAmb:"] {
        let value = status
            .lines()
            .find_map(|line| line.strip_prefix(field))
            .context("capability field missing")?;
        if u64::from_str_radix(value.trim(), 16)? != NETWORK_CAPABILITIES {
            bail!("Helper must have only CAP_NET_ADMIN and CAP_NET_RAW in {field}");
        }
    }
    if !status.lines().any(|line| {
        line.strip_prefix("NoNewPrivs:")
            .is_some_and(|value| value.trim() == "1")
    }) {
        bail!("Helper must run with NoNewPrivileges");
    }
    Ok(())
}

fn run_service() -> Result<()> {
    ensure_core_sha256_configured()?;
    let owner = owner_from_env()?;
    ensure_core_owner()?;
    validate_capabilities(&fs::read_to_string("/proc/self/status")?)?;
    linux_install::verify_runtime_bundle(owner)?;
    let runtime = Runtime::new().context("create Helper runtime")?;
    runtime.block_on(async move {
        let mut terminate = signal(SignalKind::terminate()).context("listen for SIGTERM")?;
        let mut interrupt = signal(SignalKind::interrupt()).context("listen for SIGINT")?;
        let incoming = AuthorizedIncoming::bind(owner, &linux_install::runtime_path(owner))?;
        notify_systemd(b"READY=1")?;
        let shutdown = async move {
            tokio::select! {
                _ = terminate.recv() => {}
                _ = interrupt.recv() => {}
            }
            begin_shutdown();
            let _ = notify_systemd(b"STOPPING=1");
        };
        warp::serve(routes())
            .serve_incoming_with_graceful_shutdown(incoming, shutdown)
            .await;
        release_managed_core_on_shutdown_confirmed()?;
        Ok(())
    })
}

fn notify_systemd(message: &[u8]) -> Result<()> {
    let path =
        std::env::var_os("NOTIFY_SOCKET").context("systemd notification socket is missing")?;
    notify_socket(&path, message)
}

fn notify_socket(path: &OsStr, message: &[u8]) -> Result<()> {
    use std::os::linux::net::SocketAddrExt;
    use std::os::unix::ffi::OsStrExt;
    let socket = UnixDatagram::unbound()?;
    if let Some(name) = path.as_bytes().strip_prefix(b"@") {
        let address = std::os::unix::net::SocketAddr::from_abstract_name(name)?;
        socket.send_to_addr(message, &address)?;
    } else {
        if !Path::new(path).is_absolute() {
            bail!("invalid systemd notification socket");
        }
        socket.send_to(message, Path::new(path))?;
    }
    Ok(())
}

struct AuthorizedIncoming {
    listener: UnixListener,
    owner: Owner,
    retry: Option<Pin<Box<Sleep>>>,
    _lock: File,
}

impl AuthorizedIncoming {
    fn bind(owner: Owner, runtime: &Path) -> Result<Self> {
        let directory = linux_install::open_directory(runtime)?;
        let metadata = directory.metadata()?;
        if metadata.uid() != owner.uid || metadata.mode() & 0o777 != 0o700 {
            bail!("Helper runtime must be owner-only at mode 0700");
        }
        let lock = OpenOptions::new()
            .read(true)
            .write(true)
            .create(true)
            .truncate(false)
            .mode(0o600)
            .custom_flags(libc::O_NOFOLLOW | libc::O_CLOEXEC | libc::O_NONBLOCK)
            .open(runtime.join("service.lock"))?;
        let metadata = lock.metadata()?;
        if !metadata.is_file()
            || metadata.uid() != owner.uid
            || metadata.nlink() != 1
            || metadata.mode() & 0o777 != 0o600
        {
            bail!("invalid Helper service lock");
        }
        if unsafe { libc::flock(lock.as_raw_fd(), libc::LOCK_EX | libc::LOCK_NB) } != 0 {
            bail!("another Helper already owns this runtime");
        }
        let socket_path = runtime.join("helper.sock");
        match fs::symlink_metadata(&socket_path) {
            Ok(metadata) => {
                if !metadata.file_type().is_socket()
                    || metadata.uid() != owner.uid
                    || metadata.mode() & 0o777 != 0o600
                {
                    bail!("refusing to remove an untrusted Helper socket");
                }
                match std::os::unix::net::UnixStream::connect(&socket_path) {
                    Err(error) if error.kind() == ErrorKind::ConnectionRefused => {
                        fs::remove_file(&socket_path)?
                    }
                    _ => bail!("Helper socket is not confirmed stale"),
                }
            }
            Err(error) if error.kind() == ErrorKind::NotFound => {}
            Err(error) => return Err(error.into()),
        }
        let listener = UnixListener::bind(&socket_path)?;
        fs::set_permissions(&socket_path, fs::Permissions::from_mode(0o600))?;
        Ok(Self {
            listener,
            owner,
            retry: None,
            _lock: lock,
        })
    }
}

fn is_authorized_peer(stream: &UnixStream, owner: Owner) -> bool {
    matches!(stream.peer_cred(), Ok(credentials) if credentials.uid() == owner.uid)
}

impl Stream for AuthorizedIncoming {
    type Item = Result<UnixStream, Error>;

    fn poll_next(
        mut self: Pin<&mut Self>,
        context: &mut TaskContext<'_>,
    ) -> Poll<Option<Self::Item>> {
        loop {
            if let Some(retry) = self.retry.as_mut() {
                match retry.as_mut().poll(context) {
                    Poll::Ready(()) => self.retry = None,
                    Poll::Pending => return Poll::Pending,
                }
            }
            match self.listener.poll_accept(context) {
                Poll::Ready(Ok((stream, _))) => {
                    if is_authorized_peer(&stream, self.owner) {
                        return Poll::Ready(Some(Ok(stream)));
                    }
                }
                Poll::Ready(Err(error)) => {
                    log_message(format!("Helper could not accept a connection: {error}"));
                    self.retry = Some(Box::pin(tokio::time::sleep(ACCEPT_RETRY_DELAY)));
                }
                Poll::Pending => return Poll::Pending,
            }
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use std::os::unix::fs::symlink;

    #[test]
    fn installer_accepts_only_fixed_commands_and_absolute_staging_path() {
        assert_eq!(service_command([]).unwrap(), ServiceCommand::Run);
        assert_eq!(
            service_command(["install", "--bundle", "/tmp/private"].map(OsString::from)).unwrap(),
            ServiceCommand::Install {
                bundle: "/tmp/private".into(),
                replace_owned: false,
                package: None,
            }
        );
        assert!(service_command(["install"].map(OsString::from)).is_err());
        assert!(service_command(["install", "--bundle", "../a"].map(OsString::from)).is_err());
        assert!(service_command(["exec", "/bin/sh"].map(OsString::from)).is_err());
        assert!(service_command(["uninstall", "/etc"].map(OsString::from)).is_err());
        assert!(parse_owner_id("0").is_err());
        assert!(parse_owner_id("1000\n").is_err());
        assert_eq!(parse_owner_id("1000").unwrap(), 1000);
    }

    #[test]
    fn parses_scoped_owned_replacement_and_native_package_removal() {
        assert_eq!(
            service_command(
                [
                    "install",
                    "--bundle",
                    "/tmp/private",
                    "--replace-owned",
                    "--package",
                    "deb"
                ]
                .map(OsString::from)
            )
            .unwrap(),
            ServiceCommand::Install {
                bundle: "/tmp/private".into(),
                replace_owned: true,
                package: Some(linux_install::LinuxPackage::Deb)
            },
        );
        assert_eq!(
            service_command(["package-uninstall", "--package", "rpm"].map(OsString::from)).unwrap(),
            ServiceCommand::PackageUninstall(linux_install::LinuxPackage::Rpm),
        );
        for arguments in [
            vec![
                "install",
                "--bundle",
                "/tmp/private",
                "--replace-owned",
                "--replace-owned",
            ],
            vec![
                "install",
                "--bundle",
                "/tmp/private",
                "--package",
                "unknown",
            ],
            vec!["package-uninstall", "--package", "deb", "/etc"],
            vec!["package-uninstall", "--package"],
        ] {
            assert!(service_command(arguments.into_iter().map(OsString::from)).is_err());
        }
    }

    #[test]
    fn capability_boundary_rejects_root_power_and_missing_no_new_privileges() {
        let status = "CapInh:\t0000000000003000\nCapPrm:\t0000000000003000\nCapEff:\t0000000000003000\nCapBnd:\t0000000000003000\nCapAmb:\t0000000000003000\nNoNewPrivs:\t1\n";
        validate_capabilities(status).unwrap();
        assert!(validate_capabilities(&status.replace("3000", "3001")).is_err());
        assert!(
            validate_capabilities(&status.replace("NoNewPrivs:\t1", "NoNewPrivs:\t0")).is_err()
        );
    }

    #[tokio::test]
    async fn runtime_is_private_checks_peers_and_does_not_replace_live_socket() {
        let path =
            std::env::temp_dir().join(format!("reclash-runtime-test-{}", std::process::id()));
        fs::create_dir(&path).unwrap();
        fs::set_permissions(&path, fs::Permissions::from_mode(0o700)).unwrap();
        let owner = Owner {
            uid: unsafe { libc::getuid() },
            gid: unsafe { libc::getgid() },
        };
        let incoming = AuthorizedIncoming::bind(owner, &path).unwrap();
        let client = UnixStream::connect(path.join("helper.sock")).await.unwrap();
        let (peer, _) = incoming.listener.accept().await.unwrap();
        assert!(is_authorized_peer(&peer, owner));
        assert!(!is_authorized_peer(
            &peer,
            Owner {
                uid: owner.uid + 1,
                gid: owner.gid
            }
        ));
        assert!(AuthorizedIncoming::bind(owner, &path).is_err());
        assert_eq!(
            fs::metadata(path.join("helper.sock")).unwrap().mode() & 0o777,
            0o600
        );
        drop(client);
        drop(peer);
        drop(incoming);
        fs::remove_file(path.join("helper.sock")).unwrap();
        symlink("/etc/passwd", path.join("helper.sock")).unwrap();
        assert!(AuthorizedIncoming::bind(owner, &path).is_err());
        fs::remove_dir_all(path).unwrap();
    }

    #[test]
    fn sends_systemd_ready_after_socket_setup() {
        let path = std::env::temp_dir().join(format!("reclash-notify-test-{}", std::process::id()));
        let socket = UnixDatagram::bind(&path).unwrap();
        notify_socket(path.as_os_str(), b"READY=1").unwrap();
        let mut bytes = [0; 32];
        let size = socket.recv(&mut bytes).unwrap();
        assert_eq!(&bytes[..size], b"READY=1");
        fs::remove_file(path).unwrap();
    }
}
