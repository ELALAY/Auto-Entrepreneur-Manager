# Requirements: Auto-Entrepreneur Manager (Morocco)

**Defined:** 2026-04-09
**Core Value:** A Moroccan auto-entrepreneur can complete their quarterly tax declaration confidently, knowing exactly what they owe and how to file it, based on their real tracked revenue.

---

## v1 Requirements

### Authentication (AUTH)

- [ ] **AUTH-01**: User can sign up with email and password
- [ ] **AUTH-02**: User can sign in with email and password
- [ ] **AUTH-03**: User can sign in with Google (Android, iOS, Web)
- [ ] **AUTH-04**: User session persists across app restarts
- [ ] **AUTH-05**: Unauthenticated users are redirected to login screen

### Profile (PROF)

- [ ] **PROF-01**: User can set up business profile (name, CIN, ICE, IF, CNSS number, activity category, address)
- [ ] **PROF-02**: User is prompted to complete profile before creating first invoice
- [ ] **PROF-03**: User can upload a logo image for invoice branding
- [ ] **PROF-04**: User can choose invoice template color
- [ ] **PROF-05**: User can draw their signature on a canvas (mobile and web)
- [ ] **PROF-06**: User can upload a signature image as an alternative to drawing
- [ ] **PROF-07**: Signature is saved to profile and persisted (Firebase Storage)

### Clients (CLIE)

- [ ] **CLIE-01**: User can create a client (name, address, ICE, IF, email, phone)
- [ ] **CLIE-02**: User can edit and delete a client
- [ ] **CLIE-03**: User can view a list of all their clients
- [ ] **CLIE-04**: User can view all invoices linked to a specific client

### Invoices (INVC)

- [ ] **INVC-01**: User can create an invoice linked to a client
- [ ] **INVC-02**: Invoice is assigned a sequential, gapless number (server-side Firestore transaction — no client-side generation)
- [ ] **INVC-03**: User can add line items manually (description, quantity, unit price)
- [ ] **INVC-04**: Invoice displays computed subtotal and total
- [ ] **INVC-05**: Invoice includes all legally required Moroccan fields (seller ICE, IF, CNSS, sequential number, date, client name/address/ICE/IF)
- [ ] **INVC-06**: User can apply their saved signature to an invoice (toggle on/off)
- [ ] **INVC-07**: User can export invoice as a PDF with their logo, branding colors, and signature
- [ ] **INVC-08**: PDF renders correctly on Android, iOS, and Web (including French accented characters)
- [ ] **INVC-09**: User can set invoice status (draft, sent, paid, overdue)
- [ ] **INVC-10**: User can view a list of all invoices with status badges

### Payments (PAYM)

- [ ] **PAYM-01**: User can record a payment against an invoice (date, amount, method: cash/virement/chèque/autre)
- [ ] **PAYM-02**: App shows which invoices have outstanding or overdue balances
- [ ] **PAYM-03**: Invoice balance (total minus recorded payments) is shown on invoice detail

### Expenses (EXPN)

- [ ] **EXPN-01**: User can log an expense (amount, date, category, description)
- [ ] **EXPN-02**: User can view expenses filtered by quarter or month
- [ ] **EXPN-03**: User can edit and delete an expense

### Tax Declarations (DECL)

- [ ] **DECL-01**: During onboarding, user selects their activity category (commercial, artisanal, liberal) with an explanation of each
- [ ] **DECL-02**: App calculates IR amount due for a quarter based on revenue and activity category
- [ ] **DECL-03**: App calculates CNSS contribution due for a quarter (including plancher minimum base)
- [ ] **DECL-04**: Tax rates are stored in a versioned Firestore config document — not hardcoded in Dart
- [ ] **DECL-05**: Tax calculation results display a disclaimer directing user to verify with DGI/CNSS
- [ ] **DECL-06**: User can create a quarterly declaration record (links to calculated amounts)
- [ ] **DECL-07**: User can mark a declaration as filed and record the date
- [ ] **DECL-08**: User can view declaration history (all past quarters with amounts and status)

### Dashboard (DASH)

- [ ] **DASH-01**: Dashboard shows revenue summary (current quarter total + year-to-date)
- [ ] **DASH-02**: Dashboard shows next quarterly declaration deadline with days remaining
- [ ] **DASH-03**: Dashboard shows total outstanding invoice amount and count of overdue invoices
- [ ] **DASH-04**: Dashboard shows revenue ceiling alert when user is within 20% of their annual limit
- [ ] **DASH-05**: Dashboard shows top clients by revenue (highest turnover)

---

## v2 Requirements

### Invoices (deferred)

- **INVC-V2-01**: User can pick line items from service/product catalog when building an invoice
- **INVC-V2-02**: User can send invoice as PDF attachment via email directly from the app

### Expenses (deferred)

- **EXPN-V2-01**: User can attach a receipt photo to an expense (Firebase Storage)

### Tax Declarations (deferred)

- **DECL-V2-01**: Step-by-step DAMANCOM portal filing guide walks user through each screen
- **DECL-V2-02**: In-app push notification reminder before quarterly deadline

