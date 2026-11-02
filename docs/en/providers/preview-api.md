# Preview API

A read-only JSON endpoint, version 1, that supplies the provider's presentation before the user confirms an import from a browser subscription page.

It is separate from the subscription download and from the [response headers](headers.md) applied to saved profiles.

## Discovery

The browser subscription page carries exactly one link element:

```text
<link rel="reclash-preview" href="/reclash/preview/account-scoped-token">
```

- A relative URL resolves against the final page URL.
- The endpoint must share the page's origin (scheme, host and port), must not be the page itself, and must not contain a fragment.
- ReClash does not probe conventional paths or run JavaScript to find it.
- Personalize with an opaque account-scoped token in the URL. Do not require a device ID or browser login.

## Request

- `GET` with `Accept: application/json` and the browser preview `User-Agent`.
- No device ID, client preset headers, cookies, `Authorization` or `Referer`.
- Redirects follow subscription transport rules. Only a final same-origin JSON response is accepted.

## Response

`Content-Type: application/json`, at most 64 KiB of UTF-8 JSON.

```json
{
  "version": 1,
  "provider": {
    "name": "Example VPN",
    "description": "Contact support to install your subscription.",
    "logoUrl": "/assets/provider-logo.png",
    "supportUrl": "https://t.me/example_support"
  },
  "account": {
    "name": "Personal account"
  },
  "subscription": {
    "type": "test"
  }
}
```

| Field | Type | Rules |
| --- | --- | --- |
| `version` | integer | Required, `1`. |
| `provider.name` | string, 256 characters | Service name in the confirmation header. |
| `provider.description` | string, 4096 characters | Description in the confirmation body. |
| `provider.logoUrl` | URL | Absolute, or relative to the API URL; `http(s)`. An `https` page cannot point to `http`. PNG, JPEG, WebP, GIF, SVG or ICO, at most 512 KiB. A failed image keeps the monogram; external SVG resources are not fetched. |
| `provider.supportUrl` | URL | `http(s)` or a validated Telegram link, relative to the API URL. Shown as a top-bar action behind the usual external-link confirmation; never opened automatically. |
| `account.name` | string, 256 characters | Account name, shown apart from the provider and the editable profile name. |
| `subscription.type` | string, 32 characters | `test`, `promo` or `dev` shows a badge under the name; other values show none. |

- Every field except `version` is optional. Unknown fields are ignored.
- Text is plain text, never HTML or Markdown.
- An invalid field is dropped and does not replace page metadata.
- An unsupported version, malformed JSON, an oversized response or a request failure falls back to page metadata and never blocks the import.
- A logo request carries no cookies, `Authorization`, `Referer` or device ID, even on the same origin.
- Scripts, styles, app lists, telemetry endpoints and configuration URLs in the JSON are never run or followed.

## Precedence

Valid API fields override recognized panel branding, which overrides generic HTML metadata. A missing API field keeps the lower-priority value.

## Provider requirements

- The page, endpoint and logo must be safe to read before consent. They must not register a device, use a device slot, mark the configuration as downloaded, or change account state.
- Do not put configuration or connection keys in the response.
- Send `Cache-Control: private, no-store` on account-specific responses. Keep private tokens out of logs and public caches.

ReClash cannot enforce server-side read-only behavior. Only the user's Add action starts the subscription download and any device identification. Preview data is display-only: it does not change settings, routing, transport identity, the client preset or the stored URL, and it is not kept as subscription metadata. The same `subscription.type` sent as [`reclash-subscriptiontype`](headers.md#provider-panel) marks the saved profile.

## Existing panels

Without this API, ReClash still reads:

| Source | Data |
| --- | --- |
| Remnawave | Embedded account data and browser `brandingSettings`. The temporary page session is used only for `/assets/.app-config-v2.json` on the same origin, never for this API or a logo. |
| 3x-ui | Embedded page data. |
| Marzban | Standard account fields. |
| Any page | Generic HTML metadata and explicit support links. |

A custom panel theme opts in by adding the discovery link; subscription delivery does not change.
