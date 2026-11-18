use super::hub::{error_response, json_response};
use super::site_lock_dns::{DnsQueue, Matcher, Names, NoQueue, SystemQueue, QUEUE_NUM};
use serde::{Deserialize, Serialize};
use std::collections::BTreeSet;
use std::convert::Infallible;
use std::fs::{self, OpenOptions};
use std::io::{ErrorKind, Write};
use std::net::{IpAddr, Ipv6Addr};
#[cfg(unix)]
use std::os::unix::fs::OpenOptionsExt;
use std::path::{Path, PathBuf};
use std::process::{Command, Stdio};
use std::sync::{Arc, Mutex};
use std::thread;
use warp::http::StatusCode;
use warp::{Filter, Rejection};

const TABLE: &str = "reclash_sitelock";
const STATE_FILE: &str = "site-lock.json";
const MAX_ADDRESSES: usize = 8192;
const MAX_TUN_LENGTH: usize = 15;
const MAX_STDERR_CHARS: usize = 1024;
const MAX_ERROR_ENTRY_CHARS: usize = 64;
// 8192 IPv6 CIDRs plus the largest escaped name list.
const MAX_BODY_BYTES: u64 = 16 * 1024 * 1024;
#[cfg(target_os = "linux")]
const NFT_PATHS: [&str; 3] = ["/usr/sbin/nft", "/usr/bin/nft", "/sbin/nft"];

#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
#[serde(deny_unknown_fields)]
pub(super) struct SiteLockRequest {
    tun: String,
    addresses: Vec<String>,
    #[serde(default)]
    names: Names,
}

#[derive(Debug, PartialEq, Eq)]
pub(super) enum NftError {
    Missing,
    Failed(String),
}

pub(super) trait NftRunner: Send + Sync {
    fn apply(&self, ruleset: &str) -> Result<(), NftError>;
}

#[derive(Debug, Default, PartialEq, Eq)]
struct Addresses {
    v4: Vec<(u32, u8)>,
    v6: Vec<(u128, u8)>,
}

impl Addresses {
    fn count(&self) -> usize {
        self.v4.len() + self.v6.len()
    }
}

fn validate_tun(tun: &str) -> Result<(), String> {
    let valid = tun.len() <= MAX_TUN_LENGTH
        && tun
            .bytes()
            .all(|byte| byte.is_ascii_alphanumeric() || matches!(byte, b'_' | b'.' | b'-'));
    if valid {
        Ok(())
    } else {
        Err("tun must be at most 15 characters of A-Z, a-z, 0-9, '_', '.' or '-'".to_string())
    }
}

fn v4_mask(prefix: u8) -> u32 {
    u32::MAX.checked_shl(32 - u32::from(prefix)).unwrap_or(0)
}

fn v6_mask(prefix: u8) -> u128 {
    u128::MAX.checked_shl(128 - u32::from(prefix)).unwrap_or(0)
}

enum Network {
    V4(u32, u8),
    V6(u128, u8),
}

fn parse_entry(entry: &str) -> Option<Network> {
    let (address, prefix) = match entry.split_once('/') {
        Some((address, prefix)) => {
            if prefix.is_empty() || prefix.len() > 3 || !prefix.bytes().all(|b| b.is_ascii_digit())
            {
                return None;
            }
            (address, Some(prefix.parse::<u8>().ok()?))
        }
        None => (entry, None),
    };
    match address.parse::<IpAddr>().ok()? {
        IpAddr::V4(address) => {
            let prefix = prefix.unwrap_or(32);
            (prefix <= 32).then(|| Network::V4(u32::from(address) & v4_mask(prefix), prefix))
        }
        IpAddr::V6(address) => {
            let prefix = prefix.unwrap_or(128);
            if prefix > 128 {
                return None;
            }
            match address.to_ipv4_mapped() {
                Some(mapped) if prefix >= 96 => {
                    let prefix = prefix - 96;
                    Some(Network::V4(u32::from(mapped) & v4_mask(prefix), prefix))
                }
                _ => Some(Network::V6(u128::from(address) & v6_mask(prefix), prefix)),
            }
        }
    }
}

fn normalize(request: &SiteLockRequest) -> Result<Addresses, String> {
    validate_tun(&request.tun)?;
    request.names.validate()?;
    if request.addresses.len() > MAX_ADDRESSES {
        return Err(format!("at most {MAX_ADDRESSES} addresses are allowed"));
    }
    let mut v4 = BTreeSet::new();
    let mut v6 = BTreeSet::new();
    for entry in &request.addresses {
        match parse_entry(entry) {
            Some(Network::V4(address, prefix)) => {
                v4.insert((address, prefix));
            }
            Some(Network::V6(address, prefix)) => {
                v6.insert((address, prefix));
            }
            None => {
                let shown: String = entry.chars().take(MAX_ERROR_ENTRY_CHARS).collect();
                return Err(format!("invalid address or CIDR: {shown:?}"));
            }
        }
    }
    Ok(Addresses {
        v4: v4.into_iter().collect(),
        v6: v6.into_iter().collect(),
    })
}

fn set_block(name: &str, kind: &str, elements: Vec<String>) -> String {
    let mut block = format!("  set {name} {{ type {kind}; flags interval; auto-merge;");
    if !elements.is_empty() {
        block.push_str(&format!(" elements = {{ {} }};", elements.join(", ")));
    }
    block.push_str(" }\n");
    block
}

