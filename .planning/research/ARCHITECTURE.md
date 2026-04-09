# Architecture

**Project:** Auto-Entrepreneur Manager (Morocco)
**Stack:** Flutter + Firebase
**Researched:** 2026-04-09

---

## Recommended Architecture Pattern

**Flutter official recommendation: MVVM + Repository pattern** (from flutter.dev/app-architecture, Compass case study)

```
UI Layer       → Widgets + ViewModels (Riverpod Notifiers)
Domain Layer   → Use Cases (business logic, tax calculations)
Data Layer     → Repositories (Firestore, Firebase Storage, Auth)
```

### Why This Pattern

- Official Flutter recommendation (not a community convention)
- ViewModels (Riverpod `AsyncNotifier`) handle async Firebase streams cleanly
- Domain layer isolates tax calculation logic — pure Dart, easily unit-tested
- Repository layer abstracts Firebase — mockable for tests, swappable later

---

## Folder Structure

```
lib/
  features/
    auth/
      data/           # FirebaseAuth repository
      domain/         # UserProfile model (freezed)
      presentation/   # Login, register, forgot password screens
    profile/
      data/           # Firestore user profile repository
      domain/         # Profile model, signature logic
      presentation/   # Profile setup, branding screens
    clients/
      data/           # Firestore clients repository
      domain/         # Client model (freezed)
      presentation/   # Client list, create, detail screens
    services/         # Service/product catalog
      data/
      domain/
      presentation/
    invoices/
      data/           # Firestore invoices repo + PDF generation
      domain/         # Invoice, InvoiceItem models (freezed)
      presentation/   # Invoice list, builder, detail, PDF preview
    payments/
      data/           # Firestore payments repository
      domain/         # Payment model (freezed)
      presentation/   # (embedded in invoice detail)
    expenses/
      data/           # Firestore expenses repository
      domain/         # Expense model (freezed)
      presentation/   # Expense list, create, detail
    declarations/
      data/           # Firestore declarations repository
      domain/         # Declaration model + tax calculation use cases
      presentation/   # Declaration flow, filing guide, history
    dashboard/
      presentation/   # Aggregates data from other features
  shared/
    widgets/          # Reusable UI components (status badge, amount card, etc.)
    utils/            # PDF utils, MAD currency formatter, date helpers
    providers/        # App-wide providers (auth state, locale)
    models/           # Shared value objects
  l10n/
    app_en.arb
    app_fr.arb
  main.dart
  router.dart         # go_router configuration
  firebase_options.dart
```

---

## Firestore Data Model

**Pattern: Subcollections under `/users/{uid}/`**

This is the only correct multi-tenant pattern. A single security rule protects ALL user data:
```
match /users/{userId}/{document=**} {
  allow read, write: if request.auth.uid == userId;
}
```

### Collections

```
/users/{uid}
  /clients/{clientId}
    name, address, ice, taxId, email, phone, createdAt

  /services/{serviceId}
    name, description, unitPrice, unitType, category, isActive

  /invoices/{invoiceId}
    number, clientId, date, dueDate, status,
    lineItems[], subtotal, total,
    signatureEnabled, templateId, notes,
    createdAt, updatedAt

  /payments/{paymentId}
    invoiceId, date, amount, method, notes

  /expenses/{expenseId}
    date, amount, category, description, receiptUrl, createdAt

  /declarations/{declarationId}
    period (e.g. "2026-Q1"), totalRevenue,
    irAmount, cnssAmount, status, filedDate

  (profile stored on /users/{uid} document itself)
  name, cin, ice, taxId, cnss, activityType, address,
  logoUrl, signatureUrl, brandingConfig,
  invoiceCounter (used for atomic sequential numbering)
```

### Invoice Number Generation

Sequential invoice numbering is a **Moroccan legal requirement**. Client-side generation with Firestore offline creates duplicate numbers.

**Correct approach: Firestore transaction on the user document**

```dart
// Cloud Function or client-side transaction:
await FirebaseFirestore.instance.runTransaction((tx) async {
  final userRef = db.collection('users').doc(uid);
  final snap = await tx.get(userRef);
  final next = (snap.data()?['invoiceCounter'] ?? 0) + 1;
  tx.update(userRef, {'invoiceCounter': next});
  tx.set(invoiceRef, {...invoiceData, 'number': next});
});
```

This is atomic — no two invoices can get the same number.

---

