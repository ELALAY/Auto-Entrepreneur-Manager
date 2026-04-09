# Project Research Summary

**Project:** Auto-Entrepreneur Manager (Morocco)
**Domain:** Mobile/web invoicing and tax compliance SaaS for Moroccan auto-entrepreneurs
**Researched:** 2026-04-09
**Confidence:** HIGH

---

## Executive Summary

This is a Flutter + Firebase invoicing and tax compliance tool targeting Moroccan auto-entrepreneurs — sole traders operating under the régime auto-entrepreneur. The product's core value is dual: professional PDF invoice generation with legally required Moroccan fields (ICE, IF, CNSS, sequential numbering), and automated quarterly tax calculation (IR + CNSS) by activity type. No mainstream invoicing tool addresses the Moroccan auto-entrepreneur filing workflow; that gap is the primary competitive moat.

The recommended approach is Flutter 3.18 with Riverpod 2.x state management, Firebase (Firestore + Auth + Storage) as backend, and the official Flutter MVVM + Repository architecture pattern. The app targets Android, iOS, and web from a single codebase. Feature scope must be tightly bounded: TVA (VAT) must never appear (AEs are exempt by law), multi-user and payroll features are legally inapplicable to the regime, and bank reconciliation has no Moroccan API equivalent. This is a lean compliance tool, not an accounting suite.

The single largest risk is the tax calculation feature: rates for IR and CNSS contributions vary by activity type, include a CNSS minimum quarterly base (plancher), and change with each Finance Law. These must be sourced from official DGI and CNSS documentation before writing any calculation code, stored in a versioned Firestore config document (not hardcoded Dart constants), and covered by unit tests. A secondary acute risk is Firestore security rules — the `/users/{uid}/` subcollection pattern must be implemented from day one and verified with emulator tests before any user data is stored.

---

## Key Findings

### Recommended Stack

The stack is Flutter 3.18 / Dart 3.8 with Firebase as the sole backend. Riverpod 2.x (code-generated with `@riverpod` annotations) is the clear state management choice — Provider is in maintenance mode since 2024, BLoC adds boilerplate without benefit at this scale. `go_router` is the Flutter-team standard for navigation and is required for Flutter Web URL routing and auth redirect guards.

PDF generation uses the `pdf` + `printing` packages (pure Dart, cross-platform). The critical web caveat is that `Printing.sharePdf()` does not trigger a file download on web — use `Printing.layoutPdf()` for v1 (browser print dialog). Custom TTF fonts (e.g. Roboto) must be bundled as Flutter assets because default PDF fonts do not render French accented characters (é, è, à, ç). Data models use `freezed` for immutable, equality-correct, serializable models.

**Core technologies:**
- Flutter 3.18 / Dart 3.8: Single codebase for Android, iOS, web — sealed classes and records for domain modeling
- Firebase (Firestore ^5.6, Auth ^5.5, Storage ^12.4): Backend, auth, file storage — offline persistence built in
- Riverpod 2.x (`flutter_riverpod ^2.6.1`): State management and DI — replaces deprecated Provider
- `go_router ^14.6.2`: Navigation — Flutter team standard, required for web URL routing
- `pdf ^3.11.1` + `printing ^5.14.1`: PDF generation and cross-platform preview/download
- `syncfusion_flutter_signaturepad ^27.2.3`: Canvas-based signature capture on all three platforms
- `reactive_forms ^17.0.1`: Model-driven forms for dynamic invoice line items
- `freezed_annotation ^2.4.4` + `json_annotation ^4.9.0`: Immutable, serializable data models
- `intl ^0.20.1`: Date, number, and MAD currency formatting — never `.toString()` on dates or amounts
- `fl_chart ^0.69.0`: Dashboard revenue charts — pure Flutter, web-compatible

See `.planning/research/STACK.md` for full compatibility matrix and platform setup checklists.

### Expected Features

The Moroccan auto-entrepreneur regime defines a tight feature set. Users need invoice creation as their immediate workflow, and quarterly tax preparation as their compliance workflow. Everything beyond those two pillars is either legally inapplicable or deferred.

