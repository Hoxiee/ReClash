//! The Windows kill switch: persistent WFP filters in a sublayer of their own let only
//! loopback, the TUN, the Helper and its Core, DHCP and local ranges connect while armed.

use super::site_lock_windows::ranges_text;
use std::net::Ipv6Addr;
use std::path::PathBuf;

const LOCAL_V4: [(u32, u32); 3] = [
    (u32::from_be_bytes([169, 254, 0, 0]), 0xffff_0000),
    (u32::from_be_bytes([224, 0, 0, 0]), 0xf000_0000),
    (u32::MAX, u32::MAX),
];
const LOCAL_V6: [([u8; 16], u8); 2] = [
    (Ipv6Addr::new(0xfe80, 0, 0, 0, 0, 0, 0, 0).octets(), 10),
    (Ipv6Addr::new(0xff00, 0, 0, 0, 0, 0, 0, 0).octets(), 8),
];
const LAN_V4: [(u32, u32); 3] = [
    (u32::from_be_bytes([10, 0, 0, 0]), 0xff00_0000),
    (u32::from_be_bytes([172, 16, 0, 0]), 0xfff0_0000),
    (u32::from_be_bytes([192, 168, 0, 0]), 0xffff_0000),
];
const LAN_V6: [([u8; 16], u8); 1] = [(Ipv6Addr::new(0xfc00, 0, 0, 0, 0, 0, 0, 0).octets(), 7)];
const DHCP_PORTS: [u16; 2] = [67, 547];
const UDP: u8 = 17;

/// One rule of the kill switch; each becomes a filter on the IPv4 and on the IPv6 layer.
#[derive(Debug, Clone, PartialEq, Eq)]
pub(super) enum Rule {
    Loopback,
    /// The TUN by interface LUID.
    Tun(u64),
    App(PathBuf),
    /// UDP to the DHCP server port of the layer's family.
    Dhcp,
    Ranges {
        v4: &'static [(u32, u32)],
        v6: &'static [([u8; 16], u8)],
    },
    BlockAll,
}

impl Rule {
    pub(super) fn permits(&self) -> bool {
        *self != Self::BlockAll
    }
}

pub(super) fn plan(allow_lan: bool, tun: Option<u64>, apps: &[PathBuf]) -> Vec<Rule> {
    let mut rules = vec![Rule::Loopback];
    rules.extend(tun.map(Rule::Tun));
    rules.extend(apps.iter().cloned().map(Rule::App));
    rules.push(Rule::Dhcp);
    rules.push(Rule::Ranges {
        v4: &LOCAL_V4,
        v6: &LOCAL_V6,
    });
    if allow_lan {
        rules.push(Rule::Ranges {
            v4: &LAN_V4,
            v6: &LAN_V6,
        });
    }
    rules.push(Rule::BlockAll);
    rules
}

pub(super) fn filter_count(plan: &[Rule]) -> usize {
    plan.len() * 2
}

/// The filters as GET /kill-switch lists them; `tun` names the TUN a `Tun` rule lets through.
pub(super) fn summary(plan: &[Rule], tun: &str) -> Vec<String> {
    plan.iter()
        .map(|rule| match rule {
            Rule::Loopback => "permit loopback".to_string(),
            Rule::Tun(_) => format!("permit every connection on ReClash ({tun})"),
            Rule::App(path) => format!("permit {}", path.display()),
            Rule::Dhcp => format!(
                "permit DHCP (UDP {})",
                DHCP_PORTS.map(|port| port.to_string()).join(", ")
            ),
            Rule::Ranges { v4, v6 } => format!("permit {}", ranges_text(v4, v6)),
            Rule::BlockAll => "block every other connection".to_string(),
        })
        .collect()
}

/// The boot time to the nearest minute: stable for the whole boot despite clock jitter.
pub(super) fn boot_identity(now_ms: u64, uptime_ms: u64) -> String {
    let boot_minute = (now_ms.saturating_sub(uptime_ms) + 30_000) / 60_000;
    (boot_minute * 60).to_string()
}

#[cfg(all(windows, feature = "windows-service"))]
pub(super) use system::{boot_id, WindowsKillSwitch};

