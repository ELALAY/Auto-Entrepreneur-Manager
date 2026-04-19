# Roadmap: Auto-Entrepreneur Manager (Morocco)

## Overview

Starting from the existing Flutter skeleton (routing, models, i18n scaffold, screens stubbed), this roadmap wires in Firebase and delivers a complete invoicing and tax compliance tool for Moroccan auto-entrepreneurs in six phases. Each phase completes one coherent capability before the next begins — auth gates profile, profile gates invoices, invoices gate declarations, and the dashboard aggregates everything that came before.

## Phases

**Phase Numbering:**
- Integer phases (1, 2, 3): Planned milestone work
- Decimal phases (2.1, 2.2): Urgent insertions (marked with INSERTED)

Decimal phases appear between their surrounding integers in numeric order.

- [ ] **Phase 1: Firebase + Auth** - Wire Firebase to the skeleton and deliver a fully working auth flow with route guards and security rules
- [ ] **Phase 2: Profile + Clients** - Give users a business identity (legal fields, logo, signature) and a client directory so invoices can be created
- [ ] **Phase 3: Invoices + PDF + Payments** - Deliver the core product: invoice creation with legal Moroccan fields, cross-platform PDF export, and payment recording
- [ ] **Phase 4: Expenses** - Add expense logging so the user's full financial picture is captured before tax declarations are calculated
- [ ] **Phase 5: Tax Declarations** - Calculate quarterly IR and CNSS obligations from real revenue data and guide the user through the filing process
- [ ] **Phase 6: Dashboard** - Aggregate all data into a single at-a-glance view of revenue, outstanding invoices, and upcoming deadlines

## Phase Details

### Phase 1: Firebase + Auth

**Goal**: Users can create an account, sign in (email/password and Google), and the app correctly guards all routes — unauthenticated users never reach feature screens.

**Depends on**: Nothing (skeleton exists; this phase wires Firebase)

**Requirements**: AUTH-01, AUTH-02, AUTH-03, AUTH-04, AUTH-05

**Success Criteria** (what must be TRUE):
1. User can register with email and password and immediately access the app
2. User can sign in with a Google account on Android, iOS, and web
3. Closing and reopening the app does not require the user to sign in again (session persists)
4. Navigating to any protected route without being signed in redirects to the login screen — no feature screen is accessible unauthenticated
5. Firestore security rules pass emulator tests: own data readable/writable, cross-tenant data inaccessible, unauthenticated requests rejected

**Plans**: TBD

Plans:
- [ ] 01-01: Firebase project wiring — `firebase_options.dart`, Firestore offline persistence, Storage CORS, Hosting rewrite config
- [ ] 01-02: Auth screens and Firebase Auth integration — register, sign in (email + Google), session persistence, go_router auth redirect guard
- [ ] 01-03: Firestore security rules + emulator tests — `/users/{uid}/` subcollection pattern, cross-tenant and unauthenticated rule tests

---

### Phase 2: Profile + Clients

**Goal**: Users can complete their business profile with all Moroccan legal identifier fields and manage a client directory — both prerequisites that must exist before any invoice can be created.

**Depends on**: Phase 1

**Requirements**: PROF-01, PROF-02, PROF-03, PROF-04, PROF-05, PROF-06, PROF-07, CLIE-01, CLIE-02, CLIE-03, CLIE-04

**Success Criteria** (what must be TRUE):
1. User can fill in their business profile (name, CIN, ICE, IF, CNSS number, activity category, address) and the data persists across sessions
2. User is blocked from creating an invoice if their profile is incomplete — a prompt directs them to finish setup first
3. User can upload a logo image and set a branding color, both of which appear on subsequent invoice previews
4. User can draw or upload a signature that is saved to Firebase Storage and persists to their profile
5. User can create, edit, and delete clients with ICE/IF fields, and view the list of all their clients

**Plans**: TBD

Plans:
- [ ] 02-01: Profile setup screen and Firestore persistence — all legal fields, activity category selector with explainer, PROF-01, PROF-02
- [ ] 02-02: Logo upload, branding color picker, Storage integration — PROF-03, PROF-04
- [ ] 02-03: Signature capture (SfSignaturePad draw + image upload alternative) — test all 3 platforms — PROF-05, PROF-06, PROF-07
- [ ] 02-04: Clients CRUD — list, create, edit, delete screens with ICE/IF fields — CLIE-01, CLIE-02, CLIE-03
- [ ] 02-05: Client detail screen showing linked invoices — CLIE-04

---

### Phase 3: Invoices + PDF + Payments

**Goal**: Users can create legally compliant invoices with sequential numbering, export them as a branded PDF on any platform, record payments, and track outstanding balances.

**Depends on**: Phase 2

**Requirements**: INVC-01, INVC-02, INVC-03, INVC-04, INVC-05, INVC-06, INVC-07, INVC-08, INVC-09, INVC-10, PAYM-01, PAYM-02, PAYM-03

