use crate::service::owner::{configured_owner_sid, owner_sid_arguments};
use crate::service::peer::{process_sid, sid_to_string};
use crate::service::windows_layout::{
    is_protected_directory, is_prunable, staging_name, Ace, InstallFailure, Manifest,
    INSTALL_MUTEX, INSTALL_ROOT_NAME, MANIFEST_NAME, PROTECTED_DIRECTORY_SDDL,
    SERVICE_DISPLAY_NAME, SERVICE_EXE, SERVICE_NAME,
};

use anyhow::{anyhow, bail, Context, Result};
use sha2::{Digest, Sha256};
use std::ffi::{c_void, OsStr, OsString};
use std::fs::{self, File, OpenOptions};
use std::io::{Error, ErrorKind, Read, Seek, SeekFrom, Write};
use std::os::windows::ffi::{OsStrExt, OsStringExt};
use std::os::windows::fs::{MetadataExt, OpenOptionsExt};
use std::os::windows::io::AsRawHandle;
use std::path::{Path, PathBuf};
use std::ptr::{null, null_mut};
use std::thread::sleep;
use std::time::{Duration, Instant, SystemTime, UNIX_EPOCH};

use windows_service::service::{
    Service, ServiceAccess, ServiceAction, ServiceActionType, ServiceErrorControl,
    ServiceFailureActions, ServiceFailureResetPeriod, ServiceInfo, ServiceStartType, ServiceState,
    ServiceType,
};
use windows_service::service_manager::{ServiceManager, ServiceManagerAccess};
use windows_sys::Win32::Foundation::{
    CloseHandle, LocalFree, ERROR_ALREADY_EXISTS, ERROR_SUCCESS, HANDLE, PSID, WAIT_ABANDONED,
    WAIT_OBJECT_0,
};
use windows_sys::Win32::Security::Authorization::{
    ConvertStringSecurityDescriptorToSecurityDescriptorW, GetSecurityInfo, SDDL_REVISION_1,
    SE_FILE_OBJECT,
};
use windows_sys::Win32::Security::{
    GetAce, ACE_HEADER, ACL, DACL_SECURITY_INFORMATION, OWNER_SECURITY_INFORMATION,
    PSECURITY_DESCRIPTOR, SECURITY_ATTRIBUTES,
};
use windows_sys::Win32::Storage::FileSystem::{
    CreateDirectoryW, FILE_ATTRIBUTE_DIRECTORY, FILE_ATTRIBUTE_REPARSE_POINT,
    FILE_FLAG_BACKUP_SEMANTICS, FILE_FLAG_OPEN_REPARSE_POINT, FILE_READ_ATTRIBUTES,
    FILE_SHARE_READ, FILE_SHARE_WRITE, READ_CONTROL,
};
use windows_sys::Win32::System::Com::CoTaskMemFree;
use windows_sys::Win32::System::Services::{ChangeServiceConfigW, SERVICE_NO_CHANGE};
use windows_sys::Win32::System::Threading::{CreateMutexW, ReleaseMutex, WaitForSingleObject};
use windows_sys::Win32::UI::Shell::{FOLDERID_ProgramFiles, SHGetKnownFolderPath, KF_FLAG_DEFAULT};

pub(super) const SERVICE_TYPE: ServiceType = ServiceType::OWN_PROCESS;
pub(super) const SERVICE_OPERATION_TIMEOUT: Duration = Duration::from_secs(10);
const SERVICE_POLL_INTERVAL: Duration = Duration::from_millis(100);
const SERVICE_RESTART_DELAY: Duration = Duration::from_secs(5);
const SERVICE_FAILURE_RESET_PERIOD: Duration = Duration::from_secs(24 * 60 * 60);
const SERVICE_ACCOUNT: &str = "LocalSystem";
const EXPECTED_CORE_SHA256: &str = env!("CORE_SHA256");

const ERROR_SERVICE_ALREADY_RUNNING: i32 = 1056;
const ERROR_SERVICE_DOES_NOT_EXIST: i32 = 1060;
const ERROR_SERVICE_CANNOT_ACCEPT_CTRL: i32 = 1061;
const ERROR_SERVICE_NOT_ACTIVE: i32 = 1062;
const ERROR_SERVICE_MARKED_FOR_DELETE: i32 = 1072;

