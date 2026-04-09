# Technology Stack

**Project:** Auto-Entrepreneur Manager (Morocco)
**Researched:** 2026-04-09
**Flutter SDK:** ^3.18 (Dart ^3.8.1)

---

## Core Framework

| Technology | Purpose |
|------------|---------|
| Flutter 3.18+ | UI framework — single codebase for Android/iOS/Web |
| Dart 3.8+ | Language — sealed classes, records, patterns |

---

## Firebase (Backend)

| Package | Version | Purpose |
|---------|---------|---------|
| `firebase_core` | ^3.9.0 | Firebase initialization |
| `firebase_auth` | ^5.5.0 | Email/password + Google Sign-In |
| `cloud_firestore` | ^5.6.0 | Primary database + offline persistence |
| `firebase_storage` | ^12.4.0 | Logos, signatures, receipt photos, PDFs |

---

## State Management

**Riverpod 2.x** — recommended over BLoC (too much boilerplate) and Provider (maintenance mode since 2024).

| Package | Version | Purpose |
|---------|---------|---------|
| `flutter_riverpod` | ^2.6.1 | Global state + DI |
| `riverpod_annotation` | ^2.6.1 | `@riverpod` annotations |
| `riverpod_generator` | ^2.6.1 | Code generation |

---

## Navigation

**go_router** — Flutter-team-maintained standard. Required for Flutter Web URL routing, deep links, auth redirect guards.

| Package | Version |
|---------|---------|
| `go_router` | ^14.6.2 |

---

## PDF Generation

| Package | Version | Purpose |
|---------|---------|---------|
| `pdf` | ^3.11.1 | PDF document creation (pure Dart) |
| `printing` | ^5.14.1 | Cross-platform preview + print + share |

**Critical Flutter Web behavior:**
- `Printing.sharePdf()` does NOT produce a file download on web
- Use `Printing.layoutPdf()` for v1 — opens browser print dialog → "Save as PDF"
- v2: Implement Blob URL download with conditional `dart:html` import

**Critical font requirement:**
- Default PDF fonts do NOT include French accented characters (é, è, à, ç, ê)
- Bundle a TTF font (e.g. Roboto) as a Flutter asset and embed in PDF
- Test accented characters in the very first PDF prototype

---

## Internationalization

Use Flutter's official ARB-based workflow — no third-party package needed.

| Package | Version | Purpose |
|---------|---------|---------|
| `flutter_localizations` | (Flutter SDK) | Localized Material widgets |
| `intl` | ^0.20.1 | Date/number/currency formatting |

Setup: `l10n.yaml` + `lib/l10n/app_en.arb` + `lib/l10n/app_fr.arb` → flutter gen-l10n generates type-safe `AppLocalizations`.

Use `DateFormat` and `NumberFormat` from `intl` for ALL displayed dates and numbers — never `.toString()`.

---

## Signature Capture

| Package | Version | Purpose |
|---------|---------|---------|
| `syncfusion_flutter_signaturepad` | ^27.2.3 | Canvas-based signature (web + mobile) |

**Workflow:** Draw on SfSignaturePad → export PNG bytes → upload to Firebase Storage → embed bytes in PDF via `pw.MemoryImage(bytes)`.

**Syncfusion Community License:** Free for individual developers. Verify commercial thresholds at syncfusion.com when scaling.

---

## Image Handling

| Package | Version | Notes |
|---------|---------|-------|
| `image_picker` | ^1.1.2 | Gallery/camera — on web, use `XFile.readAsBytes()`, not `.path` |
| `image_cropper` | ^8.0.2 | Platform-native crop UI — needs `image_cropper_for_web` companion on web |
| `flutter_image_compress` | ^2.3.0 | **Mobile-only** — gate with `if (!kIsWeb)` |

---

## Data Models

| Package | Version | Purpose |
|---------|---------|---------|
| `freezed_annotation` | ^2.4.4 | Immutable models with equality, copyWith, fromJson/toJson |
| `json_annotation` | ^4.9.0 | JSON serialization |

---

## UI Components

| Package | Version | Purpose |
|---------|---------|---------|
| `flutter_svg` | ^2.0.11 | SVG logos |
| `cached_network_image` | ^3.4.1 | Cache Firebase Storage images |
| `fl_chart` | ^0.69.0 | Dashboard revenue charts (works on web) |
| `shimmer` | ^3.0.0 | Loading skeleton screens |

---

## Forms

| Package | Version | Purpose |
|---------|---------|---------|
| `reactive_forms` | ^17.0.1 | Model-driven forms for invoice builder (dynamic line items) |

Use Flutter built-in `Form` for simpler screens (login, profile).

---

## Email (v1)

`url_launcher` with `mailto:` links — opens device email client. User attaches PDF manually.

v2 upgrade: Firebase Cloud Functions + SendGrid for one-tap PDF email send.

| Package | Version |
|---------|---------|
| `url_launcher` | ^6.3.1 |

**Do NOT use** `flutter_email_sender` — no web support.

---

## Dev Dependencies

| Package | Version |
|---------|---------|
| `build_runner` | ^2.4.13 |
| `freezed` | ^2.5.7 |
| `json_serializable` | ^6.9.0 |
| `riverpod_generator` | ^2.6.1 |
| `custom_lint` | ^0.7.3 |
| `riverpod_lint` | ^2.6.1 |

---

## Flutter Web Compatibility Matrix

| Package | Android | iOS | Web | Notes |
|---------|---------|-----|-----|-------|
| firebase_* | YES | YES | YES | Storage needs CORS config on web |
| flutter_riverpod | YES | YES | YES | Pure Dart |
| go_router | YES | YES | YES | Required for web URL routing |
| pdf + printing | YES | YES | YES* | Web: browser print dialog only |
| syncfusion_signaturepad | YES | YES | YES | Canvas-based |
| image_picker | YES | YES | YES* | Web: file picker, camera unreliable |
| image_cropper | YES | YES | PARTIAL | Needs web companion package |
| flutter_image_compress | YES | YES | NO | Mobile only — use kIsWeb guard |
| cached_network_image | YES | YES | YES | — |
| fl_chart | YES | YES | YES | Pure Flutter |
| reactive_forms | YES | YES | YES | Pure Dart |

---

## Platform Setup Checklist

### Web
- [ ] Firebase Storage CORS configured (images won't load without this)
- [ ] Firebase Hosting `rewrites` configured (`"**"` → `index.html`)
- [ ] Firestore offline: `persistenceEnabled: true` + `synchronizeTabs: true`

### iOS
- [ ] Camera and photo library usage descriptions in `Info.plist`
- [ ] `REVERSED_CLIENT_ID` URL scheme for Google Sign-In

### Android
- [ ] SHA-1 fingerprints (debug + release) registered in Firebase Console
- [ ] `minSdkVersion 21` in `build.gradle`

---

## Alternatives Rejected

| Category | Rejected | Reason |
|----------|----------|--------|
| State management | BLoC | Too much boilerplate for MVP |
| State management | Provider | Maintenance mode since 2024 |
| Local DB | Isar | Dropped web support in v3 |
| Local DB | sqflite | No web support |
| Navigation | auto_route | go_router is Flutter-team standard |
| Email | flutter_email_sender | No web support |
| i18n | easy_localization | Official ARB workflow is type-safe and zero-dependency |

---
*Researched: 2026-04-09*
