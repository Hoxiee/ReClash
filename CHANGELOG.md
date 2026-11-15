# Changelog

<!-- Generated from release_notes/ by `dart run tool/changelog.dart changelog`. Edit the notes, not this file. -->

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
