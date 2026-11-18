use regex::RegexSet;
use serde::{Deserialize, Serialize};
use std::collections::HashSet;
use std::sync::{Arc, Mutex, RwLock};

pub(super) const QUEUE_NUM: u16 = 31415;
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

impl Names {
    pub(super) fn count(&self) -> usize {
        self.full.len() + self.suffix.len() + self.keyword.len() + self.regex.len()
    }

    pub(super) fn validate(&self) -> Result<(), String> {
        if self.count() > MAX_NAMES {
            return Err(format!("at most {MAX_NAMES} names are allowed"));
        }
        let mut total = 0usize;
        let groups = [
            ("full", &self.full, MAX_NAME_BYTES),
            ("suffix", &self.suffix, MAX_NAME_BYTES),
            ("keyword", &self.keyword, MAX_NAME_BYTES),
            ("regex", &self.regex, MAX_REGEX_BYTES),
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
        if total > MAX_NAME_BYTES_TOTAL {
            return Err(format!(
                "names may total at most {MAX_NAME_BYTES_TOTAL} bytes"
            ));
        }
        Ok(())
    }
}

#[derive(Default)]
pub(super) struct Matcher {
    full: HashSet<String>,
    suffix: HashSet<String>,
    keyword: Vec<String>,
    regex: Option<RegexSet>,
}

fn normalize(name: &str) -> String {
    name.trim_end_matches('.').to_ascii_lowercase()
}

impl Matcher {
    pub(super) fn new(names: &Names) -> Self {
        let mut valid = Vec::new();
        for pattern in &names.regex {
            match regex::Regex::new(pattern) {
                Ok(_) => valid.push(pattern.as_str()),
                Err(error) => eprintln!("Helper skipped an invalid site lock pattern: {error}"),
            }
        }
        Self {
            full: names.full.iter().map(|name| normalize(name)).collect(),
            suffix: names.suffix.iter().map(|name| normalize(name)).collect(),
            keyword: names.keyword.iter().map(|name| normalize(name)).collect(),
            regex: if valid.is_empty() {
                None
            } else {
                RegexSet::new(valid)
                    .inspect_err(|error| {
                        eprintln!("Helper skipped the site lock patterns: {error}")
                    })
                    .ok()
            },
        }
    }

