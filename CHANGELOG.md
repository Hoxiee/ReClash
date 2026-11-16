# Changelog

<!-- Generated from release_notes/ by `dart run tool/changelog.dart changelog`. Edit the notes, not this file. -->

## v0.1.0-pre.10

Network leak protection, per-profile favorites and a macOS launch fix.

### New

- **Per-profile favorites**: mark proxies as favorites and they lead their groups in the app, the tray and the
  dashboard. Each profile keeps its own set.
- **Android kill switch status**: the app shows whether Android's always-on VPN and lockdown settings are active.
- **Block browser DoH**: an opt-in setting that stops browsers from resolving names over their own DoH and bypassing
  the app's DNS. Strict browser DoH stops resolving while it is on.

### Improved

- **TUN on Windows**: strict routing is now the default, which closes DNS leak paths. A profile can still override it.
- **Wallet pass on desktop**: the active profile's pass has its own title, and its top lines up with the other
  profiles.
- **Donate page**: the donate action comes first and the crypto card is redesigned. The network is picked from the
  coin's chips, tapping an address copies it with inline confirmation, and a link can be copied for sharing.
- **Doctor**: it confirms the node with a delay test instead of guessing, and no longer fetches profiles by itself. The
  subscription is fetched only when you tap the repair.

### Fixed

- The macOS app opens again instead of being rejected at launch.
- Profiles keep the DNS their provider sets instead of regional servers, unless you override it. Regional overrides
  you already have stay until DNS is restored to defaults.
- A sandbox test profile no longer loses its own groups to a group it does not have.
- Hotkey commands on desktop can be copied from their rows, as on the core page.
- The sidebar blur toggle sits in a styled group like the rest of the theme settings.
- Desktop self-update progress and failure messages no longer mention Android.

### Known issues

- The Android kill switch status only reflects the system's always-on VPN and lockdown settings. Change them in
  Android settings, not in the app.
- The macOS build is ad-hoc signed and not notarized, so macOS may warn when you open it for the first time.

## v0.1.0-pre.9

### New

- **Provider page from the wallet pass**: tap the host under the active profile's name to open the page the
  subscription itself serves, such as a provider panel. It is hidden when the provider asks for it not to be shown,
  and stays untappable when the stored address is not a plain web link.
- **Default request client**: new profiles start on a client called Default, which sends the app's main User-Agent.
  An existing profile keeps the client it was saved with, and the separate ReClash entry is gone.

### Fixed

- TUN starts again after an elevated run of the app left its home folder owned by Administrators (Windows).
- The donate page no longer sits off-centre on desktop.

## v0.1.0-pre.8

### Improved

- **Provider update interval**: new profiles follow the update interval set by the provider, and its switch in profile
  settings matches the rest of the app.

### Fixed

- Liquid Glass surfaces render with the full glass effect again (Linux).
- Tablets show the sidebar in automatic layout; picking the bar in the layout setting still keeps the bar (Android).
- The service install prompt opens on top of the app (Windows).

## v0.1.0-pre.7

Profiles as a wallet with provider logos, plus fixes to diagnostics, wallpapers and extension nodes.

### New

- **Profiles wallet**: profiles show as a wallet with the provider logo and a brand tint on the background. The classic
  grid stays available behind a toggle on the profiles page.

### Fixed

- The provider background is no longer lost: it survives a restart, and you can only replace it with your own image.
  Turning your image off or removing it brings the provider background back.
- Diagnostics no longer take over the VPN slot from another app during permission checks, and name the app that holds
  it when the slot is taken (Android).
- Diagnostics refresh the subscription only for profile failures; timeouts and resets go straight to resetting
  connections.
- Extension nodes wait for a restart or a free slot instead of failing the first connection attempt.
- qWDTT links import with the correct node name.
- A subscription page with a large logo or malformed text no longer breaks the preview.

## v0.1.0-pre.6

Telegram without a VPN, proxy chains, a power button that reports a verified connection, and silent desktop updates.

### Breaking changes

- **Provider settings**: provider headers and body keys for policy, appearance, power button labels, wallpaper and
  widgets are no longer read. Providers move them into the hosted file named by the `reclash-config` header.

### New

- **Telegram without a VPN**: a local relay connects Telegram over WebSocket, independent of the VPN and the profile.
  It reaches every data center through a chain of secure and fallback routes, and the route through the profile is
  opt-in. On Android it runs in its own service that survives kills, reboots and network changes.
- **Proxy chains**: build an entry, optional middle and exit chain and pick it in the main group. Chains are included in
  backup and restore.
- **Unmatched traffic goes DIRECT**: a profile option replaces its rules with a direct fallback, keeping only the rules
  you added.
