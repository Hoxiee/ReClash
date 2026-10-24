use crate::service::hub::{
    caller_routes, ensure_core_sha256_configured, log_message, release_managed_core_on_shutdown,
    Caller,
};
use crate::service::owner::{client_pid, same_sid, ManagedHost, TcpConnection};

use std::convert::Infallible;
use std::ffi::c_void;
use std::future::Future;
use std::io::{Error, Result as IoResult};
use std::net::{Ipv4Addr, SocketAddr, SocketAddrV4};
use std::pin::Pin;
use std::ptr::{null, null_mut};
use std::sync::atomic::{AtomicBool, Ordering};
use std::task::{Context, Poll};
use std::time::Duration;
use tokio::io::{AsyncRead, AsyncWrite, ReadBuf};
use tokio::net::{TcpListener, TcpStream};
use tokio::time::Sleep;
use tokio_stream::Stream;
use warp::hyper::server::accept;
use warp::hyper::service::make_service_fn;
use warp::hyper::Server;
use windows_sys::Win32::Foundation::{
    CloseHandle, LocalFree, ERROR_INSUFFICIENT_BUFFER, ERROR_SUCCESS, FILETIME, HANDLE, NO_ERROR,
};
use windows_sys::Win32::NetworkManagement::IpHelper::{
    GetExtendedTcpTable, MIB_TCPTABLE_OWNER_PID, TCP_TABLE_OWNER_PID_ALL,
};
use windows_sys::Win32::Security::Authorization::ConvertSidToStringSidW;
use windows_sys::Win32::Security::{GetTokenInformation, TokenUser, TOKEN_QUERY, TOKEN_USER};
use windows_sys::Win32::System::Registry::{
    RegCloseKey, RegCreateKeyExW, RegDeleteKeyW, RegSetValueExW, HKEY, HKEY_LOCAL_MACHINE,
    KEY_SET_VALUE, REG_DWORD, REG_OPTION_VOLATILE,
};
use windows_sys::Win32::System::Threading::{
    GetProcessTimes, OpenProcess, OpenProcessToken, PROCESS_QUERY_LIMITED_INFORMATION,
};

const AF_INET: u32 = 2;
/// Hyper-V and WinNAT reserve ranges that can cover any fixed port; only admins
/// write this volatile key under the service's own, and a reboot clears it.
const PORT_KEY: &str = r"SYSTEM\CurrentControlSet\Services\ReClashService\Runtime";
const PORT_VALUE: &str = "Port";
const TABLE_ATTEMPTS: usize = 5;
const ACCEPT_RETRY_DELAY: Duration = Duration::from_secs(1);

static REJECTION_LOGGED: AtomicBool = AtomicBool::new(false);

struct Handle(HANDLE);

impl Drop for Handle {
    fn drop(&mut self) {
        // SAFETY: the handle came from a successful Open* call.
        unsafe {
            CloseHandle(self.0);
        }
    }
}

pub fn process_sid(pid: u32) -> IoResult<String> {
    token_sid(&open_process(pid)?)
}

/// One handle for both, so a PID reused in between cannot mix two processes.
fn process_identity(pid: u32) -> IoResult<(String, u64)> {
    let process = open_process(pid)?;
    let sid = token_sid(&process)?;
    let mut created = FILETIME {
        dwLowDateTime: 0,
        dwHighDateTime: 0,
    };
    let mut unused = created;
    // SAFETY: the handle is open and every out pointer is a live FILETIME.
    if unsafe {
        GetProcessTimes(
            process.0,
            &mut created,
            &mut unused,
            &mut unused,
            &mut unused,
        )
    } == 0
    {
        return Err(Error::last_os_error());
    }
    Ok((
        sid,
        (u64::from(created.dwHighDateTime) << 32) | u64::from(created.dwLowDateTime),
    ))
}

fn open_process(pid: u32) -> IoResult<Handle> {
    let process = unsafe { OpenProcess(PROCESS_QUERY_LIMITED_INFORMATION, 0, pid) };
    if process == 0 {
        return Err(Error::last_os_error());
    }
    Ok(Handle(process))
}