### Service Catalog (deferred)

- **SERV-V2-01**: User can define reusable services/products (name, description, unit price, unit type)
- **SERV-V2-02**: User can pick from catalog when adding invoice line items

### Reports (deferred)

- **REPT-V2-01**: User can export annual income/expense summary as PDF

---

## Out of Scope

| Feature | Reason |
|---------|--------|
| Arabic / RTL interface | Significant Flutter RTL complexity; French covers professional target audience |
| In-app subscription payments | Free for v1; validate product before monetizing |
| Direct DAMANCOM portal API submission | No official Moroccan government API exists |
| TVA (VAT) fields anywhere in the app | Auto-entrepreneurs are legally TVA-exempt — do not surface TVA |
| Multi-user / accountant access | Auto-entrepreneurs are sole traders by legal definition |
| Bank import / reconciliation | No Moroccan bank API equivalent; high complexity, low payoff |
| Recurring invoices | Complex state machine; not needed at auto-entrepreneur scale |
| Double-entry bookkeeping | Far beyond auto-entrepreneur needs |
| Quotes / estimates | Separate workflow; v2+ if requested |
| Multiple business entities per account | AE is one person, one regime by law |

---

## Traceability

*Updated 2026-04-09 after roadmap creation.*

| Requirement | Phase | Status |
|-------------|-------|--------|
| AUTH-01 | Phase 1 — Firebase + Auth | Pending |
| AUTH-02 | Phase 1 — Firebase + Auth | Pending |
| AUTH-03 | Phase 1 — Firebase + Auth | Pending |
| AUTH-04 | Phase 1 — Firebase + Auth | Pending |
| AUTH-05 | Phase 1 — Firebase + Auth | Pending |
| PROF-01 | Phase 2 — Profile + Clients | Pending |
| PROF-02 | Phase 2 — Profile + Clients | Pending |
| PROF-03 | Phase 2 — Profile + Clients | Pending |
| PROF-04 | Phase 2 — Profile + Clients | Pending |
| PROF-05 | Phase 2 — Profile + Clients | Pending |
| PROF-06 | Phase 2 — Profile + Clients | Pending |
| PROF-07 | Phase 2 — Profile + Clients | Pending |
| CLIE-01 | Phase 2 — Profile + Clients | Pending |
| CLIE-02 | Phase 2 — Profile + Clients | Pending |
| CLIE-03 | Phase 2 — Profile + Clients | Pending |
| CLIE-04 | Phase 2 — Profile + Clients | Pending |
| INVC-01 | Phase 3 — Invoices + PDF + Payments | Pending |
| INVC-02 | Phase 3 — Invoices + PDF + Payments | Pending |
| INVC-03 | Phase 3 — Invoices + PDF + Payments | Pending |
| INVC-04 | Phase 3 — Invoices + PDF + Payments | Pending |
| INVC-05 | Phase 3 — Invoices + PDF + Payments | Pending |
| INVC-06 | Phase 3 — Invoices + PDF + Payments | Pending |
| INVC-07 | Phase 3 — Invoices + PDF + Payments | Pending |
| INVC-08 | Phase 3 — Invoices + PDF + Payments | Pending |
| INVC-09 | Phase 3 — Invoices + PDF + Payments | Pending |
| INVC-10 | Phase 3 — Invoices + PDF + Payments | Pending |
| PAYM-01 | Phase 3 — Invoices + PDF + Payments | Pending |
| PAYM-02 | Phase 3 — Invoices + PDF + Payments | Pending |
| PAYM-03 | Phase 3 — Invoices + PDF + Payments | Pending |
| EXPN-01 | Phase 4 — Expenses | Pending |
| EXPN-02 | Phase 4 — Expenses | Pending |
| EXPN-03 | Phase 4 — Expenses | Pending |
| DECL-01 | Phase 5 — Tax Declarations | Pending |
| DECL-02 | Phase 5 — Tax Declarations | Pending |
| DECL-03 | Phase 5 — Tax Declarations | Pending |
| DECL-04 | Phase 5 — Tax Declarations | Pending |
| DECL-05 | Phase 5 — Tax Declarations | Pending |
| DECL-06 | Phase 5 — Tax Declarations | Pending |
| DECL-07 | Phase 5 — Tax Declarations | Pending |
| DECL-08 | Phase 5 — Tax Declarations | Pending |
| DASH-01 | Phase 6 — Dashboard | Pending |
| DASH-02 | Phase 6 — Dashboard | Pending |
| DASH-03 | Phase 6 — Dashboard | Pending |
| DASH-04 | Phase 6 — Dashboard | Pending |
| DASH-05 | Phase 6 — Dashboard | Pending |

**Coverage:**
- v1 requirements: 45 total (AUTH: 5, PROF: 7, CLIE: 4, INVC: 10, PAYM: 3, EXPN: 3, DECL: 8, DASH: 5)
- Mapped to phases: 45
- Unmapped: 0 ✓

---
*Requirements defined: 2026-04-09*
*Last updated: 2026-04-09 after roadmap creation — full per-requirement traceability populated*
