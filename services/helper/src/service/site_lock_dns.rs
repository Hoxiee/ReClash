use regex::RegexSet;
use serde::{Deserialize, Serialize};
use std::collections::HashSet;
use std::sync::{Arc, Mutex, RwLock};

pub(super) const MAX_NAMES: usize = 262_144;
pub(super) const MAX_NAME_BYTES: usize = 253;
pub(super) const MAX_REGEX_BYTES: usize = 1024;
// Keeps the worst-case JSON body (every byte escaped) inside the route body limit.
pub(super) const MAX_NAME_BYTES_TOTAL: usize = 7 * 1024 * 1024;

#[derive(Debug, Default, Clone, PartialEq, Eq, Serialize, Deserialize)]
#[serde(default, deny_unknown_fields)]
pub(super) struct Names {
    pub(super) full: Vec<String>,
    pub(super) suffix: Vec<String>,
    pub(super) keyword: Vec<String>,
    pub(super) regex: Vec<String>,
}

/// One lock's names with its exceptions, which free them from this lock only.
#[derive(Debug, Default, Clone, PartialEq, Eq, Serialize, Deserialize)]
#[serde(default, deny_unknown_fields)]
pub(super) struct GuardedNames {
    pub(super) names: Names,
    pub(super) except: Names,
}

impl Names {
    pub(super) fn count(&self) -> usize {
        self.full.len() + self.suffix.len() + self.keyword.len() + self.regex.len()
    }
}

/// The limits hold for all the sets together.
pub(super) fn validate_names<'a>(sets: impl IntoIterator<Item = &'a Names>) -> Result<(), String> {
    let mut count = 0usize;
    let mut total = 0usize;
    for names in sets {
        count += names.count();
        if count > MAX_NAMES {
            return Err(format!("at most {MAX_NAMES} names are allowed"));
        }
        let groups = [
            ("full", &names.full, MAX_NAME_BYTES),
            ("suffix", &names.suffix, MAX_NAME_BYTES),
            ("keyword", &names.keyword, MAX_NAME_BYTES),
            ("regex", &names.regex, MAX_REGEX_BYTES),
        ];
        for (kind, entries, limit) in groups {
            for entry in entries {
                let valid = !entry.is_empty()
                    && entry.len() <= limit
                    && !entry
                        .chars()
                        .any(|c| c.is_ascii_control() || c.is_whitespace());
                if !valid {
                    let shown: String = entry.chars().take(64).collect();
                    return Err(format!(
                        "invalid {kind} name {shown:?}: 1 to {limit} bytes without whitespace or control characters"
                    ));
                }
                total += entry.len();
            }
        }
    }
    if total > MAX_NAME_BYTES_TOTAL {
        return Err(format!(
            "names may total at most {MAX_NAME_BYTES_TOTAL} bytes"
        ));
    }
    Ok(())
}

#[derive(Default)]
struct NameSet {
    full: HashSet<String>,
    suffix: HashSet<String>,
    keyword: Vec<String>,
    regex: Option<RegexSet>,
}

fn normalize(name: &str) -> String {
    name.trim_end_matches('.').to_ascii_lowercase()
}

impl NameSet {
    fn new(names: &Names) -> Result<Self, String> {
        for pattern in &names.regex {
            regex::Regex::new(pattern).map_err(|error| {
                format!("site lock pattern {pattern:?} is not supported: {error}")
            })?;
        }
        let regex = if names.regex.is_empty() {
            None
        } else {
            Some(
                RegexSet::new(&names.regex)
                    .map_err(|error| format!("site lock patterns cannot be combined: {error}"))?,
            )
        };
        Ok(Self::with_regex(names, regex))
    }

    fn lenient(names: &Names) -> Self {
        let mut valid = Vec::new();
        for pattern in &names.regex {
            match regex::Regex::new(pattern) {
                Ok(_) => valid.push(pattern.as_str()),
                Err(error) => eprintln!("Helper skipped an invalid site lock pattern: {error}"),
            }
        }
        let regex = if valid.is_empty() {
            None
        } else {
            RegexSet::new(valid)
                .inspect_err(|error| eprintln!("Helper skipped the site lock patterns: {error}"))
                .ok()
        };
        Self::with_regex(names, regex)
    }

