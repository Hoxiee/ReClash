use super::hub::{error_response, json_response};
use super::site_lock::{
    host_response, readable_listing, remove_optional, validate_tun, write_atomic, HostError,
    NftRunner,
};
use serde::{Deserialize, Serialize};
use std::convert::Infallible;
use std::fs;
use std::io::ErrorKind;
use std::path::PathBuf;
use std::sync::{Arc, Mutex};
use warp::http::StatusCode;
use warp::{Filter, Rejection};

const CONFIG_FILE: &str = "kill-switch.json";
const ARM_FILE: &str = "kill-switch-armed.json";
const MAX_BODY_BYTES: u64 = 4 * 1024;
const SUPPORTED: bool = cfg!(any(
    target_os = "linux",
    all(windows, feature = "windows-service")
));

#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
#[serde(rename_all = "lowercase")]
pub(super) enum Mode {
    /// Armed when the TUN comes up during a run, until disarmed.
    Standard,
    /// Armed whenever configured, from boot.
    Always,
}

#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
#[serde(deny_unknown_fields, rename_all = "camelCase")]
pub(super) struct KillSwitchConfig {
    pub(super) mode: Mode,
    pub(super) tun: String,
    pub(super) allow_lan: bool,
}

#[derive(Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
struct ArmFlag {
    boot_id: String,
}

/// What blocks traffic outside the TUN: nft on Linux, WFP on Windows.
pub(super) trait KillSwitchLayer: Send + Sync {
    fn layer(&self) -> &'static str;
    /// The problem code GET reports while an armed block is not in place.
    fn failure(&self) -> &'static str;
    fn apply(&self, config: &KillSwitchConfig) -> Result<(), HostError>;
    /// The live block as text, or `None` while none is in place.
    fn listing(&self) -> Result<Option<String>, HostError>;
    /// Whether the live block is the one `config` produces.
    fn holds(&self, config: &KillSwitchConfig, listing: &str) -> bool;
    fn lift(&self) -> Result<(), HostError>;
}

pub(super) struct NftKillSwitch {
    table: String,
    runner: Box<dyn NftRunner>,
    cgroup: Option<String>,
}

impl NftKillSwitch {
    pub(super) fn new(uid: u32, runner: Box<dyn NftRunner>, cgroup: Option<String>) -> Self {
        Self {
            table: format!("reclash_killswitch_{uid}"),
            runner,
            cgroup,
        }
    }
}

const ALWAYS_OPEN: &str = "    udp sport 68 udp dport 67 accept\n    \
    udp sport 546 udp dport 547 accept\n    \
    icmpv6 type { nd-router-solicit, nd-router-advert, nd-neighbor-solicit, nd-neighbor-advert } accept\n    \
    ip daddr { 169.254.0.0/16, 224.0.0.0/4, 255.255.255.255 } accept\n    \
    ip6 daddr { fe80::/10, ff00::/8 } accept\n";
const LAN: &str = "    ip daddr { 10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16 } accept\n    \
    ip6 daddr fc00::/7 accept\n";

// Forwarded traffic always reaches the LAN so container bridges keep working.
fn chain_block(name: &str, config: &KillSwitchConfig, cgroup: Option<&str>) -> String {
    let mut rules = String::from("    oifname \"lo\" accept\n");
    if !config.tun.is_empty() {
        rules.push_str(&format!("    oifname \"{}\" accept\n", config.tun));
    }
    if let Some(cgroup) = cgroup {
        let level = cgroup.split('/').count();
        rules.push_str(&format!(
            "    socket cgroupv2 level {level} \"{cgroup}\" accept\n"
        ));
    }
    rules.push_str(ALWAYS_OPEN);
    if config.allow_lan || name == "forward" {
        rules.push_str(LAN);
    }
    format!(
        "  chain {name} {{\n    type filter hook {name} priority filter; policy accept;\n\
         {rules}    meta l4proto tcp reject with tcp reset\n    \
         reject with icmpx admin-prohibited\n  }}\n"
    )
}

fn ruleset(table: &str, config: &KillSwitchConfig, cgroup: Option<&str>) -> String {
    format!(
        "add table inet {table}\ndelete table inet {table}\ntable inet {table} {{\n{}{}}}\n",
        chain_block("output", config, cgroup),
        chain_block("forward", config, None),
    )
}

