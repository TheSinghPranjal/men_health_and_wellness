# Privacy & data flows

Sexual-health information is treated as highly sensitive.

## What leaves the device

**Nothing, automatically.** There is no backend, account, analytics, crash reporting or ad SDK. The only outbound actions are user-initiated:

* Tapping a source link opens the system browser (`url_launcher`, external app mode).
* "Copy notes" / "Export my data" puts text on the clipboard after a confirmation that warns other apps may read it.
* The emergency button opens the phone dialler.

## On-device data

* Stored only after explicit user action (saving a reflection, a check-in, a habit…). Search text is never stored.
* Encrypted at rest (AES-256, Hive). The key is kept in the iOS Keychain (`first_unlock_this_device`) or Android Keystore-backed storage.
* Android: `allowBackup=false` plus data-extraction rules that exclude all domains from cloud backup and device transfer.
* Logs: event names and counts only, debug builds only. Errors log the exception *type*, never messages or values.
* Notifications carry no payload. The default text is "Your wellness reminder is ready." Habit titles appear only if discreet mode is off.

## Threat model

| Threat | Mitigation |
|---|---|
| Someone glances at or picks up the unlocked phone | Optional app lock (biometric/passcode after 30 s away). Content hidden in the app switcher while lock is on. Discreet notifications |
| Device backup or file extraction | Encrypted boxes, key not in backup, backups disabled |
| Shoulder-surfing via the lock screen | No sensitive words in notifications |
| Another app reading data | OS sandbox. Clipboard export only after warning |
| Rooted/jailbroken device with the user unlocked | **Not protected.** Out of scope |
| Lost encryption key (e.g. OS restore) | Data is unrecoverable by design. Boxes reset cleanly |

No custom cryptography is used. Encryption is not a claim of regulatory compliance (HIPAA, GDPR, etc.). A formal privacy/security review and a published privacy policy are required before release.

## Permissions

Requested only when needed: notifications (when a reminder is enabled) and biometrics (when app lock is enabled). The app never requests contacts, location, microphone, camera or health-device access.

## Deletion

Profile → Privacy & data offers per-category deletion and **Delete all my data**. Full deletion cancels all notifications, clears every store and resets the app to onboarding. Bundled articles are unaffected.
