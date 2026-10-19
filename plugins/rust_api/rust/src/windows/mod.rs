#[cfg(any(windows, test))]
mod contract;
#[cfg(windows)]
mod launch;
#[cfg(windows)]
mod pipe;
#[cfg(windows)]
pub(crate) mod security;

#[cfg(windows)]
pub(crate) use launch::{authorize_rpc_peer, cancel, is_managed_peer, prepare, start, stop};