/// Off-TUN DNS goes to the helper's queue; `cgroup` is the helper's own, which holds the Core.
struct DnsFilter<'a> {
    cgroup: Option<&'a str>,
}

// One rule per line: nft does not parse a reject statement closed by "}" on its line.
// Without a TUN nothing may reach these addresses but the core's proxied connections.
fn chain_block(name: &str, tun: &str, dns: Option<&DnsFilter>) -> String {
    let output = name == "output";
    let mut through_tun = String::new();
    if let (true, Some(_)) = (output, dns) {
        through_tun.push_str("    oifname \"lo\" accept\n");
    }
    if !tun.is_empty() {
        through_tun.push_str(&format!("    oifname \"{tun}\" accept\n"));
    }
    if let Some(dns) = dns {
        // The Core's own upstream DNS must keep working (redir-host mode).
        if let (true, Some(cgroup)) = (output, dns.cgroup) {
            let level = cgroup.split('/').count();
            through_tun.push_str(&format!(
                "    socket cgroupv2 level {level} \"{cgroup}\" meta l4proto {{ tcp, udp }} th dport 53 accept\n"
            ));
        }
        through_tun.push_str(&format!(
            "    meta l4proto {{ tcp, udp }} th dport 53 queue num {QUEUE_NUM}\n"
        ));
    }
    format!(
        "  chain {name} {{\n    type filter hook {name} priority filter; policy accept;\n\
         {through_tun}    \
         meta l4proto tcp ip daddr @v4 reject with tcp reset\n    \
         ip daddr @v4 reject with icmpx admin-prohibited\n    \
         meta l4proto tcp ip6 daddr @v6 reject with tcp reset\n    \
         ip6 daddr @v6 reject with icmpx admin-prohibited\n  }}\n"
    )
}

fn ruleset(tun: &str, addresses: &Addresses, dns: Option<&DnsFilter>) -> String {
    let v4 = addresses
        .v4
        .iter()
        .map(|&(address, prefix)| {
            let address = std::net::Ipv4Addr::from(address);
            if prefix == 32 {
                address.to_string()
            } else {
                format!("{address}/{prefix}")
            }
        })
        .collect();
    let v6 = addresses
        .v6
        .iter()
        .map(|&(address, prefix)| {
            let address = Ipv6Addr::from(address);
            if prefix == 128 {
                address.to_string()
            } else {
                format!("{address}/{prefix}")
            }
        })
        .collect();
    format!(
        "add table inet {TABLE}\ndelete table inet {TABLE}\ntable inet {TABLE} {{\n{}{}{}{}}}\n",
        set_block("v4", "ipv4_addr", v4),
        set_block("v6", "ipv6_addr", v6),
        chain_block("output", tun, dns),
        chain_block("forward", tun, dns),
    )
}

fn delete_ruleset() -> String {
    format!("add table inet {TABLE}\ndelete table inet {TABLE}\n")
}

pub(super) struct SystemNft;

#[cfg(target_os = "linux")]
impl NftRunner for SystemNft {
    fn apply(&self, ruleset: &str) -> Result<(), NftError> {
        let path = NFT_PATHS
            .iter()
            .map(Path::new)
            .find(|path| path.is_file())
            .ok_or(NftError::Missing)?;
        let failed = |error: std::io::Error| NftError::Failed(error.to_string());
        let mut child = Command::new(path)
            .args(["-f", "-"])
            .env_clear()
            .stdin(Stdio::piped())
            .stdout(Stdio::null())
            .stderr(Stdio::piped())
            .spawn()
            .map_err(failed)?;
        let mut stdin = child.stdin.take().expect("piped stdin");
        let input = ruleset.to_owned();
        // Writing from a thread keeps a large ruleset from deadlocking against nft's stderr.
        let writer = thread::spawn(move || stdin.write_all(input.as_bytes()));
        let output = child.wait_with_output().map_err(failed)?;
        let _ = writer.join();
        if output.status.success() {
            return Ok(());
        }
        let stderr = String::from_utf8_lossy(&output.stderr);
        let stderr: String = stderr.trim().chars().take(MAX_STDERR_CHARS).collect();
        Err(NftError::Failed(if stderr.is_empty() {
            format!("nft exited with {}", output.status)
        } else {
            stderr
        }))
    }
}

#[cfg(not(target_os = "linux"))]
impl NftRunner for SystemNft {
    fn apply(&self, _ruleset: &str) -> Result<(), NftError> {
        Err(NftError::Missing)
    }
}

fn cgroup_path(proc_cgroup: &str) -> Option<String> {
    let path = proc_cgroup
        .lines()
        .find_map(|line| line.strip_prefix("0::"))?
        .trim_matches('/');
    let valid = !path.is_empty()
        && !path
            .chars()
            .any(|c| c == '"' || c == '\\' || c.is_whitespace() || c.is_control());
    valid.then(|| path.to_string())
}

pub(super) struct SiteLockService {
    state_dir: PathBuf,
    runner: Box<dyn NftRunner>,
    queue: Arc<dyn DnsQueue>,
    cgroup: Option<String>,
    guard: Mutex<()>,
}

impl SiteLockService {
    pub(super) fn new(state_dir: PathBuf, runner: Box<dyn NftRunner>) -> Self {
        Self::with_dns(state_dir, runner, Arc::new(NoQueue), None)
    }

