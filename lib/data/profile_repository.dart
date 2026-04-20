import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../domain/tax/activity_category.dart';
import '../models/brand_logo.dart';
import '../models/branding_config.dart';
import '../models/invoice_number_config.dart';
import '../models/user_profile.dart';

class ProfileRepository {
  ProfileRepository(this._firestore, this._storage);

  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  DocumentReference<Map<String, dynamic>> _userDoc(String uid) =>
      _firestore.doc('users/$uid');

  Stream<UserProfile?> watchProfile(String uid) {
    return _userDoc(uid).snapshots().map((snap) {
      if (!snap.exists) return null;
      final data = snap.data();
      if (data == null) return null;
      return _profileFromMap(uid, data);
    });
  }

  Future<UserProfile?> getProfile(String uid) async {
    final snap = await _userDoc(uid).get();
    if (!snap.exists) return null;
    final data = snap.data();
    if (data == null) return null;
    return _profileFromMap(uid, data);
  }

  /// Merge-only update for post sign-up onboarding (does not clear other profile fields).
  Future<void> saveActivityCategories(
    String uid,
    List<ActivityCategory> categories,
  ) {
    final normalized = normalizeActivityCategories(categories);
    return _userDoc(uid).set(
      {
        'activityCategories': normalized.map((e) => e.name).toList(),
        'activityCategory': normalized.first.name,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  Future<void> saveActivityCategory(String uid, ActivityCategory category) {
    return saveActivityCategories(uid, [category]);
  }

  Future<void> saveProfile(UserProfile profile) {
    return _userDoc(profile.uid).set(
      _profileToMap(profile),
      SetOptions(merge: true),
    );
  }

  /// Uploads a new brand logo; returns the entry to merge into [UserProfile.brandLogos].
  Future<BrandLogo> uploadBrandLogo(
    String uid,
    Uint8List bytes,
    String contentType, {
    String? label,
  }) async {
    final id =
        _firestore.collection('users').doc(uid).collection('_tmp').doc().id;
    final ext = contentType.contains('png') ? 'png' : 'jpg';
    final ref = _storage.ref('users/$uid/branding/logos/$id.$ext');
    await ref.putData(
      bytes,
      SettableMetadata(contentType: contentType),
    );
    final url = await ref.getDownloadURL();
    return BrandLogo(id: id, url: url, label: label);
  }

  /// Best-effort delete of a logo file from Storage (ignore failures).
  Future<void> deleteBrandLogoInStorage(String downloadUrl) async {
    try {
      await _storage.refFromURL(downloadUrl).delete();
    } catch (_) {}
  }

  /// Uploads drawn or file signature PNG; returns download URL.
  Future<String> uploadSignature(String uid, Uint8List pngBytes) async {
    final ref = _storage.ref('users/$uid/branding/signature.png');
    await ref.putData(
      pngBytes,
      SettableMetadata(
        contentType: 'image/png',
        cacheControl: 'public, max-age=0, must-revalidate',
      ),
    );
    return ref.getDownloadURL();
  }

  Future<void> clearSignatureUrl(String uid) async {
    await _userDoc(uid).set({'signatureUrl': FieldValue.delete()}, SetOptions(merge: true));
  }

  List<BrandLogo> _brandLogosFromData(Map<String, dynamic> data) {
    final raw = data['brandLogos'];
    if (raw is List && raw.isNotEmpty) {
      return raw
          .map(BrandLogo.fromFirestore)
          .whereType<BrandLogo>()
          .toList();
    }
    final legacy = data['logoUrl'] as String?;
    if (legacy != null && legacy.isNotEmpty) {
      return [BrandLogo(id: 'migrated', url: legacy)];
    }
    return [];
  }

  UserProfile _profileFromMap(String uid, Map<String, dynamic> data) {
    final activityCategories = _activityCategoriesFromData(data);
    final accent = data['brandingAccentArgb'];
    final template = data['brandingTemplateId'] as String?;
    final invPrefix = data['invoiceNumberPrefix'] as String? ?? 'INV';
    final invPattern = data['invoiceNumberPattern'] as String? ??
        '{prefix}_{year}_{count}';
    final invDigits = (data['invoiceNumberCountDigits'] as num?)?.toInt() ?? 3;
    return UserProfile(
      uid: uid,
      name: data['businessName'] as String? ?? '',
      cin: data['cin'] as String? ?? '',
      ice: data['ice'] as String? ?? '',
      ifNumber: data['ifNumber'] as String? ?? '',
      cnssNumber: data['cnssNumber'] as String? ?? '',
      taxProfessionnelle: data['taxProfessionnelle'] as String? ?? '',
      phone: data['phone'] as String? ?? '',
      activityCategories: activityCategories,
      hasCnss: data['hasCnss'] as bool? ?? false,
      address: data['address'] as String? ?? '',
      brandLogos: _brandLogosFromData(data),
      signatureUrl: data['signatureUrl'] as String?,
      branding: BrandingConfig(
        accentColorArgb: accent is int ? accent : null,
        templateId: template,
      ),
      invoiceNumberConfig: InvoiceNumberConfig(
        prefix: invPrefix,
        pattern: invPattern,
        countDigits: invDigits.clamp(1, 12),
      ),
      nextInvoiceCount: _nextInvoiceCountFromFirestore(data),
    );
  }

  List<ActivityCategory> _activityCategoriesFromData(Map<String, dynamic> data) {
    final raw = data['activityCategories'];
    final out = <ActivityCategory>[];
    final seen = <ActivityCategory>{};
    if (raw is List) {
      for (final e in raw) {
        if (e is! String) continue;
        for (final v in ActivityCategory.values) {
          if (v.name == e && seen.add(v)) {
            out.add(v);
            break;
          }
        }
      }
    }
    if (out.isEmpty) {
      final legacyName = data['activityCategory'] as String? ?? 'commercial';
      final legacy = ActivityCategory.values.firstWhere(
        (e) => e.name == legacyName,
        orElse: () => ActivityCategory.commercial,
      );
      return [legacy];
    }
    return out;
  }

  /// Reads [nextInvoiceCount] or migrates legacy [nextInvoiceNumber] string.
  int? _nextInvoiceCountFromFirestore(Map<String, dynamic> data) {
    final n = data['nextInvoiceCount'];
    if (n is num) {
      final v = n.toInt();
      if (v >= 1) return v;
    }
    final legacy = data['nextInvoiceNumber'] as String?;
    if (legacy != null && legacy.trim().isNotEmpty) {
      final t = legacy.trim();
      final parsed = parseTrailingInvoiceSequence(t);
      if (parsed != null && parsed >= 1) return parsed;
      final direct = int.tryParse(t);
      if (direct != null && direct >= 1) return direct;
    }
    return null;
  }

  Map<String, dynamic> _profileToMap(UserProfile p) {
    return {
      'businessName': p.name.trim(),
      'cin': p.cin.trim(),
      'ice': p.ice.trim(),
      'ifNumber': p.ifNumber.trim(),
      'cnssNumber': p.cnssNumber.trim(),
      'taxProfessionnelle': p.taxProfessionnelle.trim(),
      'phone': p.phone.trim(),
      'activityCategories':
          normalizeActivityCategories(p.activityCategories)
              .map((e) => e.name)
              .toList(),
      'activityCategory': p.activityCategory.name,
      'hasCnss': p.hasCnss,
      'address': p.address.trim(),
      'brandLogos': p.brandLogos.map((e) => e.toMap()).toList(),
      'logoUrl': p.brandLogos.isNotEmpty
          ? p.brandLogos.first.url
          : FieldValue.delete(),
      'signatureUrl': p.signatureUrl,
      'brandingAccentArgb': p.branding.accentColorArgb,
      'brandingTemplateId': p.branding.templateId,
      'invoiceNumberPrefix': p.invoiceNumberConfig.prefix.trim(),
      'invoiceNumberPattern': p.invoiceNumberConfig.pattern.trim().isEmpty
          ? '{prefix}_{year}_{count}'
          : p.invoiceNumberConfig.pattern.trim(),
      'invoiceNumberCountDigits': p.invoiceNumberConfig.countDigits.clamp(1, 12),
      'nextInvoiceCount': (p.nextInvoiceCount != null && p.nextInvoiceCount! >= 1)
          ? p.nextInvoiceCount
          : FieldValue.delete(),
      'nextInvoiceNumber': FieldValue.delete(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}
