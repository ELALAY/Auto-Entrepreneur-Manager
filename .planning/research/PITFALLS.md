# Domain Pitfalls

**Domain:** Flutter + Firebase multi-tenant invoicing and tax compliance SaaS (Morocco)
**Researched:** 2026-04-09

---

## Critical Pitfalls

Mistakes that cause rewrites, data loss, legal exposure, or total rearchitecting.

---

### C1: Firestore Security Rules That Leak Cross-Tenant Data

**What goes wrong:**
Rules check `request.auth != null` and stop there. Any authenticated user can read any other user's invoices, clients, declarations, and financial data.

**Root data model trap:**
If data is stored at `/invoices/{invoiceId}` (flat) instead of `/users/{uid}/invoices/{invoiceId}` (nested), rules must use `resource.data.userId == request.auth.uid`. A missing or incorrect userId field creates a silent data leak.

**Consequences:** Legal liability under Moroccan data protection law (Loi 09-08). Business data of all users exposed. No warning — everything appears to work normally.

**Prevention:**
1. Use nested Firestore paths: `/users/{uid}/invoices/{invoiceId}`. The top-level rule `allow read, write: if request.auth.uid == uid;` then protects all subcollections.
2. Write Firestore emulator unit tests for security rules before any feature ships: own data readable, cross-tenant NOT readable, unauthenticated — no access.
3. Never expose a flat collection without a `userId` field validated in rules.

**Warning signs:** Rules file < 20 lines for 6+ collections. No emulator rule tests. `request.auth != null` is the only condition.

**Phase to address:** Authentication + Data Layer (before any user data is stored)

---

### C2: PDF Generation on Flutter Web Breaks or Produces Unusable Output

**What goes wrong:**
The `pdf` package generates PDF bytes in Dart. On Flutter web, triggering a download requires browser-specific workarounds. Teams discover this late when "export PDF" is first demoed on web.

**Specific failure modes:**
1. `dart:io` File APIs don't compile on Flutter web — `dart:html` required for downloads.
2. Custom fonts missing or corrupted if not loaded as `ByteData` assets — accented French characters (é, è, à, ç) appear as boxes.
3. Moroccan invoice legal fields (ICE, IF, CNSS, sequential number) omitted because layout was designed for mobile preview only.
4. Signature images load asynchronously — if PDF is generated before image resolves, signatures appear as blank boxes.
5. Page margins look correct in Flutter widget preview but wrong in PDF because `pdf` package uses points (pt), not pixels.

**Prevention:**
1. Validate PDF generation on ALL THREE platforms in the very first invoice spike.
2. Use `printing` package alongside `pdf` for cross-platform preview and sharing.
3. For web downloads: use `dart:html` `AnchorElement` with a blob URL, or `Printing.layoutPdf()`.
4. Bundle all fonts as assets. Test accented French characters in first PDF prototype.
5. Await signature image bytes BEFORE starting PDF build — never fire-and-forget.
6. Write a PDF field completeness test asserting all legally required fields are present.

**Warning signs:** PDF not tested on web until late. `dart:io` imported in PDF code. No custom fonts. Signature loading not awaited.

**Phase to address:** Invoice creation phase — PDF spike must happen at phase start, not end

---

### C3: Tax Calculation Hardcoded or Not Validated Against Official Sources

**What goes wrong:**
Tax rates for Moroccan auto-entrepreneurs (IR + CNSS) are coded from memory or a blog post. The rates are wrong for one or more activity categories, outdated after a Finance Law change, or applied to the wrong base.

**Morocco-specific accuracy requirements:**
Three activity categories with DIFFERENT contribution rates: Commercial, Artisanal, Liberal professions. Each has a different IR flat rate AND CNSS rate. These rates have been adjusted in Finance Laws (Loi de Finances).

**The quarterly base trap:**
CNSS contributions have a fixed minimum quarterly base (plancher). If revenue is below the plancher, CNSS is still owed at the minimum. Many implementations omit this floor entirely.

**Consequences:** Users file incorrect declarations — legal liability. App loses credibility as core value proposition.

