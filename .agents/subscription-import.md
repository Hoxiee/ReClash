# Subscription Import Paths

This note records the import entrypoints and route/error rules shared by the profile importer. The importer continues to use `resolveProfileLink`, `ProfilesAction`, the existing subscription parser and compatibility pipeline, and the durable profile save path.

## Entry points

| Entry point | Route | Consent / key handling | Result |
| --- | --- | --- | --- |
| OS URL scheme and argv | `Application._handleLink` → `UrlSchemeAction.handleLink` → `resolveProfileLink` | Confirmation reads only the browser page without HWID or client negotiation. Remnawave/3x-ui embedded page data, Marzban default page fields and generic HTML metadata are display-only. Happ/INCY client selection is local. Config download starts only after Add. | URL fetch, embedded-config import, or local proxy-link conversion through the common importer. |
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

## Browser-only link preview

- Preview uses a fixed browser User-Agent without client-format keywords such as `clash` (Remnawave may prioritize them over browser detection) and HTML Accept header, never the subscription identity store, client presets or custom profile headers.
- It fetches the supplied page through the bounded transport; HTML is parsed in an isolate without running scripts. A recognized Remnawave page may request `/assets/.app-config-v2.json` with only its ephemeral browser session; a declared logo may load without cookies, Referer or device headers. No client-format retries or config validation run before consent.
- Remnawave's `#sbpg[data-panel]` contains base64 JSON account data. 3x-ui's `window.__SUB_PAGE_DATA__` carries JSON usage fields and is parsed without executing JavaScript. Marzban's default page exposes labeled account fields. Branding settings supply Remnawave title, logo and support; 3x-ui supplies title, support and a unique account email. Custom pages fall back to HTML title, description, declared icon/image and explicit support anchors; missing values stay unknown rather than becoming zero/unlimited.
- Preview metadata is never a prepared update and cannot be committed. Add performs the ordinary authenticated/device-aware subscription import.
- Browser requests still reach the server. Arbitrary provider implementations may count any request; the client cannot guarantee a side-effect-free page on every deployment.

References checked for the browser routes:
- https://github.com/remnawave/subscription-page/blob/main/backend/src/modules/subscription/subscription.controller.ts
- https://github.com/remnawave/subscription-page/blob/main/backend/src/modules/webpage/webpage.service.ts
- https://github.com/Gozargah/Marzban/blob/master/app/routers/subscription.py
- https://github.com/Gozargah/Marzban/blob/master/app/templates/subscription/index.html
- https://github.com/MHSanaei/3x-ui/blob/main/internal/sub/controller.go

## Provider-owned preview API

[`PROVIDER_PREVIEW_API.md`](../PROVIDER_PREVIEW_API.md) defines the opt-in version 1 contract. A single `link[rel="reclash-preview"]` declares a same-origin JSON endpoint; no endpoint is guessed. Valid presentation fields override panel metadata. Requests carry no cookies, authorization or device identity. Account names are displayed separately, support is a top-bar action, and only one declared logo is requested. Failures preserve the page preview and never initiate a configuration download.
