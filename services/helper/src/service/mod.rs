pub mod hub;
#[cfg(target_os = "linux")]
pub mod linux;
#[cfg(target_os = "linux")]
mod linux_install;
#[cfg(any(windows, test))]
#[cfg_attr(all(windows, not(feature = "windows-service")), allow(dead_code))]
pub mod owner;
#[cfg(all(feature = "windows-service", target_os = "windows"))]
pub mod peer;
#[cfg(all(feature = "windows-service", target_os = "windows"))]
pub mod windows;
#[cfg(all(feature = "windows-service", target_os = "windows"))]
mod windows_install;
#[cfg(any(all(feature = "windows-service", target_os = "windows"), test))]
pub mod windows_layout;