impl KillSwitchLayer for NftKillSwitch {
    fn layer(&self) -> &'static str {
        "nftables"
    }

    fn failure(&self) -> &'static str {
        "nftFailed"
    }

    fn apply(&self, config: &KillSwitchConfig) -> Result<(), HostError> {
        let cgroup = self.cgroup.as_deref().ok_or_else(|| {
            HostError::Failed(
                "nftFailed",
                "the Helper's cgroup is unknown, so the Core could not be exempted from the block"
                    .to_string(),
            )
        })?;
        Ok(self
            .runner
            .apply(&ruleset(&self.table, config, Some(cgroup)))?)
    }

    fn listing(&self) -> Result<Option<String>, HostError> {
        Ok(self.runner.listing(&self.table)?)
    }

    // `nft list` prints a different ruleset than the one nft reads, so only what a
    // config changes is compared: the TUN let through and whether output reaches the LAN.
    fn holds(&self, config: &KillSwitchConfig, listing: &str) -> bool {
        let output = listing.split("chain forward").next().unwrap_or_default();
        let tun = config.tun.is_empty()
            || listing.contains(&format!("oifname \"{}\" accept", config.tun));
        tun && output.contains("192.168.0.0/16") == config.allow_lan
    }

    fn lift(&self) -> Result<(), HostError> {
        let table = &self.table;
        Ok(self.runner.apply(&format!(
            "add table inet {table}\ndelete table inet {table}\n"
        ))?)
    }
}

pub(super) struct KillSwitchService {
    state_dir: PathBuf,
    /// This boot's identity; a standard arm flag from another boot reads as disarmed.
    boot_id: Option<String>,
    layer: Box<dyn KillSwitchLayer>,
    guard: Mutex<()>,
}

impl KillSwitchService {
    pub(super) fn new(
        state_dir: PathBuf,
        boot_id: Option<String>,
        layer: Box<dyn KillSwitchLayer>,
    ) -> Self {
        Self {
            state_dir,
            boot_id,
            layer,
            guard: Mutex::new(()),
        }
    }

    #[cfg(target_os = "linux")]
    pub(super) fn system() -> Self {
        // SAFETY: getuid and getgid have no preconditions.
        let owner = super::linux::Owner {
            uid: unsafe { libc::getuid() },
            gid: unsafe { libc::getgid() },
        };
        let boot_id = fs::read_to_string("/proc/sys/kernel/random/boot_id")
            .ok()
            .map(|value| value.trim().to_string())
            .filter(|value| !value.is_empty());
        let layer = NftKillSwitch::new(
            owner.uid,
            Box::new(super::site_lock::SystemNft),
            super::site_lock::own_cgroup(),
        );
        Self::new(
            super::site_lock::system_state_dir(owner),
            boot_id,
            Box::new(layer),
        )
    }

    #[cfg(all(windows, feature = "windows-service"))]
    pub(super) fn system() -> Self {
        use super::kill_switch_windows::{boot_id, WindowsKillSwitch};
        let state_dir = super::windows_install::install_root_path().unwrap_or_default();
        Self::new(state_dir, boot_id(), Box::new(WindowsKillSwitch::default()))
    }

    #[cfg(not(any(target_os = "linux", all(windows, feature = "windows-service"))))]
    pub(super) fn system() -> Self {
        Self::new(
            PathBuf::new(),
            None,
            Box::new(NftKillSwitch::new(
                0,
                Box::new(super::site_lock::SystemNft),
                None,
            )),
        )
    }

    fn config(&self) -> Result<Option<KillSwitchConfig>, String> {
        match fs::read(self.state_dir.join(CONFIG_FILE)) {
            Ok(bytes) => serde_json::from_slice(&bytes)
                .map(Some)
                .map_err(|error| format!("kill switch state is unreadable: {error}")),
            Err(error) if error.kind() == ErrorKind::NotFound => Ok(None),
            Err(error) => Err(format!("kill switch state cannot be read: {error}")),
        }
    }

