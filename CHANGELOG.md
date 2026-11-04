# Changelog

<!-- Generated from release_notes/ by `dart run tool/changelog.dart changelog`. Edit the notes, not this file. -->

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
