# Auto-Entrepreneur Manager (Morocco)

## What This Is

A cross-platform Flutter app (Android, iOS, Web) that helps Moroccan auto-entrepreneurs run their freelance business and stay tax-compliant. Users can manage clients, create branded invoices, track income *(expense tracking pending)*, and get step-by-step quarterly filing guidance with calculated IR and CNSS amounts. Built as a multi-tenant SaaS — anyone can sign up and use it.

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

#### Tax Declarations (Quarterly)

- [x] App explains activity categories and applicable rates (from config)
- [x] App calculates IR and CNSS amounts due based on quarterly **paid** revenue *(IR per activity; CNSS on total quarterly paid revenue in current implementation)*
- [x] User gets a step-by-step filing guide each quarter
- [x] User can mark a declaration as filed and track status per quarter
- [x] App shows declaration history

#### Dashboard

- [x] User sees revenue summary (current quarter, year to date)
- [x] User sees upcoming declaration deadline
- [x] User sees outstanding invoices and overdue amounts

### Active *(not yet implemented)*

#### Expenses

- [ ] User can log expenses (amount, date, category, description)
- [ ] User can attach a receipt image to an expense
- [ ] User can view expenses filtered by period

### Out of Scope

- Arabic language — English + French only for v1, Arabic deferred
- In-app payments (charging users) — free for v1, monetization later
- Direct portal submission — app guides filing, user submits manually on official portals
- Accounting integrations (no Xero/QuickBooks sync) — not needed for auto-entrepreneur scale
- Multi-user / team access — one account per auto-entrepreneur

## Context

- **Legal regime**: Moroccan auto-entrepreneur (régime auto-entrepreneur) — flat contribution rates on revenue, declared and paid quarterly to CNSS + DGI
- **Activity types**: Commercial, Artisanal, Liberal — app explains each and applies correct IR rates from config
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
| Expense | id, userId, date, amount, category, description, receiptUrl *(schema TBD when Phase 4 ships)* |
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
| Tax rates in Firestore | Stay aligned with regulation changes | **Adopted** |

---

*Last updated: 2026-04-19 — requirements status: complete except Expenses*