    fn with_regex(names: &Names, regex: Option<RegexSet>) -> Self {
        Self {
            full: names.full.iter().map(|name| normalize(name)).collect(),
            suffix: names.suffix.iter().map(|name| normalize(name)).collect(),
            keyword: names.keyword.iter().map(|name| normalize(name)).collect(),
            regex,
        }
    }

    fn matches(&self, qname: &str) -> bool {
        if self.full.contains(qname) {
            return true;
        }
        let mut boundaries = std::iter::once(0).chain(qname.match_indices('.').map(|(i, _)| i + 1));
        if boundaries.any(|start| self.suffix.contains(&qname[start..])) {
            return true;
        }
        if self
            .keyword
            .iter()
            .any(|word| qname.contains(word.as_str()))
        {
            return true;
        }
        self.regex.as_ref().is_some_and(|set| set.is_match(qname))
    }

    fn is_empty(&self) -> bool {
        self.full.is_empty()
            && self.suffix.is_empty()
            && self.keyword.is_empty()
            && self.regex.is_none()
    }
}

#[derive(Default)]
pub(super) struct Matcher {
    names: NameSet,
    guarded: Vec<(NameSet, NameSet)>,
}

impl Matcher {
    /// Refuses a pattern the filter cannot compile, so a lock is never reported
    /// as mirrored while its names pass.
    pub(super) fn new(names: &Names, guarded: &[GuardedNames]) -> Result<Self, String> {
        Ok(Self {
            names: NameSet::new(names)?,
            guarded: guarded
                .iter()
                .map(|lock| Ok((NameSet::new(&lock.names)?, NameSet::new(&lock.except)?)))
                .collect::<Result<_, String>>()?,
        })
    }

    /// For a state an earlier Helper accepted: filters every pattern that still compiles.
    pub(super) fn lenient(names: &Names, guarded: &[GuardedNames]) -> Self {
        Self {
            names: NameSet::lenient(names),
            guarded: guarded
                .iter()
                .map(|lock| {
                    (
                        NameSet::lenient(&lock.names),
                        NameSet::lenient(&lock.except),
                    )
                })
                .collect(),
        }
    }

    pub(super) fn matches(&self, qname: &str) -> bool {
        let qname = normalize(qname);
        self.names.matches(&qname)
            || self
                .guarded
                .iter()
                .any(|(names, except)| names.matches(&qname) && !except.matches(&qname))
    }

    /// True when the packet asks for a locked name, or cannot be read in
    /// full: a query this filter cannot see must not slip past it.
    pub(super) fn drops(&self, packet: &[u8]) -> bool {
        if self.names.is_empty() && self.guarded.iter().all(|(names, _)| names.is_empty()) {
            return false;
        }
        question_names(packet).is_none_or(|names| names.iter().any(|name| self.matches(name)))
    }
}

fn ip_payload(packet: &[u8]) -> Option<(u8, &[u8])> {
    match packet.first()? >> 4 {
        4 => {
            let header = usize::from(packet[0] & 0x0f) * 4;
            if header < 20 || packet.len() < header {
                return None;
            }
            // More-fragments or an offset: the message is not all here.
            if u16::from_be_bytes([packet[6], packet[7]]) & 0x3fff != 0 {
                return None;
            }
            let total = usize::from(u16::from_be_bytes([packet[2], packet[3]]));
            Some((packet[9], packet.get(header..total)?))
        }
        6 => {
            let length = usize::from(u16::from_be_bytes([*packet.get(4)?, *packet.get(5)?]));
            let mut next = *packet.get(6)?;
            let mut body = packet.get(40..40 + length)?;
            // Hop-by-hop, routing and destination options; a fragment header
            // ends the walk unread.
            while matches!(next, 0 | 43 | 60) {
                let size = (usize::from(*body.get(1)?) + 1) * 8;
                next = body[0];
                body = body.get(size..)?;
            }
            Some((next, body))
        }
        _ => None,
    }
}

/// Question names of every DNS message in a raw IP packet, lowercased and
/// without a trailing dot; None when any part of it cannot be read.
pub(super) fn question_names(packet: &[u8]) -> Option<Vec<String>> {
    let (protocol, payload) = ip_payload(packet)?;
    let mut names = Vec::new();
    match protocol {
        17 => read_questions(payload.get(8..)?, &mut names)?,
        6 => {
            let offset = usize::from(payload.get(12)? >> 4) * 4;
            if offset < 20 {
                return None;
            }
            // A segment must carry whole length-prefixed messages; one that
            // continues a message from an earlier segment cannot be read.
            let mut stream = payload.get(offset..)?;
            while !stream.is_empty() {
                let length = usize::from(u16::from_be_bytes([*stream.first()?, *stream.get(1)?]));
                read_questions(stream.get(2..2 + length)?, &mut names)?;
                stream = &stream[2 + length..];
            }
        }
        _ => return None,
    }
    Some(names)
}

