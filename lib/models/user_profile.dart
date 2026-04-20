import '../domain/tax/activity_category.dart';
import 'brand_logo.dart';
import 'branding_config.dart';
import 'invoice_number_config.dart';

/// Dedupes [ActivityCategory] values preserving first-seen order.
/// Returns `[ActivityCategory.commercial]` if [input] is empty.
List<ActivityCategory> normalizeActivityCategories(
  Iterable<ActivityCategory> input,
) {
  final seen = <ActivityCategory>{};
  final out = <ActivityCategory>[];
  for (final c in input) {
    if (seen.add(c)) out.add(c);
  }
  if (out.isEmpty) return [ActivityCategory.commercial];
  return out;
}

class UserProfile {
  const UserProfile({
    required this.uid,
    required this.name,
    required this.cin,
    required this.ice,
    required this.ifNumber,
    required this.cnssNumber,
    required this.taxProfessionnelle,
    required this.phone,
    required this.address,
    this.activityCategories = const [ActivityCategory.commercial],
    this.hasCnss = false,
    this.brandLogos = const [],
    this.signatureUrl,
    this.branding = const BrandingConfig(),
    this.invoiceNumberConfig = const InvoiceNumberConfig(),
    this.nextInvoiceCount,
  });

  final String uid;
  final String name;
  final String cin;
  final String ice;
  final String ifNumber;
  final String cnssNumber;
  final String taxProfessionnelle;
  final String phone;
  final String address;

  /// Registered tax activity families (IR rates differ per category).
  /// Non-empty; use [normalizeActivityCategories] when building from UI.
  final List<ActivityCategory> activityCategories;

  /// First registered activity (legacy single-selection behavior).
  ActivityCategory get activityCategory =>
      activityCategories.isEmpty ? ActivityCategory.commercial : activityCategories.first;

  /// True when the user already contributes to CNSS through another scheme
  /// (e.g. salaried employment). CNSS is then excluded from AE declarations.
  final bool hasCnss;
  final List<BrandLogo> brandLogos;
  final String? signatureUrl;
  final BrandingConfig branding;
  final InvoiceNumberConfig invoiceNumberConfig;

  /// When non-null and ≥ 1, the next automatic invoice uses this value as the
  /// sequence count in the formatted number (with [InvoiceNumberConfig]),
  /// combined with the stored per-year counter via `max(counter+1, this)`.
  /// [InvoiceRepository.createInvoice] updates this on the server after each
  /// new invoice to `lastIssuedCount + 1` for the invoice issue year.
  final int? nextInvoiceCount;

  UserProfile copyWith({
    String? uid,
    String? name,
    String? cin,
    String? ice,
    String? ifNumber,
    String? cnssNumber,
    String? taxProfessionnelle,
    String? phone,
    String? address,
    List<ActivityCategory>? activityCategories,
    bool? hasCnss,
    List<BrandLogo>? brandLogos,
    String? signatureUrl,
    BrandingConfig? branding,
    InvoiceNumberConfig? invoiceNumberConfig,
    int? nextInvoiceCount,
    bool clearSignatureUrl = false,
    bool clearNextInvoiceCount = false,
  }) {
    return UserProfile(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      cin: cin ?? this.cin,
      ice: ice ?? this.ice,
      ifNumber: ifNumber ?? this.ifNumber,
      cnssNumber: cnssNumber ?? this.cnssNumber,
      taxProfessionnelle: taxProfessionnelle ?? this.taxProfessionnelle,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      activityCategories:
          activityCategories ?? this.activityCategories,
      hasCnss: hasCnss ?? this.hasCnss,
      brandLogos: brandLogos ?? this.brandLogos,
      signatureUrl:
          clearSignatureUrl ? null : (signatureUrl ?? this.signatureUrl),
      branding: branding ?? this.branding,
      invoiceNumberConfig:
          invoiceNumberConfig ?? this.invoiceNumberConfig,
      nextInvoiceCount: clearNextInvoiceCount
          ? null
          : (nextInvoiceCount ?? this.nextInvoiceCount),
    );
  }
}
