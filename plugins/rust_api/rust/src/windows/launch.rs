use super::contract;
#[cfg(test)]
#[path = "tests.rs"]
mod tests;
use super::pipe::BootstrapPipe;
use super::security::*;
use sha2::{Digest, Sha256};
use std::fs::{File, OpenOptions};
use std::io::{self, Read};
use std::mem::{size_of, zeroed};
use std::os::windows::fs::OpenOptionsExt;
use std::os::windows::io::{AsRawHandle, OwnedHandle};
use std::path::{Path, PathBuf};
use std::ptr::null;
use std::sync::atomic::{AtomicBool, Ordering};
use std::sync::{Arc, Condvar, Mutex};
use std::time::{Duration, Instant};
use windows_sys::Win32::Foundation::*;
use windows_sys::Win32::Storage::FileSystem::*;
use windows_sys::Win32::System::Com::*;
use windows_sys::Win32::System::JobObjects::*;
use windows_sys::Win32::System::Threading::*;
use windows_sys::Win32::UI::Shell::*;
use windows_sys::Win32::UI::WindowsAndMessaging::SW_HIDE;

pub type EventSink = Arc<dyn Fn(Vec<String>) -> bool + Send + Sync>;
static ACTIVE: Mutex<Option<Arc<Ticket>>> = Mutex::new(None);

struct Ticket {
    session_id: String,
    revoked: AtomicBool,
    commit: Mutex<()>,
    process: Mutex<Option<Arc<OwnedHandle>>>,
    job: OwnedHandle,
    access: Mutex<Option<ProcessAccess>>,
    resources: Mutex<Option<Arc<LaunchResources>>>,
    committed: AtomicBool,
    emit: Mutex<Option<EventSink>>,
    started: AtomicBool,
    completion: Condvar,
    completion_lock: Mutex<()>,
}

impl Ticket {
    fn event(&self, kind: &str, value: impl ToString) {
        let emit = self
            .emit
            .lock()
            .unwrap_or_else(|error| error.into_inner())
            .clone();
        if let Some(emit) = emit {
            if !emit(vec![kind.into(), value.to_string()]) {
                let _ = self.revoke();
            }
        }
    }

    fn revoke(&self) -> io::Result<()> {
        let _guard = self
            .commit
            .lock()
            .unwrap_or_else(|error| error.into_inner());
        self.revoked.store(true, Ordering::Release);
        self.committed.store(false, Ordering::Release);
        unsafe { TerminateJobObject(self.job.as_raw_handle(), 1) };
        self.restore_access()
    }

    fn restore_access(&self) -> io::Result<()> {
        let mut access = self
            .access
            .lock()
            .unwrap_or_else(|error| error.into_inner());
        if let Some(guard) = access.as_mut() {
            guard.restore()?;
        }
        *access = None;
        Ok(())
    }

    fn commit_bootstrap(&self, send: impl FnOnce() -> io::Result<()>) -> io::Result<()> {
        let _guard = self
            .commit
            .lock()
            .unwrap_or_else(|error| error.into_inner());
        if self.revoked.load(Ordering::Acquire) {
            return Err(io::Error::other("windows_launch_cancelled"));
        }
        self.restore_access()?;
        self.committed.store(true, Ordering::Release);
        if let Err(error) = send() {
            self.committed.store(false, Ordering::Release);
            return Err(error);
        }
        Ok(())
    }

    fn process(&self) -> Option<Arc<OwnedHandle>> {
        self.process
            .lock()
            .unwrap_or_else(|error| error.into_inner())
            .clone()
    }

    fn exit_confirmed(&self) -> io::Result<bool> {
        let Some(process) = self.process() else {
            return Ok(!self.started.load(Ordering::Acquire));
        };
        match unsafe { WaitForSingleObject(process.as_raw_handle(), 0) } {
            WAIT_OBJECT_0 => Ok(true),
            WAIT_TIMEOUT => Ok(false),
            _ => Err(io::Error::last_os_error()),
        }
    }

    fn wait_cleanup(&self, timeout: Duration) -> io::Result<bool> {
        let deadline = Instant::now() + timeout;
        let mut guard = self
            .completion_lock
            .lock()
            .unwrap_or_else(|error| error.into_inner());
        loop {
            if !self.started.load(Ordering::Acquire) && self.exit_confirmed()? {
                return Ok(true);
            }
            let remaining = deadline.saturating_duration_since(Instant::now());
            if remaining.is_zero() {
                return Ok(false);
            }
            let (next, _) = self
                .completion
                .wait_timeout(guard, remaining.min(Duration::from_millis(50)))
                .unwrap_or_else(|error| error.into_inner());
            guard = next;
        }
    }

