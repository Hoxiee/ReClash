# Support reports and fix links

How a user sends you everything about their problem with one button, and how you answer with a link that fixes it.

## Report

The user taps "Report a problem". The app checks the connection, tests every server of the profile and packs the result into one archive. Nothing leaves the device until the user sends it.

The report id (`RC-XXXX-XXXX`) is in the file name, the summary and every file. Ask for it first.

```text
reclash-report-2026-11-04-1530-RC-7K3F-92QD.zip
├── README.md            what this is and how to read it
├── report.html          open in a browser: everything below on one page
├── 01-summary.md        verdict, failed step, findings, the user's note
├── 02-findings.json     problems found, what auto-repair tried
├── 03-path.json         connection check, step by step, with timings
├── 04-servers.csv       every server: DNS, TCP, delay, error
├── 05-services.json     services through the tunnel and direct
├── 06-environment.json  hosts file, other VPNs and proxies, DNS, ports
├── 07-profile.json      your headers, update times, groups, selections
├── 08-history.json      the last 7 days: incidents, repairs, crashes
├── 09-config.yaml       the effective config
├── logs/                core.log, app.log, logcat.txt, capture.log
└── report.json          app, OS, device, locale, file list
```

Every JSON file has a `schema` field (`reclash.report.*@1`), so a panel can parse reports.

- **Read first:** `report.html` or `01-summary.md`. `04-servers.csv` tells "the server is down" from "the server is blocked on this network".
- **Redaction:** passwords, UUIDs, keys and URL tokens are masked. With "public" redaction, hosts and IPs are hashed too. A report that would still contain a secret is not created.
- **Size:** up to 10 MB; the oldest log lines go first.

## Receiving reports

By default the user sends the archive to the chat behind `reclash-supporturl`. On mobile it goes through the share sheet; on desktop the app saves the file, copies the summary and opens the chat.

To receive reports directly, send an upload URL:

```http
reclash-support-upload: https://support.example.com/reclash/reports
```

The app asks the user once, naming your domain, and then sends:

```http
POST /reclash/reports HTTP/1.1
Content-Type: multipart/form-data; boundary=…

id=RC-7K3F-92QD
summary=<the text of 01-summary.md>
report=<the zip, application/zip>
```

A `2xx` response is a success. Optional JSON body: `{"ticket": "4211", "message": "We'll answer within an hour"}`; the app shows `message` (max 200 characters) and `ticket`. Only `https` URLs are accepted.

## Fix links

You answer with a link; the user taps it, sees what it will do and confirms.

```text
reclash://fix?p=<payload>&s=<signature>
```

A stranger cannot make such a link: it is signed with your key, and the app checks it against the key from your subscription.

### Key

Generate a key once and keep the private part on your server:

```sh
go run ./core/cmd/reclash-fix keygen -out key.txt
go run ./core/cmd/reclash-fix header -key key.txt
```

Send the printed header with the subscription:

```http
reclash-support-key: ed25519:O2onvM62pC1io6jQKm8Nc2UyFXcd4kOmOsBIoYtZ2ik
```

- Accepted only from an `https` subscription; refreshed on each update.
- Up to two keys, comma-separated, for rotation.

### Signing a link

```sh
go run ./core/cmd/reclash-fix sign -key key.txt -report RC-7K3F-92QD -ttl 48h \
  profile.update proxy.select:group=Auto,node=NL-1
```

Flags go before the actions. `-ttl` is at most `168h`. `verify -header 'ed25519:…' <link>` checks a link.

### Actions

| Action | Effect |
| --- | --- |
| `profile.update` | Update the subscription |
| `profile.activate` | Make your profile the active one |
| `proxy.select:group=G,node=N` | Select a node in one of your groups |
| `connections.reset` | Flush DNS and fake-IP, close connections |
| `core.restart` | Restart the core |
| `overrides.reset` | Reset the user's overrides to defaults (undoable) |
| `config.ruleMode`, `config.freePort`, `dns.ignoreSystemHosts`, `proxy.clearOwn`, `tunnel.freeDeviceName`, `tunnel.restart` | Repairs from the app's own catalogue |

A link never changes the subscription URL, adds a profile, applies config or opens a URL. It acts only on the profile whose key signed it.

### When a link is refused

The app applies nothing and says why when:

- the link is longer than 2 KB or malformed;
- the key is not in any of the user's subscriptions;
- the signature does not match;
- it has expired or expires more than 7 days ahead;
- it was already used;
- the report id is not from this device, not for your profile, or older than 30 days;
- it has an unknown action.

A link therefore works once, on the one device that made the report.

### Wire format

For panel integrations without the CLI. `p` is base64url of the UTF-8 JSON payload, `s` is base64url of the Ed25519 signature over exactly those bytes, no padding anywhere.

```json
{"v":1,"kid":"E545QOZLVJE","rid":"RC-7K3F-92QD","exp":1767225600,"nonce":"AAECAwQFBgcICQoL","fix":[{"id":"profile.update"},{"id":"proxy.select","group":"Auto","node":"NL-1"}]}
```

- `kid`: base64url of the first 8 bytes of SHA-256 over the 32-byte public key.
- `exp`: Unix seconds. `nonce`: 12 random bytes, base64url.
- Unknown fields are refused.

> [!TIP]
> Test vector: the key from 32 zero bytes gives the header above, and signing this payload gives `s=XEdYg90ecSzT7cV1dRxH9cCVLpw01KXGiWC1Lz4iUD0kYga2zSoZwr1VQnkXVkVlyx5D3L3fGx_ursuvQvmBDQ`.