    fn with_dns(
        state_dir: PathBuf,
        runner: Box<dyn NftRunner>,
        queue: Arc<dyn DnsQueue>,
        cgroup: Option<String>,
    ) -> Self {
        Self {
            state_dir,
            runner,
            queue,
            cgroup,
            guard: Mutex::new(()),
        }
    }

    /// Starts the queue before a ruleset that sends DNS to it is applied.
    fn prepare_dns(&self, names: &Names) -> Result<(), String> {
        if names.count() == 0 {
            return Ok(());
        }
        self.queue.start()?;
        self.queue.set_matcher(Matcher::new(names));
        Ok(())
    }

    fn render(&self, request: &SiteLockRequest, addresses: &Addresses) -> String {
        let dns = (request.names.count() > 0).then_some(DnsFilter {
            cgroup: self.cgroup.as_deref(),
        });
        ruleset(&request.tun, addresses, dns.as_ref())
    }

    #[cfg(target_os = "linux")]
    pub(super) fn system() -> Self {
        // SAFETY: getuid and getgid have no preconditions.
        let owner = super::linux::Owner {
            uid: unsafe { libc::getuid() },
            gid: unsafe { libc::getgid() },
        };
        let state_dir = std::env::var("STATE_DIRECTORY")
            .ok()
            .and_then(|value| value.split(':').next().map(PathBuf::from))
            .filter(|path| path.is_absolute())
            .unwrap_or_else(|| super::linux_install::state_path(owner));
        let cgroup = fs::read_to_string("/proc/self/cgroup")
            .ok()
            .and_then(|contents| cgroup_path(&contents));
        Self::with_dns(
            state_dir,
            Box::new(SystemNft),
            SystemQueue::shared(),
            cgroup,
        )
    }

    #[cfg(not(target_os = "linux"))]
    pub(super) fn system() -> Self {
        Self::new(PathBuf::new(), Box::new(SystemNft))
    }

    fn state_file(&self) -> PathBuf {
        self.state_dir.join(STATE_FILE)
    }

    fn load(&self) -> Result<Option<SiteLockRequest>, String> {
        match fs::read(self.state_file()) {
            Ok(bytes) => serde_json::from_slice(&bytes)
                .map(Some)
                .map_err(|error| format!("site lock state is unreadable: {error}")),
            Err(error) if error.kind() == ErrorKind::NotFound => Ok(None),
            Err(error) => Err(format!("site lock state cannot be read: {error}")),
        }
    }

    fn persist(&self, request: &SiteLockRequest) -> std::io::Result<()> {
        fs::create_dir_all(&self.state_dir)?;
        let temporary = self.state_dir.join(format!("{STATE_FILE}.tmp"));
        let _ = fs::remove_file(&temporary);
        let mut options = OpenOptions::new();
        options.write(true).create_new(true);
        #[cfg(unix)]
        options.mode(0o600);
        let mut file = options.open(&temporary)?;
        file.write_all(&serde_json::to_vec(request)?)?;
        file.sync_all()?;
        fs::rename(&temporary, self.state_file())
    }

    fn remove_state(&self) -> std::io::Result<()> {
        match fs::remove_file(self.state_file()) {
            Err(error) if error.kind() != ErrorKind::NotFound => Err(error),
            _ => Ok(()),
        }
    }

    /// Re-applies the persisted lock; a missing file is not an error.
    pub(super) fn restore(&self) -> Result<(), String> {
        let _guard = self.guard.lock().unwrap_or_else(|e| e.into_inner());
        let Some(request) = self.load()? else {
            return Ok(());
        };
        let addresses = normalize(&request)?;
        self.prepare_dns(&request.names)?;
        self.runner
            .apply(&self.render(&request, &addresses))
            .map_err(|error| format!("{error:?}"))
    }

    /// Drops the table and the persisted state; used by uninstall.
    pub(super) fn clear(&self) -> Result<(), String> {
        let _guard = self.guard.lock().unwrap_or_else(|e| e.into_inner());
        match self.runner.apply(&delete_ruleset()) {
            Ok(()) | Err(NftError::Missing) => {}
            Err(NftError::Failed(message)) => return Err(message),
        }
        self.remove_state().map_err(|error| error.to_string())
    }

    fn put(&self, request: SiteLockRequest) -> warp::reply::Response {
        if !cfg!(target_os = "linux") {
            return unsupported();
        }
        let addresses = match normalize(&request) {
            Ok(addresses) => addresses,
            Err(message) => {
                return error_response("invalidRequest", message, StatusCode::BAD_REQUEST)
            }
        };
        let _guard = self.guard.lock().unwrap_or_else(|e| e.into_inner());
        if let Err(message) = self.prepare_dns(&request.names) {
            return error_response(
                "dnsFilterFailed",
                message,
                StatusCode::INTERNAL_SERVER_ERROR,
            );
        }
        if let Err(response) = self.run(&self.render(&request, &addresses)) {
            return *response;
        }
        if let Err(error) = self.persist(&request) {
            return error_response(
                "internalError",
                format!("site lock is active but its state could not be saved: {error}"),
                StatusCode::INTERNAL_SERVER_ERROR,
            );
        }
        json_response(
            &serde_json::json!({
                "active": true,
                "addresses": addresses.count(),
                "names": request.names.count(),
            }),
            StatusCode::OK,
        )
    }