    fn finish_worker(&self) {
        let _guard = self
            .completion_lock
            .lock()
            .unwrap_or_else(|error| error.into_inner());
        self.started.store(false, Ordering::Release);
        self.completion.notify_all();
    }
}

fn create_job() -> io::Result<OwnedHandle> {
    let job = owned(unsafe { CreateJobObjectW(null(), null()) })?;
    let mut limits: JOBOBJECT_EXTENDED_LIMIT_INFORMATION = unsafe { zeroed() };
    limits.BasicLimitInformation.LimitFlags = JOB_OBJECT_LIMIT_KILL_ON_JOB_CLOSE;
    check(unsafe {
        SetInformationJobObject(
            job.as_raw_handle(),
            JobObjectExtendedLimitInformation,
            (&limits as *const JOBOBJECT_EXTENDED_LIMIT_INFORMATION).cast(),
            size_of::<JOBOBJECT_EXTENDED_LIMIT_INFORMATION>() as u32,
        )
    })?;
    Ok(job)
}

fn file_info(file: &File) -> io::Result<BY_HANDLE_FILE_INFORMATION> {
    let mut info = BY_HANDLE_FILE_INFORMATION::default();
    check(unsafe { GetFileInformationByHandle(file.as_raw_handle(), &mut info) })?;
    Ok(info)
}

fn final_path(file: &File) -> io::Result<PathBuf> {
    let mut buffer = vec![0u16; 32768];
    let size = unsafe {
        GetFinalPathNameByHandleW(
            file.as_raw_handle(),
            buffer.as_mut_ptr(),
            buffer.len() as u32,
            0,
        )
    };
    if size == 0 {
        return Err(io::Error::last_os_error());
    }
    if size as usize >= buffer.len() {
        return Err(io::Error::other("windows_path_too_long"));
    }
    let path = String::from_utf16(&buffer[..size as usize])
        .map_err(|_| io::Error::other("windows_invalid_image_path"))?;
    if !contract::local_path(&path) {
        return Err(io::Error::other("windows_local_image_required"));
    }
    Ok(PathBuf::from(path))
}

struct ImageLock {
    path: PathBuf,
    file: File,
    _directories: Vec<File>,
}

fn pin_directories(path: &Path, include_self: bool) -> io::Result<Vec<File>> {
    let mut ancestors: Vec<_> = path.ancestors().skip(usize::from(!include_self)).collect();
    ancestors.reverse();
    let mut files = Vec::new();
    for ancestor in ancestors {
        let file = OpenOptions::new()
            .access_mode(FILE_READ_ATTRIBUTES)
            .share_mode(FILE_SHARE_READ | FILE_SHARE_WRITE)
            .custom_flags(FILE_FLAG_BACKUP_SEMANTICS | FILE_FLAG_OPEN_REPARSE_POINT)
            .open(ancestor)?;
        let info = file_info(&file)?;
        if info.dwFileAttributes & FILE_ATTRIBUTE_REPARSE_POINT != 0
            || info.dwFileAttributes & FILE_ATTRIBUTE_DIRECTORY == 0
        {
            return Err(io::Error::other("windows_reparse_path_rejected"));
        }
        files.push(file);
    }
    Ok(files)
}

impl ImageLock {
    fn open(path: &Path, expected_sha256: Option<&str>) -> io::Result<Self> {
        if !contract::local_path(&path.to_string_lossy()) {
            return Err(io::Error::other("windows_local_image_required"));
        }
        let directories = pin_directories(path, false)?;
        let mut file = OpenOptions::new()
            .read(true)
            .share_mode(FILE_SHARE_READ)
            .custom_flags(FILE_FLAG_OPEN_REPARSE_POINT)
            .open(path)?;
        let info = file_info(&file)?;
        if info.dwFileAttributes & (FILE_ATTRIBUTE_REPARSE_POINT | FILE_ATTRIBUTE_DIRECTORY) != 0 {
            return Err(io::Error::other("windows_reparse_image_rejected"));
        }
        let path = final_path(&file)?;
        if let Some(expected) = expected_sha256 {
            let mut hasher = Sha256::new();
            let mut buffer = [0u8; 65536];
            loop {
                let count = file.read(&mut buffer)?;
                if count == 0 {
                    break;
                }
                hasher.update(&buffer[..count]);
            }
            if format!("{:x}", hasher.finalize()) != expected {
                return Err(io::Error::other("windows_core_verification_failed"));
            }
        }
        Ok(Self {
            path,
            file,
            _directories: directories,
        })
    }

