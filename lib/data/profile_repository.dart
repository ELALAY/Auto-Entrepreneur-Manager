import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../domain/tax/activity_category.dart';
import '../models/branding_config.dart';
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
  Future<void> saveActivityCategory(String uid, ActivityCategory category) {
    return _userDoc(uid).set(
      {
        'activityCategory': category.name,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  Future<void> saveProfile(UserProfile profile) {
    return _userDoc(profile.uid).set(
      _profileToMap(profile),
      SetOptions(merge: true),
    );
  }

  /// Uploads logo bytes; returns download URL. Stored at [users/uid/branding/logo].
  Future<String> uploadLogo(String uid, Uint8List bytes, String contentType) async {
    final ref = _storage.ref('users/$uid/branding/logo');
    await ref.putData(
      bytes,
      SettableMetadata(contentType: contentType),
    );
    return ref.getDownloadURL();
  }

  /// Uploads drawn or file signature PNG; returns download URL.
  Future<String> uploadSignature(String uid, Uint8List pngBytes) async {
    final ref = _storage.ref('users/$uid/branding/signature.png');
    await ref.putData(
      pngBytes,
      SettableMetadata(contentType: 'image/png'),
    );
    return ref.getDownloadURL();
  }

  Future<void> clearLogoUrl(String uid) async {
    await _userDoc(uid).set({'logoUrl': FieldValue.delete()}, SetOptions(merge: true));
  }

  Future<void> clearSignatureUrl(String uid) async {
    await _userDoc(uid).set({'signatureUrl': FieldValue.delete()}, SetOptions(merge: true));
  }

  UserProfile _profileFromMap(String uid, Map<String, dynamic> data) {
    final categoryName = data['activityCategory'] as String? ?? 'commercial';
    final category = ActivityCategory.values.firstWhere(
      (e) => e.name == categoryName,
      orElse: () => ActivityCategory.commercial,
    );
    final accent = data['brandingAccentArgb'];
    final template = data['brandingTemplateId'] as String?;
    return UserProfile(
      uid: uid,
      name: data['businessName'] as String? ?? '',
      cin: data['cin'] as String? ?? '',
      ice: data['ice'] as String? ?? '',
      ifNumber: data['ifNumber'] as String? ?? '',
      cnssNumber: data['cnssNumber'] as String? ?? '',
      activityCategory: category,
      address: data['address'] as String? ?? '',
      logoUrl: data['logoUrl'] as String?,
      signatureUrl: data['signatureUrl'] as String?,
      branding: BrandingConfig(
        accentColorArgb: accent is int ? accent : null,
        templateId: template,
      ),
    );
  }

  Map<String, dynamic> _profileToMap(UserProfile p) {
    return {
      'businessName': p.name.trim(),
      'cin': p.cin.trim(),
      'ice': p.ice.trim(),
      'ifNumber': p.ifNumber.trim(),
      'cnssNumber': p.cnssNumber.trim(),
      'activityCategory': p.activityCategory.name,
      'address': p.address.trim(),
      'logoUrl': p.logoUrl,
      'signatureUrl': p.signatureUrl,
      'brandingAccentArgb': p.branding.accentColorArgb,
      'brandingTemplateId': p.branding.templateId,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}
