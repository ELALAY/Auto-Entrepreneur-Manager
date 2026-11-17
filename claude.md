# Auto-Entrepreneur Manager — context for Claude

## What this is

Flutter + Firebase app for Moroccan auto-entrepreneurs: clients, catalog, invoices, PDFs, payments, quarterly declarations (IR/CNSS from Firestore tax config), dashboard. English + French i18n.

## Status (2026-04-19)

**Shipped:** Firebase auth, profile (including multi–activity categories), clients, service/product catalog with per-item tax activity, invoices (single activity per invoice; derived from catalog lines or manual), payments, PDF export, tax declarations (per-activity IR; CNSS on total quarterly paid revenue), dashboard.

**Not done:** **Expenses** — logging, receipts, period filters (roadmap Phase 4).

## Where to look

| Doc | Purpose |
|-----|---------|
| `.planning/PROJECT.md` | Requirements, constraints, decisions |
| `.planning/ROADMAP.md` | Phases and completion status |
| `.planning/STATE.md` | Current position and session handoff |
| `.planning/REQUIREMENTS.md` | Requirement IDs |

## Conventions

- State: Riverpod; routing: `go_router`; backend: Firestore + Storage.
- Tax rates: loaded from Firestore config — do not hardcode in Dart for production calculations.
