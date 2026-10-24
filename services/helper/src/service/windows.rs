use crate::service::owner::{service_command, ServiceCommand};
use crate::service::peer::serve_until;
use crate::service::windows_install::{self, SERVICE_OPERATION_TIMEOUT, SERVICE_TYPE};
use crate::service::windows_layout::{failure_exit, SERVICE_NAME};

use anyhow::{Context, Result};
use once_cell::sync::OnceCell;
use std::ffi::OsString;
use std::time::Duration;

use tokio::runtime::Runtime;
use tokio::sync::watch;

use windows_service::{
    define_windows_service,
    service::{ServiceControl, ServiceControlAccept, ServiceExitCode, ServiceState, ServiceStatus},
    service_control_handler::{self, ServiceControlHandlerResult},
    service_dispatcher,
};

static OWNER_SID: OnceCell<String> = OnceCell::new();

pub fn main() -> Result<()> {
    let maintenance = match service_command(std::env::args_os().skip(1)) {
        Ok(ServiceCommand::Run { owner_sid }) => {
            return start_service(owner_sid).map_err(Into::into)
        }
        Ok(ServiceCommand::Install { owner_pid }) => windows_install::install(owner_pid),
        Ok(ServiceCommand::Upgrade) => windows_install::upgrade(),
        Ok(ServiceCommand::Uninstall) => windows_install::uninstall(),
        Err(error) => Err(error),
    };
    if let Err(error) = maintenance {
        let (exit_code, code) = failure_exit(&error);
        eprintln!("{error:#}");
        eprintln!("reclash-service-error: {code}");
        std::process::exit(exit_code);
    }
    Ok(())
}

fn start_service(owner_sid: String) -> windows_service::Result<()> {
    let _ = OWNER_SID.set(owner_sid);
    service_dispatcher::start(SERVICE_NAME, ffi_service_main)
}

define_windows_service!(ffi_service_main, service_main);

fn service_main(_arguments: Vec<OsString>) {
    let _ = run_windows_service();
}

fn run_windows_service() -> Result<()> {
    let owner_sid = OWNER_SID
        .get()
        .cloned()
        .context("the helper service has no owner")?;
    let (shutdown_tx, mut shutdown_rx) = watch::channel(false);
    let status_handle = service_control_handler::register(
        SERVICE_NAME,
        move |event| -> ServiceControlHandlerResult {
            match event {
                ServiceControl::Interrogate => ServiceControlHandlerResult::NoError,
                ServiceControl::Stop => {
                    let _ = shutdown_tx.send(true);
                    ServiceControlHandlerResult::NoError
                }
                _ => ServiceControlHandlerResult::NotImplemented,
            }
        },
    )
    .context("register helper service control handler")?;

    status_handle
        .set_service_status(service_status(
            ServiceState::StartPending,
            ServiceControlAccept::empty(),
            1,
            SERVICE_OPERATION_TIMEOUT,
            0,
        ))
        .context("report helper service startup")?;

    let runtime = match Runtime::new() {
        Ok(runtime) => runtime,
        Err(error) => {
            let _ = status_handle.set_service_status(service_status(
                ServiceState::Stopped,
                ServiceControlAccept::empty(),
                0,
                Duration::default(),
                1,
            ));
            return Err(error).context("create helper runtime");
        }
    };

    let shutdown_status_handle = status_handle;
    let running_status_handle = status_handle;
    let service_result = runtime.block_on(serve_until(
        owner_sid,
        async move {
            if !*shutdown_rx.borrow() {
                let _ = shutdown_rx.changed().await;
            }
            let _ = shutdown_status_handle.set_service_status(service_status(
                ServiceState::StopPending,
                ServiceControlAccept::empty(),
                1,
                SERVICE_OPERATION_TIMEOUT,
                0,
            ));
        },
        move || {
            running_status_handle
                .set_service_status(service_status(
                    ServiceState::Running,
                    ServiceControlAccept::STOP,
                    0,
                    Duration::default(),
                    0,
                ))
                .context("report helper service running")
        },
    ));
    let exit_code = u32::from(service_result.is_err());
    let status_result = status_handle.set_service_status(service_status(
        ServiceState::Stopped,
        ServiceControlAccept::empty(),
        0,
        Duration::default(),
        exit_code,
    ));

    service_result.context("run helper service")?;
    status_result.context("report helper service stopped")?;
    Ok(())
}

fn service_status(
    current_state: ServiceState,
    controls_accepted: ServiceControlAccept,
    checkpoint: u32,
    wait_hint: Duration,
    exit_code: u32,
) -> ServiceStatus {
    ServiceStatus {
        service_type: SERVICE_TYPE,
        current_state,
        controls_accepted,
        exit_code: ServiceExitCode::Win32(exit_code),
        checkpoint,
        wait_hint,
        process_id: None,
    }
}
