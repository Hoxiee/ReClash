# App settings

Appearance, settings flags, restrictions and Android app lists a subscription can set, and how they yield to the user.

Value syntax follows [Value formats](headers.md#value-formats). Hints come from the current profile. Appearance comes only from the [hosted config](config.md); no header sets it.

## Ownership

- Provided values apply without confirmation while their profile is current, tagged "From provider".
- A changed setting stops following the provider; its tag offers "Return to provider".
- "Return settings to provider" in application settings resets every setting, the user's overrides of general, DNS and TUN options, and changes to provider apps.
- When the current profile stops providing a value (for example, after switching profiles), a setting still following the provider returns to the user's previous value.
- Omitting a header, or a config section, withdraws its value; the setting returns to the user's value ([Metadata lifetime](README.md#metadata-lifetime)).

## Appearance

View, power button, wallpaper and widgets are set in the [hosted config](config.md#sections) named by `reclash-config`. Their values follow the ownership rules above.

## Settings flags

`reclash-settings` lists flags as `tokens`, at most 16. Listed flags turn on; the others turn off. Without the header, none of these settings is touched.

| Flag | Setting | Effect |
| --- | --- | --- |
| `minimize` | Minimize on exit | Closing the window minimizes the app. |
| `autorun` | Auto launch | Starts the app at login. |
| `shadowstart` | Silent launch | Starts without showing the window. |
| `autostart` | Auto run | Starts the proxy when the app opens. |
| `autoupdate` | Auto check for updates | Checks for app updates. |
| `openlogs` | Logcat | Captures logs. Off hides the logs entry. |
| `closeconnections` | Close connections | Drops open connections when the proxy changes. |

```http
reclash-settings: autostart,closeconnections
```

## Restrictions

`reclash-restrictions` lists restrictions as `tokens`, at most 16. The user cannot lift them.

| Token | Effect |
| --- | --- |
| `noglobal` | Removes Global mode in the app and the Core. A Global profile switches to Rule. |
| `androidsecure` | Android only. Closes every local proxy port (mixed, HTTP, SOCKS, redir, TProxy), makes the web dashboard unavailable, and sends the app's own requests directly. |
| `denywidgets` | Removes dashboard editing on both dashboards. |

`androidsecure` also applies when the [safety policy](policy.md) requires app exclusions. A policy with `global.allow: []` removes Global, as `noglobal` does.

## Android apps

| Source | Effect |
| --- | --- |
| `reclash-excludeapps`, `tun.exclude-package` in the config | Recommended exclusions from the tunnel. |
| `reclash-approuting: domestic` or `domestic:<cc>` | Adds installed apps known as domestic for the app's region, or for `<cc>`. Ignored when the region has no list. |
| `reclash-includeapps`, `tun.include-package` in the config | Recommended inclusions. |
| `reclash-policy` → `apps.android.exclude` | Required exclusions ([Required safety policy](policy.md)). |

How they combine with the user's access control:

| Access control | Provider apps applied |
| --- | --- |
| Off | Recommended and required exclusions, if any, turn on blacklist mode with just those apps. |
| Blacklist | Recommended exclusions the user did not take back, and required exclusions, are added to the user's list. |
| Whitelist | Recommended inclusions the user did not take back are added to the user's list. Required exclusions are removed from it. |

Modes never mix: recommended inclusions are ignored in blacklist mode, and recommended exclusions in whitelist mode. Provider apps carry the "From provider" tag in Access control. Unticking one takes it back; "Return apps to provider" resets that. When the effective list changes, Android asks for a VPN restart.

```http
reclash-excludeapps: com.example.bank, ru.example.gov
reclash-approuting: domestic
```

## Boundaries

- A provider can set only the settings on this page, the [update interval](headers.md#update-interval), and the routing offers in [Routing delivery](routing.md).
- No header triggers reports, telemetry or uploads.
- `reclash-hideurl` masks the URL; it does not protect it.
- Package exclusions do not cover the same service opened in a browser.