**Must have (table stakes):**
- Professional PDF invoices with ICE, IF, CNSS, date, sequential number, client details, and line items — legally required fields
- Auto-incrementing sequential invoice numbering without gaps — Moroccan legal requirement
- Client directory with ICE/IF fields for B2B clients — eliminates re-entry of required fields
- Invoice status tracking (draft / sent / paid / overdue) and payment recording
- Business profile with logo, signature, and Moroccan legal identifier fields
- Income summary by period and dashboard (revenue, outstanding, overdue)
- French-language UI — dominant business language in Morocco
- Mobile-friendly interface — Flutter covers this natively

**Should have (Morocco-specific differentiators — core moat):**
- Quarterly IR calculation by activity type (Commercial 1%, Artisanal 1%, Liberal 2% of gross revenue — VERIFY before implementing)
- CNSS contribution calculation per quarter including minimum base (plancher — VERIFY rate)
- Step-by-step DAMANCOM portal filing guide — removes the highest-friction pain point
- Quarterly declaration deadline reminders
- Declaration history with filed amounts (audit trail)
- Revenue ceiling proximity alert — AE status revoked above ceiling (VERIFY per activity type)
- Activity type explainer during onboarding — many AEs don't know their category
- Multiple payment method tracking (cash, virement, chèque) — Moroccan market still heavily cash/check

**Defer to v2+:**
- Quotes / estimates workflow
- Invoice send by email directly from app (v1: mailto: link via `url_launcher`)
- Service/product catalog (useful but not blocking)
- Expense logging + receipt capture
- Arabic RTL interface (significant Flutter RTL complexity)
- Recurring invoices, bank import, multi-user, payroll, double-entry bookkeeping — out of scope for the AE regime

**Hard anti-features (never build):**
- TVA/VAT fields anywhere — auto-entrepreneurs are legally TVA-exempt
- Multi-user / team / accountant access — AEs are sole traders by law
- Direct DAMANCOM API submission — no official government API exists

See `.planning/research/FEATURES.md` for full dependency graph and Morocco tax reference.

### Architecture Approach

The Flutter official MVVM + Repository pattern (from flutter.dev/app-architecture Compass case study) is the correct architecture. Three clear layers: UI (Widgets + Riverpod `AsyncNotifier` ViewModels), Domain (pure Dart use cases — tax calculations, invoice logic), and Data (Firebase repository implementations). The feature-first folder structure (`lib/features/{feature}/data|domain|presentation/`) keeps boundaries clear and enables parallel development across features.

Firestore data must be organized as subcollections under `/users/{uid}/` — this is the only correct multi-tenant pattern. A single security rule `allow read, write: if request.auth.uid == uid` then protects all collections. Tax calculation logic lives in pure Dart domain classes with no Firebase dependency, making it trivially unit-testable. Tax rates are stored in a versioned `/config/taxRates` Firestore document, not hardcoded as Dart constants.

**Major components:**
1. Auth + routing layer — Firebase Auth, go_router with auth redirect guards, security rules with emulator tests
2. Profile + Clients + Services — prerequisites for invoice creation; signature capture and logo upload here
3. Invoices + PDF + Payments — core value; atomic server-side invoice numbering transaction; PDF spike on all three platforms at phase start
4. Tax Declarations domain — pure Dart `TaxCalculator` class, rate config from Firestore, filing guide UX
5. Dashboard — denormalized summary document updated by Cloud Functions; no unbounded queries
6. Shared infrastructure — i18n ARB files, `intl` formatting, `freezed` models, Riverpod providers

See `.planning/research/ARCHITECTURE.md` for Firestore schema, security rules, and state management patterns.

### Critical Pitfalls

1. **Firestore rules leaking cross-tenant data (C1)** — Use `/users/{uid}/subcollection` paths from day one. Write Firestore emulator rule tests before any user data is written. Rules checking only `request.auth != null` silently expose all users' financial data.

2. **PDF generation broken on Flutter web (C2)** — Run a PDF spike on all three platforms at the very start of the invoice phase. Bundle TTF fonts for French accented characters. Use `Printing.layoutPdf()` on web (not `sharePdf()`). Await signature image bytes before building the PDF.

3. **Tax rates hardcoded or wrong (C3)** — Read current DGI Finance Law and CNSS circular before writing any calculation code. Document each rate with its source URL. Store rates in Firestore config — not Dart constants. Include the CNSS plancher (minimum base) in the calculation. Cover all activity types and edge cases with unit tests.