    fn delete(&self) -> warp::reply::Response {
        if !cfg!(target_os = "linux") {
            return unsupported();
        }
        let _guard = self.guard.lock().unwrap_or_else(|e| e.into_inner());
        match self.run(&delete_ruleset()) {
            Ok(()) => self.queue.set_matcher(Matcher::default()),
            // Without nft there is no table to delete unless a lock was persisted.
            Err(response) if self.state_file().exists() => return *response,
            Err(_) => {}
        }
        if let Err(error) = self.remove_state() {
            return error_response(
                "internalError",
                format!("site lock state could not be removed: {error}"),
                StatusCode::INTERNAL_SERVER_ERROR,
            );
        }
        json_response(&serde_json::json!({"active": false}), StatusCode::OK)
    }

    fn get(&self) -> warp::reply::Response {
        if !cfg!(target_os = "linux") {
            return unsupported();
        }
        let _guard = self.guard.lock().unwrap_or_else(|e| e.into_inner());
        let state = self.load().and_then(|request| {
            request
                .map(|request| {
                    normalize(&request)
                        .map(|addresses| (request.tun, addresses, request.names.count()))
                })
                .transpose()
        });
        match state {
            Ok(Some((tun, addresses, names))) => json_response(
                &serde_json::json!({
                    "active": true,
                    "tun": tun,
                    "addresses": addresses.count(),
                    "names": names,
                }),
                StatusCode::OK,
            ),
            Ok(None) => json_response(
                &serde_json::json!({"active": false, "tun": null, "addresses": 0, "names": 0}),
                StatusCode::OK,
            ),
            Err(message) => {
                error_response("internalError", message, StatusCode::INTERNAL_SERVER_ERROR)
            }
        }
    }

    fn run(&self, ruleset: &str) -> Result<(), Box<warp::reply::Response>> {
        self.runner.apply(ruleset).map_err(|error| {
            Box::new(match error {
                NftError::Missing => error_response(
                    "nftMissing",
                    "the nft binary was not found",
                    StatusCode::INTERNAL_SERVER_ERROR,
                ),
                NftError::Failed(message) => {
                    error_response("nftFailed", message, StatusCode::INTERNAL_SERVER_ERROR)
                }
            })
        })
    }
}

fn unsupported() -> warp::reply::Response {
    error_response(
        "unsupported",
        "site lock is only available on Linux",
        StatusCode::NOT_IMPLEMENTED,
    )
}

async fn blocking(
    service: Arc<SiteLockService>,
    work: impl FnOnce(&SiteLockService) -> warp::reply::Response + Send + 'static,
) -> Result<warp::reply::Response, Infallible> {
    Ok(tokio::task::spawn_blocking(move || work(&service))
        .await
        .unwrap_or_else(|error| {
            error_response(
                "internalError",
                format!("site lock task failed: {error}"),
                StatusCode::INTERNAL_SERVER_ERROR,
            )
        }))
}

pub(super) fn routes(
    service: Arc<SiteLockService>,
) -> impl Filter<Extract = (warp::reply::Response,), Error = Rejection> + Clone {
    let with_service = warp::any().map(move || service.clone());
    let base = warp::path("site-lock").and(warp::path::end());
    let put = base
        .and(warp::put())
        .and(with_service.clone())
        .and(warp::body::content_length_limit(MAX_BODY_BYTES))
        .and(warp::body::json())
        .and_then(|service, request: SiteLockRequest| {
            blocking(service, move |service| service.put(request))
        });
    let delete = base
        .and(warp::delete())
        .and(with_service.clone())
        .and_then(|service| blocking(service, SiteLockService::delete));
    let get = base
        .and(warp::get())
        .and(with_service)
        .and_then(|service| blocking(service, SiteLockService::get));
    put.or(delete).unify().or(get).unify()
}

#[cfg(all(test, target_os = "linux"))]
mod tests {
    use super::*;
    use crate::service::hub::{caller_routes_with, Caller};
    use crate::service::site_lock_dns::{MAX_NAMES, MAX_NAME_BYTES_TOTAL};
    use serde_json::{json, Value};
    use std::sync::atomic::{AtomicBool, Ordering};

    const CGROUP: &str = "system.slice/reclash-helper-1000.service";

    #[derive(Default)]
    struct FakeQueue {
        nft: Mutex<Option<Arc<FakeNft>>>,
        starts: Mutex<Vec<usize>>,
        matchers: Mutex<Vec<Arc<Matcher>>>,
        fail: AtomicBool,
    }

    impl DnsQueue for FakeQueue {
        fn start(&self) -> Result<(), String> {
            if self.fail.load(Ordering::SeqCst) {
                return Err("bind refused".to_string());
            }
            let applied = self
                .nft
                .lock()
                .unwrap()
                .as_ref()
                .map_or(0, |nft| nft.calls().len());
            self.starts.lock().unwrap().push(applied);
            Ok(())
        }

        fn set_matcher(&self, matcher: Matcher) {
            self.matchers.lock().unwrap().push(Arc::new(matcher));
        }
    }

    struct SharedQueue(Arc<FakeQueue>);

    impl DnsQueue for SharedQueue {
        fn start(&self) -> Result<(), String> {
            self.0.start()
        }

        fn set_matcher(&self, matcher: Matcher) {
            self.0.set_matcher(matcher)
        }
    }

    #[derive(Default)]
    struct FakeNft {
        calls: Mutex<Vec<String>>,
        outcome: Mutex<Option<NftError>>,
    }

