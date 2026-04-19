// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Gestionnaire auto-entrepreneur';

  @override
  String get navDashboard => 'Tableau de bord';

  @override
  String get navInvoices => 'Factures';

  @override
  String get navExpenses => 'Dépenses';

  @override
  String get navTax => 'Fiscalité';

  @override
  String get navMore => 'Plus';

  @override
  String get screenLogin => 'Connexion';

  @override
  String get screenSignUp => 'Créer un compte';

  @override
  String get screenDashboard => 'Tableau de bord';

  @override
  String get screenInvoices => 'Factures';

  @override
  String get screenInvoiceDetail => 'Facture';

  @override
  String get screenExpenses => 'Dépenses';

  @override
  String get screenExpenseDetail => 'Dépense';

  @override
  String get screenDeclarations => 'Déclarations';

  @override
  String get screenDeclarationDetail => 'Déclaration trimestrielle';

  @override
  String get screenMore => 'Plus';

  @override
  String get screenClients => 'Clients';

  @override
  String get screenClientDetail => 'Client';

  @override
  String get screenServices => 'Prestations';

  @override
  String get screenProfile => 'Profil et réglages';

  @override
  String get authEmail => 'Adresse e-mail';

  @override
  String get authPassword => 'Mot de passe';

  @override
  String get authConfirmPassword => 'Confirmer le mot de passe';

  @override
  String get authSignIn => 'Se connecter';

  @override
  String get authSignUp => 'Créer un compte';

  @override
  String get authSignInWithGoogle => 'Continuer avec Google';

  @override
  String get authNoAccount => 'Pas encore de compte ?';

  @override
  String get authHaveAccount => 'Déjà un compte ?';

  @override
  String get authSignUpLink => 'S\'inscrire';

  @override
  String get authSignInLink => 'Se connecter';

  @override
  String get authSignOut => 'Se déconnecter';

  @override
  String get authErrorInvalidCredentials => 'E-mail ou mot de passe incorrect.';

  @override
  String get authErrorEmailInUse => 'Cette adresse e-mail est déjà utilisée.';

  @override
  String get authErrorWeakPassword =>
      'Le mot de passe doit contenir au moins 6 caractères.';

  @override
  String get authErrorPasswordMismatch =>
      'Les mots de passe ne correspondent pas.';

  @override
  String get authErrorGeneric =>
      'Une erreur s\'est produite. Veuillez réessayer.';

  @override
  String get placeholderDashboard =>
      'Résumé du chiffre d\'affaires, échéances et factures en attente s\'afficheront ici.';

  @override
  String get dashboardTagline =>
      'CA, trésorerie et obligations — au même endroit.';

  @override
  String get dashboardStatsHint =>
      'Les totaux se mettent à jour au fil des factures et encaissements.';

  @override
  String get dashboardSectionShortcuts => 'Raccourcis';

  @override
  String dashboardDeclarationBannerActive(
    int quarter,
    int year,
    int daysRemaining,
    String deadline,
  ) {
    String _temp0 = intl.Intl.pluralLogic(
      daysRemaining,
      locale: localeName,
      other: '$daysRemaining jours',
      one: '1 jour',
    );
    return 'Déclaration Q$quarter $year : il reste $_temp0 (échéance le $deadline).';
  }

  @override
  String dashboardDeclarationBannerLastDay(
    int quarter,
    int year,
    String deadline,
  ) {
    return 'Déclaration Q$quarter $year : dernier jour pour déposer (échéance le $deadline).';
  }

  @override
  String dashboardDeclarationBannerOverdue(
    int quarter,
    int year,
    int daysOverdue,
    String deadline,
  ) {
    String _temp0 = intl.Intl.pluralLogic(
      daysOverdue,
      locale: localeName,
      other: '$daysOverdue jours',
      one: '1 jour',
    );
    return 'Déclaration Q$quarter $year : en retard de $_temp0 (échéance le $deadline).';
  }

  @override
  String get dashboardDeclarationBannerOpen => 'Ouvrir la déclaration';

  @override
  String get moreSectionBusiness => 'Activité';

  @override
  String get moreSectionAccount => 'Compte';

  @override
  String get placeholderInvoices =>
      'Créez et gérez les factures liées aux clients.';

  @override
  String get placeholderInvoiceDetail => 'Détails de la facture et lignes.';

  @override
  String get placeholderExpenses =>
      'Enregistrez les dépenses avec catégories et justificatifs.';

  @override
  String get placeholderExpenseDetail => 'Détails de la dépense.';

  @override
  String get placeholderDeclarations =>
      'Guide trimestriel IR et CNSS et historique.';

  @override
  String get placeholderDeclarationDetail =>
      'Guide de déclaration et montants pour ce trimestre.';

  @override
  String get placeholderMore => 'Clients, catalogue de prestations et profil.';

  @override
  String get placeholderClients =>
      'Gérez les fiches clients (ICE, IF, contact).';

  @override
  String get placeholderClientDetail => 'Détails du client et factures liées.';

  @override
  String get placeholderServices =>
      'Prestations et produits réutilisables pour les factures.';

  @override
  String get placeholderProfile =>
      'Profil d\'entreprise, image de marque et catégorie d\'activité.';

  @override
  String get actionSave => 'Enregistrer';

  @override
  String get actionCancel => 'Annuler';

  @override
  String get actionDone => 'OK';

  @override
  String get actionDelete => 'Supprimer';

  @override
  String get profileSectionLegal => 'Identité légale';

  @override
  String get profileFieldBusinessName => 'Raison sociale / nom légal';

  @override
  String get profileFieldCin => 'CIN';

  @override
  String get profileFieldIce => 'ICE';

  @override
  String get profileFieldIf => 'IF (identifiant fiscal)';

  @override
  String get profileFieldCnss => 'Numéro CNSS';

  @override
  String get profileFieldTaxProfessionnelle => 'Numéro Taxe professionnelle';

  @override
  String get profileFieldPhone => 'Téléphone';

  @override
  String get profileFieldAddress => 'Adresse';

  @override
  String get profileHasCnssLabel => 'Déjà couvert par la CNSS';

  @override
  String get profileHasCnssHint =>
      'Activez si vous cotisez à la CNSS par un autre régime (ex. salarié). Votre déclaration AE affichera alors 0 MAD pour la CNSS.';

  @override
  String get profileSectionInvoiceNumbers => 'Numérotation des factures';

  @override
  String get profileInvoicePrefixLabel => 'Préfixe de facture';

  @override
  String get profileInvoicePrefixHint =>
      'Court texte comme INV ou FA (inséré partout où le motif utilise le jeton prefix).';

  @override
  String get profileInvoicePatternLabel => 'Format du numéro';

  @override
  String get profileInvoicePatternHint =>
      'Utilisez les jetons prefix, year et count — chacun entre accolades. Séparateurs et ordre libres. Le motif par défaut donne par ex. INV_2026_045. Le jeton count est obligatoire.';

  @override
  String get profileInvoiceCountDigitsLabel => 'Chiffres pour la séquence';

  @override
  String get profileInvoiceCountDigitsHint =>
      'Largeur minimale du compteur annuel (ex. 3 → 045).';

  @override
  String get profileInvoicePreview => 'Aperçu';

  @override
  String get profileInvoicePatternInvalid =>
      'Le format doit inclure le jeton count (entre accolades) pour un numéro séquentiel unique par année.';

  @override
  String get profileSectionActivity => 'Catégorie d\'activité';

  @override
  String get activityCommercialShort => 'Commerce';

  @override
  String get activityArtisanalShort => 'Artisanat';

  @override
  String get activityLiberalShort => 'Libéral';

  @override
  String get activityCommercialTitle => 'Activités commerciales';

  @override
  String get activityCommercialBody =>
      'Achat/revente, import-export, commerce en ligne. Les taux IR et CNSS diffèrent selon la famille d\'activité — la déclaration utilise la catégorie enregistrée ici.';

  @override
  String get activityArtisanalTitle => 'Activités artisanales';

  @override
  String get activityArtisanalBody =>
      'Fabrication artisanale et services associés (ateliers, métiers manuels). Taux spécifiques aux auto-entrepreneurs artisans.';

  @override
  String get activityLiberalTitle => 'Professions libérales';

  @override
  String get activityLiberalBody =>
      'Prestations intellectuelles (conseil, design, informatique, etc.). Barème des professions libérales.';

  @override
  String get activityServicesShort => 'Services';

  @override
  String get activityServicesTitle => 'Activités de services';

  @override
  String get activityServicesBody =>
      'Prestataires de services (formation, coaching, événements, etc.). Bénéficie d\'un taux IR réduit de 1% — vérifiez votre éligibilité auprès de votre centre des impôts.';

  @override
  String get profileSectionBranding => 'Image de facture';

  @override
  String get profilePickLogo => 'Importer un logo';

  @override
  String get profileRemoveLogo => 'Retirer le logo';

  @override
  String get profileBrandingColor => 'Couleur d\'accent';

  @override
  String get profileBrandingColorHint =>
      'Utilisée pour les en-têtes et le PDF.';

  @override
  String get profileInvoiceTemplate => 'Mise en page';

  @override
  String get templateDefault => 'Classique';

  @override
  String get templateBordered => 'Avec encadré';

  @override
  String get profileBrandingPreviewHint =>
      'Aperçu du rendu sur les factures (PDF en phase 3).';

  @override
  String get profileSectionSignature => 'Signature';

  @override
  String get profileRemoveSignature => 'Supprimer la signature';

  @override
  String get profileSignatureClear => 'Effacer';

  @override
  String get profileSignatureSaveDrawn => 'Enregistrer le dessin';

  @override
  String get profileSignatureUpload => 'Importer une image';

  @override
  String get profileSaved => 'Profil enregistré.';

  @override
  String get profileSaveError =>
      'Enregistrement impossible. Vérifiez la connexion.';

  @override
  String get profileLogoUploaded => 'Logo mis à jour.';

  @override
  String get profileUploadError => 'Échec du téléversement.';

  @override
  String get profileSignatureEmpty => 'Dessinez d\'abord votre signature.';

  @override
  String get profileSignatureSaved => 'Signature enregistrée.';

  @override
  String get profileIncompleteHint =>
      'Renseignez tous les champs légaux avant de créer des factures.';

  @override
  String get clientAddTitle => 'Nouveau client';

  @override
  String get clientEditTitle => 'Modifier le client';

  @override
  String get clientFieldName => 'Nom';

  @override
  String get clientFieldAddress => 'Adresse';

  @override
  String get clientFieldIce => 'ICE';

  @override
  String get clientFieldIf => 'IF';

  @override
  String get clientFieldEmail => 'E-mail';

  @override
  String get clientFieldPhone => 'Téléphone';

  @override
  String get clientValidationRequired => 'Obligatoire';

  @override
  String get clientSaved => 'Client enregistré.';

  @override
  String get clientSaveError => 'Enregistrement impossible.';

  @override
  String get clientDeleteTitle => 'Supprimer le client ?';

  @override
  String get clientDeleteBody =>
      'Action irréversible. Les factures déjà créées (phase 3) restent dans le compte.';

  @override
  String get clientListError => 'Impossible de charger les clients.';

  @override
  String get clientListEmpty =>
      'Aucun client. Appuyez sur + pour en ajouter un.';

  @override
  String get clientNotFound => 'Client introuvable.';

  @override
  String get clientLinkedInvoices => 'Factures pour ce client';

  @override
  String get clientNoInvoicesYet =>
      'Aucune facture pour l\'instant (création en phase 3).';

  @override
  String get invoiceNewAction => 'Nouvelle facture';

  @override
  String get invoiceProfileRequiredTitle => 'Complétez votre profil';

  @override
  String get invoiceProfileRequiredBody =>
      'Ajoutez vos informations légales (ICE, IF, CNSS, etc.) avant de créer des factures.';

  @override
  String get invoiceGoToProfile => 'Ouvrir le profil';

  @override
  String get invoiceFormCreateTitle => 'Nouvelle facture';

  @override
  String get invoiceFormEditTitle => 'Modifier la facture';

  @override
  String get invoiceNumberLabel => 'Numéro de facture';

  @override
  String get invoiceFieldClient => 'Client';

  @override
  String get invoiceFieldIssueDate => 'Date d\'émission';

  @override
  String get invoiceFieldDueDate => 'Date d\'échéance';

  @override
  String get invoiceFieldStatus => 'Statut';

  @override
  String get invoiceFieldNotes => 'Notes';

  @override
  String get invoiceLineItems => 'Lignes';

  @override
  String get invoiceLineDescription => 'Description';

  @override
  String get invoiceLineQty => 'Quantité';

  @override
  String get invoiceLineUnitPrice => 'Prix unitaire (MAD)';

  @override
  String get invoiceAddLine => 'Ajouter une ligne';

  @override
  String get invoiceSignatureOnPdf => 'Inclure la signature sur le PDF';

  @override
  String get invoiceFormValidation =>
      'Choisissez un client et au moins une ligne avec une description.';

  @override
  String get invoiceSaved => 'Facture enregistrée.';

  @override
  String get invoiceSaveError => 'Enregistrement de la facture impossible.';

  @override
  String get invoiceSectionSeller => 'Vendeur (votre entreprise)';

  @override
  String get invoiceSectionClient => 'Client (sur la facture)';

  @override
  String get invoiceProfileMissing =>
      'Complétez le profil pour exporter le PDF.';

  @override
  String get invoiceOverdueBanner => 'Échéance dépassée — solde restant.';

  @override
  String get invoicePartiallyPaidBanner =>
      'Partiellement payée — solde restant.';

  @override
  String get invoiceTotal => 'Total';

  @override
  String get invoicePaid => 'Payé';

  @override
  String get invoiceBalance => 'Solde dû';

  @override
  String get invoicePaymentsSection => 'Paiements';

  @override
  String get invoiceNoPayments => 'Aucun paiement enregistré.';

  @override
  String get invoiceAddPayment => 'Enregistrer un paiement';

  @override
  String get invoiceEditPayment => 'Modifier le paiement';

  @override
  String get invoiceDeletePayment => 'Supprimer le paiement';

  @override
  String invoiceDeletePaymentConfirm(String amount) {
    return 'Supprimer ce paiement de $amount ?';
  }

  @override
  String get invoicePaymentAmount => 'Montant (MAD)';

  @override
  String get invoicePaymentDate => 'Date du paiement';

  @override
  String get invoicePaymentMethod => 'Mode';

  @override
  String get paymentMethodCash => 'Espèces';

  @override
  String get paymentMethodVirement => 'Virement';

  @override
  String get paymentMethodCheque => 'Chèque';

  @override
  String get paymentMethodAutre => 'Autre';

  @override
  String get invoiceStatusDraft => 'Brouillon';

  @override
  String get invoiceStatusSent => 'Envoyée';

  @override
  String get invoiceStatusPaid => 'Payée';

  @override
  String get invoiceStatusOverdue => 'En retard';

  @override
  String get invoiceListEmpty =>
      'Aucune facture. Appuyez sur + pour en créer une.';

  @override
  String get invoiceBadgeOverdue => 'En retard';

  @override
  String get invoiceBadgePartial => 'Partiel';

  @override
  String get invoicePdfError => 'Impossible de générer le PDF. Réessayez.';

  @override
  String get declTaxConfigMissing =>
      'Les taux ne sont pas configurés. Un administrateur doit créer le document Firestore config/taxRates (voir config/taxRates.firestore.json dans le projet).';

  @override
  String get declLoadError =>
      'Chargement de la déclaration impossible. Vérifiez la connexion.';

  @override
  String get declRevenueQuarter => 'Chiffre d\'affaires encaissé (trimestre)';

  @override
  String get declRevenueHint =>
      'Somme des paiements de factures datés dans ce trimestre.';

  @override
  String get declIrDue => 'IR estimé dû';

  @override
  String get declCnssDue => 'Cotisation CNSS estimée';

  @override
  String get declCnssBase => 'Assiette CNSS (après plancher)';

  @override
  String get declCnssExempt =>
      'Exempté — vous cotisez déjà à la CNSS par un autre régime';

  @override
  String declRatesVersion(int version) {
    return 'Version du barème : $version';
  }

  @override
  String get declDisclaimer =>
      'Ces montants sont des estimations selon le barème chargé dans l\'application. La loi et les circulaires CNSS évoluent — vérifiez chaque montant auprès de la DGI et de la CNSS avant paiement.';

  @override
  String get declFilingGuideTitle => 'Déclaration sur ae.gov.ma (aperçu)';

  @override
  String get declFilingStep1 =>
      'Connectez-vous au portail ae.gov.ma avec vos identifiants auto-entrepreneur.';

  @override
  String get declFilingStep2 =>
      'Ouvrez la déclaration trimestrielle pour la période concernée.';

  @override
  String get declFilingStep3 =>
      'Saisissez chiffre d\'affaires et cotisations conformément à vos pièces et aux barèmes officiels.';

  @override
  String get declFilingStep4 =>
      'Validez, payez ou planifiez le paiement selon les règles en vigueur, et conservez la quittance.';

  @override
  String get declSaveRecord => 'Enregistrer la déclaration';

  @override
  String get declSaved => 'Déclaration enregistrée.';

  @override
  String get declSaveError => 'Enregistrement impossible. Réessayez.';

  @override
  String get declMarkFiled => 'Marquer comme déposée';

  @override
  String declFiledOn(String date) {
    return 'Déposée le $date';
  }

  @override
  String get declChooseFiledDate => 'Date de dépôt';

  @override
  String get declStatusDraft => 'Brouillon';

  @override
  String get declStatusReady => 'Prête à déposer';

  @override
  String get declStatusFiled => 'Déposée';

  @override
  String get declHistoryTitle => 'Déclarations enregistrées';

  @override
  String get declHistoryEmpty =>
      'Aucune déclaration enregistrée. Ouvrez un trimestre puis « Enregistrer la déclaration ».';

  @override
  String get declOpenQuarter => 'Ouvrir un trimestre';

  @override
  String get declPickQuarterTitle => 'Trimestre';

  @override
  String get declYear => 'Année';

  @override
  String get declQuarter => 'Trimestre';

  @override
  String get declGo => 'Ouvrir';

  @override
  String get onboardingActivityTitle => 'Votre type d\'activité';

  @override
  String get onboardingActivitySubtitle =>
      'Choisissez la catégorie qui correspond le mieux à votre activité d\'auto-entrepreneur. Elle détermine le barème d\'IR appliqué.';

  @override
  String get onboardingContinue => 'Accéder à l\'application';

  @override
  String get onboardingSaved => 'Catégorie d\'activité enregistrée.';

  @override
  String get onboardingError => 'Enregistrement impossible. Réessayez.';
}