#[cfg(all(windows, feature = "windows-service"))]
mod system {
    use super::*;
    use crate::service::kill_switch::{KillSwitchConfig, KillSwitchLayer};
    use crate::service::site_lock::HostError;
    use crate::service::site_lock_windows::system::{
        check, remote, tun_luid, Engine, WfpObjects, LAYERS,
    };
    use std::ffi::c_void;
    use std::mem::zeroed;
    use std::os::windows::ffi::OsStrExt;
    use std::ptr::null_mut;
    use std::sync::Mutex;
    use std::time::{SystemTime, UNIX_EPOCH};
    use windows_sys::core::GUID;
    use windows_sys::Win32::NetworkManagement::WindowsFilteringPlatform::*;

    const KILL_SWITCH: WfpObjects = WfpObjects {
        provider: GUID::from_u128(0x5c1d7e1a_0b5e_4e1a_9c1d_000000000011),
        sublayer: GUID::from_u128(0x5c1d7e1a_0b5e_4e1a_9c1d_000000000012),
        name: "ReClash kill switch",
        weight: u16::MAX - 1,
    };

    #[link(name = "kernel32")]
    extern "system" {
        fn GetTickCount64() -> u64;
    }

    pub(in crate::service) fn boot_id() -> Option<String> {
        let now = SystemTime::now().duration_since(UNIX_EPOCH).ok()?;
        // SAFETY: GetTickCount64 has no preconditions.
        let uptime = unsafe { GetTickCount64() };
        Some(boot_identity(now.as_millis() as u64, uptime))
    }

    fn apps() -> Result<Vec<PathBuf>, String> {
        let service = std::env::current_exe()
            .map_err(|error| format!("the service executable is unknown: {error}"))?;
        let core = service
            .parent()
            .ok_or("the service executable has no directory")?
            .join(env!("CORE_NAME"));
        Ok(vec![service, core])
    }

    struct AppId(*mut FWP_BYTE_BLOB);

    impl AppId {
        fn of(path: &std::path::Path) -> Result<Self, String> {
            let name: Vec<u16> = path.as_os_str().encode_wide().chain(Some(0)).collect();
            let mut blob: *mut FWP_BYTE_BLOB = null_mut();
            // SAFETY: name is NUL-terminated and blob is an out parameter.
            let code = unsafe { FwpmGetAppIdFromFileName0(name.as_ptr(), &mut blob) };
            check(code, &format!("reading the app id of {}", path.display()))?;
            Ok(Self(blob))
        }
    }

    impl Drop for AppId {
        fn drop(&mut self) {
            // SAFETY: the blob came from FwpmGetAppIdFromFileName0.
            unsafe {
                FwpmFreeMemory0((&mut self.0 as *mut *mut FWP_BYTE_BLOB).cast::<*mut c_void>())
            };
        }
    }

    fn condition(
        field: GUID,
        match_type: FWP_MATCH_TYPE,
        kind: FWP_DATA_TYPE,
        set: impl FnOnce(&mut FWP_CONDITION_VALUE0_0),
    ) -> FWPM_FILTER_CONDITION0 {
        // SAFETY: an all-zero condition is valid before its fields are set.
        let mut condition: FWPM_FILTER_CONDITION0 = unsafe { zeroed() };
        condition.fieldKey = field;
        condition.matchType = match_type;
        condition.conditionValue.r#type = kind;
        set(&mut condition.conditionValue.Anonymous);
        condition
    }

