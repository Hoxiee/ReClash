use super::*;
use std::io::{BufRead, BufReader, Write};
use std::os::windows::fs::OpenOptionsExt;
use std::os::windows::io::AsRawHandle;
use std::process::{Command, Stdio};
use windows_sys::Win32::Security::Authorization::*;
use windows_sys::Win32::Security::*;

const SESSION: &str = "0123456789abcdef0123456789abcdef";
static SERIAL: Mutex<()> = Mutex::new(());

fn ticket() -> Arc<Ticket> {
    prepare(SESSION.into()).unwrap();
    ACTIVE.lock().unwrap().as_ref().unwrap().clone()
}

#[test]
fn quotes_round_trip_through_windows_argv() {
    let arguments = [
        "",
        "plain",
        "with spaces",
        "a\"b",
        "C:\\space here\\",
        "кириллица",
        "\\\\server\\path",
    ];
    let command = wide(&format!(
        "program.exe {}",
        arguments
            .iter()
            .map(|arg| quote(arg))
            .collect::<Vec<_>>()
            .join(" ")
    ));
    let mut count = 0;
    let argv = unsafe { CommandLineToArgvW(command.as_ptr(), &mut count) };
    assert!(!argv.is_null());
    let _memory = LocalMemory(argv.cast());
    assert_eq!(count as usize, arguments.len() + 1);
    for (index, expected) in arguments.iter().enumerate() {
        let ptr = unsafe { *argv.add(index + 1) };
        let mut length = 0;
        while unsafe { *ptr.add(length) } != 0 {
            length += 1;
        }
        let actual = String::from_utf16_lossy(unsafe { std::slice::from_raw_parts(ptr, length) });
        assert_eq!(&actual, expected);
    }
}

#[test]
fn cancel_before_start_releases_the_ticket_and_rejects_late_start() {
    let _serial = SERIAL.lock().unwrap();
    let _ticket = ticket();
    assert!(prepare(SESSION.into()).is_err());
    assert!(cancel("another-session").unwrap());
    assert!(ACTIVE.lock().unwrap().is_some());
    assert!(cancel(SESSION).unwrap());
    assert!(ACTIVE.lock().unwrap().is_none());
    assert!(start(
        SESSION.into(),
        r"\\.\pipe\ReClashCore_test".into(),
        r"C:\Users\test".into(),
        "a".repeat(64),
        Arc::new(|_| true)
    )
    .is_err());
}

#[test]
fn a_pending_shell_result_keeps_ownership_after_cancel() {
    let _serial = SERIAL.lock().unwrap();
    let ticket = ticket();
    ticket.started.store(true, Ordering::Release);
    assert!(!cancel(SESSION).unwrap());
    assert!(!stop(SESSION, 0).unwrap());
    assert!(prepare("abcdef0123456789abcdef0123456789ab".into()).is_err());
    assert!(ACTIVE.lock().unwrap().is_some());
    ticket.started.store(false, Ordering::Release);
    assert!(release_finished(&ticket).unwrap());
}

#[test]
fn cancellation_prevents_commit_and_rpc_admission() {
    let _serial = SERIAL.lock().unwrap();
    let ticket = ticket();
    let handle = owned(unsafe {
        OpenProcess(
            PROCESS_QUERY_LIMITED_INFORMATION | PROCESS_SYNCHRONIZE,
            0,
            std::process::id(),
        )
    })
    .unwrap();
    *ticket.process.lock().unwrap() = Some(Arc::new(handle));
    assert!(authorize_rpc_peer(std::process::id()).is_err());
    ticket.commit_bootstrap(|| Ok(())).unwrap();
    assert!(authorize_rpc_peer(std::process::id()).is_ok());
    assert!(authorize_rpc_peer(std::process::id() + 1).is_err());
    assert!(!cancel(SESSION).unwrap());
    assert!(!is_managed_peer(std::process::id()));
    assert!(authorize_rpc_peer(std::process::id()).is_err());
    assert!(ticket
        .commit_bootstrap(|| panic!("revoked commit must not send"))
        .is_err());
    *ticket.process.lock().unwrap() = None;
    assert!(release_finished(&ticket).unwrap());
}

fn dacl(handle: HANDLE) -> String {
    let mut descriptor = std::ptr::null_mut();
    let status = unsafe {
        GetSecurityInfo(
            handle,
            SE_KERNEL_OBJECT,
            DACL_SECURITY_INFORMATION,
            std::ptr::null_mut(),
            std::ptr::null_mut(),
            std::ptr::null_mut(),
            std::ptr::null_mut(),
            &mut descriptor,
        )
    };
    assert_eq!(status, ERROR_SUCCESS);
    let _descriptor = LocalMemory(descriptor);
    let mut text = std::ptr::null_mut();
    check(unsafe {
        ConvertSecurityDescriptorToStringSecurityDescriptorW(
            descriptor,
            SDDL_REVISION_1,
            DACL_SECURITY_INFORMATION,
            &mut text,
            std::ptr::null_mut(),
        )
    })
    .unwrap();
    let _text = LocalMemory(text.cast());
    let mut length = 0;
    while unsafe { *text.add(length) } != 0 {
        length += 1;
    }
    String::from_utf16_lossy(unsafe { std::slice::from_raw_parts(text, length) })
}

