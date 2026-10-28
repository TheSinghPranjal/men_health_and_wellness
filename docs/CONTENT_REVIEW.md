# Medical content governance

## Status

All 32 starter articles and 9 myth cards were written on 2026-10-28 from the public sources below. They are marked **"Awaiting clinical review"** in the app (`ReviewStatus.pendingClinicalReview`), and **they must be reviewed by a qualified clinician (urologist / sexual medicine specialist) before public release.** No statistics, studies or guidelines were invented. Where a source was not available to check, the claim was omitted.

## Review workflow

1. **Draft.** The author writes or edits an `Article` in `lib/features/education/data/content/`, citing only sources in `sources.dart`.
2. **Automated checks.** `flutter test test/unit/content_test.dart` verifies ids, required sections, registered sources, cross-links, the nitrate warning, and the absence of unqualified "cure/guarantee" claims.
3. **Clinical review.** The reviewer checks each claim against its cited source, the "evidence supports / uncertain" split, safety warnings, and the "when to see a clinician" triggers.
4. **Sign-off.** Set `reviewStatus: ReviewStatus.clinicallyReviewed`, bump `version`, and update `authoredOn` / `nextReviewOn`. Record the reviewer and date in the table below.
5. **Re-review.** Review every item by `nextReviewOn` (6 months), or sooner when guidelines change.

Rules: no fabricated URLs or dates, no citing a guideline for a claim it does not make, no prescription dosing, and wellness suggestions are kept distinct from clinical evidence. Reflection rules (`reflection_rules.dart`) need the same review, because they decide care-navigation wording.

| Item | Reviewer | Date | Notes |
|---|---|---|---|
| _all articles_ | _pending_ | | |
| reflection rules | _pending_ | | |

## Source register

Each URL returned HTTP 200 (or loaded via fetch) on 2026-10-28.

| Id | Source |
|---|---|
| niddk-ed, -causes, -treatment, -diet | NIDDK (NIH) Erectile Dysfunction pages |
| nhs-ed, nhs-ejaculation, nhs-libido, nhs-priapism, nhs-peyronies | NHS condition pages |
| nhs-activity, nhs-sleep, nhs-sleep-apnoea, nhs-tired, nhs-breathing, nhs-stress, nhs-anxiety, nhs-depression, nhs-eat-well, nhs-healthy-weight, nhs-quit-smoking, nhs-alcohol, nhs-sexual-health, nhs-tadalafil | NHS live-well / medicines pages |
| aua-ed, aua-ejaculation, aua-testosterone | American Urological Association guidelines |
| eau-sexual | EAU Guidelines on Sexual and Reproductive Health |
| issm-qa, issm-pe | International Society for Sexual Medicine |
| smsna-de | Sexual Medicine Society of North America: Delayed Ejaculation |
| fda-tainted | U.S. FDA: Sexual Enhancement and Energy Product Notifications |

Full URLs are in `lib/features/education/data/content/sources.dart` and on the in-app About screen. Mayo Clinic and CDC pages were not cited because they could not be fetched to verify during authoring. They can be added after manual verification.
