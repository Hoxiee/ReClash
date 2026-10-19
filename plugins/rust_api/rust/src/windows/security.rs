use std::ffi::c_void;
use std::io;
use std::mem::{size_of, zeroed};
use std::os::windows::io::{AsRawHandle, FromRawHandle, OwnedHandle};
use std::ptr::{null, null_mut};
use windows_sys::Win32::Foundation::*;
use windows_sys::Win32::Security::Authorization::*;
use windows_sys::Win32::Security::*;
use windows_sys::Win32::Storage::FileSystem::{READ_CONTROL, WRITE_DAC};
use windows_sys::Win32::System::RemoteDesktop::ProcessIdToSessionId;
use windows_sys::Win32::System::Threading::*;

pub fn wide(value: &str) -> Vec<u16> {
    value.encode_utf16().chain(Some(0)).collect()
}

pub fn check(result: i32) -> io::Result<()> {
    if result == 0 {
        Err(io::Error::last_os_error())
    } else {
        Ok(())
    }
}

pub fn owned(handle: HANDLE) -> io::Result<OwnedHandle> {
    if handle.is_null() || handle == INVALID_HANDLE_VALUE {
        return Err(io::Error::last_os_error());
    }
    Ok(unsafe { OwnedHandle::from_raw_handle(handle) })
}

pub struct LocalMemory(pub *mut c_void);

impl Drop for LocalMemory {
    fn drop(&mut self) {
        if !self.0.is_null() {
            unsafe { LocalFree(self.0) };
        }
    }
}

pub fn security_descriptor(sddl: &str) -> io::Result<LocalMemory> {
    let mut descriptor = null_mut();
    check(unsafe {
        ConvertStringSecurityDescriptorToSecurityDescriptorW(
            wide(sddl).as_ptr(),
            SDDL_REVISION_1,
            &mut descriptor,
            null_mut(),
        )
    })?;
    Ok(LocalMemory(descriptor))
}

pub fn process_token(process: HANDLE) -> io::Result<OwnedHandle> {
    let mut token = null_mut();
    check(unsafe { OpenProcessToken(process, TOKEN_QUERY, &mut token) })?;
    owned(token)
}

pub fn token_elevated(token: HANDLE) -> io::Result<bool> {
    let mut info: TOKEN_ELEVATION = unsafe { zeroed() };
    let mut size = 0;
    check(unsafe {
        GetTokenInformation(
            token,
            TokenElevation,
            (&mut info as *mut TOKEN_ELEVATION).cast(),
            size_of::<TOKEN_ELEVATION>() as u32,
            &mut size,
        )
    })?;
    Ok(info.TokenIsElevated != 0)
}

pub fn is_elevated() -> io::Result<bool> {
    let token = process_token(unsafe { GetCurrentProcess() })?;
    token_elevated(token.as_raw_handle())
}

pub fn token_sid(token: HANDLE) -> io::Result<String> {
    let mut size = 0;
    unsafe { GetTokenInformation(token, TokenUser, null_mut(), 0, &mut size) };
    if size == 0 || size > 65536 {
        return Err(io::Error::other("windows_invalid_token_user"));
    }
    let mut buffer = vec![0usize; (size as usize).div_ceil(size_of::<usize>())];
    check(unsafe {
        GetTokenInformation(
            token,
            TokenUser,
            buffer.as_mut_ptr().cast(),
            size,
            &mut size,
        )
    })?;
    let user = unsafe { &*buffer.as_ptr().cast::<TOKEN_USER>() };
    let mut string = null_mut();
    check(unsafe { ConvertSidToStringSidW(user.User.Sid, &mut string) })?;
    let _memory = LocalMemory(string.cast());
    let mut length = 0;
    while length < 256 && unsafe { *string.add(length) } != 0 {
        length += 1;
    }
    if length == 256 {
        return Err(io::Error::other("windows_invalid_sid"));
    }
    String::from_utf16(unsafe { std::slice::from_raw_parts(string, length) })
        .map_err(|_| io::Error::other("windows_invalid_sid"))
}

#[derive(Clone, Debug, PartialEq, Eq)]
pub struct TokenIdentity {
    pub sid: String,
    pub authentication: u64,
    pub session: u32,
    pub elevated: bool,
}

pub fn token_identity(token: HANDLE) -> io::Result<TokenIdentity> {
    let mut stats: TOKEN_STATISTICS = unsafe { zeroed() };
    let mut size = 0;
    check(unsafe {
        GetTokenInformation(
            token,
            TokenStatistics,
            (&mut stats as *mut TOKEN_STATISTICS).cast(),
            size_of::<TOKEN_STATISTICS>() as u32,
            &mut size,
        )
    })?;
    let mut session = 0u32;
    check(unsafe {
        GetTokenInformation(
            token,
            TokenSessionId,
            (&mut session as *mut u32).cast(),
            size_of::<u32>() as u32,
            &mut size,
        )
    })?;
    Ok(TokenIdentity {
        sid: token_sid(token)?,
        authentication: (u64::from(stats.AuthenticationId.HighPart as u32) << 32)
            | u64::from(stats.AuthenticationId.LowPart),
        session,
        elevated: token_elevated(token)?,
    })
}

pub fn process_identity(process: HANDLE) -> io::Result<TokenIdentity> {
    let token = process_token(process)?;
    token_identity(token.as_raw_handle())
}

pub fn own_sid() -> io::Result<String> {
    Ok(process_identity(unsafe { GetCurrentProcess() })?.sid)
}