    fn flagged(&self) -> bool {
        let Some(boot_id) = &self.boot_id else {
            return false;
        };
        fs::read(self.state_dir.join(ARM_FILE))
            .ok()
            .and_then(|bytes| serde_json::from_slice::<ArmFlag>(&bytes).ok())
            .is_some_and(|flag| &flag.boot_id == boot_id)
    }

    fn armed(&self, config: &KillSwitchConfig) -> bool {
        config.mode == Mode::Always || self.flagged()
    }

    fn remove_files(&self, names: &[&str]) -> std::io::Result<()> {
        names
            .iter()
            .try_for_each(|name| remove_optional(&self.state_dir.join(name)))
    }

    fn present(&self) -> Result<bool, HostError> {
        self.layer.listing().map(|listing| listing.is_some())
    }

    /// Arms a standard kill switch and applies any armed block.
    pub(super) fn arm(&self) -> Result<(), String> {
        let _guard = self.guard.lock().unwrap_or_else(|e| e.into_inner());
        let Some(config) = self.config()? else {
            return Ok(());
        };
        if config.mode == Mode::Standard {
            let boot_id = self
                .boot_id
                .clone()
                .ok_or("the boot identity is unknown, so the arm cannot be recorded")?;
            let flag = serde_json::to_vec(&ArmFlag { boot_id }).map_err(|e| e.to_string())?;
            write_atomic(&self.state_dir, ARM_FILE, &flag).map_err(|e| e.to_string())?;
        }
        self.layer.apply(&config).map_err(|error| error.to_string())
    }

    /// Applies the block when armed and lifts a leftover one otherwise.
    pub(super) fn restore(&self) -> Result<(), String> {
        let _guard = self.guard.lock().unwrap_or_else(|e| e.into_inner());
        match self.config()?.filter(|config| self.armed(config)) {
            Some(config) => self.layer.apply(&config).map_err(|error| error.to_string()),
            None => self.lift_present().map(drop),
        }
    }

    /// Re-applies an armed block the system lost or that no longer matches the config,
    /// and lifts one left while disarmed; true when it changed anything.
    pub(super) fn heal(&self) -> Result<bool, String> {
        let _guard = self.guard.lock().unwrap_or_else(|e| e.into_inner());
        let Some(config) = self.config()?.filter(|config| self.armed(config)) else {
            return self.lift_present();
        };
        let listing = self.layer.listing().map_err(|error| error.to_string())?;
        if listing.is_some_and(|listing| self.layer.holds(&config, &listing)) {
            return Ok(false);
        }
        self.layer
            .apply(&config)
            .map(|()| true)
            .map_err(|error| error.to_string())
    }

    fn lift_present(&self) -> Result<bool, String> {
        match self.present() {
            Ok(true) => self.layer.lift().map(|()| true).map_err(|e| e.to_string()),
            Ok(false) | Err(HostError::Missing) => Ok(false),
            Err(error) => Err(error.to_string()),
        }
    }

    /// Lifts the block and drops config and arm flag; used by uninstall.
    pub(super) fn clear(&self) -> Result<(), String> {
        let _guard = self.guard.lock().unwrap_or_else(|e| e.into_inner());
        match self.layer.lift() {
            Ok(()) | Err(HostError::Missing) => {}
            Err(HostError::Failed(_, message)) => return Err(message),
        }
        self.remove_files(&[CONFIG_FILE, ARM_FILE])
            .map_err(|error| error.to_string())
    }

    fn put(&self, config: KillSwitchConfig) -> warp::reply::Response {
        if !SUPPORTED {
            return unsupported();
        }
        if let Err(message) = validate_tun(&config.tun) {
            return error_response("invalidRequest", message, StatusCode::BAD_REQUEST);
        }
        let _guard = self.guard.lock().unwrap_or_else(|e| e.into_inner());
        let outcome = if self.armed(&config) {
            self.layer.apply(&config)
        } else {
            match self.layer.lift() {
                Err(HostError::Missing) => Ok(()),
                outcome => outcome,
            }
        };
        if let Err(error) = outcome {
            return host_response(error);
        }
        let saved = serde_json::to_vec(&config)
            .map_err(std::io::Error::from)
            .and_then(|bytes| write_atomic(&self.state_dir, CONFIG_FILE, &bytes));
        if let Err(error) = saved {
            return error_response(
                "internalError",
                format!("kill switch state could not be saved: {error}"),
                StatusCode::INTERNAL_SERVER_ERROR,
            );
        }
        json_response(&serde_json::json!({"ok": true}), StatusCode::OK)
    }