pub(super) fn install(owner_pid: u32) -> Result<()> {
    let owner_sid = process_sid(owner_pid)
        .with_context(|| format!("read the account of process {owner_pid}"))
        .context(InstallFailure::OwnerInvalid)?;
    install_for(&owner_sid)
}

/// The installer runs this after replacing the app files; it moves an existing
/// registration onto the new pair for the owner it already serves.
pub(super) fn upgrade() -> Result<()> {
    let owner_sid = {
        let manager = open_manager(ServiceManagerAccess::CONNECT)?;
        let service = match manager.open_service(SERVICE_NAME, ServiceAccess::QUERY_CONFIG) {
            Ok(service) => service,
            Err(error) if has_error_code(&error, ERROR_SERVICE_DOES_NOT_EXIST) => return Ok(()),
            Err(error) => {
                return Err(error)
                    .context("open the registered ReClash Service")
                    .context(InstallFailure::ServiceFailed)
            }
        };
        let config = service
            .query_config()
            .context("read the ReClash Service configuration")
            .context(InstallFailure::ServiceFailed)?;
        configured_owner_sid(&config.executable_path.to_string_lossy())
            .context("the registered ReClash Service names no valid owner")
            .context(InstallFailure::OwnerInvalid)?
    };
    install_for(&owner_sid)
}

pub(super) fn uninstall() -> Result<()> {
    let _lock = InstallLock::acquire(INSTALL_MUTEX)?;
    {
        let manager = open_manager(ServiceManagerAccess::CONNECT)?;
        remove_service(&manager).context(InstallFailure::ServiceFailed)?;
    }
    let root = install_root_path().context(InstallFailure::BundleInvalid)?;
    match fs::symlink_metadata(&root) {
        Err(error) if error.kind() == ErrorKind::NotFound => return Ok(()),
        Err(error) => return Err(error).context("inspect the install root"),
        Ok(_) => {}
    }
    drop(open_protected_directory(&root).context(InstallFailure::BundleInvalid)?);
    fs::remove_dir_all(&root).context("remove the installed ReClash Service")
}

fn install_for(owner_sid: &str) -> Result<()> {
    let _lock = InstallLock::acquire(INSTALL_MUTEX)?;
    let mut source = SourceBundle::open().context(InstallFailure::BundleInvalid)?;
    let root = InstallRoot::prepare().context(InstallFailure::BundleInvalid)?;
    let bundle = root
        .stage(&mut source)
        .context(InstallFailure::BundleInvalid)?;
    register(&bundle.join(SERVICE_EXE), owner_sid).context(InstallFailure::ServiceFailed)?;
    if let Err(error) = root.prune(&source.manifest.id()) {
        eprintln!("ReClash Service installed; inactive bundle pruning skipped: {error:#}");
    }
    Ok(())
}

struct InstallLock(HANDLE);

impl InstallLock {
    fn acquire(name: &str) -> Result<Self> {
        let name = wide(OsStr::new(name));
        // SAFETY: the name is NUL-terminated and outlives the call.
        let handle = unsafe { CreateMutexW(null(), 0, name.as_ptr()) };
        if handle == 0 {
            return Err(Error::last_os_error()).context("open the installation lock");
        }
        // SAFETY: the handle was just created and is closed exactly once.
        match unsafe { WaitForSingleObject(handle, 0) } {
            WAIT_OBJECT_0 | WAIT_ABANDONED => Ok(Self(handle)),
            _ => {
                unsafe { CloseHandle(handle) };
                Err(anyhow!("another ReClash Service installation is running"))
                    .context(InstallFailure::InstallBusy)
            }
        }
    }
}

impl Drop for InstallLock {
    fn drop(&mut self) {
        // SAFETY: this thread owns the mutex it acquired in `acquire`.
        unsafe {
            ReleaseMutex(self.0);
            CloseHandle(self.0);
        }
    }
}

struct SourceBundle {
    manifest: Manifest,
    service: File,
    core: File,
}

impl SourceBundle {
    /// The pair beside this executable; the service half is the image that is
    /// running right now, never a file the caller names.
    fn open() -> Result<Self> {
        let executable = std::env::current_exe().context("resolve the running executable")?;
        let directory = executable
            .parent()
            .context("the running executable has no directory")?;
        let mut service = open_locked(&executable)?;
        let mut core = open_locked(&directory.join(env!("CORE_NAME")))?;
        let service_sha256 = sha256(&mut service)?;
        let core_sha256 = sha256(&mut core)?;
        if core_sha256 != EXPECTED_CORE_SHA256 {
            bail!("the bundled Core does not match the embedded Core hash");
        }
        let manifest = read_manifest(&directory.join(MANIFEST_NAME))?;
        if !manifest.matches(&core_sha256, &service_sha256) {
            bail!("the bundle manifest does not describe this pair");
        }
        Ok(Self {
            manifest,
            service,
            core,
        })
    }
}