fn token_sid(process: &Handle) -> IoResult<String> {
    // SAFETY: the token is owned by a Handle; the u64 buffer gives the
    // pointer-bearing TOKEN_USER the alignment it needs.
    unsafe {
        let mut token: HANDLE = 0;
        if OpenProcessToken(process.0, TOKEN_QUERY, &mut token) == 0 {
            return Err(Error::last_os_error());
        }
        let token = Handle(token);

        let mut length = 0u32;
        GetTokenInformation(token.0, TokenUser, null_mut(), 0, &mut length);
        if length == 0 {
            return Err(Error::last_os_error());
        }
        let mut buffer = vec![0u64; (length as usize).div_ceil(8)];
        if GetTokenInformation(
            token.0,
            TokenUser,
            buffer.as_mut_ptr() as *mut c_void,
            length,
            &mut length,
        ) == 0
        {
            return Err(Error::last_os_error());
        }
        let user = &*(buffer.as_ptr() as *const TOKEN_USER);
        sid_to_string(user.User.Sid)
    }
}

pub(super) unsafe fn sid_to_string(sid: *mut c_void) -> IoResult<String> {
    let mut wide: *mut u16 = null_mut();
    if ConvertSidToStringSidW(sid, &mut wide) == 0 {
        return Err(Error::last_os_error());
    }
    let mut length = 0;
    while *wide.add(length) != 0 {
        length += 1;
    }
    let value = String::from_utf16_lossy(std::slice::from_raw_parts(wide, length));
    LocalFree(wide as *mut c_void);
    Ok(value)
}

fn tcp_connections() -> IoResult<Vec<TcpConnection>> {
    let mut size = 0u32;
    for _ in 0..TABLE_ATTEMPTS {
        let mut buffer = vec![0u32; (size as usize).div_ceil(4)];
        let pointer = if buffer.is_empty() {
            null_mut()
        } else {
            buffer.as_mut_ptr() as *mut c_void
        };
        let status = unsafe {
            GetExtendedTcpTable(pointer, &mut size, 0, AF_INET, TCP_TABLE_OWNER_PID_ALL, 0)
        };
        match status {
            NO_ERROR => return Ok(read_table(&buffer)),
            ERROR_INSUFFICIENT_BUFFER => continue,
            other => return Err(Error::from_raw_os_error(other as i32)),
        }
    }
    Err(Error::other("the TCP table kept growing"))
}

fn read_table(buffer: &[u32]) -> Vec<TcpConnection> {
    // SAFETY: a successful call left `dwNumEntries` rows in the buffer it was
    // sized for.
    unsafe {
        let table = &*(buffer.as_ptr() as *const MIB_TCPTABLE_OWNER_PID);
        std::slice::from_raw_parts(table.table.as_ptr(), table.dwNumEntries as usize)
            .iter()
            .map(|row| TcpConnection {
                local: socket_address(row.dwLocalAddr, row.dwLocalPort),
                remote: socket_address(row.dwRemoteAddr, row.dwRemotePort),
                pid: row.dwOwningPid,
            })
            .collect()
    }
}

/// Network byte order, with the port in the low 16 bits.
fn socket_address(address: u32, port: u32) -> SocketAddrV4 {
    SocketAddrV4::new(
        Ipv4Addr::from(u32::from_be(address)),
        u16::from_be(port as u16),
    )
}

fn owner_client(stream: &TcpStream, owner_sid: &str) -> Option<ManagedHost> {
    let (Ok(SocketAddr::V4(client)), Ok(SocketAddr::V4(server))) =
        (stream.peer_addr(), stream.local_addr())
    else {
        return None;
    };
    let pid = client_pid(&tcp_connections().ok()?, client, server)?;
    let (sid, created) = process_identity(pid).ok()?;
    same_sid(&sid, owner_sid).then(|| ManagedHost {
        pid,
        created,
        owner_sid: owner_sid.to_string(),
    })
}