    fn delete(&self) -> warp::reply::Response {
        if !SUPPORTED {
            return unsupported();
        }
        let _guard = self.guard.lock().unwrap_or_else(|e| e.into_inner());
        let configured = self.state_dir.join(CONFIG_FILE).exists();
        match self.layer.lift() {
            Ok(()) => {}
            // Without nft there is no table to delete unless a kill switch was configured.
            Err(error) if configured => return host_response(error),
            Err(_) => {}
        }
        if let Err(error) = self.remove_files(&[CONFIG_FILE, ARM_FILE]) {
            return error_response(
                "internalError",
                format!("kill switch state could not be removed: {error}"),
                StatusCode::INTERNAL_SERVER_ERROR,
            );
        }
        json_response(&serde_json::json!({"ok": true}), StatusCode::OK)
    }

    /// Arms again after a TUN start that did not go through a Core launch, such as
    /// TUN turned back on while the Core kept running.
    fn arm_request(&self) -> warp::reply::Response {
        if !SUPPORTED {
            return unsupported();
        }
        if let Err(message) = self.arm() {
            return error_response("internalError", message, StatusCode::INTERNAL_SERVER_ERROR);
        }
        let armed = matches!(self.config(), Ok(Some(_)));
        json_response(&serde_json::json!({"armed": armed}), StatusCode::OK)
    }

    fn disarm(&self) -> warp::reply::Response {
        if !SUPPORTED {
            return unsupported();
        }
        let _guard = self.guard.lock().unwrap_or_else(|e| e.into_inner());
        let config = match self.config() {
            Ok(config) => config,
            Err(message) => {
                return error_response("internalError", message, StatusCode::INTERNAL_SERVER_ERROR)
            }
        };
        if config.is_some_and(|config| config.mode == Mode::Always) {
            return json_response(&serde_json::json!({"armed": true}), StatusCode::OK);
        }
        if let Err(error) = self.remove_files(&[ARM_FILE]) {
            return error_response(
                "internalError",
                format!("kill switch arm flag could not be removed: {error}"),
                StatusCode::INTERNAL_SERVER_ERROR,
            );
        }
        match self.layer.lift() {
            Ok(()) | Err(HostError::Missing) => {}
            Err(error) => return host_response(error),
        }
        json_response(&serde_json::json!({"armed": false}), StatusCode::OK)
    }

    fn get(&self) -> warp::reply::Response {
        if !SUPPORTED {
            return unsupported();
        }
        let _guard = self.guard.lock().unwrap_or_else(|e| e.into_inner());
        let config = match self.config() {
            Ok(config) => config,
            Err(message) => {
                return error_response("internalError", message, StatusCode::INTERNAL_SERVER_ERROR)
            }
        };
        let armed = config.as_ref().is_some_and(|config| self.armed(config));
        let (listing, problem) = match self.layer.listing() {
            Ok(listing) => {
                let missing = armed && listing.is_none();
                (listing, missing.then(|| self.layer.failure()))
            }
            Err(HostError::Missing) => (None, Some("nftMissing")),
            Err(HostError::Failed(code, _)) => (None, Some(code)),
        };
        json_response(
            &serde_json::json!({
                "configured": config.is_some(),
                "mode": config.as_ref().map(|config| config.mode),
                "allowLan": config.as_ref().is_some_and(|config| config.allow_lan),
                "tun": config.as_ref().map(|config| config.tun.clone()),
                "armed": armed,
                "active": listing.is_some(),
                "layer": self.layer.layer(),
                "problem": problem,
                "ruleset": listing.map(|text| readable_listing(&text)),
            }),
            StatusCode::OK,
        )
    }
}

fn unsupported() -> warp::reply::Response {
    error_response(
        "unsupported",
        "the kill switch is not available on this system",
        StatusCode::NOT_IMPLEMENTED,
    )
}