fn read_questions(message: &[u8], names: &mut Vec<String>) -> Option<()> {
    if message.len() < 12 {
        return None;
    }
    let mut position = 12;
    for _ in 0..u16::from_be_bytes([message[4], message[5]]) {
        let (name, end) = read_name(message, position)?;
        position = end + 4;
        if position > message.len() {
            return None;
        }
        names.push(name);
    }
    Some(())
}

/// The name at [start] and the offset after it, following compression
/// pointers; each must point backwards, so a loop cannot form.
fn read_name(message: &[u8], start: usize) -> Option<(String, usize)> {
    let mut name = String::new();
    let mut position = start;
    let mut end = None;
    loop {
        let length = *message.get(position)?;
        match length >> 6 {
            0 => {}
            3 => {
                let target =
                    usize::from(u16::from_be_bytes([length, *message.get(position + 1)?]) & 0x3fff);
                if target >= position {
                    return None;
                }
                end.get_or_insert(position + 2);
                position = target;
                continue;
            }
            _ => return None,
        }
        position += 1;
        if length == 0 {
            break;
        }
        let label = message.get(position..position + usize::from(length))?;
        position += usize::from(length);
        if !name.is_empty() {
            name.push('.');
        }
        name.extend(
            label
                .iter()
                .map(|&byte| char::from(byte.to_ascii_lowercase())),
        );
        if name.len() > 253 {
            return None;
        }
    }
    Some((name, end.unwrap_or(position)))
}

pub(super) trait DnsQueue: Send + Sync {
    /// Binds the queue and starts answering it; later calls are no-ops.
    fn start(&self) -> Result<(), String>;
    /// Returns the matcher it replaces.
    fn set_matcher(&self, matcher: Arc<Matcher>) -> Arc<Matcher>;
}

pub(super) struct NoQueue;

impl DnsQueue for NoQueue {
    fn start(&self) -> Result<(), String> {
        Err("the DNS filter queue is not available".to_string())
    }

    fn set_matcher(&self, _matcher: Arc<Matcher>) -> Arc<Matcher> {
        Arc::default()
    }
}

pub(super) struct SystemQueue {
    queue: u16,
    matcher: Arc<RwLock<Arc<Matcher>>>,
    started: Mutex<bool>,
}

impl SystemQueue {
    /// The process serves one owner, so the first queue number asked for is the only one.
    pub(super) fn shared(queue: u16) -> Arc<SystemQueue> {
        static SHARED: std::sync::OnceLock<Arc<SystemQueue>> = std::sync::OnceLock::new();
        SHARED
            .get_or_init(|| {
                Arc::new(SystemQueue {
                    queue,
                    matcher: Arc::new(RwLock::new(Arc::new(Matcher::default()))),
                    started: Mutex::new(false),
                })
            })
            .clone()
    }
}

impl DnsQueue for SystemQueue {
    #[cfg(target_os = "linux")]
    fn start(&self) -> Result<(), String> {
        let mut started = self.started.lock().unwrap_or_else(|e| e.into_inner());
        if *started {
            return Ok(());
        }
        let number = self.queue;
        let queue = open_queue(number)
            .map_err(|error| format!("cannot bind DNS queue {number}: {error}"))?;
        let matcher = self.matcher.clone();
        std::thread::Builder::new()
            .name("site-lock-dns".into())
            .spawn(move || serve(queue, number, &matcher))
            .map_err(|error| format!("cannot start DNS filter thread: {error}"))?;
        *started = true;
        Ok(())
    }

    #[cfg(not(target_os = "linux"))]
    fn start(&self) -> Result<(), String> {
        let _ = &self.started;
        Err("the DNS filter is only available on Linux".to_string())
    }

    fn set_matcher(&self, matcher: Arc<Matcher>) -> Arc<Matcher> {
        std::mem::replace(
            &mut *self.matcher.write().unwrap_or_else(|e| e.into_inner()),
            matcher,
        )
    }
}

#[cfg(target_os = "linux")]
fn open_queue(number: u16) -> std::io::Result<nfq::Queue> {
    let mut queue = nfq::Queue::open()?;
    queue.bind(number)?;
    Ok(queue)
}

