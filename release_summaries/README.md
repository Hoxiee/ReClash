# Authored update summaries

The update sheet reads an optional, release-authored overview, not a summary scraped from Markdown. Full changelog entries remain in the release body.

For each release, add `release_summaries/<exact-tag>.json`, then use the existing commands:

```sh
dart run tool/changelog.dart verify
dart run tool/changelog.dart render release --tag <exact-tag> --out release.md
```

`render release` puts the English headline and highlights at the top of the release body, keeps the full changelog in a hidden JSON comment, and appends the validated overview under `<!-- reclash:update:json ... -->`. Stable and prerelease tags have separate files. If a file is absent, rendering keeps the existing changelog only; it does not invent release content. The generated release body uses the same request the updater already makes.

## Schema

The following is an example only, not an announcement or a real release file:

```json
{
  "schemaVersion": 1,
  "tag": "v0.1.1",
  "automaticInstall": false,
  "locales": {
    "en": {
      "headline": "A clearer update experience",
      "spotlight": {
        "title": "Updates in your own time",
        "description": "Download an update without blocking the app.",
        "kind": "update"
      },
      "highlights": [
        {
          "title": "Continue a paused download",
          "description": "Keep the verified release identity when resuming.",
          "kind": "speed",
          "platforms": ["android"]
        }
      ],
      "warnings": []
    },
    "ru": {
      "headline": "Понятное обновление приложения",
      "spotlight": {
        "title": "Обновление в вашем темпе",
        "description": "Скачивайте обновление без блокировки интерфейса.",
        "kind": "update"
      },
      "highlights": [
        {
          "title": "Продолжение загрузки",
          "description": "Докачка сохраняет проверяемую идентичность релиза.",
          "kind": "speed",
          "platforms": ["android"]
        }
      ],
      "warnings": []
    }
  }
}
```

- `tag` must exactly match the changelog tag and filename, including any prerelease suffix.
- `en` is the required fallback. Locale keys are lowercase (`ru`, `zh_cn`); the app tries the exact locale, its language, then English.
- Each locale needs a headline, one spotlight, and explicit `highlights` and `warnings` arrays. Titles and headlines are nonempty and at most 120 characters; descriptions are at most 600. There are at most ten highlights, twelve warnings, and thirty-two locales. Keep the encoded payload below 65,536 characters.
- Supported kinds: `wallpaper`, `link`, `dashboard`, `shield`, `speed`, `update`. Kinds select built-in artwork or glyphs; no remote HTML, images, scripts, or arbitrary UI are accepted.
- Optional `platforms` uses `android`, `windows`, `macos`, `linux`. An omitted or empty list means every platform. Every locale must match English warning count, order, and platform coverage; translate their text without omitting or rearranging them. Warnings stay outside collapsed details.
- Set `automaticInstall` explicitly. `false` is the normal authoring choice. `true` is only eligibility metadata: any warning blocks automatic installation, and user consent, stable-channel policy, an inactive VPN, and Android installer requirements still apply.
- The renderer escapes every `>` as the literal JSON sequence `\u003e`, so user-authored text such as `-->` cannot close the hidden comment early.

## Trust and installation

The overview is release metadata delivered over HTTPS, not a separately authenticated statement signed by the APK certificate. Never use it to authorize an otherwise unverified package. The installer still checks the pinned asset SHA-256, package identity, higher version code, expected version name, and signing certificate. A missing or invalid overview cannot relax those checks. Android may still require an installation permission or system confirmation.