async fn blocking(
    service: Arc<KillSwitchService>,
    work: impl FnOnce(&KillSwitchService) -> warp::reply::Response + Send + 'static,
) -> Result<warp::reply::Response, Infallible> {
    Ok(tokio::task::spawn_blocking(move || work(&service))
        .await
        .unwrap_or_else(|error| {
            error_response(
                "internalError",
                format!("kill switch task failed: {error}"),
                StatusCode::INTERNAL_SERVER_ERROR,
            )
        }))
}

pub(super) fn routes(
    service: Arc<KillSwitchService>,
) -> impl Filter<Extract = (warp::reply::Response,), Error = Rejection> + Clone {
    let with_service = warp::any().map(move || service.clone());
    let base = warp::path("kill-switch").and(warp::path::end());
    let put = base
        .and(warp::put())
        .and(with_service.clone())
        .and(warp::body::content_length_limit(MAX_BODY_BYTES))
        .and(warp::body::json())
        .and_then(|service, config: KillSwitchConfig| {
            blocking(service, move |service| service.put(config))
        });
    let delete = base
        .and(warp::delete())
        .and(with_service.clone())
        .and_then(|service| blocking(service, KillSwitchService::delete));
    let get = base
        .and(warp::get())
        .and(with_service.clone())
        .and_then(|service| blocking(service, KillSwitchService::get));
    let arm = warp::path!("kill-switch" / "arm")
        .and(warp::post())
        .and(with_service.clone())
        .and_then(|service| blocking(service, KillSwitchService::arm_request));
    let disarm = warp::path!("kill-switch" / "disarm")
        .and(warp::post())
        .and(with_service)
        .and_then(|service| blocking(service, KillSwitchService::disarm));
    put.or(delete)
        .unify()
        .or(get)
        .unify()
        .or(arm)
        .unify()
        .or(disarm)
        .unify()
}

#[cfg(all(test, target_os = "linux"))]
mod tests {
    use super::*;
    use crate::service::site_lock::NftError;
    use serde_json::{json, Value};

    const CGROUP: &str = "system.slice/reclash-helper-1000.service";
    const TABLE: &str = "reclash_killswitch_1000";
    const DELETE: &str =
        "add table inet reclash_killswitch_1000\ndelete table inet reclash_killswitch_1000\n";

    #[derive(Default)]
    struct FakeNft {
        calls: Mutex<Vec<String>>,
        refusal: Mutex<Option<String>>,
        listed: Mutex<Option<String>>,
        listing_failure: Mutex<Option<NftError>>,
    }

    impl FakeNft {
        fn calls(&self) -> Vec<String> {
            self.calls.lock().unwrap().clone()
        }
    }

    struct SharedNft(Arc<FakeNft>);

    impl NftRunner for SharedNft {
        fn apply(&self, ruleset: &str) -> Result<(), NftError> {
            self.0.calls.lock().unwrap().push(ruleset.to_string());
            match &*self.0.refusal.lock().unwrap() {
                Some(message) => Err(NftError::Failed(message.clone())),
                None => Ok(()),
            }
        }

        fn stored(&self, table: &str) -> Result<Option<String>, NftError> {
            self.listing(table)
        }

        fn listing(&self, _table: &str) -> Result<Option<String>, NftError> {
            match &*self.0.listing_failure.lock().unwrap() {
                Some(NftError::Missing) => Err(NftError::Missing),
                Some(NftError::Failed(message)) => Err(NftError::Failed(message.clone())),
                None => Ok(self.0.listed.lock().unwrap().clone()),
            }
        }
    }

    fn build_service(
        directory: PathBuf,
        fake: &Arc<FakeNft>,
        boot: Option<&str>,
    ) -> KillSwitchService {
        let layer = NftKillSwitch::new(
            1000,
            Box::new(SharedNft(fake.clone())),
            Some(CGROUP.to_string()),
        );
        KillSwitchService::new(directory, boot.map(str::to_string), Box::new(layer))
    }

    struct Fixture {
        directory: PathBuf,
        fake: Arc<FakeNft>,
        service: Arc<KillSwitchService>,
    }