**Prevention:**
1. Before writing any calculation code, read: current Finance Law for auto-entrepreneur rates, CNSS circular on contributions, DGI documentation on IR calculation.
2. Document EACH rate with its source URL and date confirmed valid.
3. Store rates in a versioned configuration (Firestore document or Remote Config), NOT as Dart constants. Allows updates without an app release.
4. Implement calculation as pure functions with unit tests covering: each activity category, revenue below plancher, revenue at plancher, high revenue.
5. Add a "rates last verified" date visible to users in the declaration screen.

**Warning signs:** `const double irRate = 0.01` hardcoded in Dart. No unit tests for calculation. Rates not sourced from official docs. No update mechanism without code deploy.

**Phase to address:** Tax declaration phase — validate rates from official sources BEFORE writing any calculation code

---

### C4: Offline/Online Sync Conflicts Corrupt Financial Records

**What goes wrong:**
Firestore offline persistence is treated as "free offline support" with no conflict handling. A user creates an invoice offline on mobile, edits the same draft on web while offline. When both come online, last write wins and one version is silently overwritten.

**Sequential invoice numbering trap:**
Auto-incrementing invoice numbers CANNOT be safely done client-side. Two devices offline simultaneously both generate invoice #47 — a duplicate number. In Morocco, sequential invoice numbering without gaps is a legal requirement.

**Prevention:**
1. Invoice number generation MUST use a Cloud Function (server-side atomic counter using Firestore transactions), never client-side.
2. Define allowed status transition graph and enforce in Firestore rules AND Cloud Functions. An invoice cannot go from "paid" back to "draft".
3. Use Firestore transactions for any read-then-write financial state operation.
4. Test offline scenarios: disable network in emulator, perform operations, re-enable, verify data integrity.

**Warning signs:** Invoice number generated with `DateTime.now()` or UUID on client. No Cloud Functions for financial state transitions. Status field writable directly by client.

**Phase to address:** Invoice creation phase — server-side sequential numbering must be solved from day one

---

### C5: Flutter Web Performance Collapse With Large Document Lists

**What goes wrong:**
Firestore queries load all invoices into a `StreamBuilder`. With 500+ invoices, initial load is slow and list scrolling janks. Flutter web runs on the browser's single JS thread — heavy list rendering hits the main thread and causes visible frame drops.

**Prevention:**
1. Implement cursor-based pagination from the start using Firestore `startAfterDocument` — never load unbounded collections.
2. Use `limit(25)` on all list queries. Implement "load more" or infinite scroll.
3. For dashboard aggregate numbers, maintain denormalized counters in the user profile document rather than counting query results.
4. Use `select()` projection in queries for list views — only fetch fields needed for the row.
5. Test with 200+ seeded documents before any performance claim.

**Warning signs:** `.snapshots()` with no `.limit()`. Dashboard totals computed by iterating all documents. No pagination on any list screen.

**Phase to address:** Foundation/data layer phase — query patterns set early are hard to change

---

## Moderate Pitfalls

---

### M1: Signature Capture Incompatible Across Platforms

Signature capture using a canvas-based Flutter package works on mobile but produces rasterized PNG at 1x resolution on web — the signature looks pixelated in PDFs.

**Prevention:** Test on all three platforms in first sprint. Capture at 3x resolution minimum. Store signature as PNG bytes in Firebase Storage (not URL). Provide both draw and upload paths.

**Phase to address:** User profile/branding phase

---

### M2: i18n Architecture Added Retroactively

Strings hardcoded in English during early development. By the time French is added, there are 200+ hardcoded strings across 40 files. Invoice PDFs with English labels on a French invoice are unprofessional and potentially non-compliant.

**Prevention:** Set up `flutter_localizations` and `intl` with ARB files on day one. Write French translations as each string is added. Use `DateFormat` and `NumberFormat` from `intl` — never `toString()` on dates/numbers in UI. PDF generation must also use the i18n system.

**Warning signs:** Any `Text('Invoice Date')` literal in widget code. `amount.toString()` in displayed text. Only one ARB file.

**Phase to address:** Foundation phase — before any UI screen is built

---

### M3: Firebase Storage URLs Expire, Breaking Stored References

Download URLs stored in Firestore can be revoked when security rules change or on token rotation. Invoices generated months earlier suddenly have broken logo/signature images.

**Prevention:** Store the Firebase Storage PATH (e.g., `users/{uid}/logo.png`) in Firestore, not the download URL. Resolve the current download URL at runtime via `getDownloadURL()`. For archival PDFs, embed image bytes directly at generation time.