struct InstallRoot {
    path: PathBuf,
    _handle: File,
}

impl InstallRoot {
    fn prepare() -> Result<Self> {
        let path = install_root_path()?;
        create_protected_directory(&path)?;
        let handle = open_protected_directory(&path)?;
        Ok(Self {
            path,
            _handle: handle,
        })
    }

    fn stage(&self, source: &mut SourceBundle) -> Result<PathBuf> {
        let destination = self.path.join(source.manifest.id());
        if fs::symlink_metadata(&destination).is_ok() {
            if verify_bundle(&destination, &source.manifest).is_ok() {
                return Ok(destination);
            }
            drop(open_protected_directory(&destination)?);
            fs::remove_dir_all(&destination).context("remove an incomplete bundle")?;
        }
        let stamp = SystemTime::now()
            .duration_since(UNIX_EPOCH)
            .unwrap_or_default()
            .as_nanos();
        let staging = self.path.join(staging_name(std::process::id(), stamp));
        if !create_protected_directory(&staging)? {
            bail!("the staging directory already exists");
        }
        let result = (|| {
            copy_verified(
                &mut source.service,
                &staging.join(SERVICE_EXE),
                &source.manifest.helper_sha256,
            )?;
            copy_verified(
                &mut source.core,
                &staging.join(env!("CORE_NAME")),
                &source.manifest.core_sha256,
            )?;
            write_verified(
                &staging.join(MANIFEST_NAME),
                &serde_json::to_vec(&source.manifest)?,
            )?;
            fs::rename(&staging, &destination).context("publish the staged bundle")?;
            verify_bundle(&destination, &source.manifest)
        })();
        if result.is_err() {
            let _ = fs::remove_dir_all(&staging);
        }
        result.map(|()| destination)
    }

    /// Runs only once the new registration is running, so no bundle it removes
    /// can still be the image of the service.
    fn prune(&self, keep: &str) -> Result<()> {
        let mut first_error = None;
        for entry in fs::read_dir(&self.path)? {
            let entry = entry?;
            let Some(name) = entry.file_name().to_str().map(str::to_string) else {
                continue;
            };
            if !is_prunable(&name, keep) {
                continue;
            }
            let path = entry.path();
            let result = open_protected_directory(&path)
                .map(drop)
                .and_then(|()| fs::remove_dir_all(&path).map_err(Into::into));
            if let Err(error) = result {
                first_error.get_or_insert(error.context(name));
            }
        }
        first_error.map_or(Ok(()), Err)
    }
}

fn verify_bundle(path: &Path, manifest: &Manifest) -> Result<()> {
    let _directory = open_protected_directory(path)?;
    for (name, expected) in [
        (SERVICE_EXE, &manifest.helper_sha256),
        (env!("CORE_NAME"), &manifest.core_sha256),
    ] {
        if &sha256(&mut open_locked(&path.join(name))?)? != expected {
            bail!("installed {name} does not match the bundle manifest");
        }
    }
    if &read_manifest(&path.join(MANIFEST_NAME))? != manifest {
        bail!("installed manifest does not match the bundle");
    }
    Ok(())
}

fn install_root_path() -> Result<PathBuf> {
    let mut path: *mut u16 = null_mut();
    // SAFETY: the returned buffer is freed with CoTaskMemFree as the API requires,
    // also on failure.
    let program_files = unsafe {
        let result =
            SHGetKnownFolderPath(&FOLDERID_ProgramFiles, KF_FLAG_DEFAULT as u32, 0, &mut path);
        let value = (result >= 0 && !path.is_null()).then(|| {
            let mut length = 0;
            while *path.add(length) != 0 {
                length += 1;
            }
            OsString::from_wide(std::slice::from_raw_parts(path, length))
        });
        CoTaskMemFree(path as *const c_void);
        value.ok_or_else(|| Error::from_raw_os_error(result))?
    };
    Ok(PathBuf::from(program_files).join(INSTALL_ROOT_NAME))
}