**Success Criteria** (what must be TRUE):
1. User can create an invoice linked to a client, add line items manually, and the invoice is assigned a unique sequential number via a Firestore transaction — no duplicates possible
2. Invoice displays all legally required Moroccan fields: seller ICE, IF, CNSS, sequential number, date, client name, address, and ICE/IF
3. User can export the invoice as a PDF that includes their logo, branding color, and signature (if toggled on) — PDF renders correctly with French accented characters on Android, iOS, and web
4. User can update invoice status (draft, sent, paid, overdue) and view all invoices in a list with status badges
5. User can record one or more payments against an invoice; the invoice detail shows the remaining balance (total minus payments) and the invoice list flags overdue and partially paid invoices

**Plans**: TBD

Plans:
- [ ] 03-01: PDF spike — validate cross-platform PDF generation with bundled TTF fonts, French accented characters, and web download behavior before building any invoice UI — INVC-07, INVC-08
- [ ] 03-02: Invoice creation — client picker, manual line items, subtotal/total computation, Firestore transaction for sequential numbering — INVC-01, INVC-02, INVC-03, INVC-04
- [ ] 03-03: Invoice legal fields, status workflow, and invoice list screen — INVC-05, INVC-06, INVC-09, INVC-10
- [ ] 03-04: PDF generation integrated with branding, logo, and signature — INVC-07, INVC-08
- [ ] 03-05: Payment recording and balance display — PAYM-01, PAYM-02, PAYM-03

---

### Phase 4: Expenses

**Goal**: Users can log and review their business expenses by period, giving them the full income-minus-expenses picture before tax declarations are generated.

**Depends on**: Phase 2 (auth + Storage infrastructure)

**Requirements**: EXPN-01, EXPN-02, EXPN-03

**Success Criteria** (what must be TRUE):
1. User can log an expense with amount, date, category, and description — the entry persists and appears in the expense list
2. User can filter their expense list by quarter or month to review spending for any period
3. User can edit or delete any expense they have recorded

**Plans**: TBD

Plans:
- [ ] 04-01: Expense CRUD — create, edit, delete screens with category picker and period filter — EXPN-01, EXPN-02, EXPN-03

---

### Phase 5: Tax Declarations

**Goal**: Users can generate a quarterly tax declaration with calculated IR and CNSS amounts sourced from a versioned Firestore rate config, view a step-by-step filing guide, and maintain a history of all past declarations.

**Depends on**: Phase 3 (invoice revenue totals queryable by period)

**Requirements**: DECL-01, DECL-02, DECL-03, DECL-04, DECL-05, DECL-06, DECL-07, DECL-08

**Success Criteria** (what must be TRUE):
1. During onboarding, user selects their activity category (commercial, artisanal, or liberal) with a plain-language explanation of each — the selection is saved to their profile
2. For any completed quarter, the app calculates and displays the IR amount due and the CNSS contribution (including the minimum quarterly base) using rates loaded from a Firestore config document — not hardcoded values — with a disclaimer to verify with DGI/CNSS
3. User can create a quarterly declaration record that links to the calculated amounts and view a step-by-step guide for filing on the ae.gov.ma portal
4. User can mark a declaration as filed (recording the date) and view the full history of past declarations with amounts and status

**Plans**: TBD

Plans:
- [ ] 05-01: Tax rate config — populate `/config/taxRates` Firestore document with verified rates (IR by activity type, CNSS rate + plancher), write pure Dart `TaxCalculator` with unit tests — DECL-02, DECL-03, DECL-04
- [ ] 05-02: Activity category onboarding selector and declaration creation flow — DECL-01, DECL-05, DECL-06
- [ ] 05-03: Filing guide UX, mark-as-filed action, and declaration history screen — DECL-07, DECL-08

---

### Phase 6: Dashboard

**Goal**: Users see a single screen that summarizes their revenue, flags outstanding and overdue invoices, shows the next declaration deadline, and alerts them when they are approaching their annual revenue ceiling.

**Depends on**: Phases 3 and 5 (revenue and declaration data must exist)

**Requirements**: DASH-01, DASH-02, DASH-03, DASH-04, DASH-05

**Success Criteria** (what must be TRUE):
1. Dashboard shows current quarter revenue total and year-to-date revenue, drawn from paid invoices — figures update when new payments are recorded
2. Dashboard shows the number of days until the next quarterly declaration deadline
3. Dashboard shows total outstanding invoice amount and a count of overdue invoices
4. When a user's year-to-date revenue exceeds 80% of their annual ceiling (by activity type), the dashboard displays a revenue ceiling alert
5. Dashboard shows the top clients by revenue generated (highest turnover first)

**Plans**: TBD

Plans:
- [ ] 06-01: Denormalized summary document design and Cloud Function (or client-side trigger) to maintain revenue and invoice counters — DASH-01, DASH-03
- [ ] 06-02: Dashboard screen — revenue summary, deadline countdown, outstanding invoices, ceiling alert, top clients — DASH-01, DASH-02, DASH-03, DASH-04, DASH-05

---

## Progress

**Execution Order:**
Phases execute in numeric order: 1 → 2 → 3 → 4 → 5 → 6

| Phase | Plans Complete | Status | Completed |
|-------|----------------|--------|-----------|
| 1. Firebase + Auth | 0/3 | Not started | - |
| 2. Profile + Clients | 0/5 | Not started | - |
| 3. Invoices + PDF + Payments | 0/5 | Not started | - |
| 4. Expenses | 0/1 | Not started | - |
| 5. Tax Declarations | 0/3 | Not started | - |
| 6. Dashboard | 0/2 | Not started | - |
