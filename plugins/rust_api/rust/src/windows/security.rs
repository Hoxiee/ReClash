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
            unsafe {
                LocalFree(self.0);
            }
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
    unsafe {
        GetTokenInformation(token, TokenUser, null_mut(), 0, &mut size);
    }
    if size == 0 {
        return Err(io::Error::last_os_error());
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
        return Err(io::Error::other("invalid SID string"));
    }
    Ok(String::from_utf16_lossy(unsafe {
        std::slice::from_raw_parts(string, length)
    }))
}

pub fn own_sid() -> io::Result<String> {
    let token = process_token(unsafe { GetCurrentProcess() })?;
    token_sid(token.as_raw_handle())
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
    restored: bool,
}

impl ObjectAccess {
    fn grant(handle: HANDLE, permissions: u32) -> io::Result<Self> {
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
        if result != 0 {
            return Err(io::Error::from_raw_os_error(result as i32));
        }
        let mut guard = Self {
            handle,
            _descriptor: LocalMemory(descriptor),
            original_acl: acl,
            restored: false,
        };
        if acl.is_null() {
            guard.restored = true;
            return Ok(guard);
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
        let result = unsafe { SetEntriesInAclW(1, &entry, acl, &mut new_acl) };
        if result != 0 {
            return Err(io::Error::from_raw_os_error(result as i32));
        }
        let _new_acl = LocalMemory(new_acl.cast());
        let result = unsafe {
            SetSecurityInfo(
                handle,
                SE_KERNEL_OBJECT,
                DACL_SECURITY_INFORMATION,
                null_mut(),
                null_mut(),
                new_acl,
                null(),
            )
        };
        if result != 0 {
            return Err(io::Error::from_raw_os_error(result as i32));
        }
        Ok(guard)
    }

    fn restore(&mut self) -> io::Result<()> {
        if self.restored {
            return Ok(());
        }
        let result = unsafe {
            SetSecurityInfo(
                self.handle,
                SE_KERNEL_OBJECT,
                DACL_SECURITY_INFORMATION,
                null_mut(),
                null_mut(),
                self.original_acl,
                null(),
            )
        };
        if result != 0 {
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

// The descriptors own their LocalAlloc storage; callers serialize access through a mutex.
unsafe impl Send for ProcessAccess {}

impl ProcessAccess {
    pub fn grant_admin_handoff() -> io::Result<Self> {
        let process = ObjectAccess::grant(
            unsafe { GetCurrentProcess() },
            PROCESS_DUP_HANDLE | PROCESS_QUERY_LIMITED_INFORMATION | PROCESS_SYNCHRONIZE,
        )?;
        let mut token = null_mut();
        check(unsafe {
            OpenProcessToken(
                GetCurrentProcess(),
                TOKEN_QUERY | READ_CONTROL | WRITE_DAC,
                &mut token,
            )
        })?;
        let token_handle = owned(token)?;
        let token = ObjectAccess::grant(token_handle.as_raw_handle(), TOKEN_QUERY)?;
        Ok(Self {
            process,
            token,
            _token_handle: token_handle,
        })
    }

    pub fn restore(&mut self) -> io::Result<()> {
        let token = self.token.restore();
        let process = self.process.restore();
        token.and(process)
    }
}
