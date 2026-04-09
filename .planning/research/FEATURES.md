# Feature Landscape: Invoicing + Freelancer Finance Apps

**Domain:** Invoicing & tax management SaaS for freelancers / micro-entrepreneurs
**Target market:** Moroccan auto-entrepreneurs (régime auto-entrepreneur)
**Researched:** 2026-04-09

---

## Table Stakes

Features users expect as baseline. Their absence makes the product feel unfinished.

| Feature | Why Expected | Complexity | Morocco Notes |
|---------|--------------|------------|---------------|
| Create and export professional PDF invoices | Core reason to use any invoicing tool | Low-Med | Must include ICE, IF, CNSS number, sequential number — legally required |
| Auto-incrementing invoice numbers | Legal compliance + professionalism | Low | Moroccan tax administration expects sequential, gapless numbering |
| Client directory with reusable info | Eliminates re-entering client data | Low | ICE and IF fields needed for B2B clients |
| Invoice status tracking (draft/sent/paid/overdue) | Core workflow visibility | Low | Standard across all competitors |
| Payment recording per invoice | Know what's been paid vs. owed | Low | Partial payment support expected |
| Outstanding balance per invoice | Invoice total minus payments received | Low | Drives the "what do I chase?" workflow |
| Business profile / branding setup | Logo, colors, contact info on invoices | Low | Users treat branded invoices as a credibility signal |
| Income summary by period | Know revenue at a glance | Low | Critical for tax calculation inputs |
| Dashboard with key numbers | Revenue, outstanding, overdue at a glance | Low-Med | All serious apps (Wave, Bonsai) lead with this |
| Mobile-friendly interface | Freelancers often work from phone | Med | Flutter covers this natively |
| French-language UI | Moroccan professional default language | Low | French is the dominant business language in Morocco |

---

## Differentiators

### Morocco-Specific (Highest Value — Core Moat)

| Feature | Value Proposition | Complexity | Notes |
|---------|-------------------|------------|-------|
| Quarterly IR calculation by activity type | Commercial 1%, Artisanal 1%, Liberal 2% of gross revenue | Med | **VERIFY rates with current DGI documentation before implementing** |
| CNSS contribution calculation per quarter | Separate social contribution on declared revenue | Med | **VERIFY rate and plancher with current CNSS schedule** |
| Quarter-close step-by-step filing guide | Walk user through exact DAMANCOM portal steps | Med | Removes the biggest pain point for non-technical users |
| Declaration deadline reminders per quarter | In-app alert before filing deadline | Low | **Verify exact deadline date with DGI calendar** |
| Activity type explainer (commercial/artisanal/liberal) | Many AEs unsure which category they belong to | Low | Common onboarding pain; no mainstream tool addresses this |
| Declaration history with filed amounts | Track what was declared and paid per quarter | Low | Builds audit trail; peace of mind |
| Moroccan legal field labels (ICE, IF, CNSS, CIN) | Native to Moroccan business reality | Low | Foreign apps use generic "Tax ID"; specificity builds trust |
| Revenue ceiling proximity alert | AE status is revoked above ceiling — warn user | Low | **Verify ceilings per activity type — have changed historically** |

### General Differentiators

| Feature | Value Proposition | Complexity |
|---------|-------------------|------------|
| Digital signature on invoices (draw or upload) | Adds legal weight and professionalism | Med |
| Service/product catalog | Reusable line items for faster invoice creation | Low |
| Invoice sent by email directly from app | One-step send | Med |
| Multiple payment method tracking (cash/virement/chèque) | Moroccan business still uses cash and checks heavily | Low |
| Year-to-date revenue summary | See how year is going relative to tax thresholds | Low |

---

## Anti-Features (DO NOT BUILD in v1)

| Anti-Feature | Why Avoid |
|--------------|-----------|
| Automated bank import / reconciliation | No Plaid equivalent for Moroccan banks; high complexity |
| Multi-user / team / accountant access | Auto-entrepreneurs are sole traders by legal definition |
| Direct portal submission (DAMANCOM API) | No official Moroccan government API exists |
| **TVA (VAT) accounting** | **Auto-entrepreneurs in Morocco are TVA-exempt — do NOT surface TVA fields anywhere** |
| Recurring invoices / subscriptions | Complex state machine; defer to v2 |
| Double-entry bookkeeping / journal | Far beyond auto-entrepreneur needs |
| Payroll / salaries | AEs cannot legally have employees under the regime |
| Quotes / estimates workflow | Useful but distinct from invoicing; Phase 2+ |
| Xero / QuickBooks integration | Target user doesn't use enterprise tools |
| Arabic RTL interface | Significant Flutter RTL complexity; defer to post-v1 |
| Multiple business entities per account | AE is one person, one regime by law |
| Time tracking / timer | Project management scope creep |

---

## Feature Dependencies

```
Business Profile (legal fields, logo, signature)
  → Invoice creation (needs branding, legal fields)
    → PDF export (needs invoice data)
      → Email send from app (needs PDF)
    → Payment recording (needs invoice)
      → Outstanding balance (needs invoice + payments)
        → Dashboard overdue view

Client directory
  → Invoice creation (needs a client)

Service catalog (optional)
  → Invoice line items (speeds up creation)

Activity type (set in profile)
  → IR rate lookup
  → CNSS rate lookup
  → Revenue ceiling alert

Paid invoices (from payment tracking)
  → Quarterly revenue total
    → IR amount calculation
    → CNSS amount calculation
      → Declaration step-by-step guide
        → Declaration history + status
```

---

## MVP Phase Recommendations

**Phase 1 — Core invoicing**
Profile setup, client directory, invoice creation, PDF export, signature, payment recording, dashboard

**Phase 2 — Tax engine (core differentiator)**
Activity type onboarding, IR + CNSS calculation, quarterly filing guide, declaration history, deadline reminders

**Phase 3 — Completeness**
Expense logging + receipt capture, service catalog, email send from app, revenue ceiling alert

---

## Morocco Tax Reference (VERIFY BEFORE IMPLEMENTING)

| Item | Training Knowledge | Verify With |
|------|-------------------|-------------|
| IR rate — Commercial | 1% gross quarterly revenue | tax.gov.ma + current Finance Law |
| IR rate — Artisanal | 1% gross quarterly revenue | tax.gov.ma + current Finance Law |
| IR rate — Liberal professions | 2% gross quarterly revenue | tax.gov.ma + current Finance Law |
| CNSS contribution rate | ~6.37% (verify — changes annually) | cnss.ma |
| Revenue ceiling — Commercial | MAD 500,000/year (verify) | DGI |
| Revenue ceiling — Artisanal | MAD 500,000/year (verify) | DGI |
| Revenue ceiling — Liberal | MAD 200,000/year (verify) | DGI |
| Filing portal | DAMANCOM (portail auto-entrepreneur) | damancom.ma |
| TVA status | **Exempt — do not display any TVA fields** | DGI |
| Required invoice fields | Name, address, ICE, IF, CNSS, date, sequential number, client details, line items | DGI |

---
*Researched: 2026-04-09*
