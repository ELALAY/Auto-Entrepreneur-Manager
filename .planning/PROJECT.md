# Auto-Entrepreneur Manager (Morocco)

## What This Is

A cross-platform Flutter app (Android, iOS, Web) that helps Moroccan auto-entrepreneurs run their freelance business and stay tax-compliant. Users can manage clients, create branded invoices, track income and expenses, and get step-by-step quarterly filing guidance with calculated IR and CNSS amounts. Built as a multi-tenant SaaS — anyone can sign up and use it.

## Core Value

A Moroccan auto-entrepreneur can complete their quarterly tax declaration confidently, knowing exactly what they owe and how to file it, based on their real tracked revenue.

## Requirements

### Validated *(implemented in codebase; ship feedback still welcome)*

#### Authentication & Profile

- [x] User can sign up and log in (Firebase Auth)
- [x] User can set up their business profile (name, CIN, ICE, IF, CNSS number, activity categories, address)
- [x] User can upload a logo for invoice branding
- [x] User can save a signature (draw on screen and/or upload image)
- [x] User can choose invoice template colors/style

#### Clients

- [x] User can create and manage clients (name, address, ICE/IF, email, phone)
- [x] User can view all invoices linked to a client

#### Service/Product Catalog

- [x] User can define reusable services/products (name, description, unit price, unit type: hour/day/forfait/unit), each with a tax **activity category**
- [x] User can pick from catalog when building invoice line items

#### Invoices

- [x] User can create invoices linked to a client
- [x] User can add line items manually or from the service catalog
- [x] User can apply their saved signature to an invoice (toggle)
- [x] Invoice is auto-numbered and includes legally required fields
- [x] User can set invoice status (draft, sent, paid, overdue)
- [x] User can export invoice as PDF with chosen branding/template

#### Payments

- [x] User can record payments against an invoice (date, amount, method: cash/virement/cheque/autre)
- [x] App shows invoice balance = total − payments received
- [x] App shows which invoices are partially paid or overdue

#### Expenses

- [x] User can log expenses (amount, date, category, description)
- [x] User can attach a receipt image to an expense
- [x] User can view expenses filtered by month or quarter

#### Tax Declarations (Quarterly)

- [x] App explains activity categories and applicable rates (from config, with bundled defaults)
- [x] App calculates IR per activity on quarterly **paid** revenue, then a flat CNSS amount from that quarter's total IR
- [x] User gets a step-by-step filing guide each quarter
- [x] User can mark a declaration as filed and track status per quarter
- [x] App shows declaration history

#### Dashboard

- [x] User sees revenue summary (current quarter, year to date)
- [x] User sees this quarter's expenses next to quarter revenue
- [x] User sees this quarter's estimated declaration (IR + CNSS), calculated the same way as the declaration screen
- [x] User sees upcoming declaration deadline
- [x] User sees outstanding invoices and overdue amounts

### Active *(not yet implemented)*

#### Dashboard

- [ ] User sees a revenue-ceiling alert when year-to-date paid revenue is within 20% of the annual limit
- [ ] User sees top clients by paid revenue

### Out of Scope

- Arabic language — English + French only for v1, Arabic deferred
- In-app payments (charging users) — free for v1, monetization later
- Direct portal submission — app guides filing, user submits manually on official portals
- Accounting integrations (no Xero/QuickBooks sync) — not needed for auto-entrepreneur scale
- Multi-user / team access — one account per auto-entrepreneur

## Context

- **Legal regime**: Moroccan auto-entrepreneur (régime auto-entrepreneur) — flat contribution rates on revenue, declared and paid quarterly to CNSS + DGI
- **Activity types**: Commercial, artisanal, liberal, and services — each has an IR rate from config (bundled defaults: 0.5% for the first three, 1% for services)
- **CNSS**: Flat quarterly amount chosen from the quarter's IR, not a percentage of turnover. Bands: 125 → 300, 250 → 390, 625 → 570, 1,250 → 720, 2,500 → 1,050, 6,250 → 1,500, 12,500 → 2,250, above → 3,600 MAD. Already-affiliated profiles (`hasCnss`) owe 0.
- **Invoice legal requirements**: Morocco requires ICE, IF, CNSS number, sequential numbering, date, client details
- **Platform**: Flutter (Dart) — single codebase for Android, iOS, Web
- **Backend**: Firebase — Auth, Firestore (data), Storage (images, PDFs, receipts, signatures)
- **Languages**: English + French (i18n with flutter_localizations)
- **Users**: Multi-tenant SaaS — each user's data is isolated

## Data Models

| Model | Key Fields |
|-------|-----------|
| UserProfile | uid, legal fields, **activityCategories**, address, logo, signatureUrl, brandingConfig |
| Client | id, userId, name, address, ICE, IF, email, phone |
| CatalogItem | id, userId, name, description, unitPrice, unitType, **activityCategory**, kind |
| Invoice | id, userId, clientId, number, date, dueDate, status, **activityCategory**, lineItems, signatureEnabled, notes |
| InvoiceItem | serviceId (optional catalog id), description, qty, unitPrice, total |
| Payment | id, invoiceId, userId, date, amount, method |
| Expense | id, userId, date, amount, category (office/travel/telecom/rent/equipment/fees/marketing/other), description, receiptUrl |
| Declaration | id, userId, period (Q+year), revenue/tax amounts, status, filedDate |

## Constraints

- **Tech stack**: Flutter + Firebase — decided for v1
- **Localization**: English + French — flutter_localizations, no Arabic in v1
- **Monetization**: Free for v1 — no payment infrastructure needed yet
- **Platforms**: Android + iOS + Web — Flutter web must work, not just mobile

## Key Decisions

| Decision | Rationale | Outcome |
|----------|-----------|---------|
| Firebase over Supabase | Flutter SDK, managed scaling | **Adopted** |
| Flutter for all 3 platforms | Single codebase | **Adopted** |
| English + French only | Arabic adds RTL complexity for v1 | **Adopted** |
| Free for v1 | Validate before monetizing | **Adopted** |
| Manual filing (no portal API) | No official Moroccan API | **Adopted** |
| Tax rates in Firestore | Stay aligned with regulation changes | **Adopted** — version 4 `cnssIrBands`; bundled defaults if the document is missing or still uses revenue caps |
| CNSS from quarterly IR | Official AE scale is a flat amount on the quarter's IR, not on turnover | **Adopted** 2026-11-17 |
| Pin Glance 1.2.0 and Work 2.11.2 | `home_widget` 0.9.x open ranges pull APIs this AGP/SDK cannot compile | **Adopted** — `android/pin_glance.gradle` |

### Also shipped (outside the original phase list)

- Android home-screen widgets: new invoice, dashboard peek
- Android launcher shortcut: **New Invoice** (stable ID `New Invoice`) opens the invoice form after auth and prerequisite loading; no automatic save. Native cold/warm delivery and once-only consumption are implemented. Verified by 12 new tests, all 43 Flutter tests, clean relevant analysis, and an Android debug build. Device/OEM checks remain open; see [verification](verification/android-new-invoice-shortcut.md).
- On-device MCP experiment is parked in Git stash `edbb5cb` and removed from the working app
- Invoice list filters

---

*Last updated: 2026-11-17 — Android New Invoice launcher shortcut implemented and automatically verified; real-device checks remain open. Dashboard ceiling alert and top clients still open.*
