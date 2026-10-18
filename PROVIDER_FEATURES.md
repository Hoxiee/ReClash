# Subscription Provider Support

ReClash supports a native provider contract described in `provider_standard.g.json` and `PROVIDER_HEADERS.md`. The registry used by the application is `lib/subscriptions/protocol/registry.dart`.

## Supported

- Fetching subscriptions through the dedicated transport, with bounded redirects and managed request-header policy.
- Common subscription response headers, including `Subscription-Userinfo`, `Content-Disposition`, and `profile-title`.
- Native metadata decoding through the versioned registry and codec.
- Device identity with global opt-in, per-profile overrides, and origin-scoped consent for device details.
- Client compatibility presets, automatic negotiation, and import adapters for supported configuration formats.
- `flclashx-*` metadata aliases are normalized only when the FlClashX preset is selected; all other presets accept native ReClash provider metadata names only.

## Boundaries

Provider responses cannot migrate subscription URLs, select fallback hosts, change local appearance or settings, configure app routing, or trigger reports and telemetry. These actions require explicit local workflows and are not part of the current provider contract.

Client compatibility selection and import-format adaptation are separate layers. Neither implies permission to send device identity. `reclash-hideurl` only masks the URL in the editor; it does not prevent disclosure or modification.