    pub(super) fn matches(&self, qname: &str) -> bool {
        let qname = normalize(qname);
        if self.full.contains(&qname) {
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
        self.regex.as_ref().is_some_and(|set| set.is_match(&qname))
    }

    /// True when the packet carries a DNS question for a locked name.
    pub(super) fn drops(&self, packet: &[u8]) -> bool {
        question_name(packet).is_some_and(|qname| self.matches(&qname))
    }
}

fn ip_payload(packet: &[u8]) -> Option<(u8, &[u8])> {
    match packet.first()? >> 4 {
        4 => {
            let header = usize::from(packet[0] & 0x0f) * 4;
            if header < 20 || packet.len() < header {
                return None;
            }
            if u16::from_be_bytes([packet[6], packet[7]]) & 0x1fff != 0 {
                return None;
            }
            let total = usize::from(u16::from_be_bytes([packet[2], packet[3]]));
            let end = if total >= header {
                total.min(packet.len())
            } else {
                packet.len()
            };
            Some((packet[9], &packet[header..end]))
        }
        6 => {
            if packet.len() < 40 {
                return None;
            }
            let length = usize::from(u16::from_be_bytes([packet[4], packet[5]]));
            let end = (40 + length).min(packet.len());
            Some((packet[6], &packet[40..end]))
        }
        _ => None,
    }
}

fn dns_message(packet: &[u8]) -> Option<&[u8]> {
    let (protocol, payload) = ip_payload(packet)?;
    match protocol {
        17 => payload.get(8..),
        6 => {
            let offset = usize::from(payload.get(12)? >> 4) * 4;
            let stream = payload.get(offset..)?;
            let length = usize::from(u16::from_be_bytes([*stream.first()?, *stream.get(1)?]));
            let message = stream.get(2..)?;
            Some(&message[..length.min(message.len())])
        }
        _ => None,
    }
}

/// First question name of the DNS message in a raw IP packet, lowercased and without a trailing dot.
pub(super) fn question_name(packet: &[u8]) -> Option<String> {
    let message = dns_message(packet)?;
    if message.len() < 13 || u16::from_be_bytes([message[4], message[5]]) == 0 {
        return None;
    }
    let mut name = String::new();
    let mut position = 12;
    loop {
        let length = usize::from(*message.get(position)?);
        position += 1;
        if length == 0 {
            break;
        }
        if length > 63 {
            return None;
        }
        let label = message.get(position..position + length)?;
        position += length;
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
    (!name.is_empty()).then_some(name)
}

pub(super) trait DnsQueue: Send + Sync {
    /// Binds the queue and starts answering it; later calls are no-ops.
    fn start(&self) -> Result<(), String>;
    fn set_matcher(&self, matcher: Matcher);
}

pub(super) struct NoQueue;

impl DnsQueue for NoQueue {
    fn start(&self) -> Result<(), String> {
        Err("the DNS filter queue is not available".to_string())
    }

    fn set_matcher(&self, _matcher: Matcher) {}
}

pub(super) struct SystemQueue {
    matcher: Arc<RwLock<Arc<Matcher>>>,
    started: Mutex<bool>,
}

impl SystemQueue {
    pub(super) fn shared() -> Arc<SystemQueue> {
        static SHARED: std::sync::OnceLock<Arc<SystemQueue>> = std::sync::OnceLock::new();
        SHARED
            .get_or_init(|| {
                Arc::new(SystemQueue {
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
        let queue = open_queue().map_err(|error| format!("cannot bind DNS queue: {error}"))?;
        let matcher = self.matcher.clone();
        std::thread::Builder::new()
            .name("site-lock-dns".into())
            .spawn(move || serve(queue, &matcher))
            .map_err(|error| format!("cannot start DNS filter thread: {error}"))?;
        *started = true;
        Ok(())
    }

    #[cfg(not(target_os = "linux"))]
    fn start(&self) -> Result<(), String> {
        let _ = &self.started;
        Err("the DNS filter is only available on Linux".to_string())
    }

    fn set_matcher(&self, matcher: Matcher) {
        *self.matcher.write().unwrap_or_else(|e| e.into_inner()) = Arc::new(matcher);
    }
}

#[cfg(target_os = "linux")]
fn open_queue() -> std::io::Result<nfq::Queue> {
    let mut queue = nfq::Queue::open()?;
    queue.bind(QUEUE_NUM)?;
    Ok(queue)
}

#[cfg(target_os = "linux")]
fn serve(mut queue: nfq::Queue, matcher: &RwLock<Arc<Matcher>>) {
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
            Err(error) => {
                eprintln!("Helper DNS filter lost its queue: {error}");
                drop(queue);
                queue = loop {
                    std::thread::sleep(std::time::Duration::from_secs(1));
                    match open_queue() {
                        Ok(queue) => break queue,
                        Err(error) => eprintln!("Helper DNS filter cannot rebind: {error}"),
                    }
                };
            }
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

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
        let matcher = Matcher::new(&names(&["Example.COM."], &[], &[], &[]));
        assert!(matcher.matches("example.com"));
        assert!(matcher.matches("EXAMPLE.com."));
        assert!(!matcher.matches("www.example.com"));
    }

    #[test]
    fn suffix_names_respect_label_boundaries() {
        let matcher = Matcher::new(&names(&[], &["chatgpt.com"], &[], &[]));
        assert!(matcher.matches("chatgpt.com"));
        assert!(matcher.matches("api.chatgpt.com"));
        assert!(matcher.matches("a.b.chatgpt.com"));
        assert!(!matcher.matches("notchatgpt.com"));
        assert!(!matcher.matches("chatgpt.com.evil.org"));
    }

    #[test]
    fn keyword_and_regex_names_match_anywhere() {
        let matcher = Matcher::new(&names(
            &[],
            &[],
            &["openai"],
            &["(?i)^cdn[0-9]+\\.example\\.org$"],
        ));
        assert!(matcher.matches("api.openai.net"));
        assert!(matcher.matches("cdn42.example.org"));
        assert!(!matcher.matches("cdn.example.org"));
        assert!(!matcher.matches("example.net"));
    }

    #[test]
    fn invalid_regex_is_skipped_and_valid_ones_still_apply() {
        let matcher = Matcher::new(&names(&[], &[], &[], &["(unclosed", "^ok\\.test$"]));
        assert!(matcher.matches("ok.test"));
        assert!(!matcher.matches("(unclosed"));
        assert!(!Matcher::new(&names(&[], &[], &[], &["(unclosed"])).matches("x"));
    }

    #[test]
    fn empty_matcher_matches_nothing() {
        assert!(!Matcher::default().matches("example.com"));
        assert!(!Matcher::default().drops(&udp4(&dns("example.com"))));
    }

    #[test]
    fn parses_udp_over_both_ip_versions() {
        assert_eq!(
            question_name(&udp4(&dns("Api.Example.com"))).as_deref(),
            Some("api.example.com")
        );
        assert_eq!(
            question_name(&udp6(&dns("example.org"))).as_deref(),
            Some("example.org")
        );
    }

    #[test]
    fn parses_tcp_with_the_length_prefix() {
        let packet = tcp4(&prefixed(&dns("example.com")));
        assert_eq!(question_name(&packet).as_deref(), Some("example.com"));
        assert_eq!(question_name(&tcp4(&[])), None);
        assert_eq!(question_name(&tcp4(&[0])), None);
    }

    #[test]
    fn fragments_and_malformed_packets_are_not_parsed() {
        let mut fragment = udp4(&dns("example.com"));
        fragment[7] = 8;
        assert_eq!(question_name(&fragment), None);
        let mut pointer = dns("example.com");
        pointer[12] = 0xc0;
        assert_eq!(question_name(&udp4(&pointer)), None);
        let mut no_question = dns("example.com");
        no_question[5] = 0;
        assert_eq!(question_name(&udp4(&no_question)), None);
        let truncated = udp4(&dns("example.com"));
        assert_eq!(question_name(&truncated[..truncated.len() - 9]), None);
        for packet in [&[][..], &[0x45][..], &[0x60; 10][..], &[0x10; 40][..]] {
            assert_eq!(question_name(packet), None);
        }
        let mut other = udp4(&dns("example.com"));
        other[9] = 1;
        assert_eq!(question_name(&other), None);
        let mut extension = udp6(&dns("example.com"));
        extension[6] = 0;
        assert_eq!(question_name(&extension), None);
    }

    #[test]
    fn drops_only_packets_for_locked_names() {
        let matcher = Matcher::new(&names(&[], &["chatgpt.com"], &[], &[]));
        assert!(matcher.drops(&udp4(&dns("api.chatgpt.com"))));
        assert!(matcher.drops(&tcp4(&prefixed(&dns("chatgpt.com")))));
        assert!(!matcher.drops(&udp4(&dns("example.com"))));
        assert!(!matcher.drops(&[1, 2, 3]));
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