#[cfg(target_os = "linux")]
fn serve(mut queue: nfq::Queue, number: u16, matcher: &RwLock<Arc<Matcher>>) {
    loop {
        match queue.recv() {
            Ok(mut message) => {
                let current = matcher.read().unwrap_or_else(|e| e.into_inner()).clone();
                message.set_verdict(if current.drops(message.get_payload()) {
                    nfq::Verdict::Drop
                } else {
                    nfq::Verdict::Accept
                });
                if let Err(error) = queue.verdict(message) {
                    eprintln!("Helper DNS filter could not send a verdict: {error}");
                }
            }
            Err(error) if transient(&error) => continue,
            Err(error) => {
                eprintln!("Helper DNS filter lost its queue: {error}");
                drop(queue);
                let mut delay = REBIND_DELAY;
                queue = loop {
                    std::thread::sleep(delay);
                    match open_queue(number) {
                        Ok(queue) => break queue,
                        Err(error) => eprintln!("Helper DNS filter cannot rebind: {error}"),
                    }
                    delay = (delay * 2).min(MAX_REBIND_DELAY);
                };
            }
        }
    }
}

#[cfg(target_os = "linux")]
const REBIND_DELAY: std::time::Duration = std::time::Duration::from_millis(50);
#[cfg(target_os = "linux")]
const MAX_REBIND_DELAY: std::time::Duration = std::time::Duration::from_secs(2);

#[cfg(target_os = "linux")]
/// Errors after which the socket still holds its binding: an interrupted read, a
/// kernel buffer overrun, or one oversized message. The queue stays usable.
fn transient(error: &std::io::Error) -> bool {
    use std::io::ErrorKind;
    matches!(
        error.kind(),
        ErrorKind::Interrupted | ErrorKind::WouldBlock | ErrorKind::TimedOut
    ) || matches!(error.raw_os_error(), Some(code) if code == libc::ENOBUFS || code == libc::ENOSPC)
}

#[cfg(test)]
mod tests {
    #[cfg(target_os = "linux")]
    #[test]
    fn only_a_broken_socket_is_rebound() {
        use std::io::Error;
        for code in [libc::EINTR, libc::ENOBUFS, libc::ENOSPC, libc::EAGAIN] {
            assert!(super::transient(&Error::from_raw_os_error(code)), "{code}");
        }
        for code in [libc::EBADF, libc::ENOTSOCK, libc::EPERM] {
            assert!(!super::transient(&Error::from_raw_os_error(code)), "{code}");
        }
    }

    use super::*;

    impl Names {
        fn validate(&self) -> Result<(), String> {
            validate_names([self])
        }
    }

    fn names(full: &[&str], suffix: &[&str], keyword: &[&str], regex: &[&str]) -> Names {
        let own = |list: &[&str]| list.iter().map(|value| value.to_string()).collect();
        Names {
            full: own(full),
            suffix: own(suffix),
            keyword: own(keyword),
            regex: own(regex),
        }
    }

    fn dns(name: &str) -> Vec<u8> {
        let mut message = vec![0x12, 0x34, 0x01, 0x00, 0, 1, 0, 0, 0, 0, 0, 0];
        for label in name.split('.') {
            message.push(label.len() as u8);
            message.extend(label.as_bytes());
        }
        message.extend([0, 0, 1, 0, 1]);
        message
    }

    fn udp4(message: &[u8]) -> Vec<u8> {
        let total = 20 + 8 + message.len();
        let mut packet = vec![
            0x45,
            0,
            (total >> 8) as u8,
            total as u8,
            0,
            0,
            0,
            0,
            64,
            17,
            0,
            0,
        ];
        packet.extend([10, 0, 0, 1, 10, 0, 0, 2]);
        packet.extend([0x9c, 0x40, 0, 53, 0, (8 + message.len()) as u8, 0, 0]);
        packet.extend(message);
        packet
    }

    fn udp6(message: &[u8]) -> Vec<u8> {
        let length = 8 + message.len();
        let mut packet = vec![0x60, 0, 0, 0, (length >> 8) as u8, length as u8, 17, 64];
        packet.extend([0u8; 32]);
        packet.extend([0x9c, 0x40, 0, 53, 0, length as u8, 0, 0]);
        packet.extend(message);
        packet
    }

