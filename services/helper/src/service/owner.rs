use anyhow::{anyhow, bail, Result};
use std::ffi::{OsStr, OsString};
use std::net::SocketAddrV4;

const OWNER_SID_FLAG: &str = "--owner-sid";
const OWNER_PID_FLAG: &str = "--owner-pid";
const MAX_SID_SUBAUTHORITIES: usize = 15;
const MANAGED_SERVICE_FLAG: &str = "--managed-service";
const MAX_HOME_CHARS: usize = 1024;

#[derive(Debug, PartialEq, Eq)]
pub enum ServiceCommand {
    Run { owner_sid: String },
    Install { owner_pid: u32 },
    Upgrade,
    Uninstall,
}

/// The service is registered with its owner on the command line, which is how a
/// start by the service manager learns whom to answer. Starting without one
/// fails rather than serve anybody.
pub fn service_command(args: impl IntoIterator<Item = OsString>) -> Result<ServiceCommand> {
    let args: Vec<OsString> = args.into_iter().collect();
    let args: Vec<&OsStr> = args.iter().map(OsString::as_os_str).collect();
    match args.as_slice() {
        [] => bail!("the helper service was registered without an owner; reinstall it"),
        [flag, sid] if *flag == OsStr::new(OWNER_SID_FLAG) => {
            let sid = sid
                .to_str()
                .filter(|sid| is_sid_string(sid))
                .ok_or_else(|| anyhow!("{OWNER_SID_FLAG} is not a SID"))?;
            Ok(ServiceCommand::Run {
                owner_sid: sid.to_string(),
            })
        }
        [command] if *command == OsStr::new("uninstall") => Ok(ServiceCommand::Uninstall),
        [command] if *command == OsStr::new("upgrade") => Ok(ServiceCommand::Upgrade),
        [command, flag, pid]
            if *command == OsStr::new("install") && *flag == OsStr::new(OWNER_PID_FLAG) =>
        {
            let owner_pid = pid
                .to_str()
                .and_then(|pid| pid.parse::<u32>().ok())
                .filter(|pid| *pid != 0)
                .ok_or_else(|| anyhow!("{OWNER_PID_FLAG} is not a process ID"))?;
            Ok(ServiceCommand::Install { owner_pid })
        }
        [command, ..] if *command == OsStr::new("install") => {
            bail!("install takes exactly {OWNER_PID_FLAG} <pid>")
        }
        [value, ..] => bail!("unknown helper command: {}", value.to_string_lossy()),
    }
}

pub fn owner_sid_arguments(owner_sid: &str) -> Vec<OsString> {
    vec![OsString::from(OWNER_SID_FLAG), OsString::from(owner_sid)]
}

/// Reads the owner back from the SCM command line `owner_sid_arguments`
/// registered: the executable, quoted when it has spaces, then `--owner-sid <SID>`.
pub fn configured_owner_sid(command_line: &str) -> Option<String> {
    let command_line = command_line.trim();
    let arguments = match command_line.strip_prefix('"') {
        Some(quoted) => quoted.split_once('"')?.1,
        None => command_line
            .split_once(char::is_whitespace)
            .map_or("", |(_, rest)| rest),
    };
    match arguments.split_whitespace().collect::<Vec<_>>().as_slice() {
        [flag, sid] if *flag == OWNER_SID_FLAG && is_sid_string(sid) => Some(sid.to_string()),
        _ => None,
    }
}

/// Mirrors `windowsLocalPath` in `core/cmd/core/managed_windows.go`, which the
/// Core applies again, plus the length bound of the service contract.
pub fn is_local_home(value: &str) -> bool {
    if value.chars().count() > MAX_HOME_CHARS {
        return false;
    }
    let value = value.strip_prefix(r"\\?\").unwrap_or(value);
    let bytes = value.as_bytes();
    if bytes.len() <= 3 || !bytes[0].is_ascii_alphabetic() || bytes[1] != b':' || bytes[2] != b'\\'
    {
        return false;
    }
    value[3..].split('\\').all(|component| {
        !component.is_empty()
            && component != "."
            && component != ".."
            && !component.ends_with('.')
            && !component.ends_with(' ')
            && !component.contains(|c: char| "/:<>|\"?*".contains(c) || (c as u32) < 32)
    })
}

/// The creation time keeps a recycled PID from standing in for the client.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct ManagedHost {
    pub pid: u32,
    pub created: u64,
    pub owner_sid: String,
}