**Phase to address:** User profile phase

---

### M4: Cloud Function Cold Start Delays Hurt UX

Invoice number generation (server-side) uses a Cloud Function. On Spark plan or infrequent calls, cold starts take 2-5 seconds. User clicks "Create Invoice," waits with no feedback, and double-submits.

**Prevention:** Show loading indicator immediately on any Cloud Function call. Implement idempotency keys on document-creation functions. Consider minimum instances for critical functions when on Blaze plan.

**Phase to address:** Invoice creation phase

---

### M5: Receipt Image Uploads Without Size/Type Validation

Mobile cameras produce 8-15MB JPEGs. With 100 users uploading 20 receipts/month at 10MB each, Firebase Storage costs become significant.

**Prevention:** Compress client-side with `flutter_image_compress` — target 1MB max. Validate file type (JPEG, PNG, PDF only). Set Storage rules to enforce max file size. Display upload progress.

**Phase to address:** Expense tracking phase

---

### M6: Firestore Read Costs Explode With Real-Time Listeners on Every Screen

A dashboard with 5 separate `StreamBuilder` streams fires 5 reads on every navigation. On Spark plan (100,000 reads/day free), this adds up fast.

**Prevention:** Use state management (Riverpod/Bloc) to hold subscriptions alive across navigation. Consolidate dashboard data into a single summary document updated by Cloud Functions. Use `get()` instead of `snapshots()` for data that doesn't need real-time updates.

**Phase to address:** Foundation/architecture phase

---

## Minor Pitfalls

### m1: Invoice Number Gaps Alarm Users
Deleted drafts create gaps in sequential numbers. Users and accountants flag this. Prevention: Never delete number slots — cancelled invoices keep their number with "cancelled" status.

### m2: Timezone Handling for Declaration Deadlines
UTC timestamps cause deadlines to appear off by one day for Moroccan users. Prevention: Store periods as plain strings (`"2026-Q1"`), not timestamps. Use date-only comparison for deadlines.

### m3: Flutter Web Deep Links Break on Refresh
Refreshing `/invoices/abc123` on web shows an error if state is lost. Prevention: Use `go_router` with proper guards. Configure Firebase Hosting `rewrites` to send all paths to `index.html`. Re-fetch data from Firestore on route load.

### m4: French Number Formatting Inconsistency in PDFs vs. UI
UI shows `1 234,50 MAD`, PDF shows `1,234.50 MAD`. Prevention: Use the same `intl` `NumberFormat` instance with explicit locale in both UI widgets and PDF generation code.

---

## Phase-Specific Warnings

| Phase | Pitfall | Mitigation |
|-------|---------|------------|
| Auth + data foundation | C1 (rules leaking data) | Emulator rule tests before any data write |
| User profile + branding | M3 (Storage URL expiry), M1 (signature resolution) | Store paths not URLs; test all 3 platforms |
| Invoice creation + PDF | C2 (PDF web), C4 (duplicate numbers), m4 (formatting) | PDF spike day 1; server-side atomic numbering |
| Tax declarations | C3 (wrong rates), m2 (timezone bugs) | Official sources first; date-strings not timestamps |
| Expense tracking | M5 (image upload size) | Client-side compression before upload |
| Dashboard + aggregates | M6 (read costs), C5 (performance at scale) | Denormalized summary doc; paginated queries |
| i18n throughout | M2 (retroactive string extraction) | ARB files from day 1 |
| Web routing | m3 (refresh breaks routes) | go_router + Firebase Hosting rewrites early |

---

## Research Gaps to Validate Per Phase

| Gap | Where to Verify |
|-----|----------------|
| Current Morocco auto-entrepreneur IR flat rates per activity type | tax.gov.ma + current Finance Law (Loi de Finances) |
| Current CNSS contribution rates and quarterly plancher amount | cnss.ma |
| Whether Finance Law 2025/2026 changed auto-entrepreneur thresholds | Journal Officiel du Maroc |
| `pdf` package current version and web download API | pub.dev/packages/pdf |
| `printing` package Flutter web support status | pub.dev/packages/printing |
| Flutter web CanvasKit vs. HTML renderer impact on signature capture | Flutter web rendering docs |

---
*Researched: 2026-04-09*
