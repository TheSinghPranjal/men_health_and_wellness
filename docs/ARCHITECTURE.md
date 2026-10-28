# Architecture

Feature-first, layered: **presentation → domain ← data**. Riverpod providers are the DI mechanism, and every repository is overrideable in tests.

```
lib/
  main.dart, bootstrap.dart      startup: open encrypted storage, migrate, run app
  app/                           config, router, tab shell, theme tokens
  core/
    errors/ logging/ utils/      user-safe exceptions, redacting logger, dates
    storage/                     KeyValueStore contract, Hive impl, migrations
    security/                    encryption key store (Keychain/Keystore)
    privacy/                     full deletion + export services
    widgets/                     claymorphic design system
  shared/models/                 enums (goals, metrics, theme…)
  features/<feature>/
    domain/                      entities, pure rules (no Flutter storage/network)
    data/                        repositories over KeyValueStore
    presentation/                controllers (Notifiers), screens, widgets
```

Features: onboarding, home, education, health_hub, reflections, exercises, clinician_support, experiment, daily_log, habits, progress, reminders, settings, privacy_lock.

## State

* Persisted collections use synchronous `Notifier`s. Stores are opened before `runApp`, so reads are synchronous. Writes **persist first, then update state**, so the UI never shows unsaved data. Failures throw `AppException` with a user-safe message.
* Flows (`ReflectionFlowController`) are `autoDispose.family` notifiers. Answers live in memory until the user saves.
* `clockProvider` is injectable so all date logic is testable.
* **Riverpod 3.3 caveat.** Avoid provider→provider chains watched by tab screens, and avoid `ref.invalidate` on notifiers watched by covered routes. Riverpod 3.3 can throw `markNeedsBuild` during build when paused consumers resume (fixed in 3.4, which requires Dart 3.12). Update state in place instead. When the SDK allows, upgrade to `flutter_riverpod ^3.4.3`.

## Navigation

`go_router` with a `StatefulShellRoute.indexedStack` for the 5 tabs (state preserved per tab). Detail screens are root-level routes so they cover the tab bar. A redirect sends users to `/onboarding` until it is complete, except `/emergency`, which is always reachable. Paths contain only content ids, never answers or notes. No platform deep links are registered.

## Storage

* `KeyValueStore` stores JSON maps. Hive boxes hold JSON strings: no generated adapters, explicit tolerant parsing, and corrupt records are skipped and logged by type only.
* Box names are generic (`s0`…`s9`) so file names reveal nothing.
* All boxes are encrypted with `HiveAesCipher` (AES-256). The key is generated with Hive's secure RNG and kept in `flutter_secure_storage`. If a box can't be decrypted (for example, the key was lost on restore), it is reset rather than blocking launch.
* Records carry `_v` for per-record migration. `StorageMigrator` runs ordered, forward-only store migrations and records the schema version in `s0`. To migrate: add `Migration(from, run)`, bump `latestVersion`, and add a test.

| Store | Contents | Deletion |
|---|---|---|
| preferences | onboarding, goals, theme, lock, tracking choices | full delete |
| library | bookmarks, recent views, read dates | clear history / full |
| reflections | saved reflection answers (summary recomputed) | per item / all / full |
| habits, habitCompletions | habits, `habitId|yyyy-mm-dd` keys | per habit / all / full |
| checkIns | daily self-ratings, active minutes, notes | per entry / all / full |
| reminders | wellness reminder config | full |
| clinicianNotes | appointment checklist | clear / full |
| experiments | goals and observations | per item / all / full |

## Content

Articles are typed `Article` models in `features/education/data/content/*.dart`, bundled for offline use. The UI is fully data-driven. See `CONTENT_REVIEW.md`.

## Personalisation

Transparent rules only: `DailyPlan` (goals → suggestions with a visible reason), `ReflectionRules` (answers → care-navigation level + reading). Nothing is inferred from browsing.