    fn add_rule(engine: &Engine, rule: &Rule) -> Result<(), String> {
        let app = match rule {
            Rule::App(path) => Some(AppId::of(path)?),
            _ => None,
        };
        for (family, layer) in LAYERS.into_iter().enumerate() {
            let mut luid = match rule {
                Rule::Tun(luid) => *luid,
                _ => 0,
            };
            let (mut v4, mut v6): (Vec<_>, Vec<_>) = match rule {
                Rule::Ranges { v4, v6 } if family == 0 => (
                    v4.iter()
                        .map(|&(addr, mask)| FWP_V4_ADDR_AND_MASK { addr, mask })
                        .collect(),
                    Vec::new(),
                ),
                Rule::Ranges { v6, .. } => (
                    Vec::new(),
                    v6.iter()
                        .map(|&(addr, prefix)| FWP_V6_ADDR_AND_MASK {
                            addr,
                            prefixLength: prefix,
                        })
                        .collect(),
                ),
                _ => (Vec::new(), Vec::new()),
            };
            let mut conditions: Vec<FWPM_FILTER_CONDITION0> = match rule {
                Rule::Loopback => vec![condition(
                    FWPM_CONDITION_FLAGS,
                    FWP_MATCH_FLAGS_ALL_SET,
                    FWP_UINT32,
                    |value| value.uint32 = FWP_CONDITION_FLAG_IS_LOOPBACK,
                )],
                Rule::Tun(_) => vec![condition(
                    FWPM_CONDITION_IP_LOCAL_INTERFACE,
                    FWP_MATCH_EQUAL,
                    FWP_UINT64,
                    |value| value.uint64 = &mut luid,
                )],
                Rule::App(_) => {
                    let blob = app.as_ref().map_or(null_mut(), |app| app.0);
                    vec![condition(
                        FWPM_CONDITION_ALE_APP_ID,
                        FWP_MATCH_EQUAL,
                        FWP_BYTE_BLOB_TYPE,
                        |value| value.byteBlob = blob,
                    )]
                }
                Rule::Dhcp => vec![
                    condition(
                        FWPM_CONDITION_IP_PROTOCOL,
                        FWP_MATCH_EQUAL,
                        FWP_UINT8,
                        |value| value.uint8 = UDP,
                    ),
                    condition(
                        FWPM_CONDITION_IP_REMOTE_PORT,
                        FWP_MATCH_EQUAL,
                        FWP_UINT16,
                        |value| value.uint16 = DHCP_PORTS[family],
                    ),
                ],
                Rule::Ranges { .. } => v4
                    .iter_mut()
                    .map(|mask| remote(FWP_V4_ADDR_MASK, |value| value.v4AddrMask = mask))
                    .chain(
                        v6.iter_mut()
                            .map(|mask| remote(FWP_V6_ADDR_MASK, |value| value.v6AddrMask = mask)),
                    )
                    .collect(),
                Rule::BlockAll => Vec::new(),
            };
            engine.add_filter(layer, rule.permits(), &mut conditions)?;
        }
        Ok(())
    }

    struct Applied {
        config: KillSwitchConfig,
        plan: Vec<Rule>,
    }

    #[derive(Default)]
    pub(in crate::service) struct WindowsKillSwitch {
        applied: Mutex<Option<Applied>>,
    }

    fn target(config: &KillSwitchConfig) -> Result<Vec<Rule>, String> {
        Ok(plan(config.allow_lan, tun_luid(&config.tun), &apps()?))
    }

    fn failed(message: String) -> HostError {
        HostError::Failed("wfpFailed", message)
    }

    fn live_filters() -> Result<usize, String> {
        Engine::open(&KILL_SWITCH)?.count()
    }

    impl KillSwitchLayer for WindowsKillSwitch {
        fn layer(&self) -> &'static str {
            "wfp"
        }

