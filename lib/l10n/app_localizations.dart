import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr'),
  ];

  /// Application title
  ///
  /// In en, this message translates to:
  /// **'Auto-Entrepreneur Manager'**
  String get appTitle;

  /// No description provided for @navDashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get navDashboard;

  /// No description provided for @navInvoices.
  ///
  /// In en, this message translates to:
  /// **'Invoices'**
  String get navInvoices;

  /// No description provided for @navExpenses.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get navExpenses;

  /// No description provided for @navTax.
  ///
  /// In en, this message translates to:
  /// **'Tax'**
  String get navTax;

  /// No description provided for @navMore.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get navMore;

  /// No description provided for @screenLogin.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get screenLogin;

  /// No description provided for @screenSignUp.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get screenSignUp;

  /// No description provided for @screenDashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get screenDashboard;

  /// No description provided for @screenInvoices.
  ///
  /// In en, this message translates to:
  /// **'Invoices'**
  String get screenInvoices;

  /// No description provided for @screenInvoiceDetail.
  ///
  /// In en, this message translates to:
  /// **'Invoice'**
  String get screenInvoiceDetail;

  /// No description provided for @screenExpenses.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get screenExpenses;

  /// No description provided for @screenExpenseDetail.
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get screenExpenseDetail;

  /// No description provided for @screenDeclarations.
  ///
  /// In en, this message translates to:
  /// **'Declarations'**
  String get screenDeclarations;

  /// No description provided for @screenDeclarationDetail.
  ///
  /// In en, this message translates to:
  /// **'Quarterly declaration'**
  String get screenDeclarationDetail;

  /// No description provided for @screenMore.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get screenMore;

  /// No description provided for @screenClients.
  ///
  /// In en, this message translates to:
  /// **'Clients'**
  String get screenClients;

  /// No description provided for @screenClientDetail.
  ///
  /// In en, this message translates to:
  /// **'Client'**
  String get screenClientDetail;

  /// No description provided for @screenServices.
  ///
  /// In en, this message translates to:
  /// **'Services'**
  String get screenServices;

  /// No description provided for @screenProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile & settings'**
  String get screenProfile;

  /// No description provided for @authEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get authEmail;

  /// No description provided for @authPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get authPassword;

  /// No description provided for @authConfirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get authConfirmPassword;

  /// No description provided for @authSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get authSignIn;

  /// No description provided for @authSignUp.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get authSignUp;

  /// No description provided for @authSignInWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get authSignInWithGoogle;

  /// No description provided for @authNoAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get authNoAccount;

  /// No description provided for @authHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get authHaveAccount;

  /// No description provided for @authSignUpLink.
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get authSignUpLink;

  /// No description provided for @authSignInLink.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get authSignInLink;

  /// No description provided for @authSignOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get authSignOut;

  /// No description provided for @authErrorInvalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Invalid email or password.'**
  String get authErrorInvalidCredentials;

  /// No description provided for @authErrorEmailInUse.
  ///
  /// In en, this message translates to:
  /// **'This email is already in use.'**
  String get authErrorEmailInUse;

  /// No description provided for @authErrorWeakPassword.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters.'**
  String get authErrorWeakPassword;

  /// No description provided for @authErrorPasswordMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match.'**
  String get authErrorPasswordMismatch;

  /// No description provided for @authErrorGeneric.
  ///
  /// In en, this message translates to:
  /// **'An error occurred. Please try again.'**
  String get authErrorGeneric;

  /// No description provided for @placeholderDashboard.
  ///
  /// In en, this message translates to:
  /// **'Revenue summary, declaration deadlines, and outstanding invoices will appear here.'**
  String get placeholderDashboard;

  /// No description provided for @dashboardTagline.
  ///
  /// In en, this message translates to:
  /// **'Revenue, cash flow, and compliance — in one place.'**
  String get dashboardTagline;

  /// No description provided for @dashboardStatsHint.
  ///
  /// In en, this message translates to:
  /// **'Totals update as you create and collect invoices.'**
  String get dashboardStatsHint;

  /// No description provided for @dashboardSectionShortcuts.
  ///
  /// In en, this message translates to:
  /// **'Shortcuts'**
  String get dashboardSectionShortcuts;

  /// No description provided for @moreSectionBusiness.
  ///
  /// In en, this message translates to:
  /// **'Business'**
  String get moreSectionBusiness;

  /// No description provided for @moreSectionAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get moreSectionAccount;

  /// No description provided for @placeholderInvoices.
  ///
  /// In en, this message translates to:
  /// **'Create and manage invoices linked to clients.'**
  String get placeholderInvoices;

  /// No description provided for @placeholderInvoiceDetail.
  ///
  /// In en, this message translates to:
  /// **'Invoice details and line items.'**
  String get placeholderInvoiceDetail;

  /// No description provided for @placeholderExpenses.
  ///
  /// In en, this message translates to:
  /// **'Log expenses with categories and receipt attachments.'**
  String get placeholderExpenses;

  /// No description provided for @placeholderExpenseDetail.
  ///
  /// In en, this message translates to:
  /// **'Expense details.'**
  String get placeholderExpenseDetail;

  /// No description provided for @placeholderDeclarations.
  ///
  /// In en, this message translates to:
  /// **'Quarterly IR and CNSS guidance and history.'**
  String get placeholderDeclarations;

  /// No description provided for @placeholderDeclarationDetail.
  ///
  /// In en, this message translates to:
  /// **'Filing guide and amounts for this quarter.'**
  String get placeholderDeclarationDetail;

  /// No description provided for @placeholderMore.
  ///
  /// In en, this message translates to:
  /// **'Clients, service catalog, and profile.'**
  String get placeholderMore;

  /// No description provided for @placeholderClients.
  ///
  /// In en, this message translates to:
  /// **'Manage client records (ICE, IF, contact).'**
  String get placeholderClients;

  /// No description provided for @placeholderClientDetail.
  ///
  /// In en, this message translates to:
  /// **'Client details and linked invoices.'**
  String get placeholderClientDetail;

  /// No description provided for @placeholderServices.
  ///
  /// In en, this message translates to:
  /// **'Reusable services and products for invoices.'**
  String get placeholderServices;

  /// No description provided for @placeholderProfile.
  ///
  /// In en, this message translates to:
  /// **'Business profile, branding, and tax activity category.'**
  String get placeholderProfile;

  /// No description provided for @actionSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get actionSave;

  /// No description provided for @actionCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get actionCancel;

  /// No description provided for @actionDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get actionDone;

  /// No description provided for @actionDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get actionDelete;

  /// No description provided for @profileSectionLegal.
  ///
  /// In en, this message translates to:
  /// **'Legal identity'**
  String get profileSectionLegal;

  /// No description provided for @profileFieldBusinessName.
  ///
  /// In en, this message translates to:
  /// **'Business / legal name'**
  String get profileFieldBusinessName;

  /// No description provided for @profileFieldCin.
  ///
  /// In en, this message translates to:
  /// **'CIN'**
  String get profileFieldCin;

  /// No description provided for @profileFieldIce.
  ///
  /// In en, this message translates to:
  /// **'ICE'**
  String get profileFieldIce;

  /// No description provided for @profileFieldIf.
  ///
  /// In en, this message translates to:
  /// **'IF (tax identifier)'**
  String get profileFieldIf;

  /// No description provided for @profileFieldCnss.
  ///
  /// In en, this message translates to:
  /// **'CNSS number'**
  String get profileFieldCnss;

  /// No description provided for @profileFieldTaxProfessionnelle.
  ///
  /// In en, this message translates to:
  /// **'Professional tax number (TP)'**
  String get profileFieldTaxProfessionnelle;

  /// No description provided for @profileFieldPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get profileFieldPhone;

  /// No description provided for @profileFieldAddress.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get profileFieldAddress;

  /// No description provided for @profileHasCnssLabel.
  ///
  /// In en, this message translates to:
  /// **'Already covered by CNSS'**
  String get profileHasCnssLabel;

  /// No description provided for @profileHasCnssHint.
  ///
  /// In en, this message translates to:
  /// **'Enable if you pay CNSS through another scheme (e.g. salaried employment). Your AE declaration will then show 0 MAD for CNSS.'**
  String get profileHasCnssHint;

  /// No description provided for @profileSectionActivity.
  ///
  /// In en, this message translates to:
  /// **'Activity category'**
  String get profileSectionActivity;

  /// No description provided for @activityCommercialShort.
  ///
  /// In en, this message translates to:
  /// **'Commercial'**
  String get activityCommercialShort;

  /// No description provided for @activityArtisanalShort.
  ///
  /// In en, this message translates to:
  /// **'Artisanal'**
  String get activityArtisanalShort;

  /// No description provided for @activityLiberalShort.
  ///
  /// In en, this message translates to:
  /// **'Liberal'**
  String get activityLiberalShort;

  /// No description provided for @activityCommercialTitle.
  ///
  /// In en, this message translates to:
  /// **'Commercial activities'**
  String get activityCommercialTitle;

  /// No description provided for @activityCommercialBody.
  ///
  /// In en, this message translates to:
  /// **'Buying and selling goods, import/export, e-commerce, and similar trading. IR and CNSS rates for this family differ from other categories — your declaration uses the category saved here.'**
  String get activityCommercialBody;

  /// No description provided for @activityArtisanalTitle.
  ///
  /// In en, this message translates to:
  /// **'Artisanal activities'**
  String get activityArtisanalTitle;

  /// No description provided for @activityArtisanalBody.
  ///
  /// In en, this message translates to:
  /// **'Craft production and related services (e.g. workshops, manual trades). Rates are specific to artisanal auto-entrepreneurs.'**
  String get activityArtisanalBody;

  /// No description provided for @activityLiberalTitle.
  ///
  /// In en, this message translates to:
  /// **'Liberal professions'**
  String get activityLiberalTitle;

  /// No description provided for @activityLiberalBody.
  ///
  /// In en, this message translates to:
  /// **'Professional services (consulting, design, IT services, etc.). Uses the liberal-profession contribution schedule.'**
  String get activityLiberalBody;

  /// No description provided for @activityServicesShort.
  ///
  /// In en, this message translates to:
  /// **'Services'**
  String get activityServicesShort;

  /// No description provided for @activityServicesTitle.
  ///
  /// In en, this message translates to:
  /// **'Service activities'**
  String get activityServicesTitle;

  /// No description provided for @activityServicesBody.
  ///
  /// In en, this message translates to:
  /// **'Service providers (training, coaching, events, etc.). Benefits from a reduced 1% IR rate — confirm your eligibility with your tax office.'**
  String get activityServicesBody;

  /// No description provided for @profileSectionBranding.
  ///
  /// In en, this message translates to:
  /// **'Invoice branding'**
  String get profileSectionBranding;

  /// No description provided for @profilePickLogo.
  ///
  /// In en, this message translates to:
  /// **'Upload logo'**
  String get profilePickLogo;

  /// No description provided for @profileRemoveLogo.
  ///
  /// In en, this message translates to:
  /// **'Remove logo'**
  String get profileRemoveLogo;

  /// No description provided for @profileBrandingColor.
  ///
  /// In en, this message translates to:
  /// **'Accent color'**
  String get profileBrandingColor;

  /// No description provided for @profileBrandingColorHint.
  ///
  /// In en, this message translates to:
  /// **'Used on invoice headers and PDF accents.'**
  String get profileBrandingColorHint;

  /// No description provided for @profileInvoiceTemplate.
  ///
  /// In en, this message translates to:
  /// **'Invoice layout'**
  String get profileInvoiceTemplate;

  /// No description provided for @templateDefault.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get templateDefault;

  /// No description provided for @templateBordered.
  ///
  /// In en, this message translates to:
  /// **'Bordered'**
  String get templateBordered;

  /// No description provided for @profileBrandingPreviewHint.
  ///
  /// In en, this message translates to:
  /// **'Preview of how branding may appear on invoices (Phase 3 PDF).'**
  String get profileBrandingPreviewHint;

  /// No description provided for @profileSectionSignature.
  ///
  /// In en, this message translates to:
  /// **'Signature'**
  String get profileSectionSignature;

  /// No description provided for @profileRemoveSignature.
  ///
  /// In en, this message translates to:
  /// **'Remove signature'**
  String get profileRemoveSignature;

  /// No description provided for @profileSignatureClear.
  ///
  /// In en, this message translates to:
  /// **'Clear pad'**
  String get profileSignatureClear;

  /// No description provided for @profileSignatureSaveDrawn.
  ///
  /// In en, this message translates to:
  /// **'Save drawn signature'**
  String get profileSignatureSaveDrawn;

  /// No description provided for @profileSignatureUpload.
  ///
  /// In en, this message translates to:
  /// **'Upload image'**
  String get profileSignatureUpload;

  /// No description provided for @profileSaved.
  ///
  /// In en, this message translates to:
  /// **'Profile saved.'**
  String get profileSaved;

  /// No description provided for @profileSaveError.
  ///
  /// In en, this message translates to:
  /// **'Could not save profile. Check your connection.'**
  String get profileSaveError;

  /// No description provided for @profileLogoUploaded.
  ///
  /// In en, this message translates to:
  /// **'Logo updated.'**
  String get profileLogoUploaded;

  /// No description provided for @profileUploadError.
  ///
  /// In en, this message translates to:
  /// **'Upload failed. Try again.'**
  String get profileUploadError;

  /// No description provided for @profileSignatureEmpty.
  ///
  /// In en, this message translates to:
  /// **'Draw your signature first.'**
  String get profileSignatureEmpty;

  /// No description provided for @profileSignatureSaved.
  ///
  /// In en, this message translates to:
  /// **'Signature saved.'**
  String get profileSignatureSaved;

  /// No description provided for @profileIncompleteHint.
  ///
  /// In en, this message translates to:
  /// **'Complete all legal fields below before you can create invoices.'**
  String get profileIncompleteHint;

  /// No description provided for @clientAddTitle.
  ///
  /// In en, this message translates to:
  /// **'New client'**
  String get clientAddTitle;

  /// No description provided for @clientEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit client'**
  String get clientEditTitle;

  /// No description provided for @clientFieldName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get clientFieldName;

  /// No description provided for @clientFieldAddress.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get clientFieldAddress;

  /// No description provided for @clientFieldIce.
  ///
  /// In en, this message translates to:
  /// **'ICE'**
  String get clientFieldIce;

  /// No description provided for @clientFieldIf.
  ///
  /// In en, this message translates to:
  /// **'IF'**
  String get clientFieldIf;

  /// No description provided for @clientFieldEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get clientFieldEmail;

  /// No description provided for @clientFieldPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get clientFieldPhone;

  /// No description provided for @clientValidationRequired.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get clientValidationRequired;

  /// No description provided for @clientSaved.
  ///
  /// In en, this message translates to:
  /// **'Client saved.'**
  String get clientSaved;

  /// No description provided for @clientSaveError.
  ///
  /// In en, this message translates to:
  /// **'Could not save. Try again.'**
  String get clientSaveError;

  /// No description provided for @clientDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete client?'**
  String get clientDeleteTitle;

  /// No description provided for @clientDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'This cannot be undone. Invoices already linked in Phase 3 remain in your account.'**
  String get clientDeleteBody;

  /// No description provided for @clientListError.
  ///
  /// In en, this message translates to:
  /// **'Could not load clients.'**
  String get clientListError;

  /// No description provided for @clientListEmpty.
  ///
  /// In en, this message translates to:
  /// **'No clients yet. Tap + to add your first client.'**
  String get clientListEmpty;

  /// No description provided for @clientNotFound.
  ///
  /// In en, this message translates to:
  /// **'Client not found.'**
  String get clientNotFound;

  /// No description provided for @clientLinkedInvoices.
  ///
  /// In en, this message translates to:
  /// **'Invoices for this client'**
  String get clientLinkedInvoices;

  /// No description provided for @clientNoInvoicesYet.
  ///
  /// In en, this message translates to:
  /// **'No invoices yet. They will appear here once you create them (Phase 3).'**
  String get clientNoInvoicesYet;

  /// No description provided for @invoiceNewAction.
  ///
  /// In en, this message translates to:
  /// **'New invoice'**
  String get invoiceNewAction;

  /// No description provided for @invoiceProfileRequiredTitle.
  ///
  /// In en, this message translates to:
  /// **'Complete your profile'**
  String get invoiceProfileRequiredTitle;

  /// No description provided for @invoiceProfileRequiredBody.
  ///
  /// In en, this message translates to:
  /// **'Add your legal business details (ICE, IF, CNSS, etc.) before creating invoices.'**
  String get invoiceProfileRequiredBody;

  /// No description provided for @invoiceGoToProfile.
  ///
  /// In en, this message translates to:
  /// **'Open profile'**
  String get invoiceGoToProfile;

  /// No description provided for @invoiceFormCreateTitle.
  ///
  /// In en, this message translates to:
  /// **'New invoice'**
  String get invoiceFormCreateTitle;

  /// No description provided for @invoiceFormEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit invoice'**
  String get invoiceFormEditTitle;

  /// No description provided for @invoiceNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Invoice number'**
  String get invoiceNumberLabel;

  /// No description provided for @invoiceFieldClient.
  ///
  /// In en, this message translates to:
  /// **'Client'**
  String get invoiceFieldClient;

  /// No description provided for @invoiceFieldIssueDate.
  ///
  /// In en, this message translates to:
  /// **'Issue date'**
  String get invoiceFieldIssueDate;

  /// No description provided for @invoiceFieldDueDate.
  ///
  /// In en, this message translates to:
  /// **'Due date'**
  String get invoiceFieldDueDate;

  /// No description provided for @invoiceFieldStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get invoiceFieldStatus;

  /// No description provided for @invoiceFieldNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get invoiceFieldNotes;

  /// No description provided for @invoiceLineItems.
  ///
  /// In en, this message translates to:
  /// **'Line items'**
  String get invoiceLineItems;

  /// No description provided for @invoiceLineDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get invoiceLineDescription;

  /// No description provided for @invoiceLineQty.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get invoiceLineQty;

  /// No description provided for @invoiceLineUnitPrice.
  ///
  /// In en, this message translates to:
  /// **'Unit price (MAD)'**
  String get invoiceLineUnitPrice;

  /// No description provided for @invoiceAddLine.
  ///
  /// In en, this message translates to:
  /// **'Add line'**
  String get invoiceAddLine;

  /// No description provided for @invoiceSignatureOnPdf.
  ///
  /// In en, this message translates to:
  /// **'Include signature on PDF'**
  String get invoiceSignatureOnPdf;

  /// No description provided for @invoiceFormValidation.
  ///
  /// In en, this message translates to:
  /// **'Select a client and add at least one line with a description.'**
  String get invoiceFormValidation;

  /// No description provided for @invoiceSaved.
  ///
  /// In en, this message translates to:
  /// **'Invoice saved.'**
  String get invoiceSaved;

  /// No description provided for @invoiceSaveError.
  ///
  /// In en, this message translates to:
  /// **'Could not save invoice.'**
  String get invoiceSaveError;

  /// No description provided for @invoiceSectionSeller.
  ///
  /// In en, this message translates to:
  /// **'Seller (your business)'**
  String get invoiceSectionSeller;

  /// No description provided for @invoiceSectionClient.
  ///
  /// In en, this message translates to:
  /// **'Client (on invoice)'**
  String get invoiceSectionClient;

  /// No description provided for @invoiceProfileMissing.
  ///
  /// In en, this message translates to:
  /// **'Complete your profile to export PDF.'**
  String get invoiceProfileMissing;

  /// No description provided for @invoiceOverdueBanner.
  ///
  /// In en, this message translates to:
  /// **'This invoice is past its due date and still has a balance.'**
  String get invoiceOverdueBanner;

  /// No description provided for @invoicePartiallyPaidBanner.
  ///
  /// In en, this message translates to:
  /// **'Partially paid — balance remains.'**
  String get invoicePartiallyPaidBanner;

  /// No description provided for @invoiceTotal.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get invoiceTotal;

  /// No description provided for @invoicePaid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get invoicePaid;

  /// No description provided for @invoiceBalance.
  ///
  /// In en, this message translates to:
  /// **'Balance due'**
  String get invoiceBalance;

  /// No description provided for @invoicePaymentsSection.
  ///
  /// In en, this message translates to:
  /// **'Payments'**
  String get invoicePaymentsSection;

  /// No description provided for @invoiceNoPayments.
  ///
  /// In en, this message translates to:
  /// **'No payments recorded yet.'**
  String get invoiceNoPayments;

  /// No description provided for @invoiceAddPayment.
  ///
  /// In en, this message translates to:
  /// **'Record payment'**
  String get invoiceAddPayment;

  /// No description provided for @invoiceEditPayment.
  ///
  /// In en, this message translates to:
  /// **'Edit payment'**
  String get invoiceEditPayment;

  /// No description provided for @invoiceDeletePayment.
  ///
  /// In en, this message translates to:
  /// **'Delete payment'**
  String get invoiceDeletePayment;

  /// No description provided for @invoiceDeletePaymentConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete this payment of {amount}?'**
  String invoiceDeletePaymentConfirm(String amount);

  /// No description provided for @invoicePaymentAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount (MAD)'**
  String get invoicePaymentAmount;

  /// No description provided for @invoicePaymentDate.
  ///
  /// In en, this message translates to:
  /// **'Payment date'**
  String get invoicePaymentDate;

  /// No description provided for @invoicePaymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Method'**
  String get invoicePaymentMethod;

  /// No description provided for @paymentMethodCash.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get paymentMethodCash;

  /// No description provided for @paymentMethodVirement.
  ///
  /// In en, this message translates to:
  /// **'Bank transfer'**
  String get paymentMethodVirement;

  /// No description provided for @paymentMethodCheque.
  ///
  /// In en, this message translates to:
  /// **'Cheque'**
  String get paymentMethodCheque;

  /// No description provided for @paymentMethodAutre.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get paymentMethodAutre;

  /// No description provided for @invoiceStatusDraft.
  ///
  /// In en, this message translates to:
  /// **'Draft'**
  String get invoiceStatusDraft;

  /// No description provided for @invoiceStatusSent.
  ///
  /// In en, this message translates to:
  /// **'Sent'**
  String get invoiceStatusSent;

  /// No description provided for @invoiceStatusPaid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get invoiceStatusPaid;

  /// No description provided for @invoiceStatusOverdue.
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get invoiceStatusOverdue;

  /// No description provided for @invoiceListEmpty.
  ///
  /// In en, this message translates to:
  /// **'No invoices yet. Tap + to create one.'**
  String get invoiceListEmpty;

  /// No description provided for @invoiceBadgeOverdue.
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get invoiceBadgeOverdue;

  /// No description provided for @invoiceBadgePartial.
  ///
  /// In en, this message translates to:
  /// **'Partial'**
  String get invoiceBadgePartial;

  /// No description provided for @invoicePdfError.
  ///
  /// In en, this message translates to:
  /// **'Could not build PDF. Please try again.'**
  String get invoicePdfError;

  /// No description provided for @declTaxConfigMissing.
  ///
  /// In en, this message translates to:
  /// **'Tax rates are not configured. An administrator must create the Firestore document config/taxRates (see config/taxRates.firestore.json in the project).'**
  String get declTaxConfigMissing;

  /// No description provided for @declLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load declaration data. Check your connection.'**
  String get declLoadError;

  /// No description provided for @declRevenueQuarter.
  ///
  /// In en, this message translates to:
  /// **'Cash-basis revenue this quarter'**
  String get declRevenueQuarter;

  /// No description provided for @declRevenueHint.
  ///
  /// In en, this message translates to:
  /// **'Sum of invoice payments dated in this quarter.'**
  String get declRevenueHint;

  /// No description provided for @declIrDue.
  ///
  /// In en, this message translates to:
  /// **'Income tax (IR) due'**
  String get declIrDue;

  /// No description provided for @declCnssDue.
  ///
  /// In en, this message translates to:
  /// **'CNSS contribution due'**
  String get declCnssDue;

  /// No description provided for @declCnssBase.
  ///
  /// In en, this message translates to:
  /// **'CNSS base (after minimum)'**
  String get declCnssBase;

  /// No description provided for @declCnssExempt.
  ///
  /// In en, this message translates to:
  /// **'Exempt — you already contribute to CNSS through another scheme'**
  String get declCnssExempt;

  /// No description provided for @declRatesVersion.
  ///
  /// In en, this message translates to:
  /// **'Rate table version: {version}'**
  String declRatesVersion(int version);

  /// No description provided for @declDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'These amounts are estimates based on the rate table in the app. Laws and CNSS rules change — confirm every figure with DGI and CNSS before paying.'**
  String get declDisclaimer;

  /// No description provided for @declFilingGuideTitle.
  ///
  /// In en, this message translates to:
  /// **'Filing on ae.gov.ma (overview)'**
  String get declFilingGuideTitle;

  /// No description provided for @declFilingStep1.
  ///
  /// In en, this message translates to:
  /// **'Log in to the ae.gov.ma portal with your auto-entrepreneur credentials.'**
  String get declFilingStep1;

  /// No description provided for @declFilingStep2.
  ///
  /// In en, this message translates to:
  /// **'Open the quarterly declaration (déclaration trimestrielle) for the correct period.'**
  String get declFilingStep2;

  /// No description provided for @declFilingStep3.
  ///
  /// In en, this message translates to:
  /// **'Enter the revenue and contribution amounts consistent with your records and official tables.'**
  String get declFilingStep3;

  /// No description provided for @declFilingStep4.
  ///
  /// In en, this message translates to:
  /// **'Validate, pay or schedule payment as required, and keep the receipt.'**
  String get declFilingStep4;

  /// No description provided for @declSaveRecord.
  ///
  /// In en, this message translates to:
  /// **'Save declaration record'**
  String get declSaveRecord;

  /// No description provided for @declSaved.
  ///
  /// In en, this message translates to:
  /// **'Declaration saved.'**
  String get declSaved;

  /// No description provided for @declSaveError.
  ///
  /// In en, this message translates to:
  /// **'Could not save. Try again.'**
  String get declSaveError;

  /// No description provided for @declMarkFiled.
  ///
  /// In en, this message translates to:
  /// **'Mark as filed'**
  String get declMarkFiled;

  /// No description provided for @declFiledOn.
  ///
  /// In en, this message translates to:
  /// **'Filed on {date}'**
  String declFiledOn(String date);

  /// No description provided for @declChooseFiledDate.
  ///
  /// In en, this message translates to:
  /// **'Date filed'**
  String get declChooseFiledDate;

  /// No description provided for @declStatusDraft.
  ///
  /// In en, this message translates to:
  /// **'Draft'**
  String get declStatusDraft;

  /// No description provided for @declStatusReady.
  ///
  /// In en, this message translates to:
  /// **'Ready to file'**
  String get declStatusReady;

  /// No description provided for @declStatusFiled.
  ///
  /// In en, this message translates to:
  /// **'Filed'**
  String get declStatusFiled;

  /// No description provided for @declHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Saved declarations'**
  String get declHistoryTitle;

  /// No description provided for @declHistoryEmpty.
  ///
  /// In en, this message translates to:
  /// **'No saved declarations yet. Open a quarter and tap \"Save declaration record\".'**
  String get declHistoryEmpty;

  /// No description provided for @declOpenQuarter.
  ///
  /// In en, this message translates to:
  /// **'Open a quarter'**
  String get declOpenQuarter;

  /// No description provided for @declPickQuarterTitle.
  ///
  /// In en, this message translates to:
  /// **'Quarter'**
  String get declPickQuarterTitle;

  /// No description provided for @declYear.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get declYear;

  /// No description provided for @declQuarter.
  ///
  /// In en, this message translates to:
  /// **'Quarter'**
  String get declQuarter;

  /// No description provided for @declGo.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get declGo;

  /// No description provided for @onboardingActivityTitle.
  ///
  /// In en, this message translates to:
  /// **'Your activity type'**
  String get onboardingActivityTitle;

  /// No description provided for @onboardingActivitySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose the category that best describes your auto-entrepreneur activity. It sets which IR rate schedule applies.'**
  String get onboardingActivitySubtitle;

  /// No description provided for @onboardingContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue to app'**
  String get onboardingContinue;

  /// No description provided for @onboardingSaved.
  ///
  /// In en, this message translates to:
  /// **'Activity category saved.'**
  String get onboardingSaved;

  /// No description provided for @onboardingError.
  ///
  /// In en, this message translates to:
  /// **'Could not save. Try again.'**
  String get onboardingError;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
