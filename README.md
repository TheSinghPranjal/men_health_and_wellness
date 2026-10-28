# VitalMen

A private, evidence-based men's sexual health and wellness app built with Flutter. It offers education, private self-reflections, realistic habits, and guidance on when to see a clinician. It does **not** diagnose, prescribe or promise results.

> This app provides educational and wellness information. It does not diagnose medical conditions or replace professional care.

## Design

The interface uses **claymorphism**: soft "inflated" cards with large radii, an offset drop shadow, and painted inner highlight/shade (`lib/core/widgets/clay_surface.dart`). The palette is calm (navy, muted teal, warm off-white) with pastel tones per topic. Red is reserved for urgent safety information. Light, dark and system themes are supported. Design tokens live in `lib/app/theme/clay_tokens.dart`. The typeface is Nunito (bundled, SIL OFL 1.1), so the app works offline.

## Features (first release)

| Area | What works |
|---|---|
| Onboarding | Welcome + disclaimer, 18+ gate (blocks under-18s), goals, optional personalisation, privacy choices, optional app lock |
| Home | Rule-based daily plan (each item explains *why* it is suggested), topic cards, continue learning, routine summary, goal-based suggestions |
| Learn | 32 sourced articles in 11 categories, myth-vs-evidence cards, offline search with synonyms, bookmarks, related reading |
| My Health | 8 topic modules (erectile, desire, ejaculation, intimacy, stress/sleep, lifestyle, porn & expectations, treatments) |
| Reflections | 5 optional questionnaires with deterministic, **non-diagnostic** summaries. Saved only on request |
| Care | Emergency guidance (reachable from every screen, including before onboarding), appointment checklist with copy-to-share, "when to see a clinician" |
| Exercises | Paced breathing (reduced-motion aware), progressive muscle relaxation, sensory refocusing |
| Experiment | Self-directed habit experiment with private observations. No streaks, no scores |
| Progress | Opt-in metrics, daily check-ins, habits (pause/edit/delete, no punitive streaks), single-series charts with table view |
| Reminders | Optional, discreet wording by default, permission asked only when enabled |
| Privacy | Encrypted local storage, app lock (biometrics/passcode), selective and full deletion, JSON export to clipboard |

Not implemented (by design for v1): accounts, cloud sync, AI assistant, payments, clinician discovery. Feature flags in `lib/app/app_config.dart` keep these hidden.

## Getting started

Requirements: Flutter 3.41+ / Dart 3.11+, Xcode (iOS), Android SDK (Android).

```bash
flutter pub get
flutter run
```

## Testing

```bash
flutter analyze
flutter test                                          # unit + widget (71 tests)
flutter test integration_test -d flutter-tester       # end-to-end journey, headless
flutter test integration_test -d <device-id>          # on a device/simulator
```

* `test/unit`: reflection rules, flow controller, habits, content integrity (sources, cross-links, no cure/guarantee claims), search, storage encryption, migrations, deletion, export, reminders and validators.
* `test/widget`: onboarding, under-18 block, tabs, theme, search, bookmarks, reflection save, habit creation, data deletion, app lock. `render_smoke_test.dart` renders **every route and article** at 320dp with 1.3× text in light and dark mode and fails on any overflow.
* `integration_test/app_test.dart` covers the 11 required journeys, including relaunch persistence and post-deletion state.

Tests use in-memory fakes (`test/helpers/fakes.dart`). No real personal data is used.

## Documentation

* [Architecture & storage](docs/ARCHITECTURE.md)
* [Privacy, data flows & threat model](docs/PRIVACY.md)
* [Medical content review & source register](docs/CONTENT_REVIEW.md)
* [Release checklist & known limitations](docs/RELEASE_CHECKLIST.md)

## Dependencies

| Package | Why |
|---|---|
| flutter_riverpod 3.3 | State management and DI (3.4 needs Dart 3.12) |
| go_router | Declarative routing, tab shell, onboarding redirect |
| hive_ce / hive_ce_flutter | Offline local database with AES encryption |
| flutter_secure_storage | Keeps the database encryption key in Keychain/Keystore |
| local_auth | Optional biometric/passcode app lock |
| flutter_local_notifications, timezone, flutter_timezone | Optional weekly reminders |
| fl_chart | Progress charts |
| intl, uuid, path_provider | Formatting, ids, storage paths |
| url_launcher | Opens source links / the dialler outside the app |

`freezed`/`json_serializable` were intentionally not used. The models are small and hand-written, with explicit tolerant `fromJson`, which avoids a code-generation step.
