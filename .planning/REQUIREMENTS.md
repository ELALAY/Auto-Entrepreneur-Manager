# Requirements: Auto-Entrepreneur Manager (Morocco)

**Defined:** 2026-04-09
**Status synced:** 2026-11-17 — checked against the app. Phases 1–5 are implemented, including expenses. Phase 6 is missing the revenue-ceiling alert and top clients. CNSS is a flat amount from quarterly IR.
**Core Value:** A Moroccan auto-entrepreneur can complete their quarterly tax declaration confidently, knowing exactly what they owe and how to file it, based on their real tracked revenue.

---

## v1 Requirements

Requirements marked complete reflect the documented shipped state. Existing V2 identifiers are retained for traceability where catalog selection, filing guidance, and receipt attachments have moved into v1 scope. Profiles support multiple activities; catalog items and invoices carry an activity category.

### Authentication (AUTH)

- [x] **AUTH-01**: User can sign up with email and password
- [x] **AUTH-02**: User can sign in with email and password
- [x] **AUTH-03**: User can sign in with Google (Android, iOS, Web)
- [x] **AUTH-04**: User session persists across app restarts
- [x] **AUTH-05**: Unauthenticated users are redirected to login screen

### Profile (PROF)

- [x] **PROF-01**: User can set up business profile (name, CIN, ICE, IF, CNSS number, activity categories, address)
- [x] **PROF-02**: User is prompted to complete profile before creating first invoice
- [x] **PROF-03**: User can upload a logo image for invoice branding
- [x] **PROF-04**: User can choose invoice template color
- [x] **PROF-05**: User can draw their signature on a canvas (mobile and web)
- [x] **PROF-06**: User can upload a signature image as an alternative to drawing
- [x] **PROF-07**: Signature is saved to profile and persisted (Firebase Storage)

### Clients (CLIE)

- [x] **CLIE-01**: User can create a client (name, address, ICE, IF, email, phone)
- [x] **CLIE-02**: User can edit and delete a client
- [x] **CLIE-03**: User can view a list of all their clients
- [x] **CLIE-04**: User can view all invoices linked to a specific client

### Invoices (INVC)

- [x] **INVC-01**: User can create an invoice linked to a client
- [x] **INVC-02**: Invoice is assigned a sequential, gapless number (server-side Firestore transaction — no client-side generation)
- [x] **INVC-03**: User can add line items manually (description, quantity, unit price)
- [x] **INVC-04**: Invoice displays computed subtotal and total
- [x] **INVC-05**: Invoice includes all legally required Moroccan fields (seller ICE, IF, CNSS, sequential number, date, client name/address/ICE/IF)
- [x] **INVC-06**: User can apply their saved signature to an invoice (toggle on/off)
- [x] **INVC-07**: User can export invoice as a PDF with their logo, branding colors, and signature
- [x] **INVC-08**: PDF renders correctly on Android, iOS, and Web (including French accented characters)
- [x] **INVC-09**: User can set invoice status (draft, sent, paid, overdue)
- [x] **INVC-10**: User can view a list of all invoices with status badges
- [x] **INVC-V2-01**: User can pick line items from service/product catalog when building an invoice

### Service/Product Catalog (SERV)

- [x] **SERV-V2-01**: User can define reusable services/products (name, description, unit price, unit type: hour/day/forfait/unit), each with a tax activity category
- [x] **SERV-V2-02**: User can pick from catalog when adding invoice line items

### Payments (PAYM)

- [x] **PAYM-01**: User can record a payment against an invoice (date, amount, method: cash/virement/chèque/autre)
- [x] **PAYM-02**: App shows which invoices have outstanding or overdue balances
- [x] **PAYM-03**: Invoice balance (total minus recorded payments) is shown on invoice detail

### Expenses (EXPN)

- [x] **EXPN-01**: User can log an expense (amount, date, category, description)
- [x] **EXPN-02**: User can view expenses filtered by quarter or month
- [x] **EXPN-03**: User can edit and delete an expense
- [x] **EXPN-V2-01**: User can optionally attach a receipt image to an expense (Firebase Storage)

