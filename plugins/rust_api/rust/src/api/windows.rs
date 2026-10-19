use crate::frb_generated::StreamSink;
use flutter_rust_bridge::for_generated::SseCodec;
use flutter_rust_bridge::frb;

#[frb]
pub fn windows_is_elevated() -> Result<bool, String> {
    #[cfg(windows)]
    {
        crate::windows::security::is_elevated().map_err(|error| error.to_string())
    }
    #[cfg(not(windows))]
    {
        Ok(false)
    }
}

#[frb(sync)]
pub fn prepare_windows_core_launch(session_id: String) -> Result<(), String> {
    #[cfg(windows)]
    {
        crate::windows::prepare(session_id)
    }
    #[cfg(not(windows))]
    {
        let _ = session_id;
        Err("windows_platform_unavailable".into())
    }
}

#[frb]
pub fn launch_windows_core(
    session_id: String,
    address: String,
    home_dir: String,
    expected_sha256: String,
    sink: StreamSink<Vec<String>, SseCodec>,
) -> Result<(), String> {
    #[cfg(windows)]
    {
        let emit = std::sync::Arc::new(move |event| sink.add(event).is_ok());
        if let Err(error) = crate::windows::start(
            session_id.clone(),
            address,
            home_dir,
            expected_sha256,
            emit.clone(),
        ) {
            emit(vec!["error".into(), error]);
            if crate::windows::cancel(&session_id).unwrap_or(false) {
                emit(vec!["exited".into(), String::new()]);
            }
        }
    }
    #[cfg(not(windows))]
    {
        let _ = (session_id, address, home_dir, expected_sha256);
        let _ = sink.add(vec!["error".into(), "windows_platform_unavailable".into()]);
        let _ = sink.add(vec!["exited".into(), String::new()]);
    }
    Ok(())
}

#[frb(sync)]
pub fn cancel_windows_core_launch(session_id: String) -> Result<bool, String> {
    #[cfg(windows)]
    {
        crate::windows::cancel(&session_id)
    }
    #[cfg(not(windows))]
    {
        let _ = session_id;
        Ok(true)
    }
}

#[frb]
pub fn stop_windows_core(session_id: String, timeout_millis: u32) -> Result<bool, String> {
    #[cfg(windows)]
    {
        crate::windows::stop(&session_id, timeout_millis)
    }
    #[cfg(not(windows))]
    {
        let _ = (session_id, timeout_millis);
        Ok(true)
    }
}
