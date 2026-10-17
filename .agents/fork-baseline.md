# Fork Baseline Audit

This is the reviewed intent map for the initial maintenance rollout, not an approval of a mutable upstream ref.
Use full source/normalizer/registry/tree identities from a fresh inspection when preparing the actual bootstrap.
Detailed machine reports and check receipts belong in Git common-dir state, not tracked source.

## Source Boundary

The initial source observation is `b405e90ca6647328721a189aa15ae9d53d898a2d` from FlClash dev; normalized V1
corresponds to raw source `a8655b0809085905da71fad1d323fc1f34879e79`. The current V1 source is recorded by the accepted
vendor snapshot. `vendor/flclash` keeps normalized snapshots append-only. Each accepted snapshot also produces an
independent parentless product-base commit with the same tree and provenance; `dev` replays feature commits above that
product base and does not inherit prior vendor-snapshot ancestry. Raw upstream history remains provenance, not product
history. Existing release tags remain unchanged.
The downstream delta is recorded by independent behavior and maintenance boundaries:

| Feature group | Intent | Contract/check boundary |
| --- | --- | --- |
| Core source | Select our Mihomo fork and pin; normalize only the source path | `core.integration`, Core protocol/lifecycle tests, explicit source review |
| Identity | Rebrand product/package identities while retaining upstream attribution | `identity.branding`, `release.destinations` |
| About | Keep credits, bundled licenses and product avatars | `identity.branding`, identity regressions |
| Profiles | Refuse duplicate trimmed subscription URLs when enabled; allow opt-out | `profiles.no-duplicates`, import regressions |
| Configuration | Default tabs to fade unless the user selects otherwise | `settings.specs`, config regressions |
| Linux packaging | Pacman packages, version metadata and appindicator compatibility | `linux.packaging`, packaging/version regressions |
| Navigation interactions | Sidebar/rail feedback, tooltip lifecycle, empty-state replay and non-secret input affordances | `ui.interactions`, focused interaction/input regressions |
| Form editors | Rule, map and named-URL editors validate and preserve structured values | `forms.editors`, form regression tests |
| Settings specifications | Port settings views to declared specs and apply contracts | `settings.specs`, settings regressions |
| Tools workspace | Catalog, session, search and command providers | `tools.catalog`, tools/provider tests |
| Fork maintenance | Snapshot normalization, impact, receipts, contracts and recovery | `meta.maintenance`, fork-tool tests |
| Proxy refresh | Discard stale group results across profile/runtime changes | `proxies.groups`, proxy action/controller regressions |
| Desktop window | Route close/termination through system actions and persist only current normal-window geometry | `desktop.window`, window-manager regressions |
| Adaptive navigation | Responsive navigation surfaces, route selection and view-mode boundaries | `ui.navigation`, navigation/layout regressions |
| Localization | Feature-owned fragments, upstream bases, locale baselines and generated output | `localization.catalog`, assembler and locale contract tests |

## Mechanical Normalization Versus Intent

The recipe removes package imports, bounded product identifiers, Core-path references, plugin namespaces and helper
names. Initial endpoint review identified missing plugin Kotlin paths, test Core paths, lowercase marker/package names
and platform/service names; these are now explicit rules, not whole-file downstream substitutions.
The actual repository recipe is tested for idempotence, collision rejection, retained upstream URLs and license text.

The remaining deltas are intentional group-owned content, not simply remaining rename noise:

- Core `.gitmodules` URL/branch and gitlink SHA remain downstream; raw upstream values stay in vendor.
- Public release/update/issue/site destinations remain distinct from upstream attribution links. Telegram, Homebrew,
  F-Droid and website configuration are retained policy, not claims that those external destinations are live.
- Credits include retained upstream and third-party identities, removed/replaced product avatars, license registration
  and bundled notices. Plugin README/license attribution is preserved rather than globally branded.
- Upstream locale files are kept in `arb_upstream/`; ReClash-owned translations live in
  `arb/fragments/<feature>/`. Flat `arb/intl_<locale>.arb` and generated Dart outputs are assembled artifacts;
  never hand-edit them.
- Source and test pairs for profile imports, tab defaults, tools, settings and feedback retain real behavior changes.
  Case/escaping fixtures in URI tests are test data, not a reason to rewrite protocol handling.
- Packaging/version helpers and the tray's targeted deprecation-warning workaround are functionality, not cosmetics.
- Changelog envelopes, release parsers and site rendering retain the existing release format and ownership boundary.
- `.agents`, hooks, ignored local research and verification configuration remain maintenance policy.

Watch coverage is only an index. A zero unclassified count does not establish semantic equivalence, approve a drop,
or permit weakening a contract. Newly introduced paths must be classified again; broad catch-all ownership is avoided.
The settings apply-semantics invariant is exercised through specification routes and stateful settings views; route identity alone is not treated as sufficient coverage.

## Preparation Repairs

The identity/rebrand history retains the current-code resolutions for architecture guidance, the release workflow and
`SharedStateTest.kt`: TUN core-owned fields and include-all behavior, ReClash release gating/dependencies, and no removed
`crashlytics` field assertion. No conflict markers are retained. Tests parse the release workflow and pin the public
target/dependency gates.
Unused style/import leftovers and handwritten formatting are cleaned without changing runtime behavior. Generated
formatting is left to its generators; ignored `project/` research no longer makes product analysis fail.

Adaptive navigation has its own `ui.navigation` contract and regression mapping. Keep it a separate feature boundary
from settings specifications and the Tools catalog.

## Activation Boundary

Before activating: commit the intended maintenance source, inspect that exact dev/source/recipe combination, require no
markers or unexplained residuals, and run full plus affected-platform checks. A temporary-repository structural
bootstrap rehearsal is not final candidate verification, acceptance, native-platform evidence or publication authority.
The normalized product line starts at `0.1.0-pre.1`; ReClash-Alpha version history is unrelated. Existing release tags remain untouched.
