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

#[derive(Debug, Clone, Copy)]
pub(super) enum InstallFailure {
    RegistrationConflict,
    BundleInvalid,
    SystemdFailed,
    InstallBusy,
    StopFailed,
}

impl InstallFailure {
    pub(super) fn code(self) -> &'static str {
        match self {
            Self::RegistrationConflict => "registration_conflict",
            Self::BundleInvalid => "bundle_invalid",
            Self::SystemdFailed => "systemd_failed",
            Self::InstallBusy => "install_busy",
            Self::StopFailed => "stop_failed",
        }
    }
}

impl std::fmt::Display for InstallFailure {
    fn fmt(&self, formatter: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        formatter.write_str(self.code())
    }
}

impl std::error::Error for InstallFailure {}

#[derive(Debug, Clone, Copy, Serialize, Deserialize, PartialEq, Eq)]
#[serde(rename_all = "lowercase")]
pub(super) enum LinuxPackage {
    Deb,
    Rpm,
}

impl LinuxPackage {
    pub(super) fn parse(value: &str) -> Result<Self> {
        match value {
            "deb" => Ok(Self::Deb),
            "rpm" => Ok(Self::Rpm),
            _ => bail!("unsupported native package"),
        }
    }

    fn directory(self) -> &'static Path {
        Path::new(match self {
            Self::Deb => "/opt/ReClash",
            Self::Rpm => "/usr/share/ReClash",
        })
    }
}

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
    #[serde(default, skip_serializing_if = "Option::is_none")]
    package: Option<LinuxPackage>,
}

pub(super) struct Layout {
    state: PathBuf,
    units: PathBuf,
    root_uid: u32,
    external_units: Vec<PathBuf>,
    obsolete_root: PathBuf,
}

