use anyhow::{bail, Context, Result};
use std::ffi::CString;
use std::fs::{self, File};
use std::io;
use std::os::fd::AsRawFd;

pub(super) struct Selinux {
    enabled: bool,
}

impl Selinux {
    pub(super) fn detect() -> Result<Self> {
        Self::from_enforcement(fs::read_to_string("/sys/fs/selinux/enforce"))
    }

    fn from_enforcement(state: io::Result<String>) -> Result<Self> {
        match state {
            Ok(value) if matches!(value.trim(), "0" | "1") => Ok(Self { enabled: true }),
            Ok(_) => bail!("unrecognized SELinux enforcement state"),
            Err(error) if error.kind() == io::ErrorKind::NotFound => Ok(Self { enabled: false }),
            Err(error) => Err(error).context("read SELinux enforcement state"),
        }
    }

    pub(super) fn label_executable(&self, file: &File) -> Result<()> {
        if !self.enabled {
            return Ok(());
        }
        let attribute = c"security.selinux";
        let mut current = [0_u8; 4096];
        // SAFETY: the descriptor is owned and both the attribute and writable buffer are valid.
        let size = unsafe {
            libc::fgetxattr(
                file.as_raw_fd(),
                attribute.as_ptr(),
                current.as_mut_ptr().cast(),
                current.len(),
            )
        };
        if size < 0 {
            return Err(io::Error::last_os_error()).context("read executable SELinux context");
        }
        let current = &current[..size as usize];
        let desired = executable_context(current)?;
        if current.strip_suffix(&[0]).unwrap_or(current) == desired.as_bytes() {
            return Ok(());
        }
        // SAFETY: labeling uses the verified file descriptor, not a re-resolved pathname.
        let result = unsafe {
            libc::fsetxattr(
                file.as_raw_fd(),
                attribute.as_ptr(),
                desired.as_bytes_with_nul().as_ptr().cast(),
                desired.as_bytes_with_nul().len(),
                0,
            )
        };
        if result != 0 {
            return Err(io::Error::last_os_error()).context("set executable SELinux type to bin_t");
        }
        file.sync_all()?;
        Ok(())
    }
}

fn executable_context(current: &[u8]) -> Result<CString> {
    let current = std::str::from_utf8(current.strip_suffix(&[0]).unwrap_or(current))?;
    let mut fields = current.splitn(4, ':');
    let user = fields.next().filter(|value| !value.is_empty());
    let role = fields.next().filter(|value| !value.is_empty());
    let kind = fields.next().filter(|value| !value.is_empty());
    let range = fields.next();
    let (Some(user), Some(role), Some(kind)) = (user, role, kind) else {
        bail!("invalid executable SELinux context");
    };
    if range == Some("") {
        bail!("empty executable SELinux range");
    }
    // Preserve administrator-defined domains; only replace the generic /var/lib data type.
    if kind != "var_lib_t" {
        return CString::new(current).context("invalid executable SELinux context");
    }
    let mut desired = format!("{user}:{role}:bin_t");
    if let Some(range) = range {
        desired.push(':');
        desired.push_str(range);
    }
    CString::new(desired).context("invalid executable SELinux context")
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn enforcing_and_permissive_hosts_both_label_executables() {
        for state in ["0", "1", "1\n"] {
            assert!(Selinux::from_enforcement(Ok(state.into())).unwrap().enabled);
        }
    }

    #[test]
    fn absent_selinux_does_not_read_or_change_file_labels() {
        let selinux = Selinux::from_enforcement(Err(io::ErrorKind::NotFound.into())).unwrap();
        assert!(!selinux.enabled);
        selinux
            .label_executable(&File::open("/dev/null").unwrap())
            .unwrap();
    }

    #[test]
    fn unreadable_or_invalid_state_is_not_treated_as_disabled() {
        assert!(Selinux::from_enforcement(Err(io::ErrorKind::PermissionDenied.into())).is_err());
        for state in ["", "disabled", "2"] {
            assert!(Selinux::from_enforcement(Ok(state.into())).is_err());
        }
    }

    #[test]
    fn executable_type_preserves_user_role_and_mls_range() {
        for (current, expected) in [
            (
                "unconfined_u:object_r:var_lib_t:s0\0",
                "unconfined_u:object_r:bin_t:s0",
            ),
            (
                "system_u:object_r:var_lib_t:s0-s0:c0.c1023\0",
                "system_u:object_r:bin_t:s0-s0:c0.c1023",
            ),
            ("system_u:object_r:var_lib_t", "system_u:object_r:bin_t"),
            ("system_u:object_r:bin_t:s0", "system_u:object_r:bin_t:s0"),
        ] {
            assert_eq!(
                executable_context(current.as_bytes()).unwrap().to_bytes(),
                expected.as_bytes()
            );
        }
    }

    #[test]
    fn administrator_defined_executable_types_are_preserved() {
        let context = "system_u:object_r:reclash_exec_t:s0";
        assert_eq!(
            executable_context(context.as_bytes()).unwrap().to_bytes(),
            context.as_bytes()
        );
    }

    #[test]
    fn invalid_contexts_are_rejected_without_synthesizing_a_label() {
        for value in [
            "",
            "system_u",
            "system_u:object_r",
            ":object_r:var_lib_t",
            "u::t",
            "u:r:t:",
            "u:r:t:s0\0other",
        ] {
            assert!(executable_context(value.as_bytes()).is_err(), "{value:?}");
        }
        assert!(executable_context(&[0xff]).is_err());
    }
}