/// warp forgets a custom stream's peer, so each connection gets its own router.
struct CallerStream {
    stream: TcpStream,
    caller: Caller,
}

impl AsyncRead for CallerStream {
    fn poll_read(
        mut self: Pin<&mut Self>,
        context: &mut Context<'_>,
        buffer: &mut ReadBuf<'_>,
    ) -> Poll<IoResult<()>> {
        Pin::new(&mut self.stream).poll_read(context, buffer)
    }
}

impl AsyncWrite for CallerStream {
    fn poll_write(
        mut self: Pin<&mut Self>,
        context: &mut Context<'_>,
        buffer: &[u8],
    ) -> Poll<IoResult<usize>> {
        Pin::new(&mut self.stream).poll_write(context, buffer)
    }

    fn poll_flush(mut self: Pin<&mut Self>, context: &mut Context<'_>) -> Poll<IoResult<()>> {
        Pin::new(&mut self.stream).poll_flush(context)
    }

    fn poll_shutdown(mut self: Pin<&mut Self>, context: &mut Context<'_>) -> Poll<IoResult<()>> {
        Pin::new(&mut self.stream).poll_shutdown(context)
    }
}

/// Loopback TCP has no peer credential, so the TCP table names the process
/// holding the client end, and that process must run as the account the Helper
/// was installed for.
struct AuthorizedIncoming {
    listener: TcpListener,
    owner_sid: String,
    retry: Option<Pin<Box<Sleep>>>,
}

impl Stream for AuthorizedIncoming {
    type Item = IoResult<CallerStream>;

    /// hyper ends the whole server on an accept error, so retry after a pause.
    fn poll_next(mut self: Pin<&mut Self>, context: &mut Context<'_>) -> Poll<Option<Self::Item>> {
        loop {
            if let Some(retry) = self.retry.as_mut() {
                match retry.as_mut().poll(context) {
                    Poll::Ready(()) => self.retry = None,
                    Poll::Pending => return Poll::Pending,
                }
            }
            match self.listener.poll_accept(context) {
                Poll::Ready(Ok((stream, _))) => {
                    if let Some(host) = owner_client(&stream, &self.owner_sid) {
                        return Poll::Ready(Some(Ok(CallerStream {
                            stream,
                            caller: Caller { host: Some(host) },
                        })));
                    }
                    if !REJECTION_LOGGED.swap(true, Ordering::Relaxed) {
                        log_message(
                            "Helper refused a connection from an account other than its owner"
                                .to_string(),
                        );
                    }
                }
                Poll::Ready(Err(error)) => {
                    log_message(format!("Helper could not accept a connection: {error}"));
                    self.retry = Some(Box::pin(tokio::time::sleep(ACCEPT_RETRY_DELAY)));
                }
                Poll::Pending => return Poll::Pending,
            }
        }
    }
}

fn wide(value: &str) -> Vec<u16> {
    value.encode_utf16().chain(std::iter::once(0)).collect()
}

struct PublishedPort;

impl PublishedPort {
    fn publish(port: u16) -> IoResult<Self> {
        let key_path = wide(PORT_KEY);
        let value_name = wide(PORT_VALUE);
        let data = u32::from(port).to_le_bytes();
        // SAFETY: the buffers outlive the calls, and the opened key is closed.
        let status = unsafe {
            let mut key: HKEY = 0;
            let status = RegCreateKeyExW(
                HKEY_LOCAL_MACHINE,
                key_path.as_ptr(),
                0,
                null(),
                REG_OPTION_VOLATILE,
                KEY_SET_VALUE,
                null(),
                &mut key,
                null_mut(),
            );
            if status != ERROR_SUCCESS {
                return Err(Error::from_raw_os_error(status as i32));
            }
            let status = RegSetValueExW(
                key,
                value_name.as_ptr(),
                0,
                REG_DWORD,
                data.as_ptr(),
                data.len() as u32,
            );
            RegCloseKey(key);
            status
        };
        if status != ERROR_SUCCESS {
            return Err(Error::from_raw_os_error(status as i32));
        }
        Ok(Self)
    }
}

