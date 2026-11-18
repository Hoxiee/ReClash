//! The Windows host layer: WFP filters keep the locked addresses off every interface but
//! the TUN, and NRPT rules send the locked names to a resolver inside it.

use super::site_lock::{v4_mask, Addresses, SiteLockRequest};
use std::collections::BTreeSet;
use std::net::Ipv4Addr;

pub(super) const RULE_PREFIX: &str = "{5c1d7e1a-0b5e-4e1a-9c1d-";
pub(super) const LOCAL_RULES: &str =
    r"SYSTEM\CurrentControlSet\Services\Dnscache\Parameters\DnsPolicyConfig";
pub(super) const POLICY_RULES: &str =
    r"SOFTWARE\Policies\Microsoft\Windows NT\DNSClient\DnsPolicyConfig";
// Windows reads at most 50 namespaces from one rule.
const NAMES_PER_RULE: usize = 50;
const CONDITIONS_PER_FILTER: usize = 128;
// Without a TUN address locked names still go here; the filters block it off the TUN,
// so their lookups fail instead of reaching a resolver outside the tunnel.
pub(super) const FALLBACK_RESOLVER: Ipv4Addr = Ipv4Addr::new(198, 18, 0, 2);

pub(super) fn rule_key(index: usize) -> String {
    format!("{RULE_PREFIX}{index:012x}}}")
}

/// A suffix needs its dotted form for the subdomains and its bare form for itself.
/// NRPT cannot hold keywords or patterns, and a guarded lock's exceptions stay locked.
pub(super) fn namespaces(request: &SiteLockRequest) -> Vec<String> {
    let mut namespaces = BTreeSet::new();
    let sets =
        std::iter::once(&request.names).chain(request.guarded.iter().map(|lock| &lock.names));
    for names in sets {
        for name in &names.full {
            namespaces.insert(name.trim_end_matches('.').to_ascii_lowercase());
        }
        for suffix in &names.suffix {
            let suffix = suffix.trim_matches('.').to_ascii_lowercase();
            namespaces.insert(format!(".{suffix}"));
            namespaces.insert(suffix);
        }
    }
    namespaces.retain(|name| !name.is_empty() && name != ".");
    namespaces.into_iter().collect()
}

pub(super) fn resolver(tun_address: Option<(u32, u8)>) -> Ipv4Addr {
    tun_address
        .and_then(|(address, prefix)| super::site_lock::subnet_peer(address, v4_mask(prefix)))
        .unwrap_or(FALLBACK_RESOLVER)
}

#[derive(Debug, Default, PartialEq, Eq)]
pub(super) struct FilterPlan {
    pub(super) v4: Vec<(u32, u32)>,
    pub(super) v6: Vec<([u8; 16], u8)>,
}

impl FilterPlan {
    pub(super) fn new(addresses: &Addresses, resolver: Option<Ipv4Addr>) -> Self {
        let mut v4: Vec<_> = addresses
            .v4
            .iter()
            .map(|&(address, prefix)| (address, v4_mask(prefix)))
            .collect();
        if let Some(resolver) = resolver.map(u32::from) {
            if !v4.iter().any(|&(address, mask)| resolver & mask == address) {
                v4.push((resolver, u32::MAX));
            }
        }
        let v6 = addresses
            .v6
            .iter()
            .map(|&(address, prefix)| (address.to_be_bytes(), prefix))
            .collect();
        Self { v4, v6 }
    }

    pub(super) fn filters(&self, permits: bool) -> usize {
        self.v4.chunks(CONDITIONS_PER_FILTER).len()
            + self.v6.chunks(CONDITIONS_PER_FILTER).len()
            + if permits { 2 } else { 0 }
    }
}

#[cfg(windows)]
pub(super) use system::WindowsLayer;

