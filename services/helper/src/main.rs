#[cfg(not(any(
    all(feature = "windows-service", target_os = "windows"),
    all(feature = "linux-service", target_os = "linux")
)))]
use crate::service::hub::run_service;
#[cfg(not(any(
    all(feature = "windows-service", target_os = "windows"),
    all(feature = "linux-service", target_os = "linux")
)))]
use tokio::runtime::Runtime;

mod service;

#[cfg(all(feature = "linux-service", target_os = "linux"))]
fn main() -> anyhow::Result<()> {
    service::linux::main()
}

#[cfg(all(feature = "windows-service", target_os = "windows"))]
pub fn main() -> anyhow::Result<()> {
    service::windows::main()
}

#[cfg(not(any(
    all(feature = "windows-service", target_os = "windows"),
    all(feature = "linux-service", target_os = "linux")
)))]
fn main() {
    if let Ok(rt) = Runtime::new() {
        rt.block_on(async {
            let _ = run_service().await;
        });
    }
}
