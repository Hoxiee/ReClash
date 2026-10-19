use std::io;

pub const RPC_PREFIX: &str = r"\\.\pipe\ReClashCore_";

pub fn lower_hex(value: &str, length: usize) -> bool {
    value.len() == length
        && value
            .bytes()
            .all(|byte| byte.is_ascii_digit() || (b'a'..=b'f').contains(&byte))
}

pub fn session(value: &str) -> io::Result<()> {
    if lower_hex(value, 32) {
        Ok(())
    } else {
        Err(io::Error::other("windows_invalid_session"))
    }
}

pub fn local_path(value: &str) -> bool {
    let value = value.strip_prefix(r"\\?\").unwrap_or(value);
    let bytes = value.as_bytes();
    bytes.len() > 3
        && bytes[0].is_ascii_alphabetic()
        && bytes[1] == b':'
        && matches!(bytes[2], b'\\' | b'/')
        && value[3..].split(['\\', '/']).all(|part| {
            !part.is_empty()
                && part != "."
                && part != ".."
                && !part.ends_with(['.', ' '])
                && !part
                    .chars()
                    .any(|c| c.is_control() || matches!(c, ':' | '<' | '>' | '"' | '|' | '?' | '*'))
        })
}

pub fn launch(session_id: &str, address: &str, home: &str, sha256: &str) -> io::Result<()> {
    session(session_id)?;
    if !address
        .strip_prefix(RPC_PREFIX)
        .is_some_and(|suffix| lower_hex(suffix, 32))
        || !local_path(home)
        || !lower_hex(sha256, 64)
    {
        return Err(io::Error::other("windows_invalid_launch_parameters"));
    }
    Ok(())
}

pub fn quote(value: &str) -> String {
    let mut result = String::from("\"");
    let mut slashes = 0;
    for character in value.chars() {
        if character == '\\' {
            slashes += 1;
            continue;
        }
        result.extend(std::iter::repeat_n(
            '\\',
            if character == '"' {
                slashes * 2 + 1
            } else {
                slashes
            },
        ));
        slashes = 0;
        result.push(character);
    }
    result.extend(std::iter::repeat_n('\\', slashes * 2));
    result.push('"');
    result
}

#[cfg(test)]
mod tests {
    use super::*;

    const SESSION: &str = "0123456789abcdef0123456789abcdef";

    #[test]
    fn fixed_namespace_has_an_independent_lowercase_random_suffix() {
        assert!(launch(
            SESSION,
            &format!("{RPC_PREFIX}{}", "a".repeat(32)),
            r"C:\Users\owner\ReClash",
            &"b".repeat(64),
        )
        .is_ok());
        for suffix in ["short".to_owned(), "A".repeat(32), format!("{}\0", SESSION)] {
            assert!(launch(
                SESSION,
                &format!("{RPC_PREFIX}{suffix}"),
                r"C:\Users\owner\ReClash",
                &"b".repeat(64),
            )
            .is_err());
        }
    }

    #[test]
    fn rejects_remote_paths_devices_aliases_and_invalid_hashes() {
        for path in [
            r"\\server\share\home",
            r"\\?\UNC\server\share\home",
            r"\\.\C:\home",
            r"C:\",
            r"C:\home\..\other",
            r"C:\home:stream",
            r"C:\home.",
            "C:\\home\0",
            "relative",
        ] {
            assert!(!local_path(path), "accepted {path:?}");
        }
        for hash in ["A".repeat(64), "0".repeat(63), "g".repeat(64)] {
            assert!(launch(
                SESSION,
                &format!("{RPC_PREFIX}{SESSION}"),
                r"C:\home",
                &hash
            )
            .is_err());
        }
        assert!(local_path(r"\\?\C:\Users\owner\ReClash"));
        assert!(session(&"A".repeat(32)).is_err());
    }

    #[test]
    fn shell_arguments_quote_backslashes_quotes_and_empty_values() {
        assert_eq!(quote(""), "\"\"");
        assert_eq!(quote("plain"), "\"plain\"");
        assert_eq!(quote("a\"b"), "\"a\\\"b\"");
        assert_eq!(quote("C:\\space here\\"), "\"C:\\space here\\\\\"");
        assert_eq!(quote("кириллица"), "\"кириллица\"");
    }
}