### Tax Declarations (DECL)

- [x] **DECL-01**: During onboarding, user selects their activity categories (commercial, artisanal, liberal, services) with an explanation of each
- [x] **DECL-02**: App calculates IR amount due for a quarter based on quarterly paid revenue, bucketed by activity category
- [x] **DECL-03**: App calculates CNSS as the flat quarterly amount for the quarter's total IR (300–3,600 MAD). Zero IR still selects the 300 MAD band. `hasCnss` on the profile zeroes the contribution
- [x] **DECL-04**: Tax rates load from versioned Firestore `config/taxRates` (`cnssIrBands`). A missing or old revenue-cap document falls back to bundled version-4 defaults
- [x] **DECL-05**: Tax calculation results display a disclaimer directing user to verify with DGI/CNSS
- [x] **DECL-06**: User can create a quarterly declaration record (links to calculated amounts)
- [x] **DECL-07**: User can mark a declaration as filed and record the date
- [x] **DECL-08**: User can view declaration history (all past quarters with amounts and status)
- [x] **DECL-V2-01**: User gets a step-by-step quarterly portal filing guide

### Dashboard (DASH)

- [x] **DASH-01**: Dashboard shows revenue summary (current quarter paid revenue + year-to-date paid revenue)
- [x] **DASH-02**: Dashboard shows next quarterly declaration deadline with days remaining
- [x] **DASH-03**: Dashboard shows total outstanding invoice amount and count of overdue invoices
- [x] **DASH-06**: Dashboard shows this quarter's estimated declaration (income tax + CNSS), using the same calculator as the declaration screen
- [x] **DASH-07**: Dashboard shows expenses dated in the current quarter, next to quarter revenue
- [ ] **DASH-04**: Dashboard shows revenue ceiling alert when user is within 20% of their annual limit
- [ ] **DASH-05**: Dashboard shows top clients by revenue (highest turnover)

---

## v2 Requirements

### Invoices (deferred)

- **INVC-V2-02**: User can send invoice as PDF attachment via email directly from the app

### Tax Declarations (deferred)

- **DECL-V2-02**: In-app push notification reminder before quarterly deadline

### Reports (deferred)

- **REPT-V2-01**: User can export annual income/expense summary as PDF

---

## Out of Scope

| Feature | Reason |
|---------|--------|
| Arabic / RTL interface | Significant Flutter RTL complexity; French covers professional target audience |
| In-app subscription payments | Free for v1; validate product before monetizing |
| Direct ae.gov.ma portal API submission | No official Moroccan government API exists |
| TVA (VAT) fields anywhere in the app | Auto-entrepreneurs are legally TVA-exempt — do not surface TVA |
| Multi-user / accountant access | Auto-entrepreneurs are sole traders by legal definition |
| Bank import / reconciliation | No Moroccan bank API equivalent; high complexity, low payoff |
| Recurring invoices | Complex state machine; not needed at auto-entrepreneur scale |
| Accounting integrations (Xero/QuickBooks) | Not needed for auto-entrepreneur scale |
| Double-entry bookkeeping | Far beyond auto-entrepreneur needs |
| Quotes / estimates | Separate workflow; v2+ if requested |
| Multiple business entities per account | AE is one person, one regime by law |

---

## Traceability

*Synced 2026-11-17 with the codebase. Pending: DASH-04 and DASH-05. Dashboard denormalized summaries remain an optional optimization (`06-01`).*