#[cfg(windows)]
mod system {
    use super::*;
    use crate::service::site_lock::{HostError, HostLayer};
    use crate::service::site_lock_dns::Matcher;
    use std::ffi::c_void;
    use std::mem::zeroed;
    use std::ptr::{null, null_mut};
    use std::sync::Mutex;
    use windows_sys::core::GUID;
    use windows_sys::Win32::Foundation::{
        FreeLibrary, ERROR_FILE_NOT_FOUND, ERROR_NO_MORE_ITEMS, ERROR_SUCCESS,
        FWP_E_ALREADY_EXISTS, FWP_E_FILTER_NOT_FOUND, FWP_E_IN_USE, FWP_E_PROVIDER_NOT_FOUND,
        FWP_E_SUBLAYER_NOT_FOUND, HANDLE,
    };
    use windows_sys::Win32::NetworkManagement::IpHelper::{
        ConvertInterfaceAliasToLuid, FreeMibTable, GetUnicastIpAddressTable,
        MIB_UNICASTIPADDRESS_TABLE,
    };
    use windows_sys::Win32::NetworkManagement::Ndis::NET_LUID_LH;
    use windows_sys::Win32::NetworkManagement::WindowsFilteringPlatform::*;
    use windows_sys::Win32::Networking::WinSock::AF_INET;
    use windows_sys::Win32::System::GroupPolicy::RefreshPolicyEx;
    use windows_sys::Win32::System::LibraryLoader::{GetProcAddress, LoadLibraryW};
    use windows_sys::Win32::System::Registry::{
        RegCloseKey, RegCreateKeyExW, RegDeleteKeyW, RegEnumKeyExW, RegOpenKeyExW, RegSetValueExW,
        HKEY, HKEY_LOCAL_MACHINE, KEY_READ, KEY_SET_VALUE, REG_DWORD, REG_MULTI_SZ,
        REG_OPTION_NON_VOLATILE, REG_SZ,
    };
    use windows_sys::Win32::System::Rpc::RPC_C_AUTHN_WINNT;
    use windows_sys::Win32::System::Services::{
        CloseServiceHandle, ControlService, OpenSCManagerW, OpenServiceW, SC_MANAGER_CONNECT,
        SERVICE_CONTROL_PARAMCHANGE, SERVICE_PAUSE_CONTINUE,
    };

    const PROVIDER: GUID = GUID::from_u128(0x5c1d7e1a_0b5e_4e1a_9c1d_000000000001);
    const SUBLAYER: GUID = GUID::from_u128(0x5c1d7e1a_0b5e_4e1a_9c1d_000000000002);
    const LAYERS: [GUID; 2] = [
        FWPM_LAYER_ALE_AUTH_CONNECT_V4,
        FWPM_LAYER_ALE_AUTH_CONNECT_V6,
    ];
    const DISPLAY_NAME: &str = "ReClash site lock";
    const PERMIT_WEIGHT: u8 = 15;
    const BLOCK_WEIGHT: u8 = 1;
    // Group Policy refresh flag that reapplies policies even when they did not change.
    const RP_FORCE: u32 = 1;

    fn wide(value: &str) -> Vec<u16> {
        value.encode_utf16().chain(Some(0)).collect()
    }

    fn check(code: u32, action: &str) -> Result<(), String> {
        if code == ERROR_SUCCESS {
            Ok(())
        } else {
            Err(format!("{action} failed with 0x{code:08x}"))
        }
    }

    fn tolerated(code: u32, allowed: &[i32]) -> u32 {
        if allowed.contains(&(code as i32)) {
            ERROR_SUCCESS
        } else {
            code
        }
    }

    fn tun_luid(tun: &str) -> Option<u64> {
        if tun.is_empty() {
            return None;
        }
        let alias = wide(tun);
        // SAFETY: alias is NUL-terminated and luid is a valid out parameter.
        unsafe {
            let mut luid: NET_LUID_LH = zeroed();
            (ConvertInterfaceAliasToLuid(alias.as_ptr(), &mut luid) == ERROR_SUCCESS)
                .then_some(luid.Value)
        }
    }

