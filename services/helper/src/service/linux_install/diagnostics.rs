use anyhow::{Context, Result};
use std::io::{self, Read};
use std::os::fd::AsRawFd;
use std::process::{Command, Stdio};
use std::thread;
use std::time::{Duration, Instant, SystemTime, UNIX_EPOCH};

pub(super) fn collect(name: &str, since: SystemTime) -> String {
    let state = capture(
        Command::new("/usr/bin/systemctl").args([
            "show",
            "--no-pager",
            "--property=Result,ExecMainCode,ExecMainStatus,ActiveState,SubState",
            name,
        ]),
        512,
        Duration::from_secs(2),
    )
    .unwrap_or_else(|error| format!("systemd status unavailable: {error}"));
    let since = since
        .duration_since(UNIX_EPOCH)
        .unwrap_or_default()
        .as_secs();
    let journal = capture(
        Command::new("/usr/bin/journalctl").args([
            "--no-pager",
            "--quiet",
            "--output=cat",
            "--lines=8",
            "--unit",
            name,
            &format!("--since=@{since}"),
        ]),
        2048,
        Duration::from_secs(2),
    )
    .unwrap_or_else(|error| format!("service journal unavailable: {error}"));
    format!("systemd diagnostics for {name}:\n{state}\n{journal}")
}

fn capture(command: &mut Command, limit: usize, timeout: Duration) -> Result<String> {
    let mut child = command
        .env_clear()
        .env("PATH", "/usr/bin:/bin")
        .env("LC_ALL", "C")
        .stdin(Stdio::null())
        .stdout(Stdio::piped())
        .stderr(Stdio::null())
        .spawn()
        .context("start diagnostic command")?;
    let mut stdout = child.stdout.take().expect("piped diagnostic output");
    let result = (|| {
        // SAFETY: stdout owns a live pipe descriptor; only its nonblocking flag is changed.
        let flags = unsafe { libc::fcntl(stdout.as_raw_fd(), libc::F_GETFL) };
        if flags < 0
            || unsafe { libc::fcntl(stdout.as_raw_fd(), libc::F_SETFL, flags | libc::O_NONBLOCK) }
                < 0
        {
            return Err(io::Error::last_os_error())
                .context("read diagnostic output without blocking");
        }
        let deadline = Instant::now() + timeout;
        let mut output = Vec::new();
        let mut buffer = [0_u8; 512];
        let suffix = loop {
            if output.len() >= limit {
                break "\n[diagnostic output truncated]";
            }
            if Instant::now() >= deadline {
                break "\n[diagnostic command timed out]";
            }
            let remaining = (limit - output.len()).min(buffer.len());
            match stdout.read(&mut buffer[..remaining]) {
                Ok(0) => break "",
                Ok(size) => output.extend_from_slice(&buffer[..size]),
                Err(error) if error.kind() == io::ErrorKind::WouldBlock => {
                    thread::sleep(Duration::from_millis(10));
                }
                Err(error) if error.kind() == io::ErrorKind::Interrupted => continue,
                Err(error) => return Err(error).context("read diagnostic output"),
            }
        };
        Ok(format!("{}{suffix}", String::from_utf8_lossy(&output)))
    })();
    let _ = child.kill();
    let _ = child.wait();
    result
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn short_output_is_captured() {
        let output = capture(
            Command::new("/bin/sh").args(["-c", "printf 'ExecMainStatus=203\\n'"]),
            512,
            Duration::from_secs(2),
        )
        .unwrap();
        assert_eq!(output, "ExecMainStatus=203\n");
    }

    #[test]
    fn oversized_output_is_bounded_and_the_command_is_reaped() {
        let output = capture(
            Command::new("/bin/sh").args(["-c", "while :; do printf 12345678; done"]),
            64,
            Duration::from_secs(2),
        )
        .unwrap();
        assert_eq!(
            output,
            format!("{}\n[diagnostic output truncated]", "12345678".repeat(8))
        );
    }

    #[test]
    fn stalled_command_has_a_deadline() {
        let output = capture(
            Command::new("/bin/sh").args(["-c", "while :; do :; done"]),
            64,
            Duration::from_millis(50),
        )
        .unwrap();
        assert_eq!(output, "\n[diagnostic command timed out]");
    }

    #[test]
    fn unavailable_diagnostic_command_is_reported() {
        assert!(capture(
            &mut Command::new("/nonexistent/reclash-diagnostic-command"),
            64,
            Duration::from_millis(50),
        )
        .is_err());
    }
}