        fn failure(&self) -> &'static str {
            "wfpFailed"
        }

        fn apply(&self, config: &KillSwitchConfig) -> Result<(), HostError> {
            let mut applied = self.applied.lock().unwrap_or_else(|e| e.into_inner());
            *applied = None;
            let plan = target(config).map_err(failed)?;
            let engine = Engine::open(&KILL_SWITCH).map_err(failed)?;
            engine
                .transaction(|| {
                    engine.ensure_objects()?;
                    engine.delete_filters()?;
                    plan.iter().try_for_each(|rule| add_rule(&engine, rule))
                })
                .map_err(failed)?;
            *applied = Some(Applied {
                config: config.clone(),
                plan,
            });
            Ok(())
        }

        fn listing(&self) -> Result<Option<String>, HostError> {
            let count = live_filters().map_err(failed)?;
            if count == 0 {
                return Ok(None);
            }
            let applied = self.applied.lock().unwrap_or_else(|e| e.into_inner());
            let lines = match applied.as_ref() {
                Some(applied) => summary(&applied.plan, &applied.config.tun),
                None => vec![format!("{count} WFP filters left by an earlier start")],
            };
            Ok(Some(lines.join("\n")))
        }

        // The TUN's LUID changes when the Core recreates it, so the plan is rebuilt and
        // compared, and the live filter count catches filters removed behind our back.
        fn holds(&self, config: &KillSwitchConfig, _listing: &str) -> bool {
            let applied = self.applied.lock().unwrap_or_else(|e| e.into_inner());
            let Some(applied) = applied.as_ref() else {
                return false;
            };
            applied.config == *config
                && target(config).is_ok_and(|plan| plan == applied.plan)
                && live_filters().is_ok_and(|count| count == filter_count(&applied.plan))
        }

        fn lift(&self) -> Result<(), HostError> {
            let mut applied = self.applied.lock().unwrap_or_else(|e| e.into_inner());
            *applied = None;
            Engine::open(&KILL_SWITCH)
                .and_then(|engine| engine.lift())
                .map_err(failed)
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn the_plan_opens_loopback_dhcp_and_local_ranges_before_blocking_everything() {
        assert_eq!(
            plan(false, None, &[]),
            vec![
                Rule::Loopback,
                Rule::Dhcp,
                Rule::Ranges {
                    v4: &LOCAL_V4,
                    v6: &LOCAL_V6,
                },
                Rule::BlockAll,
            ]
        );
    }

    #[test]
    fn the_plan_adds_the_tun_and_apps_before_dhcp_and_lan_before_the_block() {
        let service = PathBuf::from("C:/x/ReClashService.exe");
        let core = PathBuf::from("C:/x/ReClash.exe");
        assert_eq!(
            plan(true, Some(7), &[service.clone(), core.clone()]),
            vec![
                Rule::Loopback,
                Rule::Tun(7),
                Rule::App(service),
                Rule::App(core),
                Rule::Dhcp,
                Rule::Ranges {
                    v4: &LOCAL_V4,
                    v6: &LOCAL_V6,
                },
                Rule::Ranges {
                    v4: &LAN_V4,
                    v6: &LAN_V6,
                },
                Rule::BlockAll,
            ]
        );
    }

    #[test]
    fn only_the_last_rule_blocks_and_it_is_always_last() {
        let rules = plan(true, Some(7), &[PathBuf::from("C:/x/ReClash.exe")]);
        assert_eq!(rules.last(), Some(&Rule::BlockAll));
        let blocking: Vec<&Rule> = rules.iter().filter(|rule| !rule.permits()).collect();
        assert_eq!(blocking, vec![&Rule::BlockAll]);
    }

    #[test]
    fn each_rule_becomes_one_filter_per_ip_layer() {
        let rules = plan(true, Some(7), &[]);
        assert_eq!(filter_count(&rules), 2 * rules.len());
    }

    #[test]
    fn the_summary_lists_every_permit_and_the_final_block() {
        let rules = plan(true, Some(7), &[PathBuf::from("C:/x/ReClashService.exe")]);
        assert_eq!(
            summary(&rules, "Meta"),
            vec![
                "permit loopback".to_string(),
                "permit every connection on ReClash (Meta)".to_string(),
                "permit C:/x/ReClashService.exe".to_string(),
                "permit DHCP (UDP 67, 547)".to_string(),
                "permit 169.254.0.0/16, 224.0.0.0/4, 255.255.255.255/32, fe80::/10, ff00::/8"
                    .to_string(),
                "permit 10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16, fc00::/7".to_string(),
                "block every other connection".to_string(),
            ]
        );
    }

    #[test]
    fn the_summary_omits_the_lan_ranges_when_lan_is_not_allowed() {
        let lines = summary(&plan(false, Some(7), &[]), "Meta");
        assert!(!lines.iter().any(|line| line.contains("10.0.0.0/8")));
        assert_eq!(
            lines.last().map(String::as_str),
            Some("block every other connection")
        );
    }

    #[test]
    fn the_boot_identity_is_the_boot_minute_in_seconds() {
        assert_eq!(boot_identity(149_000, 0), "120");
        assert_eq!(boot_identity(151_000, 0), "180");
    }

    #[test]
    fn the_boot_identity_stays_the_same_later_in_the_same_boot() {
        let boot = 1_700_000_000_000;
        assert_eq!(
            boot_identity(boot + 5_000, 5_000),
            boot_identity(boot + 3_600_000, 3_600_000)
        );
    }

    #[test]
    fn an_uptime_longer_than_the_clock_saturates_at_zero() {
        assert_eq!(boot_identity(1_000, 5_000), "0");
    }
}
