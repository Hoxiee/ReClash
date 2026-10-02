use super::security::*;
use std::io;
use std::os::windows::io::{AsRawHandle, OwnedHandle};
use std::ptr::null_mut;
use std::sync::atomic::{AtomicBool, Ordering};
use std::time::{Duration, Instant};
use windows_sys::Win32::Foundation::*;
use windows_sys::Win32::Security::*;
use windows_sys::Win32::Storage::FileSystem::*;
use windows_sys::Win32::System::Pipes::*;
use windows_sys::Win32::System::Threading::{GetCurrentThread, OpenThreadToken};

pub struct BootstrapPipe(OwnedHandle);

impl BootstrapPipe {
    pub fn create(name: &str, sid: &str) -> io::Result<Self> {
        // Generic write includes CREATE_PIPE_INSTANCE, so clients request data rights explicitly.
        let descriptor =
            security_descriptor(&format!("D:P(A;;0x12019b;;;{sid})(A;;0x12019b;;;BA)"))?;
        let attributes = SECURITY_ATTRIBUTES {
            nLength: std::mem::size_of::<SECURITY_ATTRIBUTES>() as u32,
            lpSecurityDescriptor: descriptor.0,
            bInheritHandle: 0,
        };
        let handle = owned(unsafe {
            CreateNamedPipeW(
                wide(name).as_ptr(),
                PIPE_ACCESS_DUPLEX | FILE_FLAG_FIRST_PIPE_INSTANCE,
                PIPE_TYPE_BYTE | PIPE_READMODE_BYTE | PIPE_NOWAIT | PIPE_REJECT_REMOTE_CLIENTS,
                1,
                256,
                256,
                0,
                &attributes,
            )
        })?;
        Ok(Self(handle))
    }

    fn wait(revoked: &AtomicBool, deadline: Instant) -> io::Result<()> {
        if revoked.load(Ordering::Acquire) {
            return Err(io::Error::other("windows_launch_cancelled"));
        }
        if Instant::now() >= deadline {
            return Err(io::Error::new(
                io::ErrorKind::TimedOut,
                "Windows bootstrap timed out",
            ));
        }
        std::thread::sleep(Duration::from_millis(10));
        Ok(())
    }

    pub fn connect(&self, revoked: &AtomicBool, deadline: Instant) -> io::Result<()> {
        loop {
            let connected = unsafe { ConnectNamedPipe(self.0.as_raw_handle(), null_mut()) };
            if connected != 0 {
                return Ok(());
            }
            match unsafe { GetLastError() } {
                ERROR_PIPE_CONNECTED => return Ok(()),
                ERROR_PIPE_LISTENING | ERROR_NO_DATA => Self::wait(revoked, deadline)?,
                _ => return Err(io::Error::last_os_error()),
            }
        }
    }

    pub fn verify_client(&self, pid: u32, session: u32) -> io::Result<()> {
        let mut actual_pid = 0;
        let mut actual_session = 0;
        check(unsafe { GetNamedPipeClientProcessId(self.0.as_raw_handle(), &mut actual_pid) })?;
        check(unsafe { GetNamedPipeClientSessionId(self.0.as_raw_handle(), &mut actual_session) })?;
        if actual_pid != pid || actual_session != session {
            return Err(io::Error::other("Windows bootstrap peer mismatch"));
        }
        Ok(())
    }

    pub fn verify_elevation(&self) -> io::Result<()> {
        check(unsafe { ImpersonateNamedPipeClient(self.0.as_raw_handle()) })?;
        struct Revert;
        impl Drop for Revert {
            fn drop(&mut self) {
                unsafe {
                    RevertToSelf();
                }
            }
        }
        let _revert = Revert;
        let mut token = null_mut();
        check(unsafe { OpenThreadToken(GetCurrentThread(), TOKEN_QUERY, 1, &mut token) })?;
        let token = owned(token)?;
        if !token_elevated(token.as_raw_handle())? {
            return Err(io::Error::other("Windows Core is not elevated"));
        }
        let mut level = 0i32;
        let mut size = 0;
        check(unsafe {
            GetTokenInformation(
                token.as_raw_handle(),
                TokenImpersonationLevel,
                (&mut level as *mut i32).cast(),
                4,
                &mut size,
            )
        })?;
        if level != SecurityIdentification {
            return Err(io::Error::other("Unsafe Windows pipe impersonation level"));
        }
        Ok(())
    }

    pub fn read(
        &self,
        output: &mut [u8],
        revoked: &AtomicBool,
        deadline: Instant,
    ) -> io::Result<()> {
        let mut offset = 0;
        while offset < output.len() {
            Self::wait(revoked, deadline)?;
            let mut available = 0;
            check(unsafe {
                PeekNamedPipe(
                    self.0.as_raw_handle(),
                    null_mut(),
                    0,
                    null_mut(),
                    &mut available,
                    null_mut(),
                )
            })?;
            if available == 0 {
                continue;
            }
            let mut read = 0;
            check(unsafe {
                ReadFile(
                    self.0.as_raw_handle(),
                    output[offset..].as_mut_ptr(),
                    (output.len() - offset) as u32,
                    &mut read,
                    null_mut(),
                )
            })?;
            if read == 0 {
                return Err(io::Error::new(
                    io::ErrorKind::UnexpectedEof,
                    "bootstrap pipe closed",
                ));
            }
            offset += read as usize;
        }
        Ok(())
    }

    pub fn write(&self, bytes: &[u8]) -> io::Result<()> {
        let mut written = 0;
        check(unsafe {
            WriteFile(
                self.0.as_raw_handle(),
                bytes.as_ptr(),
                bytes.len() as u32,
                &mut written,
                null_mut(),
            )
        })?;
        if written as usize != bytes.len() {
            return Err(io::Error::new(
                io::ErrorKind::WriteZero,
                "short bootstrap write",
            ));
        }
        Ok(())
    }
}