    impl FakeNft {
        fn failing(error: NftError) -> Arc<Self> {
            let fake = Arc::new(Self::default());
            *fake.outcome.lock().unwrap() = Some(error);
            fake
        }

        fn calls(&self) -> Vec<String> {
            self.calls.lock().unwrap().clone()
        }
    }

    struct SharedNft(Arc<FakeNft>);

    impl NftRunner for SharedNft {
        fn apply(&self, ruleset: &str) -> Result<(), NftError> {
            self.0.calls.lock().unwrap().push(ruleset.to_string());
            match &*self.0.outcome.lock().unwrap() {
                Some(NftError::Missing) => Err(NftError::Missing),
                Some(NftError::Failed(message)) => Err(NftError::Failed(message.clone())),
                None => Ok(()),
            }
        }
    }

    struct Fixture {
        directory: PathBuf,
        fake: Arc<FakeNft>,
        queue: Arc<FakeQueue>,
        service: Arc<SiteLockService>,
    }

    impl Fixture {
        fn new(name: &str) -> Self {
            Self::with(name, Arc::new(FakeNft::default()))
        }

        fn with(name: &str, fake: Arc<FakeNft>) -> Self {
            Self::build(name, fake, Some(CGROUP))
        }

        fn build(name: &str, fake: Arc<FakeNft>, cgroup: Option<&str>) -> Self {
            let queue = Arc::new(FakeQueue::default());
            *queue.nft.lock().unwrap() = Some(fake.clone());
            let directory = std::env::temp_dir()
                .join(format!("reclash-sitelock-{name}-{}", std::process::id()));
            let _ = fs::remove_dir_all(&directory);
            fs::create_dir_all(&directory).unwrap();
            let service = Arc::new(SiteLockService::with_dns(
                directory.clone(),
                Box::new(SharedNft(fake.clone())),
                Arc::new(SharedQueue(queue.clone())),
                cgroup.map(str::to_string),
            ));
            Self {
                directory,
                fake,
                queue,
                service,
            }
        }

        async fn send(&self, method: &str, body: Option<Value>) -> (StatusCode, Value) {
            let mut request = warp::test::request().method(method).path("/site-lock");
            if let Some(body) = body {
                request = request.json(&body);
            }
            let response = request.reply(&routes(self.service.clone())).await;
            (
                response.status(),
                serde_json::from_slice(response.body()).unwrap(),
            )
        }
    }

    impl Drop for Fixture {
        fn drop(&mut self) {
            let _ = fs::remove_dir_all(&self.directory);
        }
    }

    fn request(tun: &str, addresses: &[&str]) -> SiteLockRequest {
        SiteLockRequest {
            tun: tun.to_string(),
            addresses: addresses.iter().map(|value| value.to_string()).collect(),
            names: Names::default(),
        }
    }

    fn named(tun: &str, suffix: &[&str]) -> SiteLockRequest {
        let mut request = request(tun, &["203.0.113.0/24"]);
        request.names.suffix = suffix.iter().map(|value| value.to_string()).collect();
        request
    }

    fn rules(tun: &str, addresses: &[&str]) -> String {
        let request = request(tun, addresses);
        ruleset(tun, &normalize(&request).unwrap(), None)
    }

    fn dns_rules(tun: &str, cgroup: Option<&str>) -> String {
        let request = named(tun, &["chatgpt.com"]);
        let filter = DnsFilter { cgroup };
        ruleset(tun, &normalize(&request).unwrap(), Some(&filter))
    }

    #[test]
    fn ruleset_holds_both_families_to_the_tun_in_output_and_forward() {
        let text = rules("tun0", &["203.0.113.0/24", "2001:db8::/32", "198.51.100.7"]);
        assert!(text.starts_with(
            "add table inet reclash_sitelock\ndelete table inet reclash_sitelock\ntable inet reclash_sitelock {\n"
        ));
        assert!(text.contains(
            "set v4 { type ipv4_addr; flags interval; auto-merge; elements = { 198.51.100.7, 203.0.113.0/24 }; }"
        ));
        assert!(text.contains(
            "set v6 { type ipv6_addr; flags interval; auto-merge; elements = { 2001:db8::/32 }; }"
        ));
        for hook in ["output", "forward"] {
            assert!(text.contains(&format!(
                "  chain {hook} {{\n    type filter hook {hook} priority filter; policy accept;\n    \
                 oifname \"tun0\" accept\n    \
                 meta l4proto tcp ip daddr @v4 reject with tcp reset\n    \
                 ip daddr @v4 reject with icmpx admin-prohibited\n    \
                 meta l4proto tcp ip6 daddr @v6 reject with tcp reset\n    \
                 ip6 daddr @v6 reject with icmpx admin-prohibited\n  }}\n"
            )));
        }
        assert!(text.ends_with("}\n"));
    }

    #[test]
    fn no_tun_leaves_no_way_out() {
        let text = rules("", &["203.0.113.0/24"]);
        assert!(!text.contains("oifname"));
        assert!(text
            .contains("policy accept;\n    meta l4proto tcp ip daddr @v4 reject with tcp reset\n"));
    }

    #[test]
    fn empty_sets_omit_the_elements_line() {
        let text = rules("tun0", &[]);
        assert!(text.contains("set v4 { type ipv4_addr; flags interval; auto-merge; }"));
        assert!(text.contains("set v6 { type ipv6_addr; flags interval; auto-merge; }"));
        assert!(!text.contains("elements"));
    }