## Security Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // All user data protected under /users/{userId}/
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;

      match /{collection}/{document} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
    }
  }
}
```

**Must write emulator unit tests for rules before any feature ships:**
- Own data: readable and writable ✓
- Cross-tenant: NOT accessible ✓
- Unauthenticated: no access ✓

---

## State Management

**Riverpod 2.x with `AsyncNotifier`**

```dart
// Example: invoices provider
@riverpod
class InvoicesNotifier extends _$InvoicesNotifier {
  @override
  Stream<List<Invoice>> build() {
    final uid = ref.watch(authProvider).uid!;
    return ref
        .watch(firestoreProvider)
        .collection('users/$uid/invoices')
        .orderBy('createdAt', descending: true)
        .limit(25)                    // Always paginate
        .snapshots()
        .map((s) => s.docs.map(Invoice.fromFirestore).toList());
  }
}
```

Key rules:
- All Firestore queries have `.limit()` — no unbounded collection loads
- Streams held at Riverpod provider level, not inside widget `build()`
- Dashboard uses a denormalized summary document, not 5 separate queries

---

## Navigation (go_router)

Required for Flutter Web URL routing.

```dart
// router.dart
final router = GoRouter(
  redirect: (context, state) {
    final isLoggedIn = ref.read(authProvider).isLoggedIn;
    if (!isLoggedIn && state.uri.path != '/login') return '/login';
    return null;
  },
  routes: [
    GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
    GoRoute(path: '/dashboard', builder: (_, __) => const DashboardScreen()),
    GoRoute(path: '/invoices', builder: (_, __) => const InvoiceListScreen()),
    GoRoute(path: '/invoices/:id', builder: (_, state) =>
        InvoiceDetailScreen(id: state.pathParameters['id']!)),
    // ...
  ],
);
```

Firebase Hosting `firebase.json` must include rewrites:
```json
"rewrites": [{"source": "**", "destination": "/index.html"}]
```

---

## Offline Support

**Strategy: Firestore offline persistence (built-in)**

```dart
// main.dart — enable on all platforms
await Firebase.initializeApp();
FirebaseFirestore.instance.settings = const Settings(
  persistenceEnabled: true,
  cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
);
```

On web, Firestore uses IndexedDB. Enable `synchronizeTabs: true` if multiple browser tabs are expected.

**Offline limitations to design around:**
- Invoice number generation (transaction) will fail offline — show clear error, queue for retry
- File uploads (logos, receipts) require connectivity — show offline state indicator
- Web: keep online-first UX; offline primarily for mobile

---

## Flutter Web Specifics

| Concern | Solution |
|---------|----------|
| No `dart:io` | Use `kIsWeb` checks; conditional imports for platform-specific code |
| PDF download | `Printing.layoutPdf()` (browser print dialog → Save as PDF) for v1 |
| CORS for Storage images | Configure Firebase Storage CORS before any web image loads |
| Responsive layout | `LayoutBuilder` / `MediaQuery` from day 1 — do not assume mobile size |
| Deep link refresh | go_router + Firebase Hosting `"**"` rewrite to `index.html` |
| Image compression | Gate `flutter_image_compress` with `if (!kIsWeb)` |

---

## Build Order (Phases)

Dependency graph determines safe build order:

1. **Foundation** — Firebase setup, Auth, go_router, security rules, i18n scaffold
2. **Profile + Clients + Service catalog** — prerequisites for invoices
3. **Invoices + PDF + Payments** — core value delivery; invoice numbering transaction here
4. **Expenses** — independent; can build in parallel with invoices
5. **Tax Declarations** — depends on invoice revenue totals; tax calculation domain logic
6. **Dashboard** — aggregates data from all features; build last

---

## Tax Calculation Architecture

Tax calculations are **pure Dart domain logic** — no Firebase calls, fully unit-testable.

```dart
// lib/features/declarations/domain/tax_calculator.dart
class TaxCalculator {
  static TaxResult calculate({
    required ActivityType activityType,
    required double quarterlyRevenue,
    required TaxRates rates,   // loaded from Firestore config, not hardcoded
  }) {
    final irAmount = quarterlyRevenue * rates.irRate(activityType);
    final cnssBase = max(quarterlyRevenue, rates.cnssMinBase);
    final cnssAmount = cnssBase * rates.cnssRate(activityType);
    return TaxResult(irAmount: irAmount, cnssAmount: cnssAmount);
  }
}
```

Rates stored in Firestore at `/config/taxRates` (readable by all authenticated users, writable only by admin) — not hardcoded as Dart constants.

---
*Researched: 2026-04-09*