| Requirement | Phase | Status |
|-------------|-------|--------|
| AUTH-01 | Phase 1 — Firebase + Auth | Complete |
| AUTH-02 | Phase 1 — Firebase + Auth | Complete |
| AUTH-03 | Phase 1 — Firebase + Auth | Complete |
| AUTH-04 | Phase 1 — Firebase + Auth | Complete |
| AUTH-05 | Phase 1 — Firebase + Auth | Complete |
| PROF-01 | Phase 2 — Profile + Clients | Complete |
| PROF-02 | Phase 2 — Profile + Clients | Complete |
| PROF-03 | Phase 2 — Profile + Clients | Complete |
| PROF-04 | Phase 2 — Profile + Clients | Complete |
| PROF-05 | Phase 2 — Profile + Clients | Complete |
| PROF-06 | Phase 2 — Profile + Clients | Complete |
| PROF-07 | Phase 2 — Profile + Clients | Complete |
| CLIE-01 | Phase 2 — Profile + Clients | Complete |
| CLIE-02 | Phase 2 — Profile + Clients | Complete |
| CLIE-03 | Phase 2 — Profile + Clients | Complete |
| CLIE-04 | Phase 2 — Profile + Clients | Complete |
| INVC-01 | Phase 3 — Invoices + PDF + Payments | Complete |
| INVC-02 | Phase 3 — Invoices + PDF + Payments | Complete |
| INVC-03 | Phase 3 — Invoices + PDF + Payments | Complete |
| INVC-04 | Phase 3 — Invoices + PDF + Payments | Complete |
| INVC-05 | Phase 3 — Invoices + PDF + Payments | Complete |
| INVC-06 | Phase 3 — Invoices + PDF + Payments | Complete |
| INVC-07 | Phase 3 — Invoices + PDF + Payments | Complete |
| INVC-08 | Phase 3 — Invoices + PDF + Payments | Complete |
| INVC-09 | Phase 3 — Invoices + PDF + Payments | Complete |
| INVC-10 | Phase 3 — Invoices + PDF + Payments | Complete |
| PAYM-01 | Phase 3 — Invoices + PDF + Payments | Complete |
| PAYM-02 | Phase 3 — Invoices + PDF + Payments | Complete |
| PAYM-03 | Phase 3 — Invoices + PDF + Payments | Complete |
| EXPN-01 | Phase 4 — Expenses | Complete |
| EXPN-02 | Phase 4 — Expenses | Complete |
| EXPN-03 | Phase 4 — Expenses | Complete |
| DECL-01 | Phase 5 — Tax Declarations | Complete |
| DECL-02 | Phase 5 — Tax Declarations | Complete |
| DECL-03 | Phase 5 — Tax Declarations | Complete |
| DECL-04 | Phase 5 — Tax Declarations | Complete |
| DECL-05 | Phase 5 — Tax Declarations | Complete |
| DECL-06 | Phase 5 — Tax Declarations | Complete |
| DECL-07 | Phase 5 — Tax Declarations | Complete |
| DECL-08 | Phase 5 — Tax Declarations | Complete |
| DASH-01 | Phase 6 — Dashboard | Complete |
| DASH-02 | Phase 6 — Dashboard | Complete |
| DASH-03 | Phase 6 — Dashboard | Complete |
| DASH-06 | Phase 6 — Dashboard | Complete |
| DASH-07 | Phase 6 — Dashboard | Complete |
| DASH-04 | Phase 6 — Dashboard | Pending |
| DASH-05 | Phase 6 — Dashboard | Pending |
| INVC-V2-01 | Phase 3 — Invoices + PDF + Payments | Complete |
| SERV-V2-01 | Phase 3 — Catalog support for invoices | Complete |
| SERV-V2-02 | Phase 3 — Catalog support for invoices | Complete |
| EXPN-V2-01 | Phase 4 — Expenses | Complete |
| DECL-V2-01 | Phase 5 — Tax Declarations | Complete |

**Coverage:**
- v1 requirements: 52 total (AUTH: 5, PROF: 7, CLIE: 4, INVC: 11, SERV: 2, PAYM: 3, EXPN: 4, DECL: 9, DASH: 7)
- Documented complete: 50; pending: 2 (DASH-04, DASH-05)
- Mapped to phases: 50
- Unmapped: 0 ✓

---
*Requirements defined: 2026-04-09*
*Last updated: 2026-11-17 — DASH-06 and DASH-07 added for the quarter expense total and the estimated IR+CNSS card*