    #[test]
    fn addresses_are_masked_deduplicated_and_mapped_into_v4() {
        let addresses = normalize(&request(
            "tun0",
            &[
                "10.1.2.3/8",
                "10.0.0.0/8",
                "10.9.9.9/8",
                "::ffff:192.0.2.1",
                "192.0.2.1",
                "::ffff:198.51.100.77/120",
                "2001:db8::1/32",
                "2001:db8::/32",
                "::1",
            ],
        ))
        .unwrap();
        assert_eq!(
            addresses.v4,
            vec![
                (u32::from_be_bytes([10, 0, 0, 0]), 8),
                (u32::from_be_bytes([192, 0, 2, 1]), 32),
                (u32::from_be_bytes([198, 51, 100, 0]), 24),
            ]
        );
        assert_eq!(addresses.v6.len(), 2);
        let text = ruleset("tun0", &addresses, None);
        assert!(text.contains("elements = { 10.0.0.0/8, 192.0.2.1, 198.51.100.0/24 }"));
        assert!(text.contains("elements = { ::1, 2001:db8::/32 }"));
    }

    #[test]
    fn zero_prefix_masks_everything() {
        let addresses = normalize(&request("tun0", &["1.2.3.4/0", "ffff::1/0"])).unwrap();
        assert_eq!(addresses.v4, vec![(0, 0)]);
        assert_eq!(addresses.v6, vec![(0, 0)]);
    }

    #[test]
    fn validation_rejects_bad_tun_names_entries_and_oversized_lists() {
        for tun in ["0123456789abcdef", "tun 0", "tun\"0", "tün", "a/b"] {
            assert!(normalize(&request(tun, &[])).is_err(), "{tun:?}");
        }
        for tun in ["", "t", "tun-0.x_Y", "012345678901234"] {
            assert!(normalize(&request(tun, &[])).is_ok(), "{tun:?}");
        }
        for entry in [
            "",
            "example.com",
            "1.2.3.4/33",
            "::1/129",
            "1.2.3.4/",
            "1.2.3.4/-1",
            "1.2.3.4/+1",
            "1.2.3/24",
            " 1.2.3.4",
            "1.2.3.4/8/8",
        ] {
            let error = normalize(&request("tun0", &["8.8.8.8", entry])).unwrap_err();
            assert!(error.contains(&format!("{entry:?}")), "{error}");
        }
        let many: Vec<String> = (0..=MAX_ADDRESSES)
            .map(|i| format!("10.0.{}.{}", i / 256, i % 256))
            .collect();
        let mut oversized = request("tun0", &[]);
        oversized.addresses = many.clone();
        assert!(normalize(&oversized).is_err());
        oversized.addresses = many[1..].to_vec();
        assert!(normalize(&oversized).is_ok());
        let mut bad_name = request("tun0", &[]);
        bad_name.names.full = vec!["a b".into()];
        assert!(normalize(&bad_name).is_err());
    }

    #[test]
    fn largest_valid_request_fits_the_route_body_limit() {
        let entry = "ffff:ffff:ffff:ffff:ffff:ffff:255.255.255.255/128";
        let per_name = MAX_NAME_BYTES_TOTAL / MAX_NAMES;
        let worst = "\"".repeat(per_name);
        let value = json!({
            "tun": "x".repeat(15),
            "addresses": vec![entry; MAX_ADDRESSES],
            "names": {"regex": vec![worst; MAX_NAMES]},
        });
        let body = serde_json::to_vec(&value).unwrap();
        assert!((body.len() as u64) < MAX_BODY_BYTES);
        let request: SiteLockRequest = serde_json::from_slice(&body).unwrap();
        assert!(normalize(&request).is_ok());
    }

    #[tokio::test]
    async fn put_applies_persists_and_reports_the_normalized_count() {
        let fixture = Fixture::new("put");
        let (status, body) = fixture
            .send(
                "PUT",
                Some(json!({"tun": "tun0", "addresses": ["10.0.0.1/8", "10.0.0.0/8", "2001:db8::1"]})),
            )
            .await;
        assert_eq!(status, StatusCode::OK);
        assert_eq!(body, json!({"active": true, "addresses": 2, "names": 0}));
        assert_eq!(fixture.fake.calls().len(), 1);
        let saved: Value =
            serde_json::from_slice(&fs::read(fixture.directory.join(STATE_FILE)).unwrap()).unwrap();
        assert_eq!(saved["tun"], "tun0");
        assert_eq!(saved["addresses"].as_array().unwrap().len(), 3);
        use std::os::unix::fs::PermissionsExt;
        let mode = fs::metadata(fixture.directory.join(STATE_FILE))
            .unwrap()
            .permissions()
            .mode();
        assert_eq!(mode & 0o777, 0o600);
        assert!(!fixture.directory.join("site-lock.json.tmp").exists());

        let (status, body) = fixture.send("GET", None).await;
        assert_eq!(status, StatusCode::OK);
        assert_eq!(
            body,
            json!({"active": true, "tun": "tun0", "addresses": 2, "names": 0})
        );
    }