- **Smart power button**: the simple dashboard shows "Protected" only after the connection is verified, heals a broken
  connection step by step and offers another server. It locks only when the plan has ended and the connection fails,
  and resumes after renewal. A setting restores the plain button.
- **Desktop updates**: Windows, macOS and the Linux AppImage apply updates silently at launch, on quit or after idle
  time. Windows now installs per user; the old machine-wide install is removed once with a UAC prompt.
- **Skipped release notes**: the update sheet lists the notes of every release between the installed and the offered
  version.
- **New link formats**: import TrustTunnel links. On desktop, naive, OpenFlux, qWDTT and olcRTC links import as
  extension nodes that show their protocol name and run through a matching installed protocol extension.
- **Page swipe**: swipe between pages with the bottom bar, including nested pages. A setting turns it off.
- **Donations**: a donation page in About with cards, Tribute and crypto wallets, ordered for your region.
- **Provider widgets**: providers configure banners, action panels, notes, dark theme colors and power button labels,
  including expired, exhausted, ending and grace states, through one hosted file.

### Improved

- **Tab transitions**: phones slide between pages and desktops fade; the transition setting is gone.
- **Core**: updated to mihomo v1.19.34.
- **Update sheet**: opens shorter and keeps its icon and buttons in place between stages.
- **Dashboard**: the style switch moved off the home page into appearance settings.

### Fixed

- Imported subscriptions keep every node and report what the conversion lost.
- AnyTLS and AmneziaWG links that were skipped now import, and an unsupported mieru UDP MTU is reported.
- Connecting and auto-heal no longer switch the selected server behind your back.
- Diagnostics no longer report problems that no fix can clear, and no longer refetch a subscription that was just
  updated.
- Providers that require app exclusions connect outside the Android VPN.
- A setting you changed is kept when the provider stops sending it.
- A provider app you released can be handed back from its row tag.
- Sheets no longer hide content behind the floating navigation bar.
- The setup wizard keeps its layout and focus while the keyboard is open on tablets.
- Page swipes no longer leak into opened sub-pages.
- Linux: animated elements no longer render corrupted.

### Known issues

- Desktop: protocol extensions are installed by hand; there is no in-app installer yet, so extension nodes stay
  unavailable until one is installed.

## v0.1.0-pre.5

Speed test runs inside the Core, and diagnostics can find and fix conflicts with other software.

### New

- **Speed test**: measure latency, download and upload through the route you pick. The test fits on one screen, keeps a
  history, and opens a result page with the details.
- **Environment diagnostics**: diagnostics detect conflicting VPNs, DPI bypass tools, hosts file entries and foreign
  proxies and fix them. Other software is never closed, and changes to foreign settings need a confirmed tap.
  Automatic healing is on by default and can be turned off in settings.
- **Support reports**: send a diagnostics report with one button, or share or save it when upload is unavailable.
  Provider fix links apply only known remedies and only for a matching report.
- **Core error pop-ups**: a new setting hides Core error pop-ups.

### Improved

- **Interface**: refined design of several elements, including sheets and the update dialog.

### Fixed

- The update sheet shows the release notes again.
- The proxy fix in diagnostics now reports failure when the system proxy was not applied.
- Diagnostics read the system proxy correctly on Linux desktops other than GNOME, such as KDE and MATE.
- Linux: Helper and Core executables are labeled for SELinux on install, so the service starts on SELinux systems.

## v0.1.0-pre.4

The simple dashboard becomes the default and forecasts your traffic; first-run setup is one guided journey.

### New

- **Traffic forecast**: the traffic card on the simple dashboard estimates when your quota runs out, based on recent
  daily usage of URL profiles.
- **Power button shapes**: providers can style the power button with more shapes or let the app pick one at random.
- **Adaptive glass**: glass surfaces reduce themselves automatically when the device needs it, for the current session
  only.

### Improved

- **Simple dashboard by default**: new installs open the simple dashboard and use the slide tab animation; existing
  choices are kept.
- **Setup journey**: every install walks through profile, coverage, region and summary. The detected region is
  preselected, summary rows jump back to their step, and Skip replaces Exit once you accept the agreement.
- **Agreement**: the agreement opens inside the setup and must be read to the end before you accept it.
- **Profile import**: import links show a preview before adding, a new profile opens its preview, and holding or
  right-clicking a profile deletes it.
- **Android TV**: profiles are sent from a phone instead of scanned by camera, and the send page follows the app theme.
- **Provider policies**: provider-required app exclusions are enforced on Android VPN and cannot be changed in the
  runtime configuration.

### Fixed

- `reclash://` import, routing and diagnostics links wait until setup and consent are complete; only the latest link
  is kept.
- `reclash://doctor` links open diagnostics again.
- Web dashboards no longer close on a back swipe or show stale credential errors.
- Tray icon settings moved to the Theme tab.
- The Tools page no longer swallows the start of its tab transition.
