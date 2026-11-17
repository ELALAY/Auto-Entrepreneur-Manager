# Project State

## Project Reference

See: `.planning/PROJECT.md` (updated 2026-11-17)

**Core value:** A Moroccan auto-entrepreneur can complete their quarterly tax declaration confidently, knowing exactly what they owe and how to file it, based on their real tracked revenue.

**Current focus:** Finish the dashboard (revenue-ceiling alert and top clients). Phases 1–5 are shipped. Phase 6 is partial.

## Current Position

Phase: **6 - Dashboard** (remaining: DASH-04, DASH-05)

Plan: `06-03` revenue-ceiling alert, then `06-04` top clients. `06-01` (denormalized counters) stays optional. `06-05` (quarter expenses and estimated IR+CNSS) is shipped.

Status: No technical blocker. Publish Firestore `config/taxRates` version 4 (`config/taxRates.firestore.json`) so production uses the remote IR bands instead of the bundled fallback.

Last activity: 2026-11-17 — Implemented Android **New Invoice** launcher shortcut (ANDROID-01), with cold/warm delivery, pending auth resumption, prerequisite gate, and once-only navigation. Verification and remaining device checks: [shortcut report](verification/android-new-invoice-shortcut.md).

Shortcut verification: 12 targeted tests and all 43 Flutter tests pass; relevant static analysis has no issues; Android debug APK builds successfully. Real-device launcher/OEM checks remain pending.

Progress: [███████████] ~96% (ceiling alert and top clients outstanding)

## Performance Metrics

**Velocity:**

- Total plans completed: not tracked in repo
- Average duration: -
- Total execution time: -

**By Phase:**

| Phase | Notes |
|-------|--------|
| 1–5 | **Complete** (auth, profile, clients, catalog, invoices, PDF, payments, expenses, declarations) |
| 6 | **Partial** — quarter/YTD revenue, quarter expenses, estimated IR+CNSS, deadline, outstanding and overdue are on the dashboard. Ceiling alert and top clients are not. |

**Recent Trend:**

- Last 5 plans: -
- Trend: -

*Updated after each plan completion*

## Accumulated Context

### Decisions

Decisions are logged in `PROJECT.md` Key Decisions table.

Recent decisions affecting current work:

- Stack: Flutter + Firebase, Riverpod 2.x, `go_router`
- Tax rates: Firestore `config/taxRates` when the document matches the IR-band schema; otherwise `TaxRatesConfig.bundledMoroccoDefaults()` (same numbers as `config/taxRates.firestore.json` version 4)
- Multi-activity: profile lists tax activities (commercial, artisanal, liberal, services); catalog items and invoices carry one activity; quarterly IR is summed per activity
- CNSS is the flat quarterly amount for that total IR (125 → 300 MAD through above 12,500 → 3,600 MAD). A quarter with no revenue still owes 300 MAD unless the profile is already affiliated to CNSS (`hasCnss`)
- Android: `android/pin_glance.gradle` pins Glance to 1.2.0 and WorkManager to 2.11.2, and raises library minSdk to 23, so `home_widget` 0.9.x open ranges still build on AGP 8.7 / compileSdk 35

### Pending Todos

- **Android device QA — ANDROID-01:** Launcher menu/icon, actual cold/warm delivery, email/Google sign-in, missing/offline data, existing widgets, and activity recreation. Samsung Modes and Routines is untested; no compatibility claim. See [manual checks and verification](verification/android-new-invoice-shortcut.md).
- **Phase 6 — DASH-04:** Alert when year-to-date paid revenue is within 20% of the annual ceiling for the user's activity (commerce/artisanat 500,000 MAD, services 200,000 MAD — confirm current DGI ceilings before shipping).
- **Phase 6 — DASH-05:** Top clients by paid revenue.
- **Ops:** Replace the live Firestore `config/taxRates` document with version 4 (`cnssIrBands`). Documents that still use `cnssNil` / `cnssTo2500` are rejected.

### Blockers/Concerns

- **Rates:** Bundled defaults match the 2026-11-17 scale. Re-check DGI/CNSS when the Finance Law changes, then bump `config/taxRates`.
- **Dashboard revenue:** Quarter and year-to-date figures bucket payments by invoice issue date, not by payment date.
- **PDF / web:** If changing PDF download on web, re-validate platform behavior (`Printing.layoutPdf`, save/share).

## Session Continuity

Last session: 2026-11-17

Stopped at: Android launcher shortcut implementation and automated verification (see report). Next device work is shortcut QA; next product work remains the dashboard ceiling alert and top clients.

Resume file: None