    #[tokio::test]
    async fn invalid_put_is_a_bad_request_and_changes_nothing() {
        let fixture = Fixture::new("invalid");
        let (status, body) = fixture
            .send("PUT", Some(json!({"tun": "tun0", "addresses": ["nope"]})))
            .await;
        assert_eq!(status, StatusCode::BAD_REQUEST);
        assert_eq!(body["code"], "invalidRequest");
        assert!(body["message"].as_str().unwrap().contains("nope"));
        assert!(fixture.fake.calls().is_empty());
        assert!(!fixture.directory.join(STATE_FILE).exists());
    }

    #[tokio::test]
    async fn nft_failures_are_reported_and_not_persisted() {
        let fixture = Fixture::with("failing", FakeNft::failing(NftError::Failed("boom".into())));
        let (status, body) = fixture
            .send("PUT", Some(json!({"tun": "tun0", "addresses": []})))
            .await;
        assert_eq!(status, StatusCode::INTERNAL_SERVER_ERROR);
        assert_eq!(
            (body["code"].as_str(), body["message"].as_str()),
            (Some("nftFailed"), Some("boom"))
        );
        assert!(!fixture.directory.join(STATE_FILE).exists());

        let fixture = Fixture::with("missing", FakeNft::failing(NftError::Missing));
        let (status, body) = fixture
            .send("PUT", Some(json!({"tun": "tun0", "addresses": []})))
            .await;
        assert_eq!(status, StatusCode::INTERNAL_SERVER_ERROR);
        assert_eq!(body["code"], "nftMissing");
    }

    #[tokio::test]
    async fn delete_removes_the_table_and_state_and_get_reports_inactive() {
        let fixture = Fixture::new("delete");
        fixture
            .send(
                "PUT",
                Some(json!({"tun": "tun0", "addresses": ["10.0.0.0/8"]})),
            )
            .await;
        let (status, body) = fixture.send("DELETE", None).await;
        assert_eq!((status, body), (StatusCode::OK, json!({"active": false})));
        assert_eq!(fixture.fake.calls().last().unwrap(), &delete_ruleset());
        assert!(!fixture.directory.join(STATE_FILE).exists());
        let (_, body) = fixture.send("GET", None).await;
        assert_eq!(
            body,
            json!({"active": false, "tun": null, "addresses": 0, "names": 0})
        );
        let (status, _) = fixture.send("DELETE", None).await;
        assert_eq!(status, StatusCode::OK);
    }

    #[tokio::test]
    async fn delete_without_nft_succeeds_only_when_nothing_was_persisted() {
        let fixture = Fixture::with("delete-missing", FakeNft::failing(NftError::Missing));
        let (status, _) = fixture.send("DELETE", None).await;
        assert_eq!(status, StatusCode::OK);
        fs::write(
            fixture.directory.join(STATE_FILE),
            r#"{"tun":"tun0","addresses":[]}"#,
        )
        .unwrap();
        let (status, body) = fixture.send("DELETE", None).await;
        assert_eq!(
            (status, &body["code"]),
            (StatusCode::INTERNAL_SERVER_ERROR, &json!("nftMissing"))
        );
        assert!(fixture.directory.join(STATE_FILE).exists());
    }

    #[tokio::test]
    async fn endpoint_keeps_the_native_client_restrictions() {
        let fixture = Fixture::new("caller");
        let response = warp::test::request()
            .method("GET")
            .path("/site-lock")
            .header("origin", "https://example.com")
            .reply(&caller_routes_with(
                Caller::default(),
                fixture.service.clone(),
            ))
            .await;
        assert_eq!(response.status(), StatusCode::FORBIDDEN);
        let response = warp::test::request()
            .method("GET")
            .path("/site-lock")
            .reply(&caller_routes_with(
                Caller::default(),
                fixture.service.clone(),
            ))
            .await;
        assert_eq!(response.status(), StatusCode::OK);
    }

    #[test]
    fn restore_reapplies_the_persisted_request_without_rewriting_it() {
        let fixture = Fixture::new("restore");
        assert!(fixture.service.restore().is_ok());
        assert!(fixture.fake.calls().is_empty());
        fs::write(
            fixture.directory.join(STATE_FILE),
            r#"{"tun":"tun0","addresses":["10.0.0.0/8"]}"#,
        )
        .unwrap();
        fixture.service.restore().unwrap();
        let calls = fixture.fake.calls();
        assert_eq!(calls, vec![rules("tun0", &["10.0.0.0/8"])]);
    }

    #[test]
    fn restore_reports_nft_and_state_failures() {
        let fixture = Fixture::with(
            "restore-fail",
            FakeNft::failing(NftError::Failed("x".into())),
        );
        fs::write(
            fixture.directory.join(STATE_FILE),
            r#"{"tun":"tun0","addresses":[]}"#,
        )
        .unwrap();
        assert!(fixture.service.restore().is_err());
        fs::write(fixture.directory.join(STATE_FILE), "garbage").unwrap();
        assert!(fixture.service.restore().is_err());
    }

    #[test]
    fn clear_deletes_the_table_and_the_state_file() {
        let fixture = Fixture::new("clear");
        fs::write(fixture.directory.join(STATE_FILE), "{}").unwrap();
        fixture.service.clear().unwrap();
        assert_eq!(fixture.fake.calls(), vec![delete_ruleset()]);
        assert!(!fixture.directory.join(STATE_FILE).exists());
    }

