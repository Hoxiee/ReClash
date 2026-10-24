use anyhow::{bail, Result};
use serde::{Deserialize, Serialize};

pub const SERVICE_NAME: &str = "ReClashService";
pub const SERVICE_DISPLAY_NAME: &str = "ReClash Service";
pub const SERVICE_EXE: &str = "ReClashService.exe";
pub const MANIFEST_NAME: &str = "manifest.json";
pub const INSTALL_ROOT_NAME: &str = "ReClash Service";
pub const INSTALL_MUTEX: &str = r"Global\ReClashServiceInstall";
pub const PROTOCOL: &str = "10";
pub const MAX_MANIFEST_BYTES: u64 = 4096;
/// Owner Administrators and no inheritance, so neither Program Files nor a
/// later change to it can hand a non-admin write access to the installed pair.
pub const PROTECTED_DIRECTORY_SDDL: &str =
    "O:BAD:P(A;OICI;FA;;;SY)(A;OICI;FA;;;BA)(A;OICI;0x1200a9;;;BU)";
const STAGING_PREFIX: &str = ".staging-";
const BUILTIN_ADMINISTRATORS: &str = "S-1-5-32-544";
const TRUSTED_WRITERS: [&str; 3] = [
    "S-1-5-18",
    BUILTIN_ADMINISTRATORS,
    "S-1-5-80-956008885-3418522649-1831038044-1853292631-2271478464",
];
const ACCESS_ALLOWED_ACE_TYPE: u8 = 0;
const ACCESS_ALLOWED_OBJECT_ACE_TYPE: u8 = 5;
const ACCESS_ALLOWED_CALLBACK_ACE_TYPE: u8 = 9;
const ACCESS_ALLOWED_CALLBACK_OBJECT_ACE_TYPE: u8 = 11;
/// Every right that changes the directory, its children, or who may do so,
/// including the generic and MAXIMUM_ALLOWED forms that map onto them.
const WRITE_RIGHTS: u32 = 0x0000_0002
    | 0x0000_0004
    | 0x0000_0010
    | 0x0000_0040
    | 0x0000_0100
    | 0x0001_0000
    | 0x0004_0000
    | 0x0008_0000
    | 0x0200_0000
    | 0x1000_0000
    | 0x4000_0000;

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum InstallFailure {
    BundleInvalid,
    ServiceFailed,
    OwnerInvalid,
    InstallBusy,
}

impl InstallFailure {
    pub fn code(self) -> &'static str {
        match self {
            Self::BundleInvalid => "bundle_invalid",
            Self::ServiceFailed => "service_failed",
            Self::OwnerInvalid => "owner_invalid",
            Self::InstallBusy => "install_busy",
        }
    }

    pub fn exit_code(self) -> i32 {
        match self {
            Self::BundleInvalid => 2,
            Self::ServiceFailed => 3,
            Self::OwnerInvalid => 4,
            Self::InstallBusy => 5,
        }
    }
}

impl std::fmt::Display for InstallFailure {
    fn fmt(&self, formatter: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        formatter.write_str(self.code())
    }
}

impl std::error::Error for InstallFailure {}

/// The exit code and `reclash-service-error` code a failed maintenance command
/// reports; anything not classified is exit code 1.
pub fn failure_exit(error: &anyhow::Error) -> (i32, &'static str) {
    error
        .downcast_ref::<InstallFailure>()
        .map_or((1, "internal_error"), |failure| {
            (failure.exit_code(), failure.code())
        })
}

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, Eq)]
#[serde(rename_all = "camelCase", deny_unknown_fields)]
pub struct Manifest {
    pub core_sha256: String,
    pub helper_sha256: String,
    pub helper_protocol_version: String,
}

impl Manifest {
    pub fn parse(bytes: &[u8]) -> Result<Self> {
        if bytes.len() as u64 > MAX_MANIFEST_BYTES {
            bail!("bundle manifest is too large");
        }
        let manifest: Self = serde_json::from_slice(bytes)?;
        if !is_hash(&manifest.core_sha256)
            || !is_hash(&manifest.helper_sha256)
            || manifest.helper_protocol_version != PROTOCOL
        {
            bail!("invalid ReClash Service bundle manifest");
        }
        Ok(manifest)
    }

    /// The installed directory name; the app reads readiness from it.
    pub fn id(&self) -> String {
        format!("{}-{}", self.core_sha256, self.helper_sha256)
    }

    pub fn matches(&self, core_sha256: &str, helper_sha256: &str) -> bool {
        !core_sha256.is_empty()
            && self.core_sha256 == core_sha256
            && self.helper_sha256 == helper_sha256
    }
}