4. **Duplicate invoice numbers from offline client-side generation (C4)** — Invoice number generation must use a Firestore transaction (`runTransaction`) from day one. Never generate numbers client-side. Sequential, gapless numbering is a Moroccan legal requirement.

5. **Performance collapse with unbounded Firestore queries (C5)** — Every query must have `.limit(25)`. Dashboard totals use a denormalized summary document, not real-time aggregation over all documents. Set query patterns in the foundation phase — they are hard to change later.

See `.planning/research/PITFALLS.md` for moderate pitfalls (Storage URL expiry, i18n added retroactively, Cold Function cold starts, receipt upload costs, Firestore read costs).

---

## Implications for Roadmap

Based on the dependency graph in FEATURES.md and the build order in ARCHITECTURE.md, six phases emerge. The ordering is not arbitrary — it reflects hard data dependencies and the need to front-load the highest-risk technical decisions.

### Phase 1: Foundation
**Rationale:** Every subsequent feature depends on auth, routing, security rules, and i18n. These cannot be retrofitted cleanly. Firebase setup, Firestore security rules, go_router, and ARB file i18n scaffold must be in place before any feature screen is built.
**Delivers:** Working app shell with auth flow, protected routes, French locale, and security-rule-tested data layer
**Addresses:** French-language UI (table stake), mobile-friendly interface
**Avoids:** C1 (cross-tenant data leak), M2 (retroactive i18n extraction), m3 (web deep link breaks)

### Phase 2: Business Profile + Clients
**Rationale:** Invoice creation requires a business profile (legal fields, logo, signature) and a client (ICE, IF, address). These are blocking prerequisites with no workarounds.
**Delivers:** Onboarding flow, profile with Moroccan legal fields, client directory, signature capture, logo upload
**Addresses:** Business profile and branding (table stake), Moroccan legal field labels (differentiator)
**Avoids:** M3 (store Storage paths not URLs), M1 (signature resolution — test all 3 platforms in this phase)

### Phase 3: Invoices + PDF + Payments
**Rationale:** Core value delivery. This is the reason the app exists. PDF spike on all three platforms must happen at the start of this phase, not the end. Sequential invoice numbering transaction must be implemented here, not later.
**Delivers:** Invoice creation with line items, PDF export, payment recording, outstanding balance, invoice status workflow
**Addresses:** All invoice table stakes (PDF, sequential numbering, client reuse, status tracking, payment recording)
**Avoids:** C2 (PDF web failures), C4 (duplicate invoice numbers), m4 (number formatting consistency), m1 (cancelled invoices keep numbers)

### Phase 4: Tax Declarations
**Rationale:** Depends on invoice revenue totals being queryable by period. This is the core Morocco-specific differentiator and the phase with the highest domain accuracy risk. Rates must be sourced from official documentation before a line of calculation code is written.
**Delivers:** Quarterly IR + CNSS calculation by activity type, DAMANCOM filing guide, declaration history, deadline reminders, revenue ceiling alert
**Addresses:** All Morocco-specific differentiators (core moat)
**Avoids:** C3 (wrong/hardcoded tax rates), m2 (timezone bugs — use period strings not timestamps)

### Phase 5: Expenses
**Rationale:** Independent of invoices and tax declarations; can be built after core value is delivered. Image upload infrastructure (receipt capture) has its own pitfalls handled here.
**Delivers:** Expense logging, receipt photo capture and upload, category tracking
**Avoids:** M5 (receipt image size — compress before upload, validate type and size)

### Phase 6: Dashboard + Completeness
**Rationale:** Dashboard aggregates data from all features and must be built last. Denormalized summary document pattern (updated by Cloud Functions) is required to avoid unbounded query costs.
**Delivers:** Revenue/outstanding/overdue dashboard, service catalog, year-to-date summary
**Addresses:** Dashboard table stake, service catalog differentiator
**Avoids:** C5 (unbounded query performance), M6 (Firestore read cost explosion)

### Phase Ordering Rationale

- Auth and security rules cannot be added after data is written — data model changes would be needed
- i18n ARB files added retroactively means touching every widget file; set up in Phase 1
- Profile and clients are hard blocking dependencies for invoice creation — no workaround
- Tax calculations depend on paid invoice totals by period — invoices must exist first
- Dashboard must be last because it aggregates across all features; denormalized counters need all other writes in place
- Expenses are genuinely independent and can flex in schedule without blocking other phases

