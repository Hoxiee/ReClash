# Security policy

## Supported versions

When a security fix is accepted, it is developed on `main` and targeted for the next suitable release. The latest stable release is the only release line expected to receive fixes; old and pre-release builds are not maintained separately.

| Version | Security fixes |
| --- | --- |
| Latest stable release | Yes |
| `main` | Development only |
| Older releases | No |
| Pre-release builds | No separate support |

## Report a vulnerability privately

Do not open a public issue for a vulnerability that could put users at risk. Email **hoxiee.dev@gmail.com** with the subject `ReClash security report` and include:

- the affected ReClash version, platform, and architecture;
- a concise description of the impact and required preconditions;
- reproducible steps or a minimal proof of concept;
- any suggested mitigation;
- how you would like to be credited, if at all.

Do not send real subscription links, access tokens, private keys, user traffic, or unrelated personal data. Replace them with minimal test values.

Reports are reviewed as maintainer availability allows; no response or remediation deadline is guaranteed. Please allow time for a fix and coordinated release before publishing details. If a report is not a vulnerability, it may be redirected to the normal support or issue process.

## Scope notes

ReClash is a local proxy client and deliberately exposes its mixed proxy port to applications on the same device through loopback. The loopback listener is not an isolation boundary between local applications; a report that only demonstrates another local application using that listener is not considered a vulnerability by itself.

Useful reports include, but are not limited to:

- remote code execution or memory corruption reachable through ReClash;
- authentication or authorization bypass in privileged helper paths;
- unintended exposure of listeners beyond their configured interface;
- secret disclosure caused by the application;
- unsafe update, deep-link, profile-import, or archive handling;
- sandbox or Android permission boundary violations.

Provider availability, malicious subscriptions imported by choice, upstream mihomo behavior without a ReClash-specific impact, and attacks requiring an already fully compromised device are normally outside scope. Reports about the maintained core fork may still be sent here when the impact is specific to a ReClash build.
