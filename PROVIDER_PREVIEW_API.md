# ReClash Provider Preview API

Version 1 supplies provider-controlled presentation before subscription import. It is separate from configuration downloads and the provider headers applied to saved profiles. Providers implement this read-only endpoint; ReClash discovers and consumes it.

## Discovery

Return a normal browser subscription page with exactly one link:

```html
<link rel="reclash-preview" href="/reclash/preview/account-scoped-token">
```

Relative URLs resolve against the final page URL. The endpoint must use the same origin (scheme, hostname and port) as that page, must not be the page itself, and must not contain a fragment. ReClash does not probe conventional paths or execute JavaScript to discover it. Use an opaque account-scoped token in the URL when personalized data is needed; do not require HWID or browser login.

## Request and response

ReClash sends GET with `Accept: application/json` and its browser preview User-Agent. No HWID, device details, subscription client preset, cookies, authorization header or Referer is attached to the API request. Redirects use the existing bounded transport; only a final same-origin JSON response is accepted.

Return `Content-Type: application/json` and at most 64 KiB of UTF-8 JSON:

```json
{
  "version": 1,
  "provider": {
    "name": "Example VPN",
    "description": "Contact support if you need help installing your subscription.",
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

All fields except the integer `version` are optional. Unknown fields are ignored. Names are limited to 256 characters and description to 4096. Text is plain text, not HTML or executable Markdown. Invalid fields do not replace useful page metadata. Unsupported versions, malformed JSON, oversized responses and request failures fall back to the panel page without preventing import.

- `provider.name`: service name in the confirmation header.
- `provider.description`: provider description in the confirmation body.
- `provider.logoUrl`: absolute or response-relative HTTP(S) image URL. HTTPS pages cannot downgrade to HTTP. Supported response types: PNG, JPEG, WebP, GIF, SVG and ICO (subject to decoder support). Images exceeding 512 KiB are not displayed. Failed images keep the monogram; external SVG resources are not fetched by the widget.
- `provider.supportUrl`: HTTP(S) or a validated Telegram destination. Relative links resolve against the API URL. The support action appears in the top bar and uses the existing external-link/Telegram confirmation flow; it never opens automatically.
- `account.name`: account display name, shown separately from the provider and the editable local profile name.
- `subscription.type`: `test`, `promo` or `dev`, up to 32 characters. Shows a badge under the name in the confirmation; an unknown value shows none. The same value in the `reclash-subscriptiontype` header marks the saved profile.

Priority: valid API fields override recognized panel branding, which overrides generic HTML metadata. Missing API fields preserve lower-priority values. A logo request sends no session cookies, authorization, Referer or device identity, including for a same-origin image. No scripts, styles, application lists, telemetry endpoints or configuration URLs from JSON are executed or followed.

## Provider requirements

The page, preview endpoint and logo MUST be safe to read before consent. They MUST NOT register a device, consume a device slot, mark a subscription configuration as downloaded, or change account/subscription state. Do not put configuration or connection keys into this response. Account-specific responses should use `Cache-Control: private, no-store`; never include private tokens in logs or public caches.

ReClash cannot enforce server-side read-only behavior. Its Add action alone starts ordinary subscription downloading and any configured device identification. Preview data is display-only: it cannot change application settings, routing, transport identity, selected client or stored subscription URL, and is not persisted as authoritative subscription metadata.

## Existing panels

Without this API, ReClash still recognizes Remnawave embedded account data and browser `brandingSettings`, 3x-ui embedded page data, Marzban's standard account fields, and generic HTML metadata / explicit support anchors. For Remnawave, its temporary page session is used only for the same-origin browser branding resource `/assets/.app-config-v2.json`, never for this API or a logo. Custom themes can add the discovery link to opt into this contract without modifying subscription delivery.