    fn tun_address(luid: u64) -> Option<(u32, u8)> {
        let mut table: *mut MIB_UNICASTIPADDRESS_TABLE = null_mut();
        // SAFETY: the table comes from GetUnicastIpAddressTable, holds NumEntries rows, and is
        // released with FreeMibTable; AF_INET rows carry IPv4 addresses.
        unsafe {
            if GetUnicastIpAddressTable(AF_INET, &mut table) != ERROR_SUCCESS {
                return None;
            }
            let rows =
                std::slice::from_raw_parts((*table).Table.as_ptr(), (*table).NumEntries as usize);
            let found = rows
                .iter()
                .find(|row| row.InterfaceLuid.Value == luid)
                .map(|row| {
                    let address = u32::from_be(row.Address.Ipv4.sin_addr.S_un.S_addr);
                    (address, row.OnLinkPrefixLength)
                });
            FreeMibTable(table as *const c_void);
            found
        }
    }

    struct Engine(HANDLE);

    impl Engine {
        fn open() -> Result<Self, String> {
            let mut handle: HANDLE = 0;
            // SAFETY: a local engine with the default session; handle is an out parameter.
            let code =
                unsafe { FwpmEngineOpen0(null(), RPC_C_AUTHN_WINNT, null(), null(), &mut handle) };
            check(code, "opening the filtering engine")?;
            Ok(Self(handle))
        }

        fn transaction<T>(&self, work: impl FnOnce() -> Result<T, String>) -> Result<T, String> {
            // SAFETY: self.0 is an open engine handle in every call below.
            check(
                unsafe { FwpmTransactionBegin0(self.0, 0) },
                "starting a WFP transaction",
            )?;
            match work() {
                Ok(value) => {
                    let code = unsafe { FwpmTransactionCommit0(self.0) };
                    check(code, "committing the WFP transaction")?;
                    Ok(value)
                }
                Err(error) => {
                    unsafe { FwpmTransactionAbort0(self.0) };
                    Err(error)
                }
            }
        }

        fn ensure_objects(&self) -> Result<(), String> {
            let mut name = wide(DISPLAY_NAME);
            let mut provider_key = PROVIDER;
            // SAFETY: the structures and the name they point to outlive both calls.
            unsafe {
                let mut provider: FWPM_PROVIDER0 = zeroed();
                provider.providerKey = PROVIDER;
                provider.displayData.name = name.as_mut_ptr();
                provider.flags = FWPM_PROVIDER_FLAG_PERSISTENT;
                let code = FwpmProviderAdd0(self.0, &provider, null_mut());
                check(
                    tolerated(code, &[FWP_E_ALREADY_EXISTS]),
                    "adding the WFP provider",
                )?;
                let mut sublayer: FWPM_SUBLAYER0 = zeroed();
                sublayer.subLayerKey = SUBLAYER;
                sublayer.displayData.name = name.as_mut_ptr();
                sublayer.flags = FWPM_SUBLAYER_FLAG_PERSISTENT;
                sublayer.providerKey = &mut provider_key;
                sublayer.weight = u16::MAX;
                let code = FwpmSubLayerAdd0(self.0, &sublayer, null_mut());
                check(
                    tolerated(code, &[FWP_E_ALREADY_EXISTS]),
                    "adding the WFP sublayer",
                )
            }
        }

        fn filters(&self, layer: GUID) -> Result<Vec<u64>, String> {
            const PAGE: u32 = 256;
            let mut provider = PROVIDER;
            let mut ids = Vec::new();
            // SAFETY: the template outlives the enumeration, every page is freed with
            // FwpmFreeMemory0, and the handle is destroyed on every path.
            unsafe {
                let mut template: FWPM_FILTER_ENUM_TEMPLATE0 = zeroed();
                template.providerKey = &mut provider;
                template.layerKey = layer;
                template.enumType = FWP_FILTER_ENUM_OVERLAPPING;
                template.actionMask = u32::MAX;
                let mut handle: HANDLE = 0;
                check(
                    FwpmFilterCreateEnumHandle0(self.0, &template, &mut handle),
                    "listing WFP filters",
                )?;
                let result = loop {
                    let mut entries: *mut *mut FWPM_FILTER0 = null_mut();
                    let mut count = 0u32;
                    let code = FwpmFilterEnum0(self.0, handle, PAGE, &mut entries, &mut count);
                    if let Err(error) = check(code, "listing WFP filters") {
                        break Err(error);
                    }
                    for index in 0..count as usize {
                        ids.push((**entries.add(index)).filterId);
                    }
                    if !entries.is_null() {
                        FwpmFreeMemory0((&mut entries as *mut *mut *mut FWPM_FILTER0).cast());
                    }
                    if count < PAGE {
                        break Ok(());
                    }
                };
                FwpmFilterDestroyEnumHandle0(self.0, handle);
                result.map(|()| ids)
            }
        }