/// Bound to the `--managed-service` parser in `core/cmd/core/managed_windows.go`.
pub fn managed_core_arguments(
    address: &str,
    session_id: &str,
    home: &str,
    host: &ManagedHost,
) -> Vec<OsString> {
    [
        MANAGED_SERVICE_FLAG,
        address,
        session_id,
        home,
        &host.pid.to_string(),
        &host.created.to_string(),
        &host.owner_sid,
    ]
    .into_iter()
    .map(OsString::from)
    .collect()
}

fn is_sid_string(value: &str) -> bool {
    let Some(rest) = value.strip_prefix("S-1-") else {
        return false;
    };
    let parts: Vec<&str> = rest.split('-').collect();
    parts.len() <= MAX_SID_SUBAUTHORITIES + 1
        && parts
            .iter()
            .all(|part| !part.is_empty() && part.bytes().all(|byte| byte.is_ascii_digit()))
}

pub fn same_sid(left: &str, right: &str) -> bool {
    left.eq_ignore_ascii_case(right)
}

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub struct TcpConnection {
    pub local: SocketAddrV4,
    pub remote: SocketAddrV4,
    pub pid: u32,
}

/// Both ends of a loopback connection are in the table, each owned by its own
/// process; the client's end is the one whose local address is the peer address
/// the Helper accepted.
pub fn client_pid(
    connections: &[TcpConnection],
    client: SocketAddrV4,
    server: SocketAddrV4,
) -> Option<u32> {
    connections
        .iter()
        .find(|connection| connection.local == client && connection.remote == server)
        .map(|connection| connection.pid)
        .filter(|pid| *pid != 0)
}

#[cfg(test)]
mod tests {
    use super::*;
    use std::net::Ipv4Addr;

    const SID: &str = "S-1-5-21-1004336348-1177238915-682003330-1001";

    fn os(values: &[&str]) -> Vec<OsString> {
        values.iter().map(OsString::from).collect()
    }

    fn address(port: u16) -> SocketAddrV4 {
        SocketAddrV4::new(Ipv4Addr::LOCALHOST, port)
    }

    #[test]
    fn parses_the_service_commands() {
        assert_eq!(
            service_command(os(&["--owner-sid", SID])).unwrap(),
            ServiceCommand::Run {
                owner_sid: SID.to_string()
            }
        );
        assert_eq!(
            service_command(os(&["install", "--owner-pid", "4242"])).unwrap(),
            ServiceCommand::Install { owner_pid: 4242 }
        );
        assert_eq!(
            service_command(os(&["uninstall"])).unwrap(),
            ServiceCommand::Uninstall
        );
        assert_eq!(
            service_command(os(&["upgrade"])).unwrap(),
            ServiceCommand::Upgrade
        );
    }

    #[test]
    fn refuses_to_run_without_an_owner() {
        assert!(service_command(os(&[])).is_err());
        assert!(service_command(os(&["--owner-sid"])).is_err());
        assert!(service_command(os(&["--owner-sid", "S-1-5-18", "extra"])).is_err());
    }

    #[test]
    fn rejects_an_owner_that_is_not_a_sid() {
        for value in [
            "",
            "alice",
            "S-1-",
            "S-1-5-",
            "S-1-5-x",
            "S-2-5-18",
            "S-1-5-18 ",
        ] {
            assert!(
                service_command(os(&["--owner-sid", value])).is_err(),
                "{value:?}"
            );
        }
        let long = format!("S-1-{}", vec!["5"; 17].join("-"));
        assert!(service_command(os(&["--owner-sid", &long])).is_err());
    }

    #[test]
    fn install_needs_a_real_owner_process() {
        assert!(service_command(os(&["install"])).is_err());
        assert!(service_command(os(&["install", "--owner-pid"])).is_err());
        assert!(service_command(os(&["install", "--owner-pid", "0"])).is_err());
        assert!(service_command(os(&["install", "--owner-pid", "-1"])).is_err());
        assert!(service_command(os(&["install", "--owner-pid", "abc"])).is_err());
        assert!(service_command(os(&["install", "--owner-pid", "7", "extra"])).is_err());
        assert!(service_command(os(&["install", "7"])).is_err());
    }

    #[test]
    fn rejects_unknown_or_extra_commands() {
        assert!(service_command(os(&["unknown"])).is_err());
        assert!(service_command(os(&["uninstall", "extra"])).is_err());
        assert!(service_command(os(&["upgrade", "--owner-sid", SID])).is_err());
    }

