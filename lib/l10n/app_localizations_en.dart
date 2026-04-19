// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Auto-Entrepreneur Manager';

  @override
  String get navDashboard => 'Dashboard';

  @override
  String get navInvoices => 'Invoices';

  @override
  String get navExpenses => 'Expenses';

  @override
  String get navTax => 'Tax';

  @override
  String get navMore => 'More';

  @override
  String get screenLogin => 'Sign in';

  @override
  String get screenSignUp => 'Create account';

  @override
  String get screenDashboard => 'Dashboard';

  @override
  String get screenInvoices => 'Invoices';

  @override
  String get screenInvoiceDetail => 'Invoice';

  @override
  String get screenExpenses => 'Expenses';

  @override
  String get screenExpenseDetail => 'Expense';

  @override
  String get screenDeclarations => 'Declarations';

  @override
  String get screenDeclarationDetail => 'Quarterly declaration';

  @override
  String get screenMore => 'More';

  @override
  String get screenClients => 'Clients';

  @override
  String get screenClientDetail => 'Client';

  @override
  String get screenServices => 'Services';

  @override
  String get screenProfile => 'Profile & settings';

  @override
  String get authEmail => 'Email';

  @override
  String get authPassword => 'Password';

  @override
  String get authConfirmPassword => 'Confirm password';

  @override
  String get authSignIn => 'Sign in';

  @override
  String get authSignUp => 'Create account';

  @override
  String get authSignInWithGoogle => 'Continue with Google';

  @override
  String get authNoAccount => 'Don\'t have an account?';

  @override
  String get authHaveAccount => 'Already have an account?';

  @override
  String get authSignUpLink => 'Sign up';

  @override
  String get authSignInLink => 'Sign in';

  @override
  String get authSignOut => 'Sign out';

  @override
  String get authErrorInvalidCredentials => 'Invalid email or password.';

  @override
  String get authErrorEmailInUse => 'This email is already in use.';

  @override
  String get authErrorWeakPassword => 'Password must be at least 6 characters.';

  @override
  String get authErrorPasswordMismatch => 'Passwords do not match.';

  @override
  String get authErrorGeneric => 'An error occurred. Please try again.';

  @override
  String get placeholderDashboard =>
      'Revenue summary, declaration deadlines, and outstanding invoices will appear here.';

  @override
  String get dashboardTagline =>
      'Revenue, cash flow, and compliance — in one place.';

  @override
  String get dashboardStatsHint =>
      'Totals update as you create and collect invoices.';

  @override
  String get dashboardSectionShortcuts => 'Shortcuts';

  @override
  String get moreSectionBusiness => 'Business';

  @override
  String get moreSectionAccount => 'Account';

  @override
  String get placeholderInvoices =>
      'Create and manage invoices linked to clients.';

  @override
  String get placeholderInvoiceDetail => 'Invoice details and line items.';

  @override
  String get placeholderExpenses =>
      'Log expenses with categories and receipt attachments.';

  @override
  String get placeholderExpenseDetail => 'Expense details.';

  @override
  String get placeholderDeclarations =>
      'Quarterly IR and CNSS guidance and history.';

  @override
  String get placeholderDeclarationDetail =>
      'Filing guide and amounts for this quarter.';

  @override
  String get placeholderMore => 'Clients, service catalog, and profile.';

  @override
  String get placeholderClients => 'Manage client records (ICE, IF, contact).';

  @override
  String get placeholderClientDetail => 'Client details and linked invoices.';

  @override
  String get placeholderServices =>
      'Reusable services and products for invoices.';

  @override
  String get placeholderProfile =>
      'Business profile, branding, and tax activity category.';

  @override
  String get actionSave => 'Save';

  @override
  String get actionCancel => 'Cancel';

  @override
  String get actionDone => 'Done';

  @override
  String get actionDelete => 'Delete';

  @override
  String get profileSectionLegal => 'Legal identity';

  @override
  String get profileFieldBusinessName => 'Business / legal name';

  @override
  String get profileFieldCin => 'CIN';

  @override
  String get profileFieldIce => 'ICE';

  @override
  String get profileFieldIf => 'IF (tax identifier)';

  @override
  String get profileFieldCnss => 'CNSS number';

  @override
  String get profileFieldTaxProfessionnelle => 'Professional tax number (TP)';

  @override
  String get profileFieldPhone => 'Phone';

  @override
  String get profileFieldAddress => 'Address';

  @override
  String get profileHasCnssLabel => 'Already covered by CNSS';

  @override
  String get profileHasCnssHint =>
      'Enable if you pay CNSS through another scheme (e.g. salaried employment). Your AE declaration will then show 0 MAD for CNSS.';

  @override
  String get profileSectionActivity => 'Activity category';

  @override
  String get activityCommercialShort => 'Commercial';

  @override
  String get activityArtisanalShort => 'Artisanal';

  @override
  String get activityLiberalShort => 'Liberal';

  @override
  String get activityCommercialTitle => 'Commercial activities';

  @override
  String get activityCommercialBody =>
      'Buying and selling goods, import/export, e-commerce, and similar trading. IR and CNSS rates for this family differ from other categories — your declaration uses the category saved here.';

  @override
  String get activityArtisanalTitle => 'Artisanal activities';

  @override
  String get activityArtisanalBody =>
      'Craft production and related services (e.g. workshops, manual trades). Rates are specific to artisanal auto-entrepreneurs.';

  @override
  String get activityLiberalTitle => 'Liberal professions';

  @override
  String get activityLiberalBody =>
      'Professional services (consulting, design, IT services, etc.). Uses the liberal-profession contribution schedule.';

  @override
  String get activityServicesShort => 'Services';

  @override
  String get activityServicesTitle => 'Service activities';

  @override
  String get activityServicesBody =>
      'Service providers (training, coaching, events, etc.). Benefits from a reduced 1% IR rate — confirm your eligibility with your tax office.';

  @override
  String get profileSectionBranding => 'Invoice branding';

  @override
  String get profilePickLogo => 'Upload logo';

  @override
  String get profileRemoveLogo => 'Remove logo';

  @override
  String get profileBrandingColor => 'Accent color';

  @override
  String get profileBrandingColorHint =>
      'Used on invoice headers and PDF accents.';

  @override
  String get profileInvoiceTemplate => 'Invoice layout';

  @override
  String get templateDefault => 'Default';

  @override
  String get templateBordered => 'Bordered';

  @override
  String get profileBrandingPreviewHint =>
      'Preview of how branding may appear on invoices (Phase 3 PDF).';

  @override
  String get profileSectionSignature => 'Signature';

  @override
  String get profileRemoveSignature => 'Remove signature';

  @override
  String get profileSignatureClear => 'Clear pad';

  @override
  String get profileSignatureSaveDrawn => 'Save drawn signature';

  @override
  String get profileSignatureUpload => 'Upload image';

  @override
  String get profileSaved => 'Profile saved.';

  @override
  String get profileSaveError =>
      'Could not save profile. Check your connection.';

  @override
  String get profileLogoUploaded => 'Logo updated.';

  @override
  String get profileUploadError => 'Upload failed. Try again.';

  @override
  String get profileSignatureEmpty => 'Draw your signature first.';

  @override
  String get profileSignatureSaved => 'Signature saved.';

  @override
  String get profileIncompleteHint =>
      'Complete all legal fields below before you can create invoices.';

  @override
  String get clientAddTitle => 'New client';

  @override
  String get clientEditTitle => 'Edit client';

  @override
  String get clientFieldName => 'Name';

  @override
  String get clientFieldAddress => 'Address';

  @override
  String get clientFieldIce => 'ICE';

  @override
  String get clientFieldIf => 'IF';

  @override
  String get clientFieldEmail => 'Email';

  @override
  String get clientFieldPhone => 'Phone';

  @override
  String get clientValidationRequired => 'Required';

  @override
  String get clientSaved => 'Client saved.';

  @override
  String get clientSaveError => 'Could not save. Try again.';

  @override
  String get clientDeleteTitle => 'Delete client?';

  @override
  String get clientDeleteBody =>
      'This cannot be undone. Invoices already linked in Phase 3 remain in your account.';

  @override
  String get clientListError => 'Could not load clients.';

  @override
  String get clientListEmpty =>
      'No clients yet. Tap + to add your first client.';

  @override
  String get clientNotFound => 'Client not found.';

  @override
  String get clientLinkedInvoices => 'Invoices for this client';

  @override
  String get clientNoInvoicesYet =>
      'No invoices yet. They will appear here once you create them (Phase 3).';

  @override
  String get invoiceNewAction => 'New invoice';

  @override
  String get invoiceProfileRequiredTitle => 'Complete your profile';

  @override
  String get invoiceProfileRequiredBody =>
      'Add your legal business details (ICE, IF, CNSS, etc.) before creating invoices.';

  @override
  String get invoiceGoToProfile => 'Open profile';

  @override
  String get invoiceFormCreateTitle => 'New invoice';

  @override
  String get invoiceFormEditTitle => 'Edit invoice';

  @override
  String get invoiceNumberLabel => 'Invoice number';

  @override
  String get invoiceFieldClient => 'Client';

  @override
  String get invoiceFieldIssueDate => 'Issue date';

  @override
  String get invoiceFieldDueDate => 'Due date';

  @override
  String get invoiceFieldStatus => 'Status';

  @override
  String get invoiceFieldNotes => 'Notes';

  @override
  String get invoiceLineItems => 'Line items';

  @override
  String get invoiceLineDescription => 'Description';

  @override
  String get invoiceLineQty => 'Quantity';

  @override
  String get invoiceLineUnitPrice => 'Unit price (MAD)';

  @override
  String get invoiceAddLine => 'Add line';

  @override
  String get invoiceSignatureOnPdf => 'Include signature on PDF';

  @override
  String get invoiceFormValidation =>
      'Select a client and add at least one line with a description.';

  @override
  String get invoiceSaved => 'Invoice saved.';

  @override
  String get invoiceSaveError => 'Could not save invoice.';

  @override
  String get invoiceSectionSeller => 'Seller (your business)';

  @override
  String get invoiceSectionClient => 'Client (on invoice)';

  @override
  String get invoiceProfileMissing => 'Complete your profile to export PDF.';

  @override
  String get invoiceOverdueBanner =>
      'This invoice is past its due date and still has a balance.';

  @override
  String get invoicePartiallyPaidBanner => 'Partially paid — balance remains.';

  @override
  String get invoiceTotal => 'Total';

  @override
  String get invoicePaid => 'Paid';

  @override
  String get invoiceBalance => 'Balance due';

  @override
  String get invoicePaymentsSection => 'Payments';

  @override
  String get invoiceNoPayments => 'No payments recorded yet.';

  @override
  String get invoiceAddPayment => 'Record payment';

  @override
  String get invoiceEditPayment => 'Edit payment';

  @override
  String get invoiceDeletePayment => 'Delete payment';

  @override
  String invoiceDeletePaymentConfirm(String amount) {
    return 'Delete this payment of $amount?';
  }

  @override
  String get invoicePaymentAmount => 'Amount (MAD)';

  @override
  String get invoicePaymentDate => 'Payment date';

  @override
  String get invoicePaymentMethod => 'Method';

  @override
  String get paymentMethodCash => 'Cash';

  @override
  String get paymentMethodVirement => 'Bank transfer';

  @override
  String get paymentMethodCheque => 'Cheque';

  @override
  String get paymentMethodAutre => 'Other';

  @override
  String get invoiceStatusDraft => 'Draft';

  @override
  String get invoiceStatusSent => 'Sent';

  @override
  String get invoiceStatusPaid => 'Paid';

  @override
  String get invoiceStatusOverdue => 'Overdue';

  @override
  String get invoiceListEmpty => 'No invoices yet. Tap + to create one.';

  @override
  String get invoiceBadgeOverdue => 'Overdue';

  @override
  String get invoiceBadgePartial => 'Partial';

  @override
  String get invoicePdfError => 'Could not build PDF. Please try again.';

  @override
  String get declTaxConfigMissing =>
      'Tax rates are not configured. An administrator must create the Firestore document config/taxRates (see config/taxRates.firestore.json in the project).';

  @override
  String get declLoadError =>
      'Could not load declaration data. Check your connection.';

  @override
  String get declRevenueQuarter => 'Cash-basis revenue this quarter';

  @override
  String get declRevenueHint =>
      'Sum of invoice payments dated in this quarter.';

  @override
  String get declIrDue => 'Income tax (IR) due';

  @override
  String get declCnssDue => 'CNSS contribution due';

  @override
  String get declCnssBase => 'CNSS base (after minimum)';

  @override
  String get declCnssExempt =>
      'Exempt — you already contribute to CNSS through another scheme';

  @override
  String declRatesVersion(int version) {
    return 'Rate table version: $version';
  }

  @override
  String get declDisclaimer =>
      'These amounts are estimates based on the rate table in the app. Laws and CNSS rules change — confirm every figure with DGI and CNSS before paying.';

  @override
  String get declFilingGuideTitle => 'Filing on ae.gov.ma (overview)';

  @override
  String get declFilingStep1 =>
      'Log in to the ae.gov.ma portal with your auto-entrepreneur credentials.';

  @override
  String get declFilingStep2 =>
      'Open the quarterly declaration (déclaration trimestrielle) for the correct period.';

  @override
  String get declFilingStep3 =>
      'Enter the revenue and contribution amounts consistent with your records and official tables.';

  @override
  String get declFilingStep4 =>
      'Validate, pay or schedule payment as required, and keep the receipt.';

  @override
  String get declSaveRecord => 'Save declaration record';

  @override
  String get declSaved => 'Declaration saved.';

  @override
  String get declSaveError => 'Could not save. Try again.';

  @override
  String get declMarkFiled => 'Mark as filed';

  @override
  String declFiledOn(String date) {
    return 'Filed on $date';
  }

  @override
  String get declChooseFiledDate => 'Date filed';

  @override
  String get declStatusDraft => 'Draft';

  @override
  String get declStatusReady => 'Ready to file';

  @override
  String get declStatusFiled => 'Filed';

  @override
  String get declHistoryTitle => 'Saved declarations';

  @override
  String get declHistoryEmpty =>
      'No saved declarations yet. Open a quarter and tap \"Save declaration record\".';

  @override
  String get declOpenQuarter => 'Open a quarter';

  @override
  String get declPickQuarterTitle => 'Quarter';

  @override
  String get declYear => 'Year';

  @override
  String get declQuarter => 'Quarter';

  @override
  String get declGo => 'Open';

  @override
  String get onboardingActivityTitle => 'Your activity type';

  @override
  String get onboardingActivitySubtitle =>
      'Choose the category that best describes your auto-entrepreneur activity. It sets which IR rate schedule applies.';

  @override
  String get onboardingContinue => 'Continue to app';

  @override
  String get onboardingSaved => 'Activity category saved.';

  @override
  String get onboardingError => 'Could not save. Try again.';
}