        fn delete_filters(&self) -> Result<(), String> {
            for layer in LAYERS {
                for id in self.filters(layer)? {
                    // SAFETY: id names a filter of this engine.
                    let code = unsafe { FwpmFilterDeleteById0(self.0, id) };
                    check(
                        tolerated(code, &[FWP_E_FILTER_NOT_FOUND]),
                        "deleting a WFP filter",
                    )?;
                }
            }
            Ok(())
        }

        fn add_filter(
            &self,
            layer: GUID,
            permit: bool,
            conditions: &mut [FWPM_FILTER_CONDITION0],
        ) -> Result<(), String> {
            let mut name = wide(DISPLAY_NAME);
            let mut provider = PROVIDER;
            // SAFETY: the filter, its name and its conditions outlive the call.
            unsafe {
                let mut filter: FWPM_FILTER0 = zeroed();
                filter.displayData.name = name.as_mut_ptr();
                filter.flags = FWPM_FILTER_FLAG_PERSISTENT;
                filter.providerKey = &mut provider;
                filter.layerKey = layer;
                filter.subLayerKey = SUBLAYER;
                filter.weight.r#type = FWP_UINT8;
                filter.weight.Anonymous.uint8 = if permit { PERMIT_WEIGHT } else { BLOCK_WEIGHT };
                filter.numFilterConditions = conditions.len() as u32;
                filter.filterCondition = conditions.as_mut_ptr();
                filter.action.r#type = if permit {
                    FWP_ACTION_PERMIT
                } else {
                    FWP_ACTION_BLOCK
                };
                let mut id = 0u64;
                check(
                    FwpmFilterAdd0(self.0, &filter, null_mut(), &mut id),
                    "adding a WFP filter",
                )
            }
        }

        fn apply(&self, plan: &FilterPlan, luid: Option<u64>) -> Result<(), String> {
            self.transaction(|| {
                self.ensure_objects()?;
                self.delete_filters()?;
                if let Some(mut luid) = luid {
                    for layer in LAYERS {
                        // SAFETY: an all-zero condition is valid before its fields are set.
                        let mut condition: FWPM_FILTER_CONDITION0 = unsafe { zeroed() };
                        condition.fieldKey = FWPM_CONDITION_IP_LOCAL_INTERFACE;
                        condition.matchType = FWP_MATCH_EQUAL;
                        condition.conditionValue.r#type = FWP_UINT64;
                        condition.conditionValue.Anonymous.uint64 = &mut luid;
                        self.add_filter(layer, true, std::slice::from_mut(&mut condition))?;
                    }
                }
                for chunk in plan.v4.chunks(CONDITIONS_PER_FILTER) {
                    let mut masks: Vec<_> = chunk
                        .iter()
                        .map(|&(addr, mask)| FWP_V4_ADDR_AND_MASK { addr, mask })
                        .collect();
                    let mut conditions: Vec<_> = masks
                        .iter_mut()
                        .map(|mask| remote(FWP_V4_ADDR_MASK, |value| value.v4AddrMask = mask))
                        .collect();
                    self.add_filter(LAYERS[0], false, &mut conditions)?;
                }
                for chunk in plan.v6.chunks(CONDITIONS_PER_FILTER) {
                    let mut masks: Vec<_> = chunk
                        .iter()
                        .map(|&(addr, prefix)| FWP_V6_ADDR_AND_MASK {
                            addr,
                            prefixLength: prefix,
                        })
                        .collect();
                    let mut conditions: Vec<_> = masks
                        .iter_mut()
                        .map(|mask| remote(FWP_V6_ADDR_MASK, |value| value.v6AddrMask = mask))
                        .collect();
                    self.add_filter(LAYERS[1], false, &mut conditions)?;
                }
                Ok(())
            })
        }

