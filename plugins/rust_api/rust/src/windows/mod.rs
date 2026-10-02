mod pipe;
pub(crate) mod security;
#[cfg(test)]
mod tests;

use pipe::BootstrapPipe;
use security::*;
use sha2::{Digest, Sha256};
use std::fs::{File, OpenOptions};
use std::io::{self, Read};
use std::mem::{size_of, zeroed};
use std::os::windows::fs::OpenOptionsExt;
use std::os::windows::io::{AsRawHandle, OwnedHandle};
use std::path::{Path, PathBuf};
use std::ptr::null;
use std::sync::atomic::{AtomicBool, Ordering};
use std::sync::{Arc, Mutex};
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
    committed: AtomicBool,
    emit: Mutex<Option<EventSink>>,
    started: AtomicBool,
}

impl Ticket {
    fn event(&self, kind: &str, value: impl ToString) {
        let emit = self.emit.lock().unwrap_or_else(|e| e.into_inner()).clone();
        if let Some(emit) = emit {
            if !emit(vec![kind.into(), value.to_string()]) {
                self.revoke();
            }
        }
    }

    fn revoke(&self) {
        let _guard = self.commit.lock().unwrap_or_else(|e| e.into_inner());
        self.revoked.store(true, Ordering::Release);
        let _ = self.restore_access();
        unsafe {
            TerminateJobObject(self.job.as_raw_handle(), 1);
        }
    }

    fn restore_access(&self) -> io::Result<()> {
        let mut access = self.access.lock().unwrap_or_else(|e| e.into_inner());
        if let Some(guard) = access.as_mut() {
            guard.restore()?;
        }
        *access = None;
        Ok(())
    }

    fn commit_bootstrap(&self, send: impl FnOnce() -> io::Result<()>) -> io::Result<()> {
        let _guard = self.commit.lock().unwrap_or_else(|e| e.into_inner());
        if self.revoked.load(Ordering::Acquire) {
            return Err(io::Error::other("windows_launch_cancelled"));
        }
        self.committed.store(true, Ordering::Release);
        send()
    }

    fn process(&self) -> Option<Arc<OwnedHandle>> {
        self.process
            .lock()
            .unwrap_or_else(|e| e.into_inner())
            .clone()
    }

