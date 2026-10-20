# Subscription Import Paths

This note records the import entrypoints and route/error rules shared by the profile importer. The importer continues to use `resolveProfileLink`, `ProfilesAction`, the existing subscription parser and compatibility pipeline, and the durable profile save path.

## Entry points

| Entry point | Route | Consent / key handling | Result |
| --- | --- | --- | --- |
| OS URL scheme and argv | `Application._handleLink` → `UrlSchemeAction.handleLink` → `resolveProfileLink` | A compact confirmation shows the name and origin host, not the URL path or query. Happ/INCY offers its hinted client and Auto. The selected client reaches the import action. | URL fetch, embedded-config import, or local proxy-link conversion through the common importer. |
| Manual single URL | Profiles → Add → Link → `showNamedUrlsForm` → `addProfileFromLink` | The Save action is consent. The form's initial client setting is not treated as an explicit choice; changing the selection is. AGE key can be entered with the URL. | One profile, after compatibility checks and any required loss review. |
| Manual batch | Same form in batch mode → `addProfilesFromLinks` | Existing URLs are filtered only when duplicate prevention is enabled; repeated lines follow the same setting. A provided AGE key is carried to every row; missing keys can be requested per encrypted source. | Independent imports run with bounded concurrency and finish with one added/skipped/failed summary; failure details are grouped. Proxy share links remain grouped, and successful profiles are not rolled back by a failed row. |
| Camera QR | `ScanPage` → `addProfileFromLink` | The scan returns a link; normal URL/deep-link resolution and any AGE prompt follow. | Same URL, wrapper, embedded-config, or proxy-link paths as other links. |
| QR image / file picker | `addProfileFormQrCode` / `addProfileFormFile` | File decoding stays local. Encrypted content can request an AGE key; cancellation ends silently. | Common validation and durable save; unsupported or lossy conversions do not silently replace a profile. |
| Embedded `reclash://import` config | URL-scheme parser decodes bytes locally, then asks before import | Confirmation precedes the conversion/save operation. The import does not fetch a URL. | Prepared config goes through Core validation, loss review and staged save. |
| Proxy share links | `ProfileLinkSource.shareLink` → Core `decodeShareLinks` | Conversion is local to the Core; no subscription HTTP request. | Several links are grouped into one file profile, preserving input order and uniquifying proxy names. |
| Setup wizard | `UrlSchemeAction` offers the original input to `SetupSession` | Setup owns review and consent. The ordinary profile importer does not run while setup is active. | Setup processes the offered link through its own session lifecycle. |
| URL inspector | `resolveProfileLink` and local decoding only | No import confirmation and no subscription fetch. | A local preview of URL/wrapper structure or decoded data. |

## Routing and retry

- With the app's own connection active, the ordinary HTTP route is attempted first.
- A single bypass retry is allowed only for connection/DNS failure or timeout before any HTTP response. It shares the overall timeout budget and rechecks that the app's own VPN/TUN is still active before starting.
- Android uses the Core's `VpnService.protect` connector only when the VPN is enabled and `allowBypass` is enabled. Desktop uses a narrow subscription-fetch connector through mihomo's interface finder/fallback bind while the app's TUN is applied. No OS routes are changed.
- When the connection is stopped or suspended, import uses the ordinary direct route; it does not start or restart the VPN.
- HTTP status, TLS verification, redirects, response size, invalid/empty formats, device responses, cancellation and client negotiation never trigger a route retry. The shared fetch path bounds redirects, headers, wire/decompressed bytes, timeout and cancellation; sensitive request headers are stripped when the redirect changes origin.

## Failure and support behavior

- Transport failures map to localized network/compatibility text. They do not expose exception dumps, subscription URLs or enum names.
- A device-limit response is a warning, not a general import error. A support action appears only when the response contains a validated HTTP(S) support URL. A retry does not bypass the provider's device limit.
- A missing required device registration is distinct from a device-limit response. An unsupported-device informational flag alone does not reject an otherwise usable configuration.
- AGE-key cancellation and stale/superseded imports are silent. Errors from a rejected/malformed payload remain distinct from cancellation.
- Duplicate checks compare the resolved URL, honor the user's duplicate-prevention setting, trim only leading/trailing whitespace, and hold an in-flight reservation until the save commits or rolls back.

## Telegram links

- Only the provider `supportUrl` metadata field may contain a validated Telegram destination; other provider URL fields and subscription URLs remain HTTP(S)-only.
- `tg://` and HTTPS `t.me` / `telegram.me` links use a destination-aware confirmation. The original URI and parameters are retained. If app launch fails, an HTTPS fallback is offered only for a valid `resolve` or `join` target; other Telegram actions never receive a fabricated fallback.

## Focused regression checks

```sh
flutter test test/subscriptions/transport_test.dart
flutter test test/common/telegram_link_test.dart test/common/dialog_test.dart test/common/input_entries_test.dart
flutter test test/core/protocol_contract_test.dart test/providers/url_scheme_action_test.dart
flutter test test/views/add_profile_view_test.dart test/providers/profiles_action_test.dart
(cd core && CGO_ENABLED=0 go test .)
```

Real Android VPN protection and a desktop TUN interface binding still require platform hosts for end-to-end confirmation.