    #[test]
    fn reads_the_owner_from_the_registered_command_line() {
        for command_line in [
            format!(
                r#""C:\Program Files\ReClash Service\a-b\ReClashService.exe" --owner-sid {SID}"#
            ),
            format!(r"C:\ReClash\ReClashService.exe --owner-sid {SID}"),
            format!(r#"  "C:\x y\ReClashService.exe"   --owner-sid   {SID}  "#),
        ] {
            assert_eq!(
                configured_owner_sid(&command_line).as_deref(),
                Some(SID),
                "{command_line}"
            );
        }
    }

    #[test]
    fn a_command_line_without_exactly_one_valid_owner_has_none() {
        for command_line in [
            String::new(),
            r#""C:\Program Files\ReClashService.exe""#.to_string(),
            r"C:\ReClash\ReClashService.exe".to_string(),
            format!(r#""C:\Program Files\ReClashService.exe --owner-sid {SID}"#),
            format!(r#""C:\x\ReClashService.exe" --owner-sid {SID} extra"#),
            r#""C:\x\ReClashService.exe" --owner-sid alice"#.to_string(),
            format!(r#""C:\x\ReClashService.exe" --owner-pid {SID}"#),
        ] {
            assert_eq!(configured_owner_sid(&command_line), None, "{command_line}");
        }
    }

    #[test]
    fn accepts_only_absolute_local_drive_homes() {
        for home in [
            r"C:\Users\alice\AppData\Roaming\com.follow\reclash",
            r"d:\ReClash Data\home",
            r"\\?\C:\Users\alice\reclash",
        ] {
            assert!(is_local_home(home), "{home}");
        }
        for home in [
            "",
            r"C:\",
            r"C:",
            r"C:relative\home",
            r"relative\home",
            r"\\server\share\home",
            r"\\?\UNC\server\share",
            r"C:\Users\..\Windows",
            r"C:\Users\.\alice",
            r"C:\Users\alice\",
            r"C:\Users\\alice",
            r"C:\Users\alice.",
            r"C:\Users\alice ",
            r"C:\Users\alice:stream",
            "C:/Users/alice",
            "C:\\Users\\a\u{1}b",
            r"C:\Users\a*b",
        ] {
            assert!(!is_local_home(home), "{home:?}");
        }
    }

    #[test]
    fn bounds_the_home_length() {
        let longest = format!(r"C:\{}", "a".repeat(1021));
        assert_eq!(longest.chars().count(), 1024);
        assert!(is_local_home(&longest));
        assert!(!is_local_home(&format!("{longest}a")));
    }

    #[test]
    fn launches_the_core_with_the_managed_service_arguments_in_order() {
        let host = ManagedHost {
            pid: 4242,
            created: 133_456_789_012_345_678,
            owner_sid: SID.to_string(),
        };

        let arguments = managed_core_arguments(
            r"\\.\pipe\ReClashCore_0123456789abcdef0123456789abcdef",
            "0123456789abcdef0123456789abcdef",
            r"C:\Users\alice\Ro ming\reclash",
            &host,
        );

        assert_eq!(
            arguments,
            os(&[
                "--managed-service",
                r"\\.\pipe\ReClashCore_0123456789abcdef0123456789abcdef",
                "0123456789abcdef0123456789abcdef",
                r"C:\Users\alice\Ro ming\reclash",
                "4242",
                "133456789012345678",
                SID,
            ])
        );
    }

    #[test]
    fn registration_arguments_read_back_as_the_same_owner() {
        let arguments = owner_sid_arguments(SID);

        assert_eq!(
            service_command(arguments).unwrap(),
            ServiceCommand::Run {
                owner_sid: SID.to_string()
            }
        );
    }

    #[test]
    fn compares_sids_regardless_of_case() {
        assert!(same_sid("S-1-5-21-1-2-3-1001", "s-1-5-21-1-2-3-1001"));
        assert!(!same_sid("S-1-5-21-1-2-3-1001", "S-1-5-21-1-2-3-1002"));
    }

    #[test]
    fn finds_the_process_on_the_client_end_of_the_connection() {
        let server = address(47890);
        let client = address(50123);
        let connections = [
            TcpConnection {
                local: server,
                remote: client,
                pid: 700,
            },
            TcpConnection {
                local: client,
                remote: server,
                pid: 4242,
            },
            TcpConnection {
                local: address(50124),
                remote: server,
                pid: 9999,
            },
        ];

        assert_eq!(client_pid(&connections, client, server), Some(4242));
    }

    #[test]
    fn finds_nobody_when_the_connection_is_gone_or_unowned() {
        let server = address(47890);
        let client = address(50123);
        let helper_end_only = [TcpConnection {
            local: server,
            remote: client,
            pid: 700,
        }];
        let unowned = [TcpConnection {
            local: client,
            remote: server,
            pid: 0,
        }];

        assert_eq!(client_pid(&helper_end_only, client, server), None);
        assert_eq!(client_pid(&unowned, client, server), None);
        assert_eq!(client_pid(&[], client, server), None);
    }
}