        fn lift(&self) -> Result<(), String> {
            self.transaction(|| {
                self.delete_filters()?;
                // SAFETY: the keys are constants; absent objects are tolerated.
                unsafe {
                    let code = FwpmSubLayerDeleteByKey0(self.0, &SUBLAYER);
                    check(
                        tolerated(code, &[FWP_E_SUBLAYER_NOT_FOUND, FWP_E_IN_USE]),
                        "deleting the WFP sublayer",
                    )?;
                    let code = FwpmProviderDeleteByKey0(self.0, &PROVIDER);
                    check(
                        tolerated(code, &[FWP_E_PROVIDER_NOT_FOUND, FWP_E_IN_USE]),
                        "deleting the WFP provider",
                    )
                }
            })
        }

        fn count(&self) -> Result<usize, String> {
            Ok(self.filters(LAYERS[0])?.len() + self.filters(LAYERS[1])?.len())
        }
    }

    impl Drop for Engine {
        fn drop(&mut self) {
            // SAFETY: self.0 came from FwpmEngineOpen0.
            unsafe { FwpmEngineClose0(self.0) };
        }
    }

    fn remote(
        kind: FWP_DATA_TYPE,
        set: impl FnOnce(&mut FWP_CONDITION_VALUE0_0),
    ) -> FWPM_FILTER_CONDITION0 {
        // SAFETY: an all-zero condition is valid before its fields are set.
        let mut condition: FWPM_FILTER_CONDITION0 = unsafe { zeroed() };
        condition.fieldKey = FWPM_CONDITION_IP_REMOTE_ADDRESS;
        condition.matchType = FWP_MATCH_EQUAL;
        condition.conditionValue.r#type = kind;
        set(&mut condition.conditionValue.Anonymous);
        condition
    }

    struct Key(HKEY);

    impl Drop for Key {
        fn drop(&mut self) {
            // SAFETY: self.0 is an open registry key.
            unsafe { RegCloseKey(self.0) };
        }
    }

    fn rule_keys(base: &str) -> Result<Option<Vec<String>>, String> {
        let path = wide(base);
        let mut key: HKEY = 0;
        // SAFETY: path is NUL-terminated; names are read into a buffer of the given length.
        unsafe {
            match RegOpenKeyExW(HKEY_LOCAL_MACHINE, path.as_ptr(), 0, KEY_READ, &mut key) {
                ERROR_SUCCESS => {}
                ERROR_FILE_NOT_FOUND => return Ok(None),
                code => return Err(format!("opening {base} failed with 0x{code:08x}")),
            }
            let key = Key(key);
            let mut names = Vec::new();
            for index in 0.. {
                let mut buffer = [0u16; 256];
                let mut length = buffer.len() as u32;
                let code = RegEnumKeyExW(
                    key.0,
                    index,
                    buffer.as_mut_ptr(),
                    &mut length,
                    null(),
                    null_mut(),
                    null_mut(),
                    null_mut(),
                );
                match code {
                    ERROR_SUCCESS => {
                        names.push(String::from_utf16_lossy(&buffer[..length as usize]))
                    }
                    ERROR_NO_MORE_ITEMS => break,
                    code => return Err(format!("listing {base} failed with 0x{code:08x}")),
                }
            }
            Ok(Some(names))
        }
    }

    fn set_value(key: &Key, name: &str, kind: u32, data: &[u8]) -> Result<(), String> {
        let name_wide = wide(name);
        // SAFETY: key is open for writing; data holds data.len() bytes.
        let code = unsafe {
            RegSetValueExW(
                key.0,
                name_wide.as_ptr(),
                0,
                kind,
                data.as_ptr(),
                data.len() as u32,
            )
        };
        check(code, &format!("writing the NRPT value {name}"))
    }

    fn utf16_bytes(units: impl IntoIterator<Item = u16>) -> Vec<u8> {
        units.into_iter().flat_map(u16::to_le_bytes).collect()
    }

    fn write_rule(
        base: &str,
        key: &str,
        names: &[String],
        resolver: Ipv4Addr,
    ) -> Result<(), String> {
        let path = wide(&format!(r"{base}\{key}"));
        let mut handle: HKEY = 0;
        // SAFETY: path is NUL-terminated and handle is an out parameter.
        let code = unsafe {
            RegCreateKeyExW(
                HKEY_LOCAL_MACHINE,
                path.as_ptr(),
                0,
                null(),
                REG_OPTION_NON_VOLATILE,
                KEY_SET_VALUE,
                null(),
                &mut handle,
                null_mut(),
            )
        };
        check(code, "creating an NRPT rule")?;
        let handle = Key(handle);
        let mut list: Vec<u16> = names
            .iter()
            .flat_map(|name| name.encode_utf16().chain(Some(0)))
            .collect();
        list.push(0);
        set_value(&handle, "Version", REG_DWORD, &1u32.to_le_bytes())?;
        set_value(&handle, "Name", REG_MULTI_SZ, &utf16_bytes(list))?;
        let server = utf16_bytes(wide(&resolver.to_string()));
        set_value(&handle, "GenericDNSServers", REG_SZ, &server)?;
        // 0x8 makes the rule override the DNS servers of every interface.
        set_value(&handle, "ConfigOptions", REG_DWORD, &8u32.to_le_bytes())
    }

    fn delete_key(path: &str) -> Result<(), String> {
        let path_wide = wide(path);
        // SAFETY: path is NUL-terminated.
        match unsafe { RegDeleteKeyW(HKEY_LOCAL_MACHINE, path_wide.as_ptr()) } {
            ERROR_SUCCESS | ERROR_FILE_NOT_FOUND => Ok(()),
            code => Err(format!("deleting {path} failed with 0x{code:08x}")),
        }
    }

    fn sync_rules(base: &str, rules: &[&[String]], resolver: Ipv4Addr) -> Result<(), String> {
        for (index, names) in rules.iter().enumerate() {
            write_rule(base, &rule_key(index), names, resolver)?;
        }
        let wanted: BTreeSet<String> = (0..rules.len()).map(rule_key).collect();
        for key in rule_keys(base)?.unwrap_or_default() {
            if key.starts_with(RULE_PREFIX) && !wanted.contains(&key) {
                delete_key(&format!(r"{base}\{key}"))?;
            }
        }
        Ok(())
    }

    // Any Group Policy NRPT rule makes Windows ignore the local ones.
    fn policy_rules() -> Result<bool, String> {
        Ok(rule_keys(POLICY_RULES)?
            .is_some_and(|keys| keys.iter().any(|key| !key.starts_with(RULE_PREFIX))))
    }

    fn ours(base: &str) -> Result<usize, String> {
        Ok(rule_keys(base)?
            .unwrap_or_default()
            .iter()
            .filter(|key| key.starts_with(RULE_PREFIX))
            .count())
    }

    fn apply_rules(namespaces: &[String], resolver: Ipv4Addr) -> Result<bool, String> {
        let rules: Vec<&[String]> = namespaces.chunks(NAMES_PER_RULE).collect();
        let policy = policy_rules()?;
        sync_rules(LOCAL_RULES, &rules, resolver)?;
        let had_policy = ours(POLICY_RULES)? > 0;
        if policy {
            sync_rules(POLICY_RULES, &rules, resolver)?;
        } else if had_policy {
            drop_policy_rules()?;
        }
        notify(policy || had_policy);
        Ok(policy)
    }

    // An empty policy key would still hide the local rules.
    fn drop_policy_rules() -> Result<(), String> {
        sync_rules(POLICY_RULES, &[], FALLBACK_RESOLVER)?;
        if rule_keys(POLICY_RULES)?.is_some_and(|keys| keys.is_empty()) {
            delete_key(POLICY_RULES)?;
        }
        Ok(())
    }

    fn lift_rules() -> Result<(), String> {
        let had_policy = ours(POLICY_RULES)? > 0;
        sync_rules(LOCAL_RULES, &[], FALLBACK_RESOLVER)?;
        if had_policy {
            drop_policy_rules()?;
        }
        notify(had_policy);
        Ok(())
    }

    // Best effort: the DNS client also watches its keys, and a stale cache entry expires.
    fn notify(policy: bool) {
        // SAFETY: plain Win32 calls; every opened handle is closed, and the flush entry
        // point of dnsapi.dll takes no arguments and returns a BOOL.
        unsafe {
            if policy {
                RefreshPolicyEx(1, RP_FORCE);
            }
            let manager = OpenSCManagerW(null(), null(), SC_MANAGER_CONNECT);
            if manager != 0 {
                let name = wide("Dnscache");
                let service = OpenServiceW(manager, name.as_ptr(), SERVICE_PAUSE_CONTINUE);
                if service != 0 {
                    let mut status = zeroed();
                    ControlService(service, SERVICE_CONTROL_PARAMCHANGE, &mut status);
                    CloseServiceHandle(service);
                }
                CloseServiceHandle(manager);
            }
            let library = wide("dnsapi.dll");
            let module = LoadLibraryW(library.as_ptr());
            if module != 0 {
                let entry = GetProcAddress(module, c"DnsFlushResolverCache".as_ptr().cast());
                if let Some(flush) = entry {
                    let flush: unsafe extern "system" fn() -> i32 = std::mem::transmute(flush);
                    flush();
                }
                FreeLibrary(module);
            }
        }
    }

    #[derive(Debug, PartialEq, Eq)]
    struct Applied {
        request: SiteLockRequest,
        luid: Option<u64>,
        resolver: Option<Ipv4Addr>,
        filters: usize,
        rules: usize,
        policy: bool,
    }

    #[derive(Default)]
    pub(in crate::service) struct WindowsLayer {
        applied: Mutex<Option<Applied>>,
    }

    impl WindowsLayer {
        fn target(request: &SiteLockRequest) -> (Option<u64>, Vec<String>, Option<Ipv4Addr>) {
            let luid = tun_luid(&request.tun);
            let namespaces = namespaces(request);
            let resolver = (!namespaces.is_empty()).then(|| resolver(luid.and_then(tun_address)));
            (luid, namespaces, resolver)
        }
    }

    impl HostLayer for WindowsLayer {
        fn apply(
            &self,
            request: &SiteLockRequest,
            addresses: &Addresses,
            _matcher: Option<Matcher>,
        ) -> Result<(), HostError> {
            let mut applied = self.applied.lock().unwrap_or_else(|e| e.into_inner());
            *applied = None;
            let (luid, namespaces, resolver) = Self::target(request);
            let plan = FilterPlan::new(addresses, resolver);
            Engine::open()
                .and_then(|engine| engine.apply(&plan, luid))
                .map_err(|message| HostError::Failed("firewallFailed", message))?;
            let policy = match resolver {
                Some(resolver) => apply_rules(&namespaces, resolver),
                None => lift_rules().map(|()| false),
            }
            .map_err(|message| HostError::Failed("dnsPolicyFailed", message))?;
            *applied = Some(Applied {
                request: request.clone(),
                luid,
                resolver,
                filters: plan.filters(luid.is_some()),
                rules: namespaces.chunks(NAMES_PER_RULE).len(),
                policy,
            });
            Ok(())
        }

        fn holds(&self, request: &SiteLockRequest, _addresses: &Addresses) -> Result<bool, String> {
            let applied = self.applied.lock().unwrap_or_else(|e| e.into_inner());
            let Some(applied) = applied.as_ref() else {
                return Ok(false);
            };
            let (luid, _, resolver) = Self::target(request);
            if applied.request != *request || applied.luid != luid || applied.resolver != resolver {
                return Ok(false);
            }
            let rules_hold = ours(LOCAL_RULES)? == applied.rules
                && policy_rules()? == applied.policy
                && (!applied.policy || ours(POLICY_RULES)? == applied.rules);
            Ok(rules_hold && Engine::open()?.count()? == applied.filters)
        }

        fn lift(&self) -> Result<(), HostError> {
            let mut applied = self.applied.lock().unwrap_or_else(|e| e.into_inner());
            *applied = None;
            lift_rules().map_err(|message| HostError::Failed("dnsPolicyFailed", message))?;
            Engine::open()
                .and_then(|engine| engine.lift())
                .map_err(|message| HostError::Failed("firewallFailed", message))
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::service::site_lock_dns::{GuardedNames, Names};

    fn request(names: Names, guarded: Vec<GuardedNames>) -> SiteLockRequest {
        SiteLockRequest {
            tun: "Meta".to_string(),
            addresses: Vec::new(),
            names,
            guarded,
        }
    }

    fn strings(values: &[&str]) -> Vec<String> {
        values.iter().map(|value| value.to_string()).collect()
    }

    #[test]
    fn a_suffix_covers_the_name_and_its_subdomains_while_patterns_stay_out() {
        let names = Names {
            full: strings(&["API.example.org."]),
            suffix: strings(&["chatgpt.com", ".openai.com"]),
            keyword: strings(&["claude"]),
            regex: strings(&["^x\\.y$"]),
        };
        let guarded = GuardedNames {
            names: Names {
                suffix: strings(&["chatgpt.com", "x.ai"]),
                ..Names::default()
            },
            except: Names {
                full: strings(&["free.x.ai"]),
                ..Names::default()
            },
        };
        assert_eq!(
            namespaces(&request(names, vec![guarded])),
            strings(&[
                ".chatgpt.com",
                ".openai.com",
                ".x.ai",
                "api.example.org",
                "chatgpt.com",
                "openai.com",
                "x.ai",
            ])
        );
    }

    #[test]
    fn rule_keys_are_braced_guids_that_carry_the_prefix() {
        let key = rule_key(0x1f);
        assert_eq!(key, "{5c1d7e1a-0b5e-4e1a-9c1d-00000000001f}");
        assert!(key.starts_with(RULE_PREFIX));
        let groups: Vec<usize> = key
            .trim_matches(['{', '}'])
            .split('-')
            .map(str::len)
            .collect();
        assert_eq!(groups, vec![8, 4, 4, 4, 12]);
    }

    #[test]
    fn the_resolver_is_the_tun_peer_or_a_blocked_fallback() {
        let address = u32::from(Ipv4Addr::new(198, 18, 0, 1));
        assert_eq!(resolver(Some((address, 30))), Ipv4Addr::new(198, 18, 0, 2));
        let address = u32::from(Ipv4Addr::new(172, 19, 0, 1));
        assert_eq!(resolver(Some((address, 16))), Ipv4Addr::new(172, 19, 0, 2));
        assert_eq!(resolver(Some((address, 32))), FALLBACK_RESOLVER);
        assert_eq!(resolver(None), FALLBACK_RESOLVER);
    }

    #[test]
    fn the_plan_blocks_the_resolver_once_and_counts_the_filters() {
        let addresses = Addresses {
            v4: vec![(u32::from(Ipv4Addr::new(203, 0, 113, 0)), 24)],
            v6: vec![(0x2001_0db8 << 96, 32)],
        };
        let plan = FilterPlan::new(&addresses, Some(FALLBACK_RESOLVER));
        assert_eq!(
            plan.v4,
            vec![
                (u32::from(Ipv4Addr::new(203, 0, 113, 0)), 0xffff_ff00),
                (u32::from(FALLBACK_RESOLVER), u32::MAX),
            ]
        );
        assert_eq!(plan.v6[0].0[..4], [0x20, 0x01, 0x0d, 0xb8]);
        assert_eq!(plan.v6[0].1, 32);
        assert_eq!(plan.filters(true), 4);
        assert_eq!(plan.filters(false), 2);

        let fake_ip = Addresses {
            v4: vec![(u32::from(Ipv4Addr::new(198, 18, 0, 0)), 16)],
            v6: Vec::new(),
        };
        assert_eq!(
            FilterPlan::new(&fake_ip, Some(FALLBACK_RESOLVER)).v4.len(),
            1
        );
        assert_eq!(FilterPlan::new(&fake_ip, None).filters(false), 1);
    }

    #[test]
    fn large_lists_split_across_filters() {
        let addresses = Addresses {
            v4: (0..300u32).map(|index| (index << 8, 24)).collect(),
            v6: Vec::new(),
        };
        assert_eq!(FilterPlan::new(&addresses, None).filters(false), 3);
    }
}