/// Creates the directory with the protected descriptor in one step; an
/// existing one is left for `open_protected_directory` to judge.
fn create_protected_directory(path: &Path) -> Result<bool> {
    let sddl = wide(OsStr::new(PROTECTED_DIRECTORY_SDDL));
    let path = wide(path.as_os_str());
    let mut descriptor: PSECURITY_DESCRIPTOR = null_mut();
    // SAFETY: both strings are NUL-terminated, and the descriptor is freed
    // with LocalFree once CreateDirectoryW has copied it.
    unsafe {
        if ConvertStringSecurityDescriptorToSecurityDescriptorW(
            sddl.as_ptr(),
            SDDL_REVISION_1,
            &mut descriptor,
            null_mut(),
        ) == 0
        {
            return Err(Error::last_os_error()).context("build the install descriptor");
        }
        let attributes = SECURITY_ATTRIBUTES {
            nLength: std::mem::size_of::<SECURITY_ATTRIBUTES>() as u32,
            lpSecurityDescriptor: descriptor,
            bInheritHandle: 0,
        };
        let created = CreateDirectoryW(path.as_ptr(), &attributes) != 0;
        let error = Error::last_os_error();
        LocalFree(descriptor as _);
        if created {
            return Ok(true);
        }
        if error.raw_os_error() == Some(ERROR_ALREADY_EXISTS as i32) {
            return Ok(false);
        }
        Err(error).context("create a protected install directory")
    }
}

/// Opens the directory itself rather than what a reparse point names, and holds
/// it against rename and deletion while the handle lives.
fn open_protected_directory(path: &Path) -> Result<File> {
    let directory = OpenOptions::new()
        .access_mode(READ_CONTROL | FILE_READ_ATTRIBUTES)
        .share_mode(FILE_SHARE_READ | FILE_SHARE_WRITE)
        .custom_flags(FILE_FLAG_BACKUP_SEMANTICS | FILE_FLAG_OPEN_REPARSE_POINT)
        .open(path)
        .with_context(|| format!("open {}", path.display()))?;
    let attributes = directory.metadata()?.file_attributes();
    if attributes & FILE_ATTRIBUTE_REPARSE_POINT != 0 || attributes & FILE_ATTRIBUTE_DIRECTORY == 0
    {
        bail!("{} is not a plain directory", path.display());
    }
    let (owner, dacl) = file_security(&directory)?;
    if !is_protected_directory(&owner, dacl.as_deref()) {
        bail!(
            "{} is not owned by Administrators or is writable by other accounts",
            path.display()
        );
    }
    Ok(directory)
}

fn file_security(file: &File) -> Result<(String, Option<Vec<Ace>>)> {
    let mut owner: PSID = null_mut();
    let mut dacl: *mut ACL = null_mut();
    let mut descriptor: PSECURITY_DESCRIPTOR = null_mut();
    // SAFETY: owner and DACL point into the descriptor, which is read before
    // LocalFree releases it.
    unsafe {
        let status = GetSecurityInfo(
            file.as_raw_handle() as HANDLE,
            SE_FILE_OBJECT,
            OWNER_SECURITY_INFORMATION | DACL_SECURITY_INFORMATION,
            &mut owner,
            null_mut(),
            &mut dacl,
            null_mut(),
            &mut descriptor,
        );
        if status != ERROR_SUCCESS {
            return Err(Error::from_raw_os_error(status as i32)).context("read directory security");
        }
        let result = (|| {
            let owner = sid_to_string(owner)?;
            if dacl.is_null() {
                return Ok((owner, None));
            }
            let mut aces = Vec::new();
            for index in 0..u32::from((*dacl).AceCount) {
                let mut ace: *mut c_void = null_mut();
                if GetAce(dacl, index, &mut ace) == 0 {
                    return Err(Error::last_os_error());
                }
                let header = *(ace as *const ACE_HEADER);
                let mask = *((ace as *const u8).add(4) as *const u32);
                let sid = if Ace::has_sid(header.AceType) {
                    Some(sid_to_string((ace as *mut u8).add(8) as PSID)?)
                } else {
                    None
                };
                aces.push(Ace {
                    kind: header.AceType,
                    mask,
                    sid,
                });
            }
            Ok((owner, Some(aces)))
        })();
        LocalFree(descriptor as _);
        result.context("read directory security")
    }
}