#[test]
fn handoff_restores_both_process_and_token_dacls() {
    let _serial = SERIAL.lock().unwrap();
    let process = unsafe { GetCurrentProcess() };
    let mut token = std::ptr::null_mut();
    check(unsafe { OpenProcessToken(process, TOKEN_QUERY | READ_CONTROL, &mut token) }).unwrap();
    let token = owned(token).unwrap();
    let process_before = dacl(process);
    let token_before = dacl(token.as_raw_handle());
    {
        let mut access = ProcessAccess::grant_admin_handoff().unwrap();
        access.restore().unwrap();
        access.restore().unwrap();
    }
    assert_eq!(dacl(process), process_before);
    assert_eq!(dacl(token.as_raw_handle()), token_before);
    {
        let _access = ProcessAccess::grant_admin_handoff().unwrap();
    }
    assert_eq!(dacl(process), process_before);
    assert_eq!(dacl(token.as_raw_handle()), token_before);
}

#[test]
fn bootstrap_pipe_rejects_another_server_and_honors_revocation() {
    let name = format!(r"\\.\pipe\ReClash.test.{}", std::process::id());
    let pipe = BootstrapPipe::create(&name, &own_sid().unwrap()).unwrap();
    assert!(BootstrapPipe::create(&name, &own_sid().unwrap()).is_err());
    assert!(pipe
        .connect(
            &AtomicBool::new(true),
            Instant::now() + Duration::from_secs(5)
        )
        .is_err());
    assert!(pipe
        .connect(&AtomicBool::new(false), Instant::now())
        .is_err());
}

#[test]
fn bootstrap_checks_kernel_peer_and_identification_only_token() {
    let name = format!(r"\\.\pipe\ReClash.peer-test.{}", std::process::id());
    for qos in [
        SECURITY_IDENTIFICATION,
        SECURITY_ANONYMOUS,
        SECURITY_IMPERSONATION,
    ] {
        let pipe = BootstrapPipe::create(&name, &own_sid().unwrap()).unwrap();
        let mut client = std::fs::OpenOptions::new()
            .access_mode(FILE_READ_DATA | FILE_WRITE_DATA | SYNCHRONIZE)
            .security_qos_flags(qos)
            .open(&name)
            .unwrap();
        let revoked = AtomicBool::new(false);
        let deadline = Instant::now() + Duration::from_secs(2);
        pipe.connect(&revoked, deadline).unwrap();
        client.write_all(b"hello").unwrap();
        let mut hello = [0; 5];
        pipe.read(&mut hello, &revoked, deadline).unwrap();
        let pid = std::process::id();
        let session = process_session(pid).unwrap();
        pipe.verify_client(pid, session).unwrap();
        assert!(pipe.verify_client(pid + 1, session).is_err());
        assert!(pipe.verify_client(pid, session + 1).is_err());
        assert_eq!(
            pipe.verify_elevation().is_ok(),
            qos == SECURITY_IDENTIFICATION && is_elevated().unwrap()
        );
    }
}

#[test]
fn job_child() {
    if std::env::var_os("RECLASH_JOB_TEST_CHILD").is_none() {
        return;
    }
    println!("ready");
    std::thread::sleep(Duration::from_secs(30));
}

#[test]
fn last_job_handle_kills_child_without_a_terminate_process_handle() {
    let mut child = Command::new(std::env::current_exe().unwrap())
        .args(["--exact", "windows::tests::job_child", "--nocapture"])
        .env("RECLASH_JOB_TEST_CHILD", "1")
        .stdout(Stdio::piped())
        .spawn()
        .unwrap();
    let mut output = BufReader::new(child.stdout.take().unwrap());
    let mut line = String::new();
    while !line.contains("ready") {
        line.clear();
        assert_ne!(output.read_line(&mut line).unwrap(), 0);
    }
    let observer = owned(unsafe {
        OpenProcess(
            PROCESS_QUERY_LIMITED_INFORMATION | PROCESS_SYNCHRONIZE,
            0,
            child.id(),
        )
    })
    .unwrap();
    let job = create_job().unwrap();
    check(unsafe { AssignProcessToJobObject(job.as_raw_handle(), child.as_raw_handle()) }).unwrap();
    assert!(child.try_wait().unwrap().is_none());
    drop(job);
    assert_eq!(
        unsafe { WaitForSingleObject(observer.as_raw_handle(), 5000) },
        WAIT_OBJECT_0
    );
    // The 5s wait against the 30s sleep already proves the kill; the
    // job-close exit code reads as success on CI, so it cannot prove it.
    child.wait().unwrap();
}