    impl Fixture {
        fn new(name: &str) -> Self {
            let directory = std::env::temp_dir()
                .join(format!("reclash-killswitch-{name}-{}", std::process::id()));
            let _ = fs::remove_dir_all(&directory);
            fs::create_dir_all(&directory).unwrap();
            let fake = Arc::new(FakeNft::default());
            let service = Arc::new(build_service(directory.clone(), &fake, Some("boot-a")));
            Self {
                directory,
                fake,
                service,
            }
        }

        fn restarted(&self, boot: &str) -> Arc<KillSwitchService> {
            Arc::new(build_service(
                self.directory.clone(),
                &self.fake,
                Some(boot),
            ))
        }
    }

    impl Drop for Fixture {
        fn drop(&mut self) {
            let _ = fs::remove_dir_all(&self.directory);
        }
    }

    async fn send(
        service: &Arc<KillSwitchService>,
        method: &str,
        path: &str,
        body: Option<Value>,
    ) -> (StatusCode, Value) {
        let mut request = warp::test::request().method(method).path(path);
        if let Some(body) = body {
            request = request.json(&body);
        }
        let response = request.reply(&routes(service.clone())).await;
        (
            response.status(),
            serde_json::from_slice(response.body()).unwrap_or(Value::Null),
        )
    }

    fn body(mode: &str, tun: &str, allow_lan: bool) -> Value {
        json!({"mode": mode, "tun": tun, "allowLan": allow_lan})
    }

    fn config(mode: Mode, allow_lan: bool) -> KillSwitchConfig {
        KillSwitchConfig {
            mode,
            tun: "tun0".to_string(),
            allow_lan,
        }
    }

    #[test]
    fn standard_ruleset_lets_only_the_tun_and_local_traffic_out() {
        let text = ruleset(TABLE, &config(Mode::Standard, false), Some(CGROUP));
        assert!(text.starts_with(&format!("{DELETE}table inet {TABLE} {{\n")));
        let (output, forward) = text.split_once("  chain forward {").unwrap();
        for line in [
            "oifname \"lo\" accept",
            "oifname \"tun0\" accept",
            "socket cgroupv2 level 2 \"system.slice/reclash-helper-1000.service\" accept",
            "udp sport 68 udp dport 67 accept",
            "icmpv6 type { nd-router-solicit, nd-router-advert, nd-neighbor-solicit, nd-neighbor-advert } accept",
            "ip daddr { 169.254.0.0/16, 224.0.0.0/4, 255.255.255.255 } accept",
        ] {
            assert!(output.contains(line), "{line}");
        }
        assert!(!output.contains("192.168.0.0/16"));
        assert!(output.ends_with(
            "    meta l4proto tcp reject with tcp reset\n    reject with icmpx admin-prohibited\n  }\n"
        ));
        assert!(forward.contains("ip daddr { 10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16 } accept"));
        assert!(!forward.contains("cgroupv2"));
    }

    #[test]
    fn allow_lan_adds_the_private_ranges_to_output_too() {
        let text = ruleset(TABLE, &config(Mode::Standard, true), Some(CGROUP));
        let (output, _) = text.split_once("  chain forward {").unwrap();
        assert!(output.contains("ip daddr { 10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16 } accept"));
        assert!(output.contains("ip6 daddr fc00::/7 accept"));
    }

    #[tokio::test]
    async fn put_standard_before_any_start_saves_config_and_applies_nothing() {
        let fixture = Fixture::new("put-standard");
        let (status, response) = send(
            &fixture.service,
            "PUT",
            "/kill-switch",
            Some(body("standard", "tun0", false)),
        )
        .await;
        assert_eq!((status, response), (StatusCode::OK, json!({"ok": true})));
        assert_eq!(fixture.fake.calls(), vec![DELETE.to_string()]);
        assert!(fixture.directory.join(CONFIG_FILE).exists());
        let (status, response) = send(&fixture.service, "GET", "/kill-switch", None).await;
        assert_eq!(status, StatusCode::OK);
        assert_eq!(response["configured"], true);
        assert_eq!(response["armed"], false);
    }