/// Denies writers for as long as the handle lives, so the bytes hashed are the
/// bytes copied.
fn open_locked(path: &Path) -> Result<File> {
    let file = OpenOptions::new()
        .read(true)
        .share_mode(FILE_SHARE_READ)
        .open(path)
        .with_context(|| format!("open {}", path.display()))?;
    if !file.metadata()?.is_file() {
        bail!("{} is not a regular file", path.display());
    }
    Ok(file)
}

fn sha256(file: &mut File) -> Result<String> {
    file.seek(SeekFrom::Start(0))?;
    let mut hasher = Sha256::new();
    let mut buffer = [0; 65536];
    loop {
        let size = file.read(&mut buffer)?;
        if size == 0 {
            return Ok(format!("{:x}", hasher.finalize()));
        }
        hasher.update(&buffer[..size]);
    }
}

fn read_manifest(path: &Path) -> Result<Manifest> {
    let mut bytes = Vec::new();
    open_locked(path)?
        .take(crate::service::windows_layout::MAX_MANIFEST_BYTES + 1)
        .read_to_end(&mut bytes)?;
    Manifest::parse(&bytes)
}

fn copy_verified(source: &mut File, path: &Path, expected: &str) -> Result<()> {
    source.seek(SeekFrom::Start(0))?;
    let mut destination = OpenOptions::new().write(true).create_new(true).open(path)?;
    std::io::copy(source, &mut destination)?;
    destination.sync_all()?;
    drop(destination);
    if sha256(&mut open_locked(path)?)? != expected {
        bail!("{} changed during installation", path.display());
    }
    Ok(())
}

fn write_verified(path: &Path, value: &[u8]) -> Result<()> {
    let mut destination = OpenOptions::new().write(true).create_new(true).open(path)?;
    destination.write_all(value)?;
    destination.sync_all()?;
    drop(destination);
    let mut written = Vec::new();
    open_locked(path)?.read_to_end(&mut written)?;
    if written != value {
        bail!("{} changed during installation", path.display());
    }
    Ok(())
}

fn open_manager(access: ServiceManagerAccess) -> Result<ServiceManager> {
    ServiceManager::local_computer(None::<&str>, access)
        .context("open Windows service manager")
        .context(InstallFailure::ServiceFailed)
}

fn service_info(executable: &Path, owner_sid: &str) -> ServiceInfo {
    ServiceInfo {
        name: OsString::from(SERVICE_NAME),
        display_name: OsString::from(SERVICE_DISPLAY_NAME),
        service_type: SERVICE_TYPE,
        start_type: ServiceStartType::AutoStart,
        error_control: ServiceErrorControl::Normal,
        executable_path: executable.to_path_buf(),
        launch_arguments: owner_sid_arguments(owner_sid),
        dependencies: Vec::new(),
        account_name: Some(OsString::from(SERVICE_ACCOUNT)),
        account_password: None,
    }
}

struct PreviousRegistration {
    command_line: Vec<u16>,
    was_running: bool,
}

fn register(executable: &Path, owner_sid: &str) -> Result<()> {
    let manager =
        open_manager(ServiceManagerAccess::CONNECT | ServiceManagerAccess::CREATE_SERVICE)?;
    let info = service_info(executable, owner_sid);
    let access = ServiceAccess::QUERY_CONFIG
        | ServiceAccess::CHANGE_CONFIG
        | ServiceAccess::QUERY_STATUS
        | ServiceAccess::START
        | ServiceAccess::STOP
        | ServiceAccess::DELETE;
    let (service, previous) = match open_existing(&manager, access)? {
        Some(service) => {
            let previous = PreviousRegistration {
                command_line: wide(
                    service
                        .query_config()
                        .context("read the current registration")?
                        .executable_path
                        .as_os_str(),
                ),
                was_running: service.query_status()?.current_state != ServiceState::Stopped,
            };
            stop_service(&service)?;
            if let Err(error) = service.change_config(&info) {
                if previous.was_running {
                    let _ = start_and_wait(&service);
                }
                return Err(error).context("reconfigure ReClash Service");
            }
            (service, Some(previous))
        }
        None => (
            manager
                .create_service(&info, access)
                .context("create ReClash Service")?,
            None,
        ),
    };
    let result = service
        .update_failure_actions(crash_recovery())
        .context("configure ReClash Service recovery")
        .and_then(|()| start_and_wait(&service));
    if let Err(error) = result {
        if let Err(rollback) = roll_back(&manager, service, previous.as_ref()) {
            return Err(rollback)
                .context(format!("installation failed: {error:#}; rollback failed"));
        }
        return Err(error).context("ReClash Service installation rolled back");
    }
    Ok(())
}

