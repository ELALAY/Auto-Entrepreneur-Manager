# Project State

## Project Reference

See: .planning/PROJECT.md (updated 2026-04-09)

**Core value:** A Moroccan auto-entrepreneur can complete their quarterly tax declaration confidently, knowing exactly what they owe and how to file it, based on their real tracked revenue.
**Current focus:** Phase 1 — Firebase + Auth

## Current Position

Phase: 1 of 6 (Firebase + Auth)
Plan: 0 of 3 in current phase
Status: Ready to plan
Last activity: 2026-04-09 — Roadmap and STATE initialized

Progress: [░░░░░░░░░░] 0%

## Performance Metrics

**Velocity:**
- Total plans completed: 0
- Average duration: —
- Total execution time: —

**By Phase:**

| Phase | Plans | Total | Avg/Plan |
|-------|-------|-------|----------|
| - | - | - | - |

**Recent Trend:**
- Last 5 plans: —
- Trend: —

*Updated after each plan completion*

## Accumulated Context

### Decisions

Decisions are logged in PROJECT.md Key Decisions table.
Recent decisions affecting current work:

- Stack: Flutter + Firebase decided, Riverpod 2.x for state management, go_router for navigation
- Flutter skeleton already built (routing, models, i18n scaffold, screens stubbed) — Phase 1 wires Firebase, does not rebuild skeleton
- Tax rates must be fetched from Firestore config document — never hardcoded in Dart

### Pending Todos

None yet.

### Blockers/Concerns

- **Phase 5 prerequisite:** Morocco IR and CNSS rates must be verified against current DGI Finance Law and CNSS circulars before Phase 5 begins — training-time rates may be outdated
- **Phase 3 prerequisite:** PDF web download behavior (`Printing.layoutPdf()` vs. `dart:html` blob URL) must be validated in a spike at the start of Phase 3 — do not assume from documentation

## Session Continuity

Last session: 2026-04-09
Stopped at: Roadmap created, STATE initialized — ready to plan Phase 1
Resume file: None
