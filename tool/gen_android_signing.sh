#!/usr/bin/env bash
# Generates an Android release keystore and prints the four GitHub Actions
# secrets (KEYSTORE, KEY_ALIAS, STORE_PASSWORD, KEY_PASSWORD) as a Markdown
# table, ready to paste into Settings -> Secrets and variables -> Actions.
#
# Usage: bash tool/gen_android_signing.sh [--out-dir DIR] [--alias NAME]
#        [--dname DN] [--validity DAYS] [--keysize BITS]
#
# The keystore is permanent: Android updates require the same signature, so
# back up the .jks file and the password somewhere safe (password manager +
# offline copy). Keep the out dir outside the repository: only *.jks /
# *.keystore / local.properties are gitignored, the .pw and base64 files
# are not and must never be committed.
set -euo pipefail

alias_name="reclash"
dname="CN=ReClash, OU=ReClash, O=ReClash"
validity="10000"
keysize="2048"
out_dir=""

usage() {
  cat <<'EOF'
Usage: tool/gen_android_signing.sh [options]

  --out-dir DIR   Where to write the artifacts (default: fresh mktemp dir).
  --alias NAME    Key alias (default: reclash).
  --dname DN      Distinguished name (default: CN=ReClash, OU=ReClash, O=ReClash).
  --validity DAYS Certificate validity in days (default: 10000).
  --keysize BITS  RSA key size (default: 2048).
EOF
}

while (($# > 0)); do
  case "$1" in
    --out-dir) out_dir="${2:?missing value}"; shift 2 ;;
    --alias) alias_name="${2:?missing value}"; shift 2 ;;
    --dname) dname="${2:?missing value}"; shift 2 ;;
    --validity) validity="${2:?missing value}"; shift 2 ;;
    --keysize) keysize="${2:?missing value}"; shift 2 ;;
    -h | --help) usage; exit 0 ;;
    *) echo "Unknown option: $1" >&2; usage >&2; exit 64 ;;
  esac
done

for dep in keytool openssl; do
  command -v "$dep" >/dev/null || {
    echo "Missing dependency: $dep" >&2
    exit 1
  }
done

if [[ -z "$out_dir" ]]; then
  out_dir="$(mktemp -d -t reclash-signing.XXXXXX)"
fi
mkdir -p "$out_dir"
chmod 700 "$out_dir"

jks="$out_dir/reclash-release.jks"
pw_file="$out_dir/reclash-store.pw"
b64_file="$out_dir/reclash-release-base64.txt"

# 32 alphanumeric chars; PKCS12 keystores do not support a key password
# different from the store password, so one password serves both secrets.
store_pw=""
while ((${#store_pw} < 32)); do
  store_pw="$store_pw$(openssl rand -base64 24 | tr -d '/+=\n\r')"
done
store_pw="${store_pw:0:32}"
printf '%s' "$store_pw" >"$pw_file"
chmod 600 "$pw_file"

keytool -genkeypair -v \
  -keystore "$jks" -alias "$alias_name" \
  -keyalg RSA -keysize "$keysize" -validity "$validity" \
  -storepass:file "$pw_file" -dname "$dname" >/dev/null

keytool -list -keystore "$jks" -storepass:file "$pw_file" >/dev/null
chmod 600 "$jks"

base64 <"$jks" | tr -d '\n\r' >"$b64_file"
chmod 600 "$b64_file"
keystore_b64="$(cat "$b64_file")"

fingerprint="$(keytool -list -v -keystore "$jks" -storepass:file "$pw_file" |
  grep -m1 'SHA256:' | sed 's/^ *//')"

cat <<EOF
Artifacts (keep out of git, back up the .jks + password):
- $jks
- $pw_file
- $b64_file
- $fingerprint

| Name | Value |
|---|---|
| \`KEYSTORE\` | \`$keystore_b64\` |
| \`KEY_ALIAS\` | \`$alias_name\` |
| \`STORE_PASSWORD\` | \`$store_pw\` |
| \`KEY_PASSWORD\` | \`$store_pw\` |
EOF
