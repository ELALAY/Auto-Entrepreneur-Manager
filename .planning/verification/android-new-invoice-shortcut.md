# Android New Invoice launcher shortcut

Implemented: 2026-11-17. Requirement: ANDROID-01 (platform enhancement outside
the original six product phases).

## Inspected flow and implementation

- `MainActivity` already uses `singleTop` and forwards `onNewIntent` to Flutter
  and its plugins. That forwarding and `setIntent` remain in place.
- Android home widgets use the `home_widget` action and the
  `autoentinvoice://invoice/new?homeWidget=1` / dashboard URIs. Their URI handling
  remains intact; a later widget tap explicitly cancels a pending shortcut so
  it takes precedence. No notification navigation handler exists in this repo.
  Unknown native actions and existing URI deliveries are not intercepted.
- Static `res/xml/shortcuts.xml` is registered on the launcher activity. Exact
  stable ID and short/long label: **New Invoice**. The icon is a local invoice
  document with a plus sign. Static launcher shortcuts require Android 7.1/API
  25+ and a launcher that supports them; the application's minSdk stays 23.
- The explicit shortcut intent targets the existing activity, with action
  `com.example.auto_entrepreneur_manager.action.NEW_INVOICE` and string extra
  `shortcut_id=New Invoice`. Both must match; arbitrary paths are never accepted.
- A small dependency-free MethodChannel queues native cold/warm delivery,
  assigns a delivery UUID, and drains it after Dart subscribes. The native
  launch marker is cleared when drained so activity recreation does not replay
  that consumed intent. Startup and warm notifications use the same drain.
- `ShortcutInbox` retains one pending navigation in memory through sign-in,
  rejects invalid/duplicate deliveries, coalesces taps while waiting, and
  consumes the matching delivery once immediately before form navigation.
- Existing auth redirects still protect routes. Login completion resumes the
  pending gate; sign-up and activity onboarding keep their existing sequence.
  Onboarding completion resumes the gate only when an action is pending.
  Ordinary dashboard, deep-link, and other feature navigation is not redirected.
- Before constructing `InvoiceFormScreen`, the gate waits for authenticated
  profile, clients, and catalog streams. It checks the existing legal-profile
  completeness rule, requires at least one client, accepts an empty catalog,
  and rechecks auth/data/current route after the frame before navigating.
- Missing profile or clients offers explicit setup navigation. Choosing it
  ends the pending action; the user can open New Invoice again after setup.
  Load errors retain the action and offer retry/cancel. Cancellation prevents
  delayed data from navigating later. Messages are localized in English/French.
- Opening the gate has no repository writes or form submission. The form's
  existing number preview is read-only; number allocation and invoice creation
  still occur only on explicit Save. No package dependencies were added.

## Automated verification

- Shortcut-specific tests: **12 passed**. Coverage: cold drain, warm delivery,
  startup race, disposal, missing native implementation, invalid actions,
  duplicate delivery and exact consumption, preservation of non-auth routes,
  real auth-router login resumption, delayed prerequisite loading, missing
  profile/client recovery, retry, cancellation, and no duplicate form opening.
- Relevant Flutter analysis: **passed, no issues** using
  `flutter analyze --no-pub lib/app.dart lib/router/app_router.dart lib/shortcuts lib/features/onboarding/activity_onboarding_screen.dart lib/l10n test/android_shortcut_delivery_test.dart test/new_invoice_shortcut_gate_test.dart`.
- Android debug build: **passed**, `flutter build apk --debug --no-pub`;
  output `build/app/outputs/flutter-apk/app-debug.apk`.
- Full existing Flutter test suite: **43 passed**, `flutter test --no-pub`.
  The existing PDF test prints Helvetica Unicode/em-dash fallback warnings but
  passes. All 12 new shortcut tests are included in this total.
- Android resource/package inspection: **passed** using Android SDK `aapt2`
  against the built APK. Compiled `res/xml/shortcuts.xml` contains literal ID
  `New Invoice`, the invoice-plus icon, both label references, the expected
  activity/action/extra, and string resource value `New Invoice`. The merged
  manifest includes `android.app.shortcuts` and retains the home-widget action
  and both existing widget receiver declarations.
- `git diff --check`: **passed** (only Windows LF/CRLF informational notices).

## Remaining device checks / manual test plan

These are **not yet device-verified**. The tests mock the platform channel;
compilation does not prove launcher or OEM behavior.

1. Install `build/app/outputs/flutter-apk/app-debug.apk` on an Android API 25+
   device. Use the app's normal Firebase sign-in and a complete business
   profile with at least one client. Long-press the app icon: verify exactly
   **New Invoice** and the invoice-plus icon. An updated launcher may need its
   icon/menu refreshed after installation.
2. Cold launch: force-stop the app in Android settings, then tap the shortcut.
   Expect a blank new-invoice form after loading. Record invoice count and
   next-number/counter beforehand; verify neither changes until Save is tapped.
3. Warm launch: open another screen, press Home, long-press the icon, and tap
   New Invoice. Verify one blank form, normal Back navigation, and no save.
   Repeat a tap later to confirm a new delivery can open a new form.
4. Sign out, launch the shortcut, cancel a Google sign-in once if applicable,
   then sign in (email and Google). Verify the action survives and opens once.
   Check sign-up → activity onboarding → setup guidance for an incomplete account.
5. Try missing/incomplete profile and no clients. Check setup buttons and
   Cancel. Complete setup, then launch the shortcut again. An empty catalog
   must still allow manual invoice items.
6. Throttle/disable network with uncached prerequisite data. Expect loading or
   an error with retry/cancel, no premature form, and no navigation after Cancel.
   Restore connectivity and retry. Switch accounts while loading and verify
   the previous account's data is not used.
7. Tap each existing new-invoice/dashboard widget during normal use and while a
   shortcut waits. Verify that widget navigation wins. Check ordinary links,
   notification entry points if added outside this repo, app-icon launch,
   orientation changes, and activity recreation for unwanted replay.
8. Invalid explicit action/missing `shortcut_id` must leave normal navigation
   intact and never create an invoice. Normal app resume after consumption
   must not replay the shortcut.
9. Samsung One UI launcher visibility and **Samsung Modes and Routines** are
   **untested**. Do not claim compatibility unless exercised on a real Samsung
   device, recording model, Android/One UI version, and observed behavior.

The pending action is intentionally in-memory. Survives sign-in/navigation in
the running app, not a force-stop or OS process death after native delivery.
No cross-process persistence or background work is introduced.
