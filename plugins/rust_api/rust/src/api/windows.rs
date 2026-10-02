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
        Err("Windows Core launch is unavailable on this platform".into())
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
        crate::windows::start(
            session_id,
            address,
            home_dir,
            expected_sha256,
            std::sync::Arc::new(move |event| sink.add(event).is_ok()),
        )
    }
    #[cfg(not(windows))]
    {
        let _ = (session_id, address, home_dir, expected_sha256, sink);
        Err("Windows Core launch is unavailable on this platform".into())
    }
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