    fn tcp4(stream: &[u8]) -> Vec<u8> {
        let total = 20 + 20 + stream.len();
        let mut packet = vec![
            0x45,
            0,
            (total >> 8) as u8,
            total as u8,
            0,
            0,
            0,
            0,
            64,
            6,
            0,
            0,
        ];
        packet.extend([10, 0, 0, 1, 10, 0, 0, 2]);
        let mut header = vec![0u8; 20];
        header[12] = 0x50;
        packet.extend(header);
        packet.extend(stream);
        packet
    }

    fn prefixed(message: &[u8]) -> Vec<u8> {
        let mut stream = vec![(message.len() >> 8) as u8, message.len() as u8];
        stream.extend(message);
        stream
    }

    #[test]
    fn full_names_match_exactly_ignoring_case_and_trailing_dot() {
        let matcher = Matcher::new(&names(&["Example.COM."], &[], &[], &[]), &[]).unwrap();
        assert!(matcher.matches("example.com"));
        assert!(matcher.matches("EXAMPLE.com."));
        assert!(!matcher.matches("www.example.com"));
    }

    #[test]
    fn suffix_names_respect_label_boundaries() {
        let matcher = Matcher::new(&names(&[], &["chatgpt.com"], &[], &[]), &[]).unwrap();
        assert!(matcher.matches("chatgpt.com"));
        assert!(matcher.matches("api.chatgpt.com"));
        assert!(matcher.matches("a.b.chatgpt.com"));
        assert!(!matcher.matches("notchatgpt.com"));
        assert!(!matcher.matches("chatgpt.com.evil.org"));
    }

    #[test]
    fn keyword_and_regex_names_match_anywhere() {
        let matcher = Matcher::new(
            &names(&[], &[], &["openai"], &["(?i)^cdn[0-9]+\\.example\\.org$"]),
            &[],
        )
        .unwrap();
        assert!(matcher.matches("api.openai.net"));
        assert!(matcher.matches("cdn42.example.org"));
        assert!(!matcher.matches("cdn.example.org"));
        assert!(!matcher.matches("example.net"));
    }

    #[test]
    fn exceptions_free_names_from_their_own_lock_only() {
        let guarded = [GuardedNames {
            names: names(&[], &["openai.com"], &[], &[]),
            except: names(&["status.openai.com"], &[], &[], &[]),
        }];
        let alone = Matcher::new(&Names::default(), &guarded).unwrap();
        assert!(alone.matches("api.openai.com"));
        assert!(!alone.matches("status.openai.com"));
        assert!(!alone.drops(&udp4(&dns("status.openai.com"))));
        let both = Matcher::new(&names(&["status.openai.com"], &[], &[], &[]), &guarded).unwrap();
        assert!(both.matches("status.openai.com"));
    }

    #[test]
    fn invalid_regex_is_refused_strictly_and_skipped_leniently() {
        let mixed = names(&[], &[], &[], &["(unclosed", "^ok\\.test$"]);
        let error = Matcher::new(&mixed, &[]).err().unwrap();
        assert!(error.contains("(unclosed"));
        let matcher = Matcher::lenient(&mixed, &[]);
        assert!(matcher.matches("ok.test"));
        assert!(!matcher.matches("(unclosed"));
        assert!(!Matcher::lenient(&names(&[], &[], &[], &["(unclosed"]), &[]).matches("x"));
    }

    #[test]
    fn empty_matcher_matches_nothing() {
        assert!(!Matcher::default().matches("example.com"));
        assert!(!Matcher::default().drops(&udp4(&dns("example.com"))));
    }

    fn one(name: &str) -> Option<Vec<String>> {
        Some(vec![name.to_string()])
    }

    #[test]
    fn parses_udp_over_both_ip_versions() {
        assert_eq!(
            question_names(&udp4(&dns("Api.Example.com"))),
            one("api.example.com")
        );
        assert_eq!(
            question_names(&udp6(&dns("example.org"))),
            one("example.org")
        );
    }

    #[test]
    fn walks_ipv6_extension_headers() {
        let plain = udp6(&dns("example.org"));
        let mut packet = plain[..40].to_vec();
        packet[6] = 0;
        let length = u16::from_be_bytes([packet[4], packet[5]]) + 8;
        packet[4..6].copy_from_slice(&length.to_be_bytes());
        packet.extend([17, 0, 0, 0, 0, 0, 0, 0]);
        packet.extend(&plain[40..]);
        assert_eq!(question_names(&packet), one("example.org"));
        packet[40] = 44;
        assert_eq!(question_names(&packet), None);
    }