    #[test]
    fn dns_ruleset_queues_off_tun_dns_after_the_exemptions() {
        let text = dns_rules("tun0", Some(CGROUP));
        let queue = "meta l4proto { tcp, udp } th dport 53 queue num 31415";
        let cgroup = format!(
            "socket cgroupv2 level 2 \"{CGROUP}\" meta l4proto {{ tcp, udp }} th dport 53 accept"
        );
        assert!(text.contains(&format!(
            "  chain output {{\n    type filter hook output priority filter; policy accept;\n    \
             oifname \"lo\" accept\n    oifname \"tun0\" accept\n    {cgroup}\n    {queue}\n    \
             meta l4proto tcp ip daddr @v4 reject with tcp reset\n"
        )));
        assert!(text.contains(&format!(
            "  chain forward {{\n    type filter hook forward priority filter; policy accept;\n    \
             oifname \"tun0\" accept\n    {queue}\n    meta l4proto tcp ip daddr @v4 reject"
        )));
    }

    #[test]
    fn dns_ruleset_without_tun_or_cgroup_drops_those_lines() {
        let text = dns_rules("", None);
        assert!(text.contains("policy accept;\n    oifname \"lo\" accept\n    meta l4proto { tcp, udp } th dport 53 queue num 31415\n"));
        assert!(!text.contains("cgroupv2"));
        assert_eq!(text.matches("oifname").count(), 1);
    }

    #[test]
    fn without_names_the_ruleset_has_no_queue_rules() {
        let text = rules("tun0", &["10.0.0.0/8"]);
        assert!(!text.contains("queue") && !text.contains("\"lo\""));
    }

    #[test]
    fn cgroup_path_comes_from_the_unified_hierarchy_line() {
        let contents = "1:name=x:/legacy\n0::/system.slice/reclash-helper-1000.service\n";
        assert_eq!(cgroup_path(contents).as_deref(), Some(CGROUP));
        assert_eq!(cgroup_path("0::/\n"), None);
        assert_eq!(cgroup_path("1:cpu:/a\n"), None);
        assert_eq!(cgroup_path("0::/a\"b\n"), None);
    }

    #[tokio::test]
    async fn put_with_names_starts_the_queue_before_applying() {
        let fixture = Fixture::new("names");
        let request = named("tun0", &["chatgpt.com"]);
        let (status, body) = fixture
            .send("PUT", Some(serde_json::to_value(&request).unwrap()))
            .await;
        assert_eq!(status, StatusCode::OK);
        assert_eq!(body, json!({"active": true, "addresses": 1, "names": 1}));
        assert_eq!(*fixture.queue.starts.lock().unwrap(), vec![0]);
        {
            let matchers = fixture.queue.matchers.lock().unwrap();
            assert!(matchers[0].matches("api.chatgpt.com"));
            assert!(!matchers[0].matches("notchatgpt.com"));
        }
        assert!(fixture.fake.calls()[0].contains("queue num 31415"));
        let (_, body) = fixture.send("GET", None).await;
        assert_eq!(body["names"], 1);
        fixture.send("DELETE", None).await;
        assert!(!fixture
            .queue
            .matchers
            .lock()
            .unwrap()
            .last()
            .unwrap()
            .matches("chatgpt.com"));
    }

    #[tokio::test]
    async fn queue_bind_failure_is_reported_and_nothing_is_applied() {
        let fixture = Fixture::new("bind-fail");
        fixture.queue.fail.store(true, Ordering::SeqCst);
        let request = named("tun0", &["chatgpt.com"]);
        let (status, body) = fixture
            .send("PUT", Some(serde_json::to_value(&request).unwrap()))
            .await;
        assert_eq!(status, StatusCode::INTERNAL_SERVER_ERROR);
        assert_eq!(body["code"], "dnsFilterFailed");
        assert!(fixture.fake.calls().is_empty());
        assert!(!fixture.directory.join(STATE_FILE).exists());
    }

    #[tokio::test]
    async fn put_without_names_never_touches_the_queue() {
        let fixture = Fixture::new("no-names");
        fixture.queue.fail.store(true, Ordering::SeqCst);
        let (status, _) = fixture
            .send("PUT", Some(json!({"tun": "tun0", "addresses": []})))
            .await;
        assert_eq!(status, StatusCode::OK);
    }

    #[test]
    fn restore_with_names_starts_the_queue_before_applying() {
        let fixture = Fixture::new("restore-names");
        let request = named("tun0", &["chatgpt.com"]);
        fs::write(
            fixture.directory.join(STATE_FILE),
            serde_json::to_vec(&request).unwrap(),
        )
        .unwrap();
        fixture.service.restore().unwrap();
        assert_eq!(*fixture.queue.starts.lock().unwrap(), vec![0]);
        assert_eq!(fixture.fake.calls().len(), 1);
        assert!(fixture.fake.calls()[0].contains("socket cgroupv2 level 2"));

        let failing = Fixture::new("restore-names-fail");
        failing.queue.fail.store(true, Ordering::SeqCst);
        fs::write(
            failing.directory.join(STATE_FILE),
            serde_json::to_vec(&request).unwrap(),
        )
        .unwrap();
        assert!(failing.service.restore().is_err());
        assert!(failing.fake.calls().is_empty());
    }

    #[test]
    fn unknown_name_kinds_are_rejected() {
        let body = json!({"tun": "tun0", "addresses": [], "names": {"glob": ["a"]}});
        assert!(serde_json::from_value::<SiteLockRequest>(body).is_err());
    }
}
