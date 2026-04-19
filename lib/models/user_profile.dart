import '../domain/tax/activity_category.dart';
import 'branding_config.dart';

class UserProfile {
  const UserProfile({
    required this.uid,
    required this.name,
    required this.cin,
    required this.ice,
    required this.ifNumber,
    required this.cnssNumber,
    required this.activityCategory,
    required this.address,
    this.logoUrl,
    this.signatureUrl,
    this.branding = const BrandingConfig(),
  });

  final String uid;
  final String name;
  final String cin;
  final String ice;
  final String ifNumber;
  final String cnssNumber;
  final ActivityCategory activityCategory;
  final String address;
  final String? logoUrl;
  final String? signatureUrl;
  final BrandingConfig branding;

  UserProfile copyWith({
    String? uid,
    String? name,
    String? cin,
    String? ice,
    String? ifNumber,
    String? cnssNumber,
    ActivityCategory? activityCategory,
    String? address,
    String? logoUrl,
    String? signatureUrl,
    BrandingConfig? branding,
    bool clearLogoUrl = false,
    bool clearSignatureUrl = false,
  }) {
    return UserProfile(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      cin: cin ?? this.cin,
      ice: ice ?? this.ice,
      ifNumber: ifNumber ?? this.ifNumber,
      cnssNumber: cnssNumber ?? this.cnssNumber,
      activityCategory: activityCategory ?? this.activityCategory,
      address: address ?? this.address,
      logoUrl: clearLogoUrl ? null : (logoUrl ?? this.logoUrl),
      signatureUrl:
          clearSignatureUrl ? null : (signatureUrl ?? this.signatureUrl),
      branding: branding ?? this.branding,
    );
  }
}