    #[tokio::test]
    async fn arm_records_the_boot_and_a_restart_on_the_same_boot_reapplies_it() {
        let fixture = Fixture::new("arm");
        send(
            &fixture.service,
            "PUT",
            "/kill-switch",
            Some(body("standard", "tun0", false)),
        )
        .await;
        fixture.service.arm().unwrap();
        let calls = fixture.fake.calls();
        assert_eq!(calls.len(), 2);
        assert!(calls[1].contains("oifname \"tun0\" accept"));
        let flag = fs::read_to_string(fixture.directory.join(ARM_FILE)).unwrap();
        assert!(flag.contains("boot-a"));

        let restarted = fixture.restarted("boot-a");
        let (_, response) = send(&restarted, "GET", "/kill-switch", None).await;
        assert_eq!(response["armed"], true);
        restarted.restore().unwrap();
        let calls = fixture.fake.calls();
        assert_eq!(calls.len(), 3);
        assert_eq!(calls[2], calls[1]);
    }

    #[tokio::test]
    async fn an_arm_flag_from_another_boot_reads_as_disarmed() {
        let fixture = Fixture::new("other-boot");
        send(
            &fixture.service,
            "PUT",
            "/kill-switch",
            Some(body("standard", "tun0", false)),
        )
        .await;
        fixture.service.arm().unwrap();
        let next = fixture.restarted("boot-b");
        let (_, response) = send(&next, "GET", "/kill-switch", None).await;
        assert_eq!(response["armed"], false);

        let before = fixture.fake.calls().len();
        next.restore().unwrap();
        assert_eq!(fixture.fake.calls().len(), before);

        *fixture.fake.listed.lock().unwrap() = Some(format!("table inet {TABLE} {{\n}}\n"));
        next.restore().unwrap();
        assert_eq!(fixture.fake.calls().last().unwrap(), DELETE);
    }

    #[tokio::test]
    async fn always_mode_applies_on_put_without_arming() {
        let fixture = Fixture::new("always");
        let (status, _) = send(
            &fixture.service,
            "PUT",
            "/kill-switch",
            Some(body("always", "tun0", false)),
        )
        .await;
        assert_eq!(status, StatusCode::OK);
        let calls = fixture.fake.calls();
        assert_eq!(calls.len(), 1);
        assert!(calls[0].contains(&format!("table inet {TABLE} {{")));
        let (_, response) = send(&fixture.service, "GET", "/kill-switch", None).await;
        assert_eq!(response["armed"], true);
        assert_eq!(response["mode"], "always");
    }

    #[tokio::test]
    async fn disarm_lifts_a_standard_block_but_never_an_always_one() {
        let fixture = Fixture::new("disarm");
        send(
            &fixture.service,
            "PUT",
            "/kill-switch",
            Some(body("standard", "tun0", false)),
        )
        .await;
        fixture.service.arm().unwrap();
        let (status, response) = send(&fixture.service, "POST", "/kill-switch/disarm", None).await;
        assert_eq!(
            (status, response),
            (StatusCode::OK, json!({"armed": false}))
        );
        assert!(!fixture.directory.join(ARM_FILE).exists());
        assert_eq!(fixture.fake.calls().last().unwrap(), DELETE);

        send(
            &fixture.service,
            "PUT",
            "/kill-switch",
            Some(body("always", "tun0", false)),
        )
        .await;
        let before = fixture.fake.calls().len();
        let (status, response) = send(&fixture.service, "POST", "/kill-switch/disarm", None).await;
        assert_eq!((status, response), (StatusCode::OK, json!({"armed": true})));
        assert_eq!(fixture.fake.calls().len(), before);
    }

    #[tokio::test]
    async fn arm_route_records_the_flag_and_applies_the_block() {
        let fixture = Fixture::new("arm-route");
        send(
            &fixture.service,
            "PUT",
            "/kill-switch",
            Some(body("standard", "tun0", false)),
        )
        .await;
        let (status, response) = send(&fixture.service, "POST", "/kill-switch/arm", None).await;
        assert_eq!((status, response), (StatusCode::OK, json!({"armed": true})));
        assert!(fixture.directory.join(ARM_FILE).exists());
        assert!(fixture
            .fake
            .calls()
            .last()
            .unwrap()
            .contains(&format!("table inet {TABLE} {{")));
    }