fn is_hash(value: &str) -> bool {
    value.len() == 64
        && value
            .bytes()
            .all(|byte| byte.is_ascii_digit() || (b'a'..=b'f').contains(&byte))
}

pub fn staging_name(pid: u32, stamp: u128) -> String {
    format!("{STAGING_PREFIX}{pid}-{stamp}")
}

/// Only names this installer creates are removed from the install root, so an
/// entry an administrator put there survives pruning.
pub fn is_prunable(name: &str, keep: &str) -> bool {
    if name == keep {
        return false;
    }
    if let Some(stamp) = name.strip_prefix(STAGING_PREFIX) {
        return stamp
            .split_once('-')
            .is_some_and(|(pid, time)| is_decimal(pid) && is_decimal(time));
    }
    name.split_once('-')
        .is_some_and(|(core, helper)| is_hash(core) && is_hash(helper))
}

fn is_decimal(value: &str) -> bool {
    !value.is_empty() && value.bytes().all(|byte| byte.is_ascii_digit())
}

#[derive(Debug, Clone, PartialEq, Eq)]
pub struct Ace {
    pub kind: u8,
    pub mask: u32,
    pub sid: Option<String>,
}

impl Ace {
    pub fn has_sid(kind: u8) -> bool {
        matches!(
            kind,
            ACCESS_ALLOWED_ACE_TYPE | ACCESS_ALLOWED_CALLBACK_ACE_TYPE
        )
    }

    fn allows(&self) -> bool {
        Self::has_sid(self.kind)
            || matches!(
                self.kind,
                ACCESS_ALLOWED_OBJECT_ACE_TYPE | ACCESS_ALLOWED_CALLBACK_OBJECT_ACE_TYPE
            )
    }
}

/// A missing DACL grants everyone everything; an allow ACE whose trustee the
/// check cannot read counts as untrusted.
pub fn is_protected_directory(owner_sid: &str, dacl: Option<&[Ace]>) -> bool {
    let Some(dacl) = dacl else {
        return false;
    };
    owner_sid.eq_ignore_ascii_case(BUILTIN_ADMINISTRATORS)
        && !dacl.iter().any(|ace| {
            ace.allows()
                && ace.mask & WRITE_RIGHTS != 0
                && !ace.sid.as_deref().is_some_and(|sid| {
                    TRUSTED_WRITERS
                        .iter()
                        .any(|trusted| trusted.eq_ignore_ascii_case(sid))
                })
        })
}

#[cfg(test)]
mod tests {
    use super::*;

    const CORE: &str = "1111111111111111111111111111111111111111111111111111111111111111";
    const HELPER: &str = "2222222222222222222222222222222222222222222222222222222222222222";

    fn manifest_json(protocol: &str) -> String {
        format!(
            r#"{{"coreSha256":"{CORE}","helperSha256":"{HELPER}","helperProtocolVersion":"{protocol}"}}"#
        )
    }

    fn ace(kind: u8, mask: u32, sid: Option<&str>) -> Ace {
        Ace {
            kind,
            mask,
            sid: sid.map(str::to_string),
        }
    }

    fn protected_dacl() -> Vec<Ace> {
        vec![
            ace(0, 0x001f_01ff, Some("S-1-5-18")),
            ace(0, 0x001f_01ff, Some("S-1-5-32-544")),
            ace(0, 0x0012_00a9, Some("S-1-5-32-545")),
        ]
    }

    #[test]
    fn names_follow_the_service_contract() {
        assert_eq!(SERVICE_NAME, "ReClashService");
        assert_eq!(SERVICE_DISPLAY_NAME, "ReClash Service");
        assert_eq!(SERVICE_EXE, "ReClashService.exe");
        assert_eq!(MANIFEST_NAME, "manifest.json");
        assert_eq!(INSTALL_ROOT_NAME, "ReClash Service");
        assert_eq!(INSTALL_MUTEX, r"Global\ReClashServiceInstall");
    }

    #[test]
    fn installed_directories_are_created_admin_owned_without_inheritance() {
        let (owner, dacl) = PROTECTED_DIRECTORY_SDDL.split_once("D:").unwrap();

        assert_eq!(owner, "O:BA");
        assert!(dacl.starts_with("P("));
        let aces: Vec<&str> = dacl[1..]
            .trim_matches(|c| c == '(' || c == ')')
            .split(")(")
            .collect();
        assert_eq!(
            aces,
            ["A;OICI;FA;;;SY", "A;OICI;FA;;;BA", "A;OICI;0x1200a9;;;BU"]
        );
        assert_eq!(0x0012_00a9 & WRITE_RIGHTS, 0);
    }

