use super::contract::quote;
use super::*;
use std::fs::OpenOptions;
use std::io::{BufRead, BufReader, Write};
use std::os::windows::fs::OpenOptionsExt;
use std::os::windows::io::AsRawHandle;
use std::process::{Command, Stdio};
use std::sync::atomic::{AtomicBool, Ordering};
use std::sync::{Arc, Mutex};
use std::time::{Duration, Instant};
use windows_sys::Win32::Foundation::*;
use windows_sys::Win32::Security::Authorization::*;
use windows_sys::Win32::Security::*;
use windows_sys::Win32::Storage::FileSystem::*;
use windows_sys::Win32::System::JobObjects::*;
use windows_sys::Win32::System::Threading::*;
use windows_sys::Win32::UI::Shell::*;

const SESSION: &str = "0123456789abcdef0123456789abcdef";
static SERIAL: Mutex<()> = Mutex::new(());

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
        assert_eq!(
            String::from_utf16_lossy(unsafe { std::slice::from_raw_parts(ptr, length) }),
            *expected
        );
    }
}

#[test]
fn cancel_before_start_rejects_a_late_worker_without_losing_a_new_session() {
    let _serial = SERIAL.lock().unwrap();
    prepare(SESSION.into()).unwrap();
    assert!(prepare(SESSION.into()).is_err());
    assert!(cancel("aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa").unwrap());
    assert!(cancel(SESSION).unwrap());
    assert!(start(
        SESSION.into(),
        format!(r"\\.\pipe\ReClashCore_{SESSION}"),
        r"C:\Users\test".into(),
        "a".repeat(64),
        Arc::new(|_| true)
    )
    .is_err());
    prepare("aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa".into()).unwrap();
    assert!(cancel(SESSION).unwrap());
    assert!(prepare(SESSION.into()).is_err());
    assert!(cancel("aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa").unwrap());
}

#[test]
fn pending_shell_and_worker_cleanup_keep_the_active_ticket() {
    let _serial = SERIAL.lock().unwrap();
    prepare(SESSION.into()).unwrap();
    let ticket = ACTIVE.lock().unwrap().as_ref().unwrap().clone();
    ticket.started.store(true, Ordering::Release);
    assert!(!cancel(SESSION).unwrap());
    assert!(!stop(SESSION, 0).unwrap());
    assert!(prepare("aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa".into()).is_err());
    ticket.finish_worker();
    assert!(stop(SESSION, 0).unwrap());
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
fn handoff_restores_process_and_token_on_success_and_drop() {
    let _serial = SERIAL.lock().unwrap();
    let process = unsafe { GetCurrentProcess() };
    let mut token = std::ptr::null_mut();
    check(unsafe { OpenProcessToken(process, TOKEN_QUERY | READ_CONTROL, &mut token) }).unwrap();
    let token = owned(token).unwrap();
    let process_before = dacl(process);
    let token_before = dacl(token.as_raw_handle());
    for explicit in [true, false] {
        {
            let mut access = ProcessAccess::capture().unwrap();
            access.grant_admin_handoff().unwrap();
            if explicit {
                access.restore().unwrap();
                access.restore().unwrap();
            }
        }
        assert_eq!(dacl(process), process_before);
        assert_eq!(dacl(token.as_raw_handle()), token_before);
    }
}

#[test]
fn bootstrap_pipe_rejects_duplicate_server_revocation_and_stale_deadline() {
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
fn bootstrap_verifies_launched_token_not_original_app_sid() {
    let name = format!(r"\\.\pipe\ReClash.peer-test.{}", std::process::id());
    for qos in [
        SECURITY_IDENTIFICATION,
        SECURITY_ANONYMOUS,
        SECURITY_IMPERSONATION,
    ] {
        let pipe = BootstrapPipe::create(&name, &own_sid().unwrap()).unwrap();
        let mut client = OpenOptions::new()
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
        let expected = process_identity(unsafe { GetCurrentProcess() }).unwrap();
        assert_eq!(
            pipe.verify_token(&expected).is_ok(),
            qos == SECURITY_IDENTIFICATION && expected.elevated
        );
        let mut wrong = expected;
        wrong.sid = "S-1-5-18".into();
        wrong.authentication ^= 1;
        assert!(pipe.verify_token(&wrong).is_err());
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
fn last_job_handle_kills_only_the_spawned_child() {
    let mut child = Command::new(std::env::current_exe().unwrap())
        .args([
            "--exact",
            "windows::launch::tests::job_child",
            "--nocapture",
        ])
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
    child.wait().unwrap();
}