    #[tokio::test]
    async fn delete_removes_both_files_and_lifts_the_block() {
        let fixture = Fixture::new("delete");
        send(
            &fixture.service,
            "PUT",
            "/kill-switch",
            Some(body("standard", "tun0", false)),
        )
        .await;
        fixture.service.arm().unwrap();
        let (status, response) = send(&fixture.service, "DELETE", "/kill-switch", None).await;
        assert_eq!((status, response), (StatusCode::OK, json!({"ok": true})));
        assert!(!fixture.directory.join(CONFIG_FILE).exists());
        assert!(!fixture.directory.join(ARM_FILE).exists());
        assert_eq!(fixture.fake.calls().last().unwrap(), DELETE);
    }

    #[tokio::test]
    async fn heal_reapplies_a_missing_or_mismatched_block_and_lifts_a_disarmed_one() {
        let fixture = Fixture::new("heal");
        send(
            &fixture.service,
            "PUT",
            "/kill-switch",
            Some(body("always", "tun0", false)),
        )
        .await;
        assert_eq!(fixture.service.heal(), Ok(true));

        *fixture.fake.listed.lock().unwrap() =
            Some(ruleset(TABLE, &config(Mode::Always, false), Some(CGROUP)));
        assert_eq!(fixture.service.heal(), Ok(false));

        *fixture.fake.listed.lock().unwrap() =
            Some(ruleset(TABLE, &config(Mode::Always, true), Some(CGROUP)));
        assert_eq!(fixture.service.heal(), Ok(true));

        send(
            &fixture.service,
            "PUT",
            "/kill-switch",
            Some(body("standard", "tun0", false)),
        )
        .await;
        *fixture.fake.listed.lock().unwrap() = Some(format!("table inet {TABLE} {{\n}}\n"));
        assert_eq!(fixture.service.heal(), Ok(true));
        assert_eq!(fixture.fake.calls().last().unwrap(), DELETE);
    }

    #[tokio::test]
    async fn put_rejects_an_invalid_tun_and_unknown_fields() {
        let fixture = Fixture::new("put-invalid");
        for tun in ["0123456789abcdef", "tun 0"] {
            let (status, response) = send(
                &fixture.service,
                "PUT",
                "/kill-switch",
                Some(body("always", tun, false)),
            )
            .await;
            assert_eq!(status, StatusCode::BAD_REQUEST, "{tun:?}");
            assert_eq!(response["code"], "invalidRequest");
        }
        let (status, _) = send(
            &fixture.service,
            "PUT",
            "/kill-switch",
            Some(json!({"mode": "always", "tun": "tun0", "allowLan": false, "extra": true})),
        )
        .await;
        assert!(status.is_client_error());
        assert!(fixture.fake.calls().is_empty());
        assert!(!fixture.directory.join(CONFIG_FILE).exists());
    }

    #[tokio::test]
    async fn get_reports_a_missing_nft_binary_as_a_problem() {
        let fixture = Fixture::new("get-missing");
        *fixture.fake.listing_failure.lock().unwrap() = Some(NftError::Missing);
        let (status, response) = send(&fixture.service, "GET", "/kill-switch", None).await;
        assert_eq!(status, StatusCode::OK);
        assert_eq!(response["problem"], "nftMissing");
        assert_eq!(response["active"], false);
    }

    #[tokio::test]
    async fn a_block_is_never_installed_without_the_core_exemption() {
        let fake = Arc::new(FakeNft::default());
        let layer = NftKillSwitch::new(1000, Box::new(SharedNft(fake.clone())), None);
        let error = layer.apply(&config(Mode::Always, false)).unwrap_err();
        assert!(matches!(error, HostError::Failed("nftFailed", _)));
        assert!(fake.calls().is_empty());
        assert!(layer.lift().is_ok());
    }

    #[tokio::test]
    async fn an_always_block_the_system_refuses_is_not_saved() {
        let fixture = Fixture::new("refused");
        *fixture.fake.refusal.lock().unwrap() = Some("refused".to_string());
        let (status, response) = send(
            &fixture.service,
            "PUT",
            "/kill-switch",
            Some(body("always", "tun0", false)),
        )
        .await;
        assert_eq!(status, StatusCode::INTERNAL_SERVER_ERROR);
        assert_eq!(response["code"], "nftFailed");
        assert!(!fixture.directory.join(CONFIG_FILE).exists());
    }
}