fn roll_back(
    manager: &ServiceManager,
    service: Service,
    previous: Option<&PreviousRegistration>,
) -> Result<()> {
    stop_service(&service)?;
    let Some(previous) = previous else {
        service.delete().context("delete the new registration")?;
        drop(service);
        return wait_for_deletion(manager);
    };
    // SAFETY: the command line is NUL-terminated; every other field is left
    // unchanged by SERVICE_NO_CHANGE and null pointers.
    let restored = unsafe {
        ChangeServiceConfigW(
            service.raw_handle(),
            SERVICE_NO_CHANGE,
            SERVICE_NO_CHANGE,
            SERVICE_NO_CHANGE,
            previous.command_line.as_ptr(),
            null(),
            null_mut(),
            null(),
            null(),
            null(),
            null(),
        )
    };
    if restored == 0 {
        return Err(Error::last_os_error()).context("restore the previous ImagePath");
    }
    if previous.was_running {
        start_and_wait(&service)?;
    }
    Ok(())
}

fn open_existing(manager: &ServiceManager, access: ServiceAccess) -> Result<Option<Service>> {
    match manager.open_service(SERVICE_NAME, access) {
        Ok(service) => Ok(Some(service)),
        Err(error) if has_error_code(&error, ERROR_SERVICE_DOES_NOT_EXIST) => Ok(None),
        Err(error) if has_error_code(&error, ERROR_SERVICE_MARKED_FOR_DELETE) => {
            wait_for_deletion(manager)?;
            Ok(None)
        }
        Err(error) => Err(error).context("open existing ReClash Service"),
    }
}

/// The SCM side of the Linux unit's `Restart=on-failure`; a clean stop stays stopped.
fn crash_recovery() -> ServiceFailureActions {
    let restart = ServiceAction {
        action_type: ServiceActionType::Restart,
        delay: SERVICE_RESTART_DELAY,
    };
    ServiceFailureActions {
        reset_period: ServiceFailureResetPeriod::After(SERVICE_FAILURE_RESET_PERIOD),
        reboot_msg: None,
        command: None,
        actions: Some(vec![restart.clone(), restart.clone(), restart]),
    }
}

fn remove_service(manager: &ServiceManager) -> Result<()> {
    let access = ServiceAccess::QUERY_STATUS | ServiceAccess::STOP | ServiceAccess::DELETE;
    let Some(service) = open_existing(manager, access)? else {
        return Ok(());
    };
    stop_service(&service)?;
    if let Err(error) = service.delete() {
        if !has_error_code(&error, ERROR_SERVICE_MARKED_FOR_DELETE)
            && !has_error_code(&error, ERROR_SERVICE_DOES_NOT_EXIST)
        {
            return Err(error).context("delete ReClash Service");
        }
    }
    drop(service);
    wait_for_deletion(manager)
}

fn start_and_wait(service: &Service) -> Result<()> {
    if let Err(error) = service.start::<&OsStr>(&[]) {
        if !has_error_code(&error, ERROR_SERVICE_ALREADY_RUNNING) {
            return Err(error).context("start ReClash Service");
        }
    }
    wait_for_running(service)
}

fn stop_service(service: &Service) -> Result<()> {
    let started_at = Instant::now();
    loop {
        let state = service
            .query_status()
            .context("query ReClash Service before stopping")?
            .current_state;
        if state == ServiceState::Stopped {
            return Ok(());
        }
        if state != ServiceState::StopPending {
            if let Err(error) = service.stop() {
                if has_error_code(&error, ERROR_SERVICE_NOT_ACTIVE) {
                    return Ok(());
                }
                if !has_error_code(&error, ERROR_SERVICE_CANNOT_ACCEPT_CTRL) {
                    return Err(error).context("stop ReClash Service");
                }
            }
        }
        if started_at.elapsed() >= SERVICE_OPERATION_TIMEOUT {
            bail!("timed out waiting for ReClash Service to stop from {state:?}");
        }
        sleep(SERVICE_POLL_INTERVAL);
    }
}