    fn wait_exit(&self, timeout: Duration) -> io::Result<bool> {
        let Some(process) = self.process() else {
            return Ok(!self.started.load(Ordering::Acquire));
        };
        let result = unsafe {
            WaitForSingleObject(
                process.as_raw_handle(),
                timeout.as_millis().min(u32::MAX as u128 - 1) as u32,
            )
        };
        match result {
            WAIT_OBJECT_0 => Ok(true),
            WAIT_TIMEOUT => Ok(false),
            _ => Err(io::Error::last_os_error()),
        }
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

struct ImageLock {
    path: PathBuf,
    _file: File,
    _directories: Vec<File>,
}

impl ImageLock {
    fn open(path: &Path, expected_sha256: &str) -> io::Result<Self> {
        let path = path.canonicalize()?;
        if path.to_string_lossy().starts_with(r"\\?\UNC\") {
            return Err(io::Error::other("Windows Core must be on a local drive"));
        }
        let mut directories = Vec::new();
        for ancestor in path.ancestors().skip(1) {
            directories.push(
                OpenOptions::new()
                    .access_mode(FILE_READ_ATTRIBUTES)
                    .share_mode(FILE_SHARE_READ | FILE_SHARE_WRITE)
                    .custom_flags(FILE_FLAG_BACKUP_SEMANTICS)
                    .open(ancestor)?,
            );
        }
        let mut file = OpenOptions::new()
            .read(true)
            .share_mode(FILE_SHARE_READ)
            .open(&path)?;
        let mut hasher = Sha256::new();
        let mut buffer = [0u8; 65536];
        loop {
            let count = file.read(&mut buffer)?;
            if count == 0 {
                break;
            }
            hasher.update(&buffer[..count]);
        }
        if format!("{:x}", hasher.finalize()) != expected_sha256 {
            return Err(io::Error::other("Windows Core manifest mismatch"));
        }
        Ok(Self {
            path,
            _file: file,
            _directories: directories,
        })
    }
}

fn quote(value: &str) -> String {
    let mut result = String::from("\"");
    let mut slashes = 0;
    for character in value.chars() {
        if character == '\\' {
            slashes += 1;
            continue;
        }
        if character == '"' {
            result.extend(std::iter::repeat_n('\\', slashes * 2 + 1));
        } else {
            result.extend(std::iter::repeat_n('\\', slashes));
        }
        slashes = 0;
        result.push(character);
    }
    result.extend(std::iter::repeat_n('\\', slashes * 2));
    result.push('"');
    result
}

fn shell_launch(path: &Path, arguments: &[String]) -> io::Result<OwnedHandle> {
    let result = unsafe {
        CoInitializeEx(
            std::ptr::null(),
            (COINIT_APARTMENTTHREADED | COINIT_DISABLE_OLE1DDE) as u32,
        )
    };
    if result < 0 {
        return Err(io::Error::other(format!(
            "Windows shell initialization failed: {result:#x}"
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
    let path = path.strip_prefix(r"\\?\").unwrap_or(&path);
    let file = wide(path);
    let verb = wide("runas");
    let parameters = wide(
        &arguments
            .iter()
            .map(|s| quote(s))
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
    if session_id.len() != 32
        || !session_id
            .bytes()
            .all(|b| b.is_ascii_digit() || (b'a'..=b'f').contains(&b))
    {
        return Err("Invalid Windows launch session".into());
    }
    let mut active = ACTIVE.lock().map_err(|_| "Windows launch lock poisoned")?;
    if active.is_some() {
        return Err("windows_launch_pending".into());
    }
    *active = Some(Arc::new(Ticket {
        session_id,
        revoked: AtomicBool::new(false),
        commit: Mutex::new(()),
        process: Mutex::new(None),
        job: create_job().map_err(|e| e.to_string())?,
        access: Mutex::new(None),
        committed: AtomicBool::new(false),
        emit: Mutex::new(None),
        started: AtomicBool::new(false),
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
    if session_id.len() != 32
        || !session_id
            .bytes()
            .all(|b| b.is_ascii_digit() || (b'a'..=b'f').contains(&b))
    {
        return Err("Invalid Windows launch session".into());
    }
    if !address.starts_with(r"\\.\pipe\")
        || address.contains('\0')
        || home_dir.contains('\0')
        || !Path::new(&home_dir).is_absolute()
        || expected_sha256.len() != 64
        || !expected_sha256.bytes().all(|b| b.is_ascii_hexdigit())
    {
        return Err("Invalid Windows launch parameters".into());
    }
    let active = ACTIVE.lock().map_err(|_| "Windows launch lock poisoned")?;
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
        .map_err(|_| "Windows event lock poisoned")? = Some(emit);
    drop(active);
    let worker_ticket = ticket.clone();
    if let Err(error) = std::thread::Builder::new()
        .name("windows-core-launch".into())
        .spawn(move || {
            let result = run(&worker_ticket, &address, &home_dir, &expected_sha256);
            if let Err(error) = result {
                worker_ticket.revoke();
                let code = if error.raw_os_error() == Some(ERROR_CANCELLED as i32) {
                    "windows_launch_cancelled".to_owned()
                } else {
                    error.to_string()
                };
                worker_ticket.event("error", code);
            }
            if let Some(process) = worker_ticket.process() {
                let result = unsafe { WaitForSingleObject(process.as_raw_handle(), INFINITE) };
                if result != WAIT_OBJECT_0 {
                    worker_ticket.event("error", "Windows Core exit could not be confirmed");
                    return;
                }
            }
            if worker_ticket.process().is_none() {
                worker_ticket.started.store(false, Ordering::Release);
            }
            if let Err(error) = release_finished(&worker_ticket) {
                worker_ticket.event("error", error);
                return;
            }
            worker_ticket.event("exited", "");
        })
    {
        let mut active = ACTIVE.lock().map_err(|_| "Windows launch lock poisoned")?;
        *active = None;
        return Err(error.to_string());
    }
    Ok(())
}

fn run(ticket: &Ticket, address: &str, home_dir: &str, expected_sha256: &str) -> io::Result<()> {
    let executable = std::env::current_exe()?
        .parent()
        .ok_or_else(|| io::Error::other("Missing executable directory"))?
        .join("ReClashCore.exe");
    let image = ImageLock::open(&executable, expected_sha256)?;
    let own_pid = std::process::id();
    let own_session = process_session(own_pid)?;
    let own_created = creation_time(unsafe { GetCurrentProcess() })?;
    let sid = own_sid()?;
    let name = format!(
        r"\\.\pipe\ReClash.bootstrap.{own_pid}.{}",
        ticket.session_id
    );
    let pipe = BootstrapPipe::create(&name, &sid)?;
    {
        let _commit = ticket.commit.lock().unwrap_or_else(|e| e.into_inner());
        if ticket.revoked.load(Ordering::Acquire) {
            return Err(io::Error::other("windows_launch_cancelled"));
        }
        *ticket.access.lock().unwrap_or_else(|e| e.into_inner()) =
            Some(ProcessAccess::grant_admin_handoff()?);
    }
    if ticket.revoked.load(Ordering::Acquire) {
        return Err(io::Error::other("windows_launch_cancelled"));
    }
    let process = Arc::new(shell_launch(
        &image.path,
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
    *ticket.process.lock().unwrap_or_else(|e| e.into_inner()) = Some(process.clone());
    let pid = unsafe { GetProcessId(process.as_raw_handle()) };
    if pid == 0 {
        return Err(io::Error::last_os_error());
    }
    ticket.event("spawned", pid);
    let deadline = Instant::now() + Duration::from_secs(10);
    pipe.connect(&ticket.revoked, deadline)?;
    pipe.verify_client(pid, own_session)?;
    let mut hello = [0; 16];
    pipe.read(&mut hello, &ticket.revoked, deadline)?;
    if &hello[..8] != b"RCXWIN01"
        || u64::from_le_bytes(hello[8..].try_into().unwrap())
            != creation_time(process.as_raw_handle())?
        || unsafe { WaitForSingleObject(process.as_raw_handle(), 0) } != WAIT_TIMEOUT
    {
        return Err(io::Error::other("Invalid Windows bootstrap greeting"));
    }
    pipe.verify_elevation()?;
    pipe.write(&(ticket.job.as_raw_handle() as usize as u64).to_le_bytes())?;
    let mut joined = [0; 8];
    pipe.read(&mut joined, &ticket.revoked, deadline)?;
    if &joined != b"RCXJOIN1" {
        return Err(io::Error::other("Windows Core did not join its job"));
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
        return Err(io::Error::other("Windows Core job mismatch"));
    }
    ticket.restore_access()?;
    ticket.commit_bootstrap(|| pipe.write(b"RCXGO001"))?;
    ticket.event("ready", pid);
    Ok(())
}

fn release_finished(ticket: &Arc<Ticket>) -> io::Result<bool> {
    if !ticket.wait_exit(Duration::ZERO)? {
        return Ok(false);
    }
    ticket.restore_access()?;
    let mut active = ACTIVE
        .lock()
        .map_err(|_| io::Error::other("Windows launch lock poisoned"))?;
    if active
        .as_ref()
        .is_some_and(|current| Arc::ptr_eq(current, ticket))
    {
        *active = None;
    }
    Ok(true)
}

pub fn cancel(session_id: &str) -> Result<bool, String> {
    let ticket = ACTIVE
        .lock()
        .map_err(|_| "Windows launch lock poisoned")?
        .as_ref()
        .filter(|ticket| ticket.session_id == session_id)
        .cloned();
    let Some(ticket) = ticket else {
        return Ok(true);
    };
    ticket.revoke();
    ticket.restore_access().map_err(|e| e.to_string())?;
    release_finished(&ticket).map_err(|e| e.to_string())
}

pub fn stop(session_id: &str, timeout_millis: u32) -> Result<bool, String> {
    let active = ACTIVE
        .lock()
        .map_err(|_| "Windows launch lock poisoned")?
        .clone();
    let Some(ticket) = active.filter(|ticket| ticket.session_id == session_id) else {
        return Ok(true);
    };
    ticket.revoke();
    ticket.restore_access().map_err(|e| e.to_string())?;
    if !ticket
        .wait_exit(Duration::from_millis(timeout_millis.into()))
        .map_err(|e| e.to_string())?
    {
        return Ok(false);
    }
    release_finished(&ticket).map_err(|e| e.to_string())
}

pub fn authorize_rpc_peer(pid: u32) -> io::Result<()> {
    let active = ACTIVE
        .lock()
        .map_err(|_| io::Error::other("Windows launch lock poisoned"))?
        .clone();
    let Some(ticket) = active else {
        return Ok(());
    };
    let Some(process) = ticket.process() else {
        return Err(io::Error::other("Windows Core launch is pending"));
    };
    if ticket.revoked.load(Ordering::Acquire)
        || !ticket.committed.load(Ordering::Acquire)
        || unsafe { GetProcessId(process.as_raw_handle()) } != pid
        || unsafe { WaitForSingleObject(process.as_raw_handle(), 0) } != WAIT_TIMEOUT
    {
        return Err(io::Error::other("Windows Core IPC peer mismatch"));
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
            && ticket
                .process()
                .is_some_and(|process| unsafe { GetProcessId(process.as_raw_handle()) } == pid)
    })
}
