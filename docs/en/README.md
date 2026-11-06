# ReClash documentation

Technical reference for subscription providers integrating with ReClash and for RCX, the client's auto-routing language.

## Sections

| Section | For | Covers |
| --- | --- | --- |
| [Providers](providers/README.md) | Subscription services | Response headers, provider manifest, client requests, required policy, preview API, rollout |
| [RCX auto routing](auto-routing/README.md) | Users and providers who ship routing | Profiles, conditions, scenarios, sharing, the in-app editor |

## Machine-readable sources

| Resource | Use |
| --- | --- |
| [`provider-config.schema.json`](../../provider-config.schema.json) | JSON Schema of the provider manifest |
| [`rcx-profile.schema.json`](../../rcx-profile.schema.json) | JSON Schema of RCX profiles and scenarios |
| [`provider_standard.g.json`](../../provider_standard.g.json) | Generated registry of every provider header, alias and manifest field |

## Conventions

- Header names are case-insensitive. A header name in `code` links to its entry in the header reference.
- Every page is built from `docs/` in the ReClash repository; the source link on each page names the exact commit.