pub fn creation_time(process: HANDLE) -> io::Result<u64> {
    let mut created = FILETIME::default();
    let mut exited = FILETIME::default();
    let mut kernel = FILETIME::default();
    let mut user = FILETIME::default();
    check(unsafe { GetProcessTimes(process, &mut created, &mut exited, &mut kernel, &mut user) })?;
    Ok((u64::from(created.dwHighDateTime) << 32) | u64::from(created.dwLowDateTime))
}

pub fn process_session(pid: u32) -> io::Result<u32> {
    let mut session = 0;
    check(unsafe { ProcessIdToSessionId(pid, &mut session) })?;
    Ok(session)
}

struct ObjectAccess {
    handle: HANDLE,
    _descriptor: LocalMemory,
    original_acl: *mut ACL,
    protection: u32,
    restored: bool,
}

impl ObjectAccess {
    fn capture(handle: HANDLE) -> io::Result<Self> {
        let mut acl = null_mut();
        let mut descriptor = null_mut();
        let result = unsafe {
            GetSecurityInfo(
                handle,
                SE_KERNEL_OBJECT,
                DACL_SECURITY_INFORMATION,
                null_mut(),
                null_mut(),
                &mut acl,
                null_mut(),
                &mut descriptor,
            )
        };
        if result != ERROR_SUCCESS {
            return Err(io::Error::from_raw_os_error(result as i32));
        }
        let memory = LocalMemory(descriptor);
        let mut control = 0;
        let mut revision = 0;
        check(unsafe { GetSecurityDescriptorControl(descriptor, &mut control, &mut revision) })?;
        Ok(Self {
            handle,
            _descriptor: memory,
            original_acl: acl,
            protection: if control & SE_DACL_PROTECTED != 0 {
                PROTECTED_DACL_SECURITY_INFORMATION
            } else {
                UNPROTECTED_DACL_SECURITY_INFORMATION
            },
            restored: true,
        })
    }

    fn grant(&mut self, permissions: u32) -> io::Result<()> {
        if self.original_acl.is_null() {
            return Ok(());
        }
        let mut admin_sid = null_mut();
        check(unsafe { ConvertStringSidToSidW(wide("S-1-5-32-544").as_ptr(), &mut admin_sid) })?;
        let _sid = LocalMemory(admin_sid);
        let entry = EXPLICIT_ACCESS_W {
            grfAccessPermissions: permissions,
            grfAccessMode: GRANT_ACCESS,
            grfInheritance: 0,
            Trustee: TRUSTEE_W {
                TrusteeForm: TRUSTEE_IS_SID,
                TrusteeType: TRUSTEE_IS_GROUP,
                ptstrName: admin_sid.cast(),
                ..Default::default()
            },
        };
        let mut new_acl = null_mut();
        let result = unsafe { SetEntriesInAclW(1, &entry, self.original_acl, &mut new_acl) };
        if result != ERROR_SUCCESS {
            return Err(io::Error::from_raw_os_error(result as i32));
        }
        let _new_acl = LocalMemory(new_acl.cast());
        self.restored = false;
        let result = unsafe {
            SetSecurityInfo(
                self.handle,
                SE_KERNEL_OBJECT,
                DACL_SECURITY_INFORMATION | self.protection,
                null_mut(),
                null_mut(),
                new_acl,
                null(),
            )
        };
        if result != ERROR_SUCCESS {
            return Err(io::Error::from_raw_os_error(result as i32));
        }
        Ok(())
    }

    fn restore(&mut self) -> io::Result<()> {
        if self.restored {
            return Ok(());
        }
        let result = unsafe {
            SetSecurityInfo(
                self.handle,
                SE_KERNEL_OBJECT,
                DACL_SECURITY_INFORMATION | self.protection,
                null_mut(),
                null_mut(),
                self.original_acl,
                null(),
            )
        };
        if result != ERROR_SUCCESS {
            return Err(io::Error::from_raw_os_error(result as i32));
        }
        self.restored = true;
        Ok(())
    }
}

impl Drop for ObjectAccess {
    fn drop(&mut self) {
        let _ = self.restore();
    }
}

pub struct ProcessAccess {
    process: ObjectAccess,
    token: ObjectAccess,
    _token_handle: OwnedHandle,
}

// Descriptors own their LocalAlloc storage; the ticket serializes mutation.
unsafe impl Send for ProcessAccess {}

impl ProcessAccess {
    pub fn capture() -> io::Result<Self> {
        let process = ObjectAccess::capture(unsafe { GetCurrentProcess() })?;
        let mut token = null_mut();
        check(unsafe {
            OpenProcessToken(
                GetCurrentProcess(),
                TOKEN_QUERY | READ_CONTROL | WRITE_DAC,
                &mut token,
            )
        })?;
        let token_handle = owned(token)?;
        let token = ObjectAccess::capture(token_handle.as_raw_handle())?;
        Ok(Self {
            process,
            token,
            _token_handle: token_handle,
        })
    }

    pub fn grant_admin_handoff(&mut self) -> io::Result<()> {
        self.process
            .grant(PROCESS_DUP_HANDLE | PROCESS_QUERY_LIMITED_INFORMATION | PROCESS_SYNCHRONIZE)?;
        self.token.grant(TOKEN_QUERY)
    }

    pub fn restore(&mut self) -> io::Result<()> {
        let token = self.token.restore();
        let process = self.process.restore();
        token.and(process)
    }
}