    #[test]
    fn maps_failures_to_the_contract_exit_codes() {
        for (failure, exit, code) in [
            (InstallFailure::BundleInvalid, 2, "bundle_invalid"),
            (InstallFailure::ServiceFailed, 3, "service_failed"),
            (InstallFailure::OwnerInvalid, 4, "owner_invalid"),
            (InstallFailure::InstallBusy, 5, "install_busy"),
        ] {
            let error = anyhow::Error::new(std::io::Error::other("cause"))
                .context(failure)
                .context("outer context");
            assert_eq!(failure_exit(&error), (exit, code));
        }
        assert_eq!(
            failure_exit(&anyhow::anyhow!("unclassified")),
            (1, "internal_error")
        );
    }

    #[test]
    fn the_bundle_is_addressed_by_both_hashes() {
        let manifest = Manifest::parse(manifest_json("10").as_bytes()).unwrap();

        assert_eq!(manifest.id(), format!("{CORE}-{HELPER}"));
        assert!(manifest.matches(CORE, HELPER));
        assert!(!manifest.matches(HELPER, HELPER));
        assert!(!manifest.matches("", HELPER));
    }

    #[test]
    fn rejects_manifests_of_another_protocol_or_shape() {
        assert!(Manifest::parse(manifest_json("9").as_bytes()).is_err());
        assert!(Manifest::parse(manifest_json("8").as_bytes()).is_err());
        let extra = manifest_json("10").replace('}', r#","extra":true}"#);
        assert!(Manifest::parse(extra.as_bytes()).is_err());
        let upper = manifest_json("10").replace(CORE, &CORE.replace('1', "A"));
        assert!(Manifest::parse(upper.as_bytes()).is_err());
        let padded = format!("{}{}", manifest_json("10"), " ".repeat(4096));
        assert!(Manifest::parse(padded.as_bytes()).is_err());
    }

    #[test]
    fn prunes_only_installer_owned_names_other_than_the_current_bundle() {
        let current = format!("{CORE}-{HELPER}");
        let previous = format!("{HELPER}-{CORE}");

        assert!(!is_prunable(&current, &current));
        assert!(is_prunable(&previous, &current));
        assert!(is_prunable(&staging_name(42, 1_700_000_000), &current));
        for name in [
            "notes.txt",
            "ReClashService.exe",
            ".staging-",
            ".staging-42",
            ".staging-x-1",
            &format!("{CORE}-{}", &HELPER[1..]),
            &format!("{CORE}_{HELPER}"),
            &format!("{CORE}-{HELPER}-extra"),
        ] {
            assert!(!is_prunable(name, &current), "{name}");
        }
    }

    #[test]
    fn the_installed_layout_is_administrator_owned_and_read_only_for_users() {
        assert!(is_protected_directory(
            "S-1-5-32-544",
            Some(&protected_dacl())
        ));
        assert!(is_protected_directory("s-1-5-32-544", Some(&[])));
        assert!(!is_protected_directory(
            "S-1-5-21-1-2-3-1001",
            Some(&protected_dacl())
        ));
        assert!(!is_protected_directory("S-1-5-18", Some(&protected_dacl())));
        assert!(!is_protected_directory("S-1-5-32-544", None));
    }

    #[test]
    fn any_write_right_for_a_non_admin_principal_is_unsafe() {
        for (kind, mask, sid) in [
            (0, 0x0000_0002, Some("S-1-5-32-545")),
            (0, 0x0001_0000, Some("S-1-1-0")),
            (0, 0x0004_0000, Some("S-1-5-11")),
            (0, 0x1000_0000, Some("S-1-3-0")),
            (0, 0x4000_0000, Some("S-1-5-21-1-2-3-1001")),
            (9, 0x0000_0040, Some("S-1-5-32-545")),
            (5, 0x0000_0004, None),
            (11, 0x0000_0100, None),
        ] {
            let mut dacl = protected_dacl();
            dacl.push(ace(kind, mask, sid));
            assert!(
                !is_protected_directory("S-1-5-32-544", Some(&dacl)),
                "{kind} {mask:#x} {sid:?}"
            );
        }
    }

    #[test]
    fn deny_and_read_entries_do_not_make_the_layout_unsafe() {
        let mut dacl = protected_dacl();
        dacl.push(ace(1, 0x001f_01ff, Some("S-1-1-0")));
        dacl.push(ace(0, 0x0012_00a9, Some("S-1-1-0")));
        dacl.push(ace(
            0,
            0x001f_01ff,
            Some("S-1-5-80-956008885-3418522649-1831038044-1853292631-2271478464"),
        ));

        assert!(is_protected_directory("S-1-5-32-544", Some(&dacl)));
    }
}