    fn verify_process(&self, process: HANDLE) -> io::Result<()> {
        let mut buffer = vec![0u16; 32768];
        let mut length = buffer.len() as u32;
        check(unsafe { QueryFullProcessImageNameW(process, 0, buffer.as_mut_ptr(), &mut length) })?;
        let path = PathBuf::from(
            String::from_utf16(&buffer[..length as usize])
                .map_err(|_| io::Error::other("windows_invalid_process_image"))?,
        );
        let actual = ImageLock::open(&path, None)?;
        let expected = file_info(&self.file)?;
        let actual = file_info(&actual.file)?;
        if expected.dwVolumeSerialNumber != actual.dwVolumeSerialNumber
            || expected.nFileIndexHigh != actual.nFileIndexHigh
            || expected.nFileIndexLow != actual.nFileIndexLow
        {
            return Err(io::Error::other("windows_core_image_mismatch"));
        }
        Ok(())
    }
}

struct LaunchResources {
    image: ImageLock,
    _app: ImageLock,
    _home: Vec<File>,
    pipe: BootstrapPipe,
}

fn shell_launch(path: &Path, arguments: &[String]) -> io::Result<OwnedHandle> {
    let result = unsafe {
        CoInitializeEx(
            null(),
            (COINIT_APARTMENTTHREADED | COINIT_DISABLE_OLE1DDE) as u32,
        )
    };
    if result < 0 {
        return Err(io::Error::other(format!(
            "windows_shell_initialization_failed: {result:#x}"
        )));
    }
    struct Apartment;
    impl Drop for Apartment {
        fn drop(&mut self) {
            unsafe { CoUninitialize() };
        }
    }
    let _apartment = Apartment;
    let path = path.to_string_lossy();
    let file = wide(path.strip_prefix(r"\\?\").unwrap_or(&path));
    let verb = wide("runas");
    let parameters = wide(
        &arguments
            .iter()
            .map(|argument| contract::quote(argument))
            .collect::<Vec<_>>()
            .join(" "),
    );
    let mut info: SHELLEXECUTEINFOW = unsafe { zeroed() };
    info.cbSize = size_of::<SHELLEXECUTEINFOW>() as u32;
    info.fMask = SEE_MASK_NOCLOSEPROCESS | SEE_MASK_NOASYNC | SEE_MASK_FLAG_NO_UI;
    info.lpVerb = verb.as_ptr();
    info.lpFile = file.as_ptr();
    info.lpParameters = parameters.as_ptr();
    info.nShow = SW_HIDE;
    check(unsafe { ShellExecuteExW(&mut info) })?;
    owned(info.hProcess)
}

pub fn prepare(session_id: String) -> Result<(), String> {
    contract::session(&session_id).map_err(|error| error.to_string())?;
    let mut active = ACTIVE.lock().map_err(|_| "windows_launch_lock_poisoned")?;
    if active.is_some() {
        return Err("windows_launch_pending".into());
    }
    *active = Some(Arc::new(Ticket {
        session_id,
        revoked: AtomicBool::new(false),
        commit: Mutex::new(()),
        process: Mutex::new(None),
        job: create_job().map_err(|error| format!("windows_job_creation_failed: {error}"))?,
        access: Mutex::new(None),
        resources: Mutex::new(None),
        committed: AtomicBool::new(false),
        emit: Mutex::new(None),
        started: AtomicBool::new(false),
        completion: Condvar::new(),
        completion_lock: Mutex::new(()),
    }));
    Ok(())
}

pub fn start(
    session_id: String,
    address: String,
    home_dir: String,
    expected_sha256: String,
    emit: EventSink,
) -> Result<(), String> {
    contract::launch(&session_id, &address, &home_dir, &expected_sha256)
        .map_err(|error| error.to_string())?;
    let active = ACTIVE.lock().map_err(|_| "windows_launch_lock_poisoned")?;
    let ticket = active
        .as_ref()
        .filter(|ticket| ticket.session_id == session_id)
        .ok_or("windows_launch_cancelled")?
        .clone();
    if ticket.revoked.load(Ordering::Acquire) || ticket.started.swap(true, Ordering::AcqRel) {
        return Err("windows_launch_cancelled".into());
    }
    *ticket
        .emit
        .lock()
        .unwrap_or_else(|error| error.into_inner()) = Some(emit);
    drop(active);
    let worker_ticket = ticket.clone();
    if let Err(error) = std::thread::Builder::new()
        .name("windows-core-launch".into())
        .spawn(move || {
            if let Err(error) = run(&worker_ticket, &address, &home_dir, &expected_sha256) {
                let _ = worker_ticket.revoke();
                let code = if error.raw_os_error() == Some(ERROR_CANCELLED as i32)
                    || worker_ticket.revoked.load(Ordering::Acquire)
                        && error.to_string() == "windows_launch_cancelled"
                {
                    "windows_launch_cancelled".to_owned()
                } else {
                    format!("windows_launch_failed: {error}")
                };
                worker_ticket.event("error", code);
            }
            let exit = worker_ticket
                .process()
                .map(|process| unsafe { WaitForSingleObject(process.as_raw_handle(), INFINITE) });
            worker_ticket.finish_worker();
            if exit.is_some_and(|status| status != WAIT_OBJECT_0) {
                worker_ticket.event("error", "windows_exit_unconfirmed");
                return;
            }
            match release_finished(&worker_ticket) {
                Ok(true) => worker_ticket.event("exited", ""),
                Ok(false) => worker_ticket.event("error", "windows_exit_unconfirmed"),
                Err(error) => {
                    worker_ticket.event("error", format!("windows_cleanup_failed: {error}"))
                }
            }
        })
    {
        ticket.finish_worker();
        let _ = ticket.revoke();
        let _ = release_finished(&ticket);
        return Err(format!("windows_worker_creation_failed: {error}"));
    }
    Ok(())
}

fn run(ticket: &Ticket, address: &str, home_dir: &str, expected_sha256: &str) -> io::Result<()> {
    let app = std::env::current_exe()?;
    if !app
        .file_name()
        .is_some_and(|name| name.to_string_lossy().eq_ignore_ascii_case("ReClash.exe"))
    {
        return Err(io::Error::other("windows_app_image_mismatch"));
    }
    let executable = app
        .parent()
        .ok_or_else(|| io::Error::other("windows_missing_app_directory"))?
        .join("ReClashCore.exe");
    let own_pid = std::process::id();
    let own_session = process_session(own_pid)?;
    let own_created = creation_time(unsafe { GetCurrentProcess() })?;
    let sid = own_sid()?;
    let name = format!(
        r"\\.\pipe\ReClash.bootstrap.{own_pid}.{}",
        ticket.session_id
    );
    let resources = Arc::new(LaunchResources {
        image: ImageLock::open(&executable, Some(expected_sha256))?,
        _app: ImageLock::open(&app, None)?,
        _home: pin_directories(Path::new(home_dir), true)?,
        pipe: BootstrapPipe::create(&name, &sid)?,
    });
    *ticket
        .resources
        .lock()
        .unwrap_or_else(|error| error.into_inner()) = Some(resources.clone());
    {
        let _commit = ticket
            .commit
            .lock()
            .unwrap_or_else(|error| error.into_inner());
        if ticket.revoked.load(Ordering::Acquire) {
            return Err(io::Error::other("windows_launch_cancelled"));
        }
        let mut access = ticket
            .access
            .lock()
            .unwrap_or_else(|error| error.into_inner());
        *access = Some(ProcessAccess::capture()?);
        access
            .as_mut()
            .ok_or_else(|| io::Error::other("windows_missing_access_guard"))?
            .grant_admin_handoff()?;
    }
    if ticket.revoked.load(Ordering::Acquire) {
        return Err(io::Error::other("windows_launch_cancelled"));
    }
    let process = Arc::new(shell_launch(
        &resources.image.path,
        &[
            "--managed-windows".into(),
            name,
            own_pid.to_string(),
            own_created.to_string(),
            sid,
            own_session.to_string(),
            address.into(),
            ticket.session_id.clone(),
            home_dir.into(),
        ],
    )?);
    *ticket
        .process
        .lock()
        .unwrap_or_else(|error| error.into_inner()) = Some(process.clone());
    let pid = unsafe { GetProcessId(process.as_raw_handle()) };
    if pid == 0 {
        return Err(io::Error::last_os_error());
    }
    ticket.event("spawned", pid);
    let deadline = Instant::now() + Duration::from_secs(10);
    resources.pipe.connect(&ticket.revoked, deadline)?;
    resources.pipe.verify_client(pid, own_session)?;
    let mut hello = [0; 16];
    resources.pipe.read(&mut hello, &ticket.revoked, deadline)?;
    if &hello[..8] != b"RCXWIN01"
        || u64::from_le_bytes(
            hello[8..]
                .try_into()
                .map_err(|_| io::Error::other("windows_invalid_bootstrap_hello"))?,
        ) != creation_time(process.as_raw_handle())?
        || unsafe { WaitForSingleObject(process.as_raw_handle(), 0) } != WAIT_TIMEOUT
    {
        return Err(io::Error::other("windows_invalid_bootstrap_hello"));
    }
    resources.image.verify_process(process.as_raw_handle())?;
    let identity = process_identity(process.as_raw_handle())?;
    if identity.session != own_session {
        return Err(io::Error::other("windows_core_session_mismatch"));
    }
    resources.pipe.verify_token(&identity)?;
    resources
        .pipe
        .write(&(ticket.job.as_raw_handle() as usize as u64).to_le_bytes())?;
    let mut joined = [0; 8];
    resources
        .pipe
        .read(&mut joined, &ticket.revoked, deadline)?;
    if &joined != b"RCXJOIN1" {
        return Err(io::Error::other("windows_core_job_not_joined"));
    }
    let mut in_job = 0;
    check(unsafe {
        IsProcessInJob(
            process.as_raw_handle(),
            ticket.job.as_raw_handle(),
            &mut in_job,
        )
    })?;
    if in_job == 0 {
        return Err(io::Error::other("windows_core_job_mismatch"));
    }
    ticket.commit_bootstrap(|| resources.pipe.write(b"RCXGO001"))?;
    ticket.event("ready", pid);
    Ok(())
}

fn release_finished(ticket: &Arc<Ticket>) -> io::Result<bool> {
    if ticket.started.load(Ordering::Acquire) || !ticket.exit_confirmed()? {
        return Ok(false);
    }
    ticket.restore_access()?;
    let mut active = ACTIVE
        .lock()
        .map_err(|_| io::Error::other("windows_launch_lock_poisoned"))?;
    if active
        .as_ref()
        .is_some_and(|current| Arc::ptr_eq(current, ticket))
    {
        ticket
            .resources
            .lock()
            .unwrap_or_else(|error| error.into_inner())
            .take();
        *active = None;
    }
    Ok(true)
}

pub fn cancel(session_id: &str) -> Result<bool, String> {
    contract::session(session_id).map_err(|error| error.to_string())?;
    let ticket = ACTIVE
        .lock()
        .map_err(|_| "windows_launch_lock_poisoned")?
        .as_ref()
        .filter(|ticket| ticket.session_id == session_id)
        .cloned();
    let Some(ticket) = ticket else {
        return Ok(true);
    };
    ticket
        .revoke()
        .map_err(|error| format!("windows_acl_restore_failed: {error}"))?;
    release_finished(&ticket).map_err(|error| error.to_string())
}

pub fn stop(session_id: &str, timeout_millis: u32) -> Result<bool, String> {
    contract::session(session_id).map_err(|error| error.to_string())?;
    let ticket = ACTIVE
        .lock()
        .map_err(|_| "windows_launch_lock_poisoned")?
        .as_ref()
        .filter(|ticket| ticket.session_id == session_id)
        .cloned();
    let Some(ticket) = ticket else {
        return Ok(true);
    };
    ticket
        .revoke()
        .map_err(|error| format!("windows_acl_restore_failed: {error}"))?;
    if !ticket
        .wait_cleanup(Duration::from_millis(timeout_millis.into()))
        .map_err(|error| error.to_string())?
    {
        return Ok(false);
    }
    release_finished(&ticket).map_err(|error| error.to_string())
}

pub fn authorize_rpc_peer(pid: u32) -> io::Result<()> {
    let active = ACTIVE
        .lock()
        .map_err(|_| io::Error::other("windows_launch_lock_poisoned"))?
        .clone();
    let Some(ticket) = active else {
        return Ok(());
    };
    let Some(process) = ticket.process() else {
        return Err(io::Error::other("windows_launch_pending"));
    };
    if ticket.revoked.load(Ordering::Acquire)
        || !ticket.committed.load(Ordering::Acquire)
        || unsafe { GetProcessId(process.as_raw_handle()) } != pid
        || unsafe { WaitForSingleObject(process.as_raw_handle(), 0) } != WAIT_TIMEOUT
    {
        return Err(io::Error::other("windows_rpc_peer_mismatch"));
    }
    Ok(())
}

pub fn is_managed_peer(pid: u32) -> bool {
    let Ok(active) = ACTIVE.lock() else {
        return false;
    };
    active.as_ref().is_some_and(|ticket| {
        ticket.committed.load(Ordering::Acquire)
            && !ticket.revoked.load(Ordering::Acquire)
            && ticket.process().is_some_and(|process| unsafe {
                GetProcessId(process.as_raw_handle()) == pid
                    && WaitForSingleObject(process.as_raw_handle(), 0) == WAIT_TIMEOUT
            })
    })
}