    #[test]
    fn reads_every_question_and_every_tcp_message() {
        let mut two = dns("a.example");
        two[5] = 2;
        two.extend([3, b'w', b'w', b'w', 0xc0, 14, 0, 1, 0, 1]);
        assert_eq!(
            question_names(&udp4(&two)),
            Some(vec!["a.example".to_string(), "www.example".to_string()])
        );
        let mut stream = prefixed(&dns("a.example"));
        stream.extend(prefixed(&dns("b.example")));
        assert_eq!(
            question_names(&tcp4(&stream)),
            Some(vec!["a.example".to_string(), "b.example".to_string()])
        );
        assert_eq!(question_names(&tcp4(&[])), Some(vec![]));
    }

    #[test]
    fn unreadable_packets_are_reported_as_such() {
        let mut fragment = udp4(&dns("example.com"));
        fragment[7] = 8;
        assert_eq!(question_names(&fragment), None);
        let mut more = udp4(&dns("example.com"));
        more[6] = 0x20;
        assert_eq!(question_names(&more), None);
        let mut forward = dns("example.com");
        forward[12] = 0xc0;
        forward[13] = 12;
        assert_eq!(question_names(&udp4(&forward)), None);
        let truncated = udp4(&dns("example.com"));
        assert_eq!(question_names(&truncated[..truncated.len() - 9]), None);
        let mut split = prefixed(&dns("example.com"));
        split.truncate(split.len() - 3);
        assert_eq!(question_names(&tcp4(&split)), None);
        assert_eq!(question_names(&tcp4(&[0])), None);
        for packet in [&[][..], &[0x45][..], &[0x60; 10][..], &[0x10; 40][..]] {
            assert_eq!(question_names(packet), None);
        }
        let mut other = udp4(&dns("example.com"));
        other[9] = 1;
        assert_eq!(question_names(&other), None);
    }

    #[test]
    fn drops_locked_names_and_what_it_cannot_read() {
        let matcher = Matcher::new(&names(&[], &["chatgpt.com"], &[], &[]), &[]).unwrap();
        assert!(matcher.drops(&udp4(&dns("api.chatgpt.com"))));
        assert!(matcher.drops(&tcp4(&prefixed(&dns("chatgpt.com")))));
        let mut second = dns("example.com");
        second[5] = 2;
        second.extend([
            7, b'c', b'h', b'a', b't', b'g', b'p', b't', 0xc0, 20, 0, 1, 0, 1,
        ]);
        assert!(matcher.drops(&udp4(&second)));
        assert!(matcher.drops(&[1, 2, 3]));
        assert!(!matcher.drops(&udp4(&dns("example.com"))));
        assert!(!matcher.drops(&tcp4(&[])));
        assert!(!Matcher::default().drops(&[1, 2, 3]));
    }

    #[test]
    fn validation_enforces_name_limits() {
        assert!(names(&["a"], &["b"], &["c"], &["^d$"]).validate().is_ok());
        for bad in ["", "a b", "a\tb", "a\u{7f}", "a\nb"] {
            assert!(names(&[bad], &[], &[], &[]).validate().is_err(), "{bad:?}");
            assert!(names(&[], &[], &[], &[bad]).validate().is_err(), "{bad:?}");
        }
        let long = "a".repeat(MAX_NAME_BYTES + 1);
        assert!(names(&[&long[1..]], &[], &[], &[]).validate().is_ok());
        for kind in 0..3 {
            let mut set = Names::default();
            [&mut set.full, &mut set.suffix, &mut set.keyword][kind].push(long.clone());
            assert!(set.validate().is_err());
        }
        assert!(names(&[], &[], &[], &[&"a".repeat(MAX_REGEX_BYTES)])
            .validate()
            .is_ok());
        assert!(names(&[], &[], &[], &[&"a".repeat(MAX_REGEX_BYTES + 1)])
            .validate()
            .is_err());
        let many = Names {
            full: vec!["a".to_string(); MAX_NAMES + 1],
            ..Names::default()
        };
        assert!(many.validate().is_err());
        let bulky = Names {
            regex: vec!["a".repeat(MAX_REGEX_BYTES); MAX_NAME_BYTES_TOTAL / MAX_REGEX_BYTES + 1],
            ..Names::default()
        };
        assert!(bulky.validate().is_err());
    }
}
