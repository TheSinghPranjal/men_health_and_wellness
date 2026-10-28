# Release checklist

This build is **not production-ready** until every unchecked item below is resolved.

## Blocking

- [ ] Clinical review and sign-off of all articles, myths and reflection rules (`CONTENT_REVIEW.md`)
- [ ] Published privacy policy and terms. Legal review for target regions (health-data rules, age gating)
- [ ] Independent privacy/security review of storage, lock and notification behaviour
- [ ] Release signing configs (Android currently signs release with the debug key; iOS team/bundle id)
- [ ] Final application id / bundle id (currently `com.the_lazy_bear_club.men_health_and_wellness`)
- [ ] App icon and launch screen artwork
- [ ] Manual test on physical iOS and Android devices: biometrics, reminders after reboot, time-zone change, notification denial
- [ ] Accessibility pass with TalkBack / VoiceOver and the largest text sizes

## Done in this build

- [x] `flutter analyze`: no issues
- [x] Unit and widget tests: 71 passing. Integration journey passing (headless)
- [x] Every route and article renders at 320dp, 1.3× text, light and dark
- [x] Emergency guidance reachable everywhere, including before onboarding
- [x] Encrypted storage, backup exclusion, discreet notifications, full and selective deletion

## Known limitations

- Content is in English only (`locale` field exists for future localisation).
- Reminders use inexact Android alarms (no exact-alarm permission), so they may arrive a few minutes late.
- The app lock relies on device authentication. If the device has no passcode, the lock cannot be enabled.
- Riverpod is pinned to 3.3.x by the Dart 3.11 SDK. See ARCHITECTURE.md for the workaround in place.
- Integration test uses fakes for storage, notifications and authentication. Platform plugins need on-device verification.
- No IIEF-5/SHIM questionnaire is included (licensing and validation not established). Reflections are custom and non-diagnostic.

## Recommended next steps

1. Clinical review → flip `reviewStatus` to reviewed.
2. Add localisation (ARB files) and region-aware emergency numbers from a verified source.
3. Upgrade to Riverpod 3.4+ once on Dart 3.12, and remove the in-place-update workaround if desired.
4. Consider opt-in encrypted backup (separate feature with explicit consent).
5. Optional AI educational assistant, only with retrieval over reviewed content, consent and the safety rules in the product brief.
