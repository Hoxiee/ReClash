---
name: localization
description: Use when changing ReClash UI text, scanning for hardcoded Chinese strings, updating ARB localization, or fixing generated locale output in this repository.
---

# Localization

## When To Use

Use this for localization work in this repository, especially hardcoded UI text in `lib/`, ARB updates, missing translations, or generated `lib/l10n/` output that does not match source ARB values.

Do not use this for README translation sync or manual edits to generated localization Dart.

## Workflow

1. Scan user-facing Dart text before opening many files. `intl_utils` reads assembled `arb/intl_<locale>.arb` files and writes app-owned `lib/l10n/`; normalized vendor-generated Dart is retained separately in `upstream_l10n/`:

   ```bash
   rg -n "[\\p{Han}]" lib -g '!lib/l10n/intl/**' -g '!lib/**/generated/**'
   ```

2. Inspect the smallest relevant call sites and existing feature fragment.
3. Author upstream bases only under `arb_upstream/`. `arb/locales/` is a stable baseline for a downstream-only locale; do not add feature strings there. Put all new or changed ReClash messages in the owning `arb/fragments/<feature>/intl_<locale>.arb`. Never hand-edit assembled `arb/intl_<locale>.arb` files.
4. Keep one owner per message key. A fragment value may override an upstream base message; another feature fragment cannot claim the same key. Use a `null` fragment value only to deliberately remove an upstream message.
5. Replace inline strings with existing project accessors:
   - Widgets with `BuildContext`: `context.appLocalizations.key` from `lib/common/context.dart`.
   - Controllers/providers/non-widget code: `currentAppLocalizations.key` from `lib/common/app_localizations.dart`.
6. Prefer `dart run tool/l10n.dart apply <spec.json>`: it writes every locale of the fragment, validates locales,
   placeholders, and ownership, then assembles and regenerates in one step. Use `find`/`get` to reuse existing keys
   and `audit --fragment <feature>` afterwards; never read generated `lib/l10n/` files. By hand, assemble and
   regenerate:

   ```bash
   dart run tool/assemble_l10n.dart
   dart run intl_utils:generate
   ```

7. On a fresh checkout, run `dart tool/prepare.dart` first: assembled ARBs, `lib/l10n/`, and generated application models/providers/database code are ignored, not versioned. Never add them to Git; `upstream_l10n/` remains tracked vendor provenance.
8. Run `dart run tool/assemble_l10n.dart --check`, `flutter analyze --no-fatal-infos`, and `flutter test test/tool/l10n_assembler_test.dart test/l10n test/lint/dynamic_message_key_test.dart`. The lint test checks locale key parity and rejects runtime-derived `Intl.message` keys; enum labels go through `lib/common/l10n_labels.dart`.
9. Re-run the Han-text scan for targeted strings.

## Pitfalls

- A locale that still shows English lacks the key or carries an English value in its source ARB; fix that ARB and
  regenerate. Do not edit generated Dart.
- Ignore `lib/l10n/intl/**` and `lib/**/generated/**` during text scans.