impl Layout {
    pub(super) fn system() -> Self {
        Self {
            state: STATE_ROOT.into(),
            units: UNIT_ROOT.into(),
            root_uid: 0,
            external_units: [
                "/run/systemd/system",
                "/usr/local/lib/systemd/system",
                "/usr/lib/systemd/system",
                "/lib/systemd/system",
                "/run/systemd/transient",
                "/run/systemd/generator",
                "/run/systemd/generator.early",
                "/run/systemd/generator.late",
            ]
            .map(PathBuf::from)
            .to_vec(),
            obsolete_root: "/opt/reclash-helper".into(),
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
            return Err(InstallFailure::InstallBusy)
                .context("another installer owns this account's Helper transaction");
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
    replace_owned: bool,
    package: Option<LinuxPackage>,
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
            replace_owned: false,
            package: None,
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
    obsolete_bundle: Option<PathBuf>,
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

fn path_present(path: &Path) -> Result<bool> {
    match fs::symlink_metadata(path) {
        Ok(_) => Ok(true),
        Err(error) if error.kind() == std::io::ErrorKind::NotFound => Ok(false),
        Err(error) => Err(error.into()),
    }
}

fn verify_unit_namespace(layout: &Layout, owner: Owner) -> Result<()> {
    let name = service_name(owner);
    for root in std::iter::once(&layout.units).chain(&layout.external_units) {
        if (root != &layout.units && path_present(&root.join(&name))?)
            || path_present(&root.join(format!("{name}.d")))?
        {
            bail!("refusing to replace a shadowed systemd unit or external drop-ins");
        }
    }
    Ok(())
}

fn obsolete_unit_contents(executable: &Path, owner: Owner) -> String {
    format!(
        "# ReClash managed Linux Helper v1\n# OwnerUID={}\n\
         [Unit]\nDescription=ReClash Linux network helper\nAfter=network.target\n\n\
         [Service]\nType=notify\nNotifyAccess=main\nTimeoutStartSec=15\n\
         User={}\nGroup={}\nExecStart={}\nRuntimeDirectory=reclash-helper-{}\n\
         RuntimeDirectoryMode=0700\nUMask=0077\n\
         AmbientCapabilities=CAP_NET_ADMIN CAP_NET_RAW\n\
         CapabilityBoundingSet=CAP_NET_ADMIN CAP_NET_RAW\nNoNewPrivileges=yes\n\
         ProtectSystem=full\nRestrictSUIDSGID=yes\nKillMode=control-group\n\
         TimeoutStopSec=8\nRestart=on-failure\nRestartSec=2\n\n\
         [Install]\nWantedBy=multi-user.target\n",
        owner.uid,
        owner.uid,
        owner.gid,
        executable.display(),
        owner.uid,
    )
}

fn verified_obsolete_bundle(layout: &Layout, owner: Owner, unit: &[u8]) -> Result<PathBuf> {
    let text = std::str::from_utf8(unit)?;
    let executable = text
        .lines()
        .find_map(|line| line.strip_prefix("ExecStart="))
        .context("owned unit executable is missing")?;
    let executable = Path::new(executable);
    let bundle = executable
        .parent()
        .context("owned Helper bundle is missing")?;
    let hash = bundle
        .file_name()
        .and_then(|name| name.to_str())
        .context("missing bundle hash")?;
    if !valid_hash(hash)
        || bundle != layout.obsolete_root.join(owner.uid.to_string()).join(hash)
        || executable.file_name().and_then(|name| name.to_str()) != Some(HELPER_NAME)
        || unit != obsolete_unit_contents(executable, owner).as_bytes()
    {
        bail!("refusing to replace an unrecognized unregistered unit");
    }
    for ancestor in bundle.ancestors() {
        if ancestor
            == layout
                .obsolete_root
                .parent()
                .context("missing installation root")?
        {
            secure_directory(ancestor, layout.root_uid)?;
            break;
        }
        secure_directory(ancestor, layout.root_uid)?;
    }
    let directory = secure_directory(bundle, layout.root_uid)?;
    let entries = fs::read_dir(bundle)?.collect::<std::io::Result<Vec<_>>>()?;
    if entries.len() != 2 {
        bail!("obsolete bundle contains unexpected entries");
    }
    for name in [HELPER_NAME, CORE_NAME] {
        let mut file = open_member(&directory, name)?;
        secure_file(&file, layout.root_uid, false)?;
        verify_elf(&mut file)?;
        if file.metadata()?.mode() & 0o111 != 0o111
            || (name == HELPER_NAME && hash_file(&mut file)? != hash)
        {
            bail!("obsolete executable integrity check failed");
        }
    }
    Ok(bundle.to_path_buf())
}

fn snapshot(
    layout: &Layout,
    owner: Owner,
    systemd: &mut impl Systemd,
    replace_owned: bool,
) -> Result<Snapshot> {
    let (unit, registration, obsolete_bundle) = (|| -> Result<_> {
        verify_unit_namespace(layout, owner)?;
        let mut obsolete_bundle = None;
        let unit = read_optional(&layout.unit(owner), layout.root_uid)?;
        let registration = read_optional(&layout.registration(owner), layout.root_uid)?
            .map(|value| serde_json::from_slice::<Registration>(&value))
            .transpose()?;
        if let Some(registration) = &registration {
            registration.bundle.validate()?;
            if registration.uid != owner.uid
                || registration.gid == 0
                || registration.gid == u32::MAX
            {
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
        } else if let Some(unit) = &unit {
            if !replace_owned {
                return Err(InstallFailure::RegistrationConflict)
                    .context("refusing to overwrite a systemd unit without an owned registration");
            }
            obsolete_bundle = Some(
                verified_obsolete_bundle(layout, owner, unit)
                    .context(InstallFailure::RegistrationConflict)?,
            );
        }
        Ok((unit, registration, obsolete_bundle))
    })()
    .context(InstallFailure::RegistrationConflict)?;
    let name = service_name(owner);
    let active = systemd
        .query("is-active", &name)
        .context(InstallFailure::SystemdFailed)?;
    let enabled = systemd
        .query("is-enabled", &name)
        .context(InstallFailure::SystemdFailed)?;
    if registration.is_none() && obsolete_bundle.is_none() && (active || enabled) {
        return Err(InstallFailure::RegistrationConflict)
            .context("an unrecognized service already owns this account's unit name");
    }
    Ok(Snapshot {
        unit,
        registration,
        obsolete_bundle,
        active,
        enabled,
    })
}

fn stop_confirmed(systemd: &mut impl Systemd, name: &str) -> Result<()> {
    systemd
        .run(&["stop", name])
        .context(InstallFailure::StopFailed)?;
    if systemd
        .query("is-active", name)
        .context(InstallFailure::StopFailed)?
    {
        return Err(InstallFailure::StopFailed)
            .context("Helper shutdown was not confirmed; replacement is blocked");
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
        if let Some(registration) = &previous.registration {
            atomic_write(
                &layout.registration(owner),
                &serde_json::to_vec(registration)?,
                0o644,
                layout.root_uid,
            )?;
        } else {
            remove_optional(&layout.registration(owner))?;
        }
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

pub(super) fn install(
    owner: Owner,
    source_path: &Path,
    replace_owned: bool,
    package: Option<LinuxPackage>,
) -> Result<()> {
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
    let mut source = SourceBundle::open(source_path, owner, env!("CORE_SHA256"), &running_helper)
        .context(InstallFailure::BundleInvalid)?;
    if let Some(package) = package {
        verify_package_marker(package).context(InstallFailure::BundleInvalid)?;
        let manifest =
            packaged_manifest(package.directory(), 0).context(InstallFailure::BundleInvalid)?;
        if manifest != source.manifest {
            return Err(InstallFailure::BundleInvalid)
                .context("staged pair does not match the native package");
        }
    }
    source.replace_owned = replace_owned;
    source.package = package;
    install_bundle(&Layout::system(), owner, source, &mut Systemctl)
}

fn install_bundle(
    layout: &Layout,
    owner: Owner,
    mut source: SourceBundle,
    systemd: &mut impl Systemd,
) -> Result<()> {
    let _lock = layout.prepare(owner)?;
    let previous = snapshot(layout, owner, systemd, source.replace_owned)?;
    let bundle =
        stage_install(layout, owner, &mut source).context(InstallFailure::BundleInvalid)?;
    let name = service_name(owner);
    if previous.unit.is_some() {
        stop_confirmed(systemd, &name)?;
    }
    let registration = Registration {
        uid: owner.uid,
        gid: owner.gid,
        bundle: source.manifest.clone(),
        package: source.package,
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
    })()
    .context(InstallFailure::SystemdFailed);
    if let Err(error) = result {
        if let Err(rollback) = restore(layout, owner, &previous, systemd) {
            return Err(rollback)
                .context(format!("installation failed: {error:#}; rollback blocked"));
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
    if let Some(path) = previous.obsolete_bundle {
        let cleanup = (|| -> Result<()> {
            for name in [HELPER_NAME, CORE_NAME] {
                fs::remove_file(path.join(name))?;
            }
            fs::remove_dir(path)?;
            Ok(())
        })();
        if let Err(error) = cleanup {
            eprintln!("Helper installed; obsolete bundle cleanup skipped: {error}");
        }
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
    uninstall_owner(&layout, owner, None, &mut systemd)
}

fn remove_optional(path: &Path) -> Result<()> {
    match fs::remove_file(path) {
        Ok(()) => Ok(()),
        Err(error) if error.kind() == std::io::ErrorKind::NotFound => Ok(()),
        Err(error) => Err(error.into()),
    }
}

fn uninstall_owner(
    layout: &Layout,
    owner: Owner,
    expected: Option<(LinuxPackage, &Manifest)>,
    systemd: &mut impl Systemd,
) -> Result<()> {
    let previous = snapshot(layout, owner, systemd, false)?;
    let Some(registration) = previous.registration else {
        return Ok(());
    };
    if expected.is_some_and(|(package, manifest)| {
        registration.package != Some(package) || &registration.bundle != manifest
    }) {
        return Ok(());
    }
    let name = service_name(owner);
    stop_confirmed(systemd, &name)?;
    systemd
        .run(&["disable", &name])
        .context(InstallFailure::SystemdFailed)?;
    fs::remove_file(layout.unit(owner))?;
    fs::remove_file(layout.registration(owner))?;
    systemd
        .run(&["daemon-reload"])
        .context(InstallFailure::SystemdFailed)?;
    let keep = if expected.is_some() {
        let removed = registration.bundle.id();
        fs::read_dir(layout.bundles(owner))?
            .map(|entry| entry.map(|entry| entry.file_name().to_string_lossy().into_owned()))
            .collect::<std::io::Result<Vec<_>>>()?
            .into_iter()
            .filter(|id| id != &removed)
            .collect()
    } else {
        Vec::new()
    };
    prune(layout, owner, &keep)
}

fn packaged_manifest(path: &Path, uid: u32) -> Result<Manifest> {
    for ancestor in path.ancestors() {
        secure_directory(ancestor, uid)?;
    }
    let directory = secure_directory(path, uid)?;
    let manifest_file = open_member(&directory, MANIFEST_NAME)?;
    secure_file(&manifest_file, uid, false)?;
    if manifest_file.metadata()?.len() > 4096 {
        bail!("package manifest is too large");
    }
    let manifest: Manifest = serde_json::from_reader(manifest_file)?;
    manifest.validate()?;
    for (name, expected) in [
        (HELPER_NAME, &manifest.helper_sha256),
        (CORE_NAME, &manifest.core_sha256),
    ] {
        let mut file = open_member(&directory, name)?;
        secure_file(&file, uid, false)?;
        verify_elf(&mut file)?;
        if file.metadata()?.mode() & 0o111 != 0o111 || hash_file(&mut file)? != *expected {
            bail!("native package executable integrity check failed");
        }
    }
    Ok(manifest)
}

fn verify_package_marker(package: LinuxPackage) -> Result<()> {
    let directory = secure_directory(package.directory(), 0)?;
    let mut marker = open_member(&directory, "reclash-package")?;
    secure_file(&marker, 0, false)?;
    if marker.metadata()?.len() != 4 {
        bail!("invalid native package identity");
    }
    let mut contents = [0; 4];
    marker.read_exact(&mut contents)?;
    let expected = match package {
        LinuxPackage::Deb => b"deb\n",
        LinuxPackage::Rpm => b"rpm\n",
    };
    if &contents != expected {
        bail!("native package identity does not match removal request");
    }
    Ok(())
}

pub(super) fn package_uninstall(package: LinuxPackage) -> Result<()> {
    if unsafe { libc::getuid() } != 0 || unsafe { libc::geteuid() } != 0 {
        bail!("package removal requires root");
    }
    verify_package_marker(package).context(InstallFailure::BundleInvalid)?;
    let manifest =
        packaged_manifest(package.directory(), 0).context(InstallFailure::BundleInvalid)?;
    let running = File::open("/proc/self/exe")?.metadata()?;
    let packaged = fs::symlink_metadata(package.directory().join(HELPER_NAME))?;
    if running.dev() != packaged.dev()
        || running.ino() != packaged.ino()
        || manifest.core_sha256 != env!("CORE_SHA256")
    {
        bail!("package removal must run the verified packaged Helper");
    }
    remove_package_registrations(&Layout::system(), package, &manifest, &mut Systemctl)
}

fn remove_package_registrations(
    layout: &Layout,
    package: LinuxPackage,
    manifest: &Manifest,
    systemd: &mut impl Systemd,
) -> Result<()> {
    if !path_present(&layout.state)? {
        return Ok(());
    }
    secure_directory(&layout.state, layout.root_uid)?;
    for entry in fs::read_dir(&layout.state)? {
        let entry = entry?;
        let Some(uid) = entry.file_name().to_str().and_then(|value| {
            value
                .parse::<u32>()
                .ok()
                .filter(|uid| *uid != 0 && *uid != u32::MAX && uid.to_string() == value)
        }) else {
            continue;
        };
        let registration = (|| -> Result<Option<Registration>> {
            secure_directory(&entry.path(), layout.root_uid)?;
            let owner = Owner { uid, gid: 1 };
            let Some(value) = read_optional(&layout.registration(owner), layout.root_uid)? else {
                return Ok(None);
            };
            let registration: Registration = serde_json::from_slice(&value)?;
            if registration.uid != uid || registration.gid == 0 || registration.gid == u32::MAX {
                bail!("package registration owner is invalid");
            }
            Ok(Some(registration))
        })();
        let registration = match registration {
            Ok(Some(registration)) => registration,
            Ok(None) => continue,
            Err(error) => {
                eprintln!("Package removal preserved unrecognized Helper owner {uid}: {error:#}");
                continue;
            }
        };
        if registration.package != Some(package) || &registration.bundle != manifest {
            continue;
        }
        let owner = Owner {
            uid,
            gid: registration.gid,
        };
        let _lock = layout.prepare(owner)?;
        uninstall_owner(layout, owner, Some((package, manifest)), systemd)?;
    }
    Ok(())
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
                    external_units: Vec::new(),
                    obsolete_root: root.join("obsolete"),
                },
                owner: Owner {
                    uid: if uid == 0 { 1000 } else { uid },
                    gid: unsafe { libc::getegid() }.max(1),
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
            SourceBundle::open(
                &path,
                Owner {
                    uid: self.layout.root_uid,
                    gid: self.owner.gid,
                },
                &manifest.core_sha256,
                &running,
            )
            .unwrap()
        }
    }

    impl Fixture {
        fn obsolete(&self) -> PathBuf {
            self.layout.prepare(self.owner).unwrap();
            let helper = b"\x7fELFobsolete-helper";
            let hash = format!("{:x}", Sha256::digest(helper));
            let owner_dir = self.layout.obsolete_root.join(self.owner.uid.to_string());
            fs::create_dir(&self.layout.obsolete_root).unwrap();
            fs::create_dir(&owner_dir).unwrap();
            let bundle = owner_dir.join(hash);
            fs::create_dir(&bundle).unwrap();
            for (name, contents) in [
                (HELPER_NAME, helper.as_slice()),
                (CORE_NAME, b"\x7fELFobsolete-core"),
            ] {
                fs::write(bundle.join(name), contents).unwrap();
                fs::set_permissions(bundle.join(name), fs::Permissions::from_mode(0o755)).unwrap();
            }
            fs::write(
                self.layout.unit(self.owner),
                obsolete_unit_contents(&bundle.join(HELPER_NAME), self.owner),
            )
            .unwrap();
            bundle
        }

        fn replace_source(&self, name: &str) -> SourceBundle {
            let mut source = self.source(name);
            source.replace_owned = true;
            source
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
    fn authorized_owned_reset_installs_only_current_protocol_and_removes_obsolete_pair() {
        let fixture = Fixture::new();
        let obsolete = fixture.obsolete();
        let mut systemd = FakeSystemd {
            active: true,
            enabled: true,
            ..Default::default()
        };
        install_bundle(
            &fixture.layout,
            fixture.owner,
            fixture.replace_source("new"),
            &mut systemd,
        )
        .unwrap();
        assert!(!obsolete.exists());
        let registration: Registration =
            serde_json::from_slice(&fs::read(fixture.layout.registration(fixture.owner)).unwrap())
                .unwrap();
        assert_eq!(registration.bundle.helper_protocol_version, "9");
        assert!(systemd.active && systemd.enabled);
        assert!(
            systemd
                .calls
                .iter()
                .position(|call| call[0] == "stop")
                .unwrap()
                < systemd
                    .calls
                    .iter()
                    .position(|call| call[0] == "start")
                    .unwrap()
        );
    }

    #[test]
    fn owned_reset_requires_explicit_replacement_authorization() {
        let fixture = Fixture::new();
        let obsolete = fixture.obsolete();
        let mut systemd = FakeSystemd::default();
        let error = install_bundle(
            &fixture.layout,
            fixture.owner,
            fixture.source("new"),
            &mut systemd,
        )
        .unwrap_err();
        assert!(matches!(
            error.downcast_ref::<InstallFailure>(),
            Some(InstallFailure::RegistrationConflict)
        ));
        assert!(obsolete.exists());
        assert!(systemd.calls.is_empty());
    }

    #[test]
    fn owned_reset_rolls_back_unit_without_inventing_registration() {
        for enabled in [false, true] {
            let fixture = Fixture::new();
            let obsolete = fixture.obsolete();
            let unit = fs::read(fixture.layout.unit(fixture.owner)).unwrap();
            let mut systemd = FakeSystemd {
                active: true,
                enabled,
                fail_start: true,
                ..Default::default()
            };
            let error = install_bundle(
                &fixture.layout,
                fixture.owner,
                fixture.replace_source("new"),
                &mut systemd,
            )
            .unwrap_err();
            assert!(matches!(
                error.downcast_ref::<InstallFailure>(),
                Some(InstallFailure::SystemdFailed)
            ));
            assert_eq!(fs::read(fixture.layout.unit(fixture.owner)).unwrap(), unit);
            assert!(!fixture.layout.registration(fixture.owner).exists());
            assert!(obsolete.join(HELPER_NAME).exists());
            assert!(systemd.active);
            assert_eq!(systemd.enabled, enabled);
        }
    }

    #[test]
    fn owned_reset_does_not_replace_unconfirmed_old_service() {
        let fixture = Fixture::new();
        let obsolete = fixture.obsolete();
        let unit = fs::read(fixture.layout.unit(fixture.owner)).unwrap();
        let mut systemd = FakeSystemd {
            active: true,
            enabled: true,
            fail_stop: true,
            ..Default::default()
        };
        let error = install_bundle(
            &fixture.layout,
            fixture.owner,
            fixture.replace_source("new"),
            &mut systemd,
        )
        .unwrap_err();
        assert!(matches!(
            error.downcast_ref::<InstallFailure>(),
            Some(InstallFailure::StopFailed)
        ));
        assert_eq!(fs::read(fixture.layout.unit(fixture.owner)).unwrap(), unit);
        assert!(obsolete.exists());
        assert!(!systemd.calls.iter().any(|call| call[0] == "start"));
    }

    #[test]
    fn owned_reset_rejects_modified_unit_hash_and_linked_helper() {
        for modification in ["unit", "hash", "link", "owner"] {
            let fixture = Fixture::new();
            let obsolete = fixture.obsolete();
            let unit = fixture.layout.unit(fixture.owner);
            match modification {
                "unit" => fs::write(
                    &unit,
                    format!(
                        "{}\nExecStartPost=/bin/true\n",
                        fs::read_to_string(&unit).unwrap()
                    ),
                )
                .unwrap(),
                "hash" => fs::write(obsolete.join(HELPER_NAME), b"\x7fELFdifferent").unwrap(),
                "link" => {
                    fs::remove_file(obsolete.join(HELPER_NAME)).unwrap();
                    symlink(obsolete.join(CORE_NAME), obsolete.join(HELPER_NAME)).unwrap();
                }
                "owner" => {
                    let contents = fs::read_to_string(&unit).unwrap().replace(
                        &format!("# OwnerUID={}\n", fixture.owner.uid),
                        "# OwnerUID=99999\n",
                    );
                    fs::write(&unit, contents).unwrap();
                }
                _ => unreachable!(),
            }
            let before = fs::read(&unit).unwrap();
            let mut systemd = FakeSystemd::default();
            assert!(install_bundle(
                &fixture.layout,
                fixture.owner,
                fixture.replace_source("new"),
                &mut systemd
            )
            .is_err());
            assert_eq!(fs::read(&unit).unwrap(), before);
            assert!(systemd.calls.is_empty());
        }
    }

    #[test]
    fn install_rejects_external_units_and_dropins_before_systemd_mutation() {
        for dropin in [false, true] {
            let mut fixture = Fixture::new();
            let external = fixture.root.join("external-units");
            fs::create_dir(&external).unwrap();
            fixture.layout.external_units.push(external.clone());
            if dropin {
                fs::create_dir(
                    fixture
                        .layout
                        .units
                        .join(format!("{}.d", service_name(fixture.owner))),
                )
                .unwrap();
            } else {
                fs::write(external.join(service_name(fixture.owner)), b"foreign").unwrap();
            }
            let mut systemd = FakeSystemd::default();
            assert!(install_bundle(
                &fixture.layout,
                fixture.owner,
                fixture.replace_source("new"),
                &mut systemd
            )
            .is_err());
            assert!(systemd.calls.is_empty());
            assert!(!fixture.layout.unit(fixture.owner).exists());
        }
    }

    #[test]
    fn package_removal_matches_owner_source_and_exact_pair() {
        let fixture = Fixture::new();
        let mut source = fixture.source("package");
        let manifest = source.manifest.clone();
        source.package = Some(LinuxPackage::Deb);
        let mut systemd = FakeSystemd::default();
        install_bundle(&fixture.layout, fixture.owner, source, &mut systemd).unwrap();
        systemd.calls.clear();
        remove_package_registrations(&fixture.layout, LinuxPackage::Rpm, &manifest, &mut systemd)
            .unwrap();
        let different = fixture.source("different").manifest;
        remove_package_registrations(&fixture.layout, LinuxPackage::Deb, &different, &mut systemd)
            .unwrap();
        assert!(systemd.calls.is_empty());
        assert!(systemd.active);
        remove_package_registrations(&fixture.layout, LinuxPackage::Deb, &manifest, &mut systemd)
            .unwrap();
        assert!(!fixture.layout.unit(fixture.owner).exists());
        assert!(!fixture.layout.registration(fixture.owner).exists());
        assert!(!fixture.layout.bundle(fixture.owner, &manifest).exists());
        assert!(!systemd.active && !systemd.enabled);
    }

    #[test]
    fn package_removal_preserves_appimage_registration_and_unknown_owner_data() {
        let fixture = Fixture::new();
        let source = fixture.source("appimage");
        let manifest = source.manifest.clone();
        let mut systemd = FakeSystemd::default();
        install_bundle(&fixture.layout, fixture.owner, source, &mut systemd).unwrap();
        let unknown = fixture.layout.state.join("not-an-owner");
        fs::create_dir(&unknown).unwrap();
        fs::write(unknown.join("keep"), b"keep").unwrap();
        systemd.calls.clear();
        remove_package_registrations(&fixture.layout, LinuxPackage::Deb, &manifest, &mut systemd)
            .unwrap();
        assert!(fixture.layout.registration(fixture.owner).exists());
        assert!(unknown.join("keep").exists());
        assert!(systemd.calls.is_empty());
    }

    #[test]
    fn package_removal_preserves_an_inactive_appimage_pair_for_the_same_owner() {
        let fixture = Fixture::new();
        let mut systemd = FakeSystemd::default();
        let appimage = fixture.source("appimage");
        let appimage_path = fixture.layout.bundle(fixture.owner, &appimage.manifest);
        install_bundle(&fixture.layout, fixture.owner, appimage, &mut systemd).unwrap();
        let mut native = fixture.source("package");
        let manifest = native.manifest.clone();
        native.package = Some(LinuxPackage::Deb);
        install_bundle(&fixture.layout, fixture.owner, native, &mut systemd).unwrap();
        remove_package_registrations(&fixture.layout, LinuxPackage::Deb, &manifest, &mut systemd)
            .unwrap();
        assert!(appimage_path.join(HELPER_NAME).exists());
        assert!(!fixture.layout.bundle(fixture.owner, &manifest).exists());
        assert!(!fixture.layout.registration(fixture.owner).exists());
    }

    #[test]
    fn package_removal_keeps_registration_when_shutdown_is_unconfirmed() {
        let fixture = Fixture::new();
        let mut source = fixture.source("package");
        let manifest = source.manifest.clone();
        source.package = Some(LinuxPackage::Deb);
        let mut systemd = FakeSystemd::default();
        install_bundle(&fixture.layout, fixture.owner, source, &mut systemd).unwrap();
        let unit = fs::read(fixture.layout.unit(fixture.owner)).unwrap();
        systemd.fail_stop = true;
        assert!(remove_package_registrations(
            &fixture.layout,
            LinuxPackage::Deb,
            &manifest,
            &mut systemd
        )
        .is_err());
        assert_eq!(fs::read(fixture.layout.unit(fixture.owner)).unwrap(), unit);
        assert!(fixture.layout.registration(fixture.owner).exists());
        assert!(fixture.layout.bundle(fixture.owner, &manifest).exists());
    }

    #[test]
    fn install_lock_rejects_concurrent_staging() {
        let fixture = Fixture::new();
        let _lock = fixture.layout.prepare(fixture.owner).unwrap();
        assert!(fixture.layout.prepare(fixture.owner).is_err());
    }
}
