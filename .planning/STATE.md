# Project State

## Project Reference

See: `.planning/PROJECT.md` (updated 2026-04-19)

**Core value:** A Moroccan auto-entrepreneur can complete their quarterly tax declaration confidently, knowing exactly what they owe and how to file it, based on their real tracked revenue.

**Current focus:** **Expenses only** - the only major capability not yet implemented (Roadmap Phase 4). Phases 1-3 and 5-6 are shipped in-app.

## Current Position

Phase: **4 - Expenses** (remaining)

Plan: Implement expense CRUD plus filters when this phase is picked up (`04-01` on roadmap).

Status: No technical blocker documented - **product backlog = expenses**

Last activity: 2026-04-19 - Planning docs synced (complete except expenses)

Progress: [██████████░] ~92% (expenses outstanding)

## Performance Metrics

**Velocity:**

- Total plans completed: not tracked in repo
- Average duration: -
- Total execution time: -

**By Phase:**

| Phase | Notes |
|-------|--------|
| 1-3, 5-6 | **Complete** in the app (auth, profile incl. multi-activity, clients, catalog, invoices, PDF, payments, declarations, dashboard) |
| 4 | **Expenses** - not implemented |

**Recent Trend:**

- Last 5 plans: -
- Trend: -

*Updated after each plan completion*

## Accumulated Context

### Decisions

Decisions are logged in `PROJECT.md` Key Decisions table.

Recent decisions affecting current work:

- Stack: Flutter + Firebase, Riverpod 2.x, `go_router`
- Tax rates from Firestore config - never hardcoded for filing calculations
- Multi-activity support: profile lists tax activities; catalog items and invoices carry activity; quarterly IR buckets by activity; CNSS uses total quarterly paid revenue (validate Moroccan mixed-activity CNSS rules if regulations require)

### Pending Todos

- **Phase 4 - Expenses:** amount/date/category/description, receipt image optional, period filters - see `ROADMAP.md` Phase 4 and `PROJECT.md` Active requirements.

### Blockers/Concerns

- **Rates:** Keep Firestore IR/CNSS config aligned with current DGI/CNSS rules.
- **PDF / web:** If changing PDF download on web, re-validate platform behavior (`Printing.layoutPdf`, save/share).

## Session Continuity

Last session: 2026-04-19

Stopped at: Documentation sync - status = complete except expenses

Resume file: None
