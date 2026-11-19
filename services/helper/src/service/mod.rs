pub mod hub;
#[cfg_attr(not(target_os = "linux"), allow(dead_code))]
mod kill_switch;
#[cfg(any(windows, test))]
#[cfg_attr(not(all(windows, feature = "windows-service")), allow(dead_code))]
mod kill_switch_windows;
#[cfg(target_os = "linux")]
pub mod linux;
#[cfg(target_os = "linux")]
mod linux_install;
#[cfg(any(windows, test))]
#[cfg_attr(all(windows, not(feature = "windows-service")), allow(dead_code))]
pub mod owner;
#[cfg(all(feature = "windows-service", target_os = "windows"))]
pub mod peer;
#[cfg_attr(not(target_os = "linux"), allow(dead_code))]
pub mod site_lock;
#[cfg_attr(not(target_os = "linux"), allow(dead_code))]
mod site_lock_dns;
#[cfg(any(windows, test))]
#[cfg_attr(not(all(windows, feature = "windows-service")), allow(dead_code))]
mod site_lock_windows;
#[cfg(all(feature = "windows-service", target_os = "windows"))]
pub mod windows;
#[cfg(all(feature = "windows-service", target_os = "windows"))]
mod windows_install;
#[cfg(any(all(feature = "windows-service", target_os = "windows"), test))]
pub mod windows_layout;
