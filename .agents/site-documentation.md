# Website Documentation

The website is the independent sibling repository `../reclash-site/` (`Hoxiee/reclash-site`). `site` is a relative
symlink to that checkout for local navigation, not an application asset directory. Read `../reclash-site/AGENTS.md`
before changing it. Its Nuxt site, document compiler, search, styles, browser-local tools and deployment belong to that
repository. Keep the application's private maintenance UI in `tool/fork_atlas/`; never publish its repository data.

## Change Documentation With Behavior

A change to public behavior is not complete until the affected website documentation is updated in the same task.
Check user instructions, defaults, supported platforms, failure behavior, examples and compatibility. For an internal-only
change, state briefly why the existing documentation remains accurate; do not fabricate a documentation edit.

| Change | Authoritative source | Website destination |
| --- | --- | --- |
| RCX behavior, YAML, editor or screenshot contract | `docs/{en,ru,zh-CN}/auto-routing/` | Generated snapshots in `../reclash-site/content/rcx/` and the RCX handbook |
| Provider header names, types, aliases or tokens | The application registry and `provider_standard.g.json` | `../reclash-site/shared/provider/standard.json`; review the guide, reference, builder and mocks |
| Required provider policy | `provider-policy.schema.json`, Core/parser tests and `docs/en/PROVIDER_FEATURES.md` | `../reclash-site/public/schemas/provider-policy.schema.json` and the provider guide |
| RCX schema | `rcx-profile.schema.json` | `../reclash-site/public/schemas/rcx-profile.schema.json` and handbook examples |
| Setup, downloads and general client behavior | Application code and its tests | The corresponding localized Nuxt page and site metadata |

Provider policy is a versioned inline YAML contract, not a new provider HTTP header. Do not add a competing header
registry or copy validation rules into the website builder. Keep English repository text and the site's existing
localized content conventions; RCX chapters keep all three languages and stable translated anchors.

## Source And Snapshot Workflow

Keep the two checkouts next to each other. Clone the website only when `../reclash-site/` is absent; preserve an
existing checkout's working branch and local changes. Setup never advances it to a remote tip:

```sh
git clone https://github.com/Hoxiee/reclash-site.git ../reclash-site
npm --prefix ../reclash-site ci
```

`node tool/site_docs.mjs --sync` copies the provider registry and both JSON schemas verbatim. `--check` writes nothing:
it compares those exports and every RCX Markdown file against the application's current checkout. The website's own
`docs:check` additionally validates navigation, translated anchors, diagrams and screenshot manifests.

RCX prose is authored in the application repository, not in copied website Markdown. Once its source changes are
committed under explicit authority, refresh the snapshot from the application root:

```sh
npm --prefix ../reclash-site run docs:sync -- "$PWD"
node tool/site_docs.mjs --sync
```

Regenerate diagrams with `npm --prefix ../reclash-site run docs:diagrams` only when their Mermaid source changes. Use documented
screenshot slots and demo data, never real subscription credentials or browser-test screenshots. Do not create a second
Markdown renderer or search engine alongside the website's existing build-time compiler and lazy local search.

If a source commit is not authorized, leave the source changes uncommitted and report snapshot synchronization as
pending; do not falsify its source revision, claim a stale site is current, or silently commit to make the check pass.

## Verification And Delivery

From the application root:

```sh
node --test test/tool/site_docs_test.mjs
node tool/site_docs.mjs --check
npm --prefix ../reclash-site run check
npm --prefix ../reclash-site run test:e2e
```

The site check builds static output and enforces its JavaScript budgets. Browser tests cover navigation, search,
localization and narrow-screen layout. Check new user-visible states at desktop and phone widths in the existing site
theme. Neither a source checksum nor a green build proves that prose describes the behavior correctly: that remains a
review obligation. `.github/workflows/site-docs.yaml` checks exported data and documentation snapshots without publishing.

Application and website commits are separate permissions. Preserve unrelated changes in both repositories. Report each
branch, its uncommitted changes and the documentation/check status. The documentation workflow checks out the website's
default branch beside the application; local coordinated changes are not available to CI until published under separate
authority. Push neither repository and deploy nothing without publication authority.