### Research Flags

Phases needing deeper research or explicit rate verification during planning:

- **Phase 4 (Tax Declarations):** Morocco-specific IR and CNSS rates, CNSS plancher, revenue ceilings per activity type, and filing deadlines must be verified against current DGI Finance Law and CNSS circulars before the phase begins. Training-time knowledge may be outdated after annual Finance Law changes.
- **Phase 3 (PDF on Web):** Verify current `pdf` and `printing` package web download behavior — the blob URL / `dart:html` approach should be prototyped at phase start, not assumed.

Phases with well-documented patterns (research-phase likely unnecessary):

- **Phase 1 (Foundation):** Firebase + Flutter setup, go_router auth guards, and ARB i18n are thoroughly documented in official Flutter and Firebase docs.
- **Phase 2 (Profile + Clients):** Standard Firestore CRUD + Storage upload patterns; Syncfusion signaturepad is well-documented.
- **Phase 5 (Expenses):** Image capture, compression, and upload to Firebase Storage is a standard pattern.
- **Phase 6 (Dashboard):** Firestore denormalized counters and `fl_chart` integration are well-documented.

---

## Confidence Assessment

| Area | Confidence | Notes |
|------|------------|-------|
| Stack | HIGH | All packages verified on pub.dev; official Flutter and Firebase documentation consulted; web compatibility matrix verified |
| Features | HIGH (general) / MEDIUM (tax rates) | Table stakes and anti-features are high-confidence; Morocco-specific tax rates require official-source verification before implementation |
| Architecture | HIGH | MVVM + Repository is the official Flutter recommendation; Firestore subcollection pattern is standard; tax calculation architecture is well-reasoned |
| Pitfalls | HIGH | All critical pitfalls are drawn from known failure patterns in Flutter + Firebase invoicing apps; Morocco-specific pitfalls (sequential numbering, TVA exemption) are regime-specific and well-founded |

**Overall confidence:** HIGH — with the explicit caveat that Morocco tax rates (IR, CNSS, revenue ceilings, filing deadlines) must be verified against current official sources (tax.gov.ma, cnss.ma, Journal Officiel) before Phase 4 begins.

### Gaps to Address

- **Morocco IR flat rates per activity type (2025/2026):** Verify against current Finance Law before writing any calculation code. Rates in research are training-knowledge and may have changed.
- **CNSS contribution rates and quarterly plancher:** Verify at cnss.ma. The plancher (minimum base) must be included in implementation — many tools omit it.
- **Revenue ceilings per activity type:** Ceilings have changed historically. Verify current amounts at DGI before implementing ceiling alerts.
- **PDF web download implementation:** Test `Printing.layoutPdf()` vs. `dart:html` blob URL approach in a spike at the start of Phase 3. Do not assume behavior from documentation alone.
- **Flutter web rendering (CanvasKit vs. HTML renderer):** Validate signature capture behavior on both renderers — CanvasKit may produce better fidelity but affects load time.

---

## Sources

### Primary (HIGH confidence)
- flutter.dev/app-architecture (Compass case study) — MVVM + Repository pattern, official Flutter recommendation
- pub.dev — Package versions, compatibility, and web support matrix
- Firebase documentation — Firestore security rules, subcollection patterns, offline persistence, Storage CORS
- Syncfusion documentation — SfSignaturePad web and mobile compatibility

### Secondary (MEDIUM confidence)
- Community consensus on Riverpod vs. BLoC vs. Provider (Provider maintenance-mode deprecation widely reported)
- go_router as Flutter-team navigation standard (widely confirmed in Flutter community)
- Morocco auto-entrepreneur regime feature requirements — inferred from DGI/CNSS documentation and AE regime rules

### Tertiary (LOW confidence — requires verification)
- Morocco IR flat rates: 1% (Commercial/Artisanal), 2% (Liberal) — training knowledge, must verify against current Finance Law
- CNSS contribution rate ~6.37% — training knowledge, must verify at cnss.ma
- Revenue ceilings: MAD 500,000 (Commercial/Artisanal), MAD 200,000 (Liberal) — training knowledge, verify at DGI
- DAMANCOM portal as official AE filing portal — verify still current at damancom.ma

---
*Research completed: 2026-04-09*
*Ready for roadmap: yes*