fn wait_for_deletion(manager: &ServiceManager) -> Result<()> {
    let started_at = Instant::now();
    loop {
        match manager.open_service(SERVICE_NAME, ServiceAccess::QUERY_STATUS) {
            Err(error) if has_error_code(&error, ERROR_SERVICE_DOES_NOT_EXIST) => return Ok(()),
            Err(error) if !has_error_code(&error, ERROR_SERVICE_MARKED_FOR_DELETE) => {
                return Err(error).context("check ReClash Service deletion")
            }
            Ok(service) => drop(service),
            Err(_) => {}
        }
        if started_at.elapsed() >= SERVICE_OPERATION_TIMEOUT {
            bail!("timed out waiting for ReClash Service deletion");
        }
        sleep(SERVICE_POLL_INTERVAL);
    }
}

fn wait_for_running(service: &Service) -> Result<()> {
    let started_at = Instant::now();
    loop {
        let state = service
            .query_status()
            .context("query ReClash Service after starting")?
            .current_state;
        match state {
            ServiceState::Running => return Ok(()),
            ServiceState::Stopped => bail!("ReClash Service stopped during startup"),
            _ => {}
        }
        if started_at.elapsed() >= SERVICE_OPERATION_TIMEOUT {
            bail!("timed out waiting for ReClash Service to run from {state:?}");
        }
        sleep(SERVICE_POLL_INTERVAL);
    }
}

fn has_error_code(error: &windows_service::Error, code: i32) -> bool {
    matches!(error, windows_service::Error::Winapi(error) if error.raw_os_error() == Some(code))
}

fn wide(value: &OsStr) -> Vec<u16> {
    value.encode_wide().chain(std::iter::once(0)).collect()
}

#[cfg(test)]
mod tests {
    use super::*;

    fn temporary_directory(label: &str) -> PathBuf {
        let path = std::env::temp_dir().join(format!(
            "reclash-service-{label}-{}-{}",
            std::process::id(),
            SystemTime::now()
                .duration_since(UNIX_EPOCH)
                .unwrap()
                .as_nanos()
        ));
        fs::create_dir(&path).unwrap();
        path
    }

    #[test]
    fn the_install_root_is_under_the_known_program_files_folder() {
        let root = install_root_path().unwrap();

        assert!(root.is_absolute(), "{}", root.display());
        assert_eq!(root.file_name().unwrap(), INSTALL_ROOT_NAME);
        assert!(root.parent().unwrap().is_dir());
    }

    #[test]
    fn a_second_installer_is_busy_while_the_first_holds_the_lock() {
        let name = format!(r"Local\ReClashServiceInstallTest-{}", std::process::id());
        let first = InstallLock::acquire(&name).unwrap();

        let busy = std::thread::scope(|scope| {
            scope
                .spawn(|| InstallLock::acquire(&name).map(drop))
                .join()
                .unwrap()
        });
        let error = busy.unwrap_err();
        assert_eq!(
            crate::service::windows_layout::failure_exit(&error),
            (5, "install_busy")
        );

        drop(first);
        std::thread::scope(|scope| {
            scope
                .spawn(|| InstallLock::acquire(&name).map(drop))
                .join()
                .unwrap()
        })
        .unwrap();
    }

    #[test]
    fn a_directory_others_can_write_is_not_an_install_directory() {
        let directory = temporary_directory("acl");

        assert!(open_protected_directory(&directory).is_err());
        let handle = OpenOptions::new()
            .access_mode(READ_CONTROL)
            .custom_flags(FILE_FLAG_BACKUP_SEMANTICS)
            .open(&directory)
            .unwrap();
        let (owner, dacl) = file_security(&handle).unwrap();
        assert!(owner.starts_with("S-1-5-"), "{owner}");
        assert!(dacl.is_some());
        drop(handle);
        fs::remove_dir(directory).unwrap();
    }

    #[test]
    fn copies_are_verified_against_the_expected_hash() {
        let directory = temporary_directory("copy");
        let source_path = directory.join("source");
        fs::write(&source_path, b"test").unwrap();
        let mut source = open_locked(&source_path).unwrap();

        copy_verified(
            &mut source,
            &directory.join("copy"),
            "9f86d081884c7d659a2feaa0c55ad015a3bf4f1b2b0b822cd15d6c15b0f00a08",
        )
        .unwrap();
        assert!(copy_verified(&mut source, &directory.join("other"), "0").is_err());
        assert!(copy_verified(
            &mut source,
            &directory.join("copy"),
            "9f86d081884c7d659a2feaa0c55ad015a3bf4f1b2b0b822cd15d6c15b0f00a08",
        )
        .is_err());

        drop(source);
        fs::remove_dir_all(directory).unwrap();
    }
}
