import '../domain/tax/activity_category.dart';
import 'brand_logo.dart';
import 'branding_config.dart';
import 'invoice_number_config.dart';

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
    required this.activityCategory,
    required this.address,
    this.hasCnss = false,
    this.brandLogos = const [],
    this.signatureUrl,
    this.branding = const BrandingConfig(),
    this.invoiceNumberConfig = const InvoiceNumberConfig(),
    this.nextInvoiceNumber,
  });

  final String uid;
  final String name;
  final String cin;
  final String ice;
  final String ifNumber;
  final String cnssNumber;
  final String taxProfessionnelle;
  final String phone;
  final ActivityCategory activityCategory;
  final String address;

  /// True when the user already contributes to CNSS through another scheme
  /// (e.g. salaried employment). CNSS is then excluded from AE declarations.
  final bool hasCnss;
  final List<BrandLogo> brandLogos;
  final String? signatureUrl;
  final BrandingConfig branding;
  final InvoiceNumberConfig invoiceNumberConfig;

  /// When non-null and non-empty, the next automatic invoice uses this number
  /// once, then the field is cleared (see [InvoiceRepository.createInvoice]).
  final String? nextInvoiceNumber;

  UserProfile copyWith({
    String? uid,
    String? name,
    String? cin,
    String? ice,
    String? ifNumber,
    String? cnssNumber,
    String? taxProfessionnelle,
    String? phone,
    ActivityCategory? activityCategory,
    String? address,
    bool? hasCnss,
    List<BrandLogo>? brandLogos,
    String? signatureUrl,
    BrandingConfig? branding,
    InvoiceNumberConfig? invoiceNumberConfig,
    String? nextInvoiceNumber,
    bool clearSignatureUrl = false,
    bool clearNextInvoiceNumber = false,
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
      activityCategory: activityCategory ?? this.activityCategory,
      address: address ?? this.address,
      hasCnss: hasCnss ?? this.hasCnss,
      brandLogos: brandLogos ?? this.brandLogos,
      signatureUrl:
          clearSignatureUrl ? null : (signatureUrl ?? this.signatureUrl),
      branding: branding ?? this.branding,
      invoiceNumberConfig:
          invoiceNumberConfig ?? this.invoiceNumberConfig,
      nextInvoiceNumber: clearNextInvoiceNumber
          ? null
          : (nextInvoiceNumber ?? this.nextInvoiceNumber),
    );
  }
}
