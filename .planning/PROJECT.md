# Auto-Entrepreneur Manager (Morocco)

## What This Is

A cross-platform Flutter app (Android, iOS, Web) that helps Moroccan auto-entrepreneurs run their freelance business and stay tax-compliant. Users can manage clients, create branded invoices, track income and expenses, and get step-by-step quarterly filing guidance with calculated IR and CNSS amounts. Built as a multi-tenant SaaS — anyone can sign up and use it.

## Core Value

A Moroccan auto-entrepreneur can complete their quarterly tax declaration confidently, knowing exactly what they owe and how to file it, based on their real tracked revenue.

## Requirements

### Validated

(None yet — ship to validate)

### Active

#### Authentication & Profile
- [ ] User can sign up and log in (Firebase Auth)
- [ ] User can set up their business profile (name, CIN, ICE, IF, CNSS number, activity type, address)
- [ ] User can upload a logo for invoice branding
- [ ] User can save a signature (draw on screen and/or upload image)
- [ ] User can choose invoice template colors/style

#### Clients
- [ ] User can create and manage clients (name, address, ICE/IF, email, phone)
- [ ] User can view all invoices linked to a client

#### Service/Product Catalog
- [ ] User can define reusable services/products (name, description, unit price, unit type: hour/day/forfait/unit)
- [ ] User can pick from catalog when building invoice line items

#### Invoices
- [ ] User can create invoices linked to a client
- [ ] User can add line items manually or from the service catalog
- [ ] User can apply their saved signature to an invoice (toggle)
- [ ] Invoice is auto-numbered and includes all legally required fields
- [ ] User can set invoice status (draft, sent, paid, overdue)
- [ ] User can export invoice as PDF with chosen branding/template
- [ ] User can send invoice by email directly from the app

#### Payments
- [ ] User can record payments against an invoice (date, amount, method: cash/virement/cheque/autre)
- [ ] App shows invoice balance = total - payments received
- [ ] App shows which invoices are partially paid or overdue

#### Expenses
- [ ] User can log expenses (amount, date, category, description)
- [ ] User can attach a receipt image to an expense
- [ ] User can view expenses filtered by period

#### Tax Declarations (Quarterly)
- [ ] App explains activity categories (commercial, artisanal, liberal) and applicable rates
- [ ] App calculates IR and CNSS amounts due based on quarterly revenue
- [ ] User gets a step-by-step filing guide each quarter
- [ ] User can mark a declaration as filed and track status per quarter
- [ ] App shows declaration history

#### Dashboard
- [ ] User sees revenue summary (current quarter, year to date)
- [ ] User sees upcoming declaration deadline
- [ ] User sees outstanding invoices and overdue amounts

### Out of Scope

- Arabic language — English + French only for v1, Arabic deferred
- In-app payments (charging users) — free for v1, monetization later
- Direct portal submission — app guides filing, user submits manually on official portals
- Accounting integrations (no Xero/QuickBooks sync) — not needed for auto-entrepreneur scale
- Multi-user / team access — one account per auto-entrepreneur

## Context

- **Legal regime**: Moroccan auto-entrepreneur (régime auto-entrepreneur) — flat contribution rates on revenue, declared and paid quarterly to CNSS + DGI
- **Activity types**: Commercial (rate varies), Artisanal (rate varies), Liberal professions (rate varies) — app must explain each and apply correct rates
- **Invoice legal requirements**: Morocco requires ICE, IF, CNSS number, sequential numbering, date, client details
- **Platform**: Flutter (Dart) — single codebase for Android, iOS, Web
- **Backend**: Firebase — Auth, Firestore (data), Storage (images, PDFs, receipts, signatures)
- **Languages**: English + French (i18n with flutter_localizations)
- **Users**: Multi-tenant SaaS — each user's data is isolated

## Data Models

| Model | Key Fields |
|-------|-----------|
| UserProfile | uid, name, CIN, ICE, IF, CNSS, activityType, address, logo, signatureUrl, brandingConfig |
| Client | id, userId, name, address, ICE, IF, email, phone |
| Service | id, userId, name, description, unitPrice, unitType (hour/day/forfait/unit), category |
| Invoice | id, userId, clientId, number, date, dueDate, status, lineItems, signatureEnabled, templateId, notes |
| InvoiceItem | serviceId (optional), description, qty, unitPrice, total |
| Payment | id, invoiceId, userId, date, amount, method |
| Expense | id, userId, date, amount, category, description, receiptUrl |
| Declaration | id, userId, period (Q+year), totalRevenue, irAmount, cnssAmount, status, filedDate |

## Constraints

- **Tech stack**: Flutter + Firebase — decided, not up for debate in v1
- **Localization**: English + French — flutter_localizations, no Arabic in v1
- **Monetization**: Free for v1 — no payment infrastructure needed yet
- **Platforms**: Android + iOS + Web — Flutter web must work, not just mobile

## Key Decisions

| Decision | Rationale | Outcome |
|----------|-----------|---------|
| Firebase over Supabase | Faster to build, excellent Flutter SDK, managed scaling | — Pending |
| Flutter for all 3 platforms | Single codebase, user requested mobile + web | — Pending |
| English + French only | Covers target user base, Arabic adds RTL complexity | — Pending |
| Free for v1 | Validate product before monetizing | — Pending |
| Manual filing (no portal API) | No official Moroccan API available, step-by-step guide sufficient | — Pending |

---
*Last updated: 2026-04-09 after initialization*