impl Drop for PublishedPort {
    fn drop(&mut self) {
        let key_path = wide(PORT_KEY);
        unsafe {
            RegDeleteKeyW(HKEY_LOCAL_MACHINE, key_path.as_ptr());
        }
    }
}

pub(super) async fn serve_until<F, S>(
    owner_sid: String,
    shutdown: F,
    on_started: S,
) -> anyhow::Result<()>
where
    F: Future<Output = ()> + Send + 'static,
    S: FnOnce() -> anyhow::Result<()>,
{
    ensure_core_sha256_configured()?;

    let listener = TcpListener::bind((Ipv4Addr::LOCALHOST, 0))
        .await
        .map_err(|error| anyhow::anyhow!("bind helper server: {error}"))?;
    let port = listener
        .local_addr()
        .map_err(|error| anyhow::anyhow!("read helper server port: {error}"))?
        .port();
    let published = PublishedPort::publish(port)
        .map_err(|error| anyhow::anyhow!("publish helper server port: {error}"))?;
    on_started()?;
    let incoming = AuthorizedIncoming {
        listener,
        owner_sid,
        retry: None,
    };
    let make_service = make_service_fn(|connection: &CallerStream| {
        let service = warp::service(caller_routes(connection.caller.clone()));
        async move { Ok::<_, Infallible>(service) }
    });
    let served = Server::builder(accept::from_stream(incoming))
        .serve(make_service)
        .with_graceful_shutdown(shutdown)
        .await;
    if let Err(error) = served {
        log_message(format!("Helper server stopped: {error}"));
    }
    drop(published);
    release_managed_core_on_shutdown();

    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;

    fn v4(address: SocketAddr) -> SocketAddrV4 {
        match address {
            SocketAddr::V4(address) => address,
            SocketAddr::V6(_) => panic!("expected an IPv4 address"),
        }
    }

    #[test]
    fn the_tcp_table_names_this_process_on_its_own_loopback_connection() {
        let listener = std::net::TcpListener::bind((Ipv4Addr::LOCALHOST, 0)).unwrap();
        let server = v4(listener.local_addr().unwrap());
        let client = std::net::TcpStream::connect(server).unwrap();
        let _accepted = listener.accept().unwrap();
        let client = v4(client.local_addr().unwrap());

        let connections = tcp_connections().unwrap();

        assert_eq!(
            client_pid(&connections, client, server),
            Some(std::process::id())
        );
    }

    #[test]
    fn reads_the_account_of_a_process() {
        let sid = process_sid(std::process::id()).unwrap();

        assert!(sid.starts_with("S-1-5-"), "{sid}");
        assert!(process_sid(u32::MAX - 3).is_err());
    }

    #[test]
    fn identifies_a_process_by_account_and_creation_time() {
        let (sid, created) = process_identity(std::process::id()).unwrap();

        assert_eq!(sid, process_sid(std::process::id()).unwrap());
        assert!(created > 0);
        assert_eq!(process_identity(std::process::id()).unwrap().1, created);
    }

    #[tokio::test]
    async fn admits_the_owner_with_its_process_and_refuses_any_other_account() {
        let listener = TcpListener::bind((Ipv4Addr::LOCALHOST, 0)).await.unwrap();
        let _client = std::net::TcpStream::connect(listener.local_addr().unwrap()).unwrap();
        let (accepted, _) = listener.accept().await.unwrap();
        let owner = process_sid(std::process::id()).unwrap();

        let host = owner_client(&accepted, &owner).expect("the owner is admitted");
        assert_eq!(host.pid, std::process::id());
        assert_eq!(host.owner_sid, owner);
        assert_eq!(
            host.created,
            process_identity(std::process::id()).unwrap().1
        );
        assert!(owner_client(&accepted, "S-1-5-21-1-2-3-1001").is_none());
    }
}
