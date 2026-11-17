# Auto-Entrepreneur Manager — context for Claude

## What this is

Flutter + Firebase app for Moroccan auto-entrepreneurs: clients, catalog, invoices, PDFs, payments, quarterly declarations (IR/CNSS from Firestore tax config), dashboard. English + French i18n.

## Status (2026-11-17)

**Shipped:** Firebase auth, profile (multi-activity, including services), clients, catalog, invoices, payments, PDF, expenses (categories, month/quarter filters, optional receipt), tax declarations (IR per activity; CNSS is the flat amount for that quarter's total IR), dashboard revenue / quarter expenses / estimated IR+CNSS / deadline / outstanding invoices, Android home-screen widgets, on-device MCP connector.

**Not done:** Dashboard revenue-ceiling alert (DASH-04) and top clients (DASH-05). Optional: denormalized dashboard counters (`06-01`).

**Tax config:** `config/taxRates` version 4 (`cnssIrBands`). Old revenue-cap fields are ignored; the app then uses bundled defaults. Publish the JSON template to Firestore when updating production.

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
