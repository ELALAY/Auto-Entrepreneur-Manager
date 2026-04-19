import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:signature/signature.dart';

import '../../data/firebase_providers.dart';
import '../../domain/tax/activity_category.dart';
import '../../l10n/app_localizations.dart';
import '../../models/branding_config.dart';
import '../../models/user_profile.dart';
import '../../providers/profile_providers.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _businessName = TextEditingController();
  final _cin = TextEditingController();
  final _ice = TextEditingController();
  final _ifNumber = TextEditingController();
  final _cnss = TextEditingController();
  final _taxProfessionnelle = TextEditingController();
  final _phone = TextEditingController();
  final _address = TextEditingController();

  late final SignatureController _signatureController;
  ActivityCategory _category = ActivityCategory.commercial;
  Color? _accentColor;
  String _templateId = 'default';
  bool _syncedFromRemote = false;
  bool _saving = false;
  String? _logoUrl;
  String? _signatureUrl;

  @override
  void initState() {
    super.initState();
    _signatureController = SignatureController(
      penStrokeWidth: 2,
      penColor: Colors.black,
      exportBackgroundColor: Colors.white,
    );
  }

  @override
  void dispose() {
    _businessName.dispose();
    _cin.dispose();
    _ice.dispose();
    _ifNumber.dispose();
    _cnss.dispose();
    _taxProfessionnelle.dispose();
    _phone.dispose();
    _address.dispose();
    _signatureController.dispose();
    super.dispose();
  }

  void _applyRemote(UserProfile? p) {
    if (_syncedFromRemote) return;
    _syncedFromRemote = true;
    if (p == null) {
      return;
    }
    _businessName.text = p.name;
    _cin.text = p.cin;
    _ice.text = p.ice;
    _ifNumber.text = p.ifNumber;
    _cnss.text = p.cnssNumber;
    _taxProfessionnelle.text = p.taxProfessionnelle;
    _phone.text = p.phone;
    _address.text = p.address;
    _category = p.activityCategory;
    _logoUrl = p.logoUrl;
    _signatureUrl = p.signatureUrl;
    _templateId = p.branding.templateId ?? 'default';
    final argb = p.branding.accentColorArgb;
    _accentColor = argb != null ? Color(argb) : null;
  }

  UserProfile _buildProfile(String uid) {
    return UserProfile(
      uid: uid,
      name: _businessName.text,
      cin: _cin.text,
      ice: _ice.text,
      ifNumber: _ifNumber.text,
      cnssNumber: _cnss.text,
      taxProfessionnelle: _taxProfessionnelle.text,
      phone: _phone.text,
      activityCategory: _category,
      address: _address.text,
      logoUrl: _logoUrl,
      signatureUrl: _signatureUrl,
      branding: BrandingConfig(
        // ignore: deprecated_member_use
        accentColorArgb: _accentColor?.value,
        templateId: _templateId == 'default' ? null : _templateId,
      ),
    );
  }

  Future<void> _saveProfile() async {
    final l10n = AppLocalizations.of(context)!;
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    setState(() => _saving = true);
    try {
      final profile = _buildProfile(uid);
      await ref.read(profileRepositoryProvider).saveProfile(profile);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.profileSaved)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.profileSaveError),
          backgroundColor: Colors.red.shade800,
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _pickLogo() async {
    final l10n = AppLocalizations.of(context)!;
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final pick = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pick == null) return;
    final bytes = await pick.readAsBytes();
    final mime = pick.name.toLowerCase().endsWith('.png')
        ? 'image/png'
        : 'image/jpeg';
    setState(() => _saving = true);
    try {
      final url = await ref
          .read(profileRepositoryProvider)
          .uploadLogo(uid, bytes, mime);
      setState(() {
        _logoUrl = url;
      });
      await ref.read(profileRepositoryProvider).saveProfile(_buildProfile(uid));
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.profileLogoUploaded)));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.profileUploadError),
            backgroundColor: Colors.red.shade800,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _removeLogo() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    setState(() => _saving = true);
    try {
      await ref.read(profileRepositoryProvider).clearLogoUrl(uid);
      setState(() => _logoUrl = null);
      await ref.read(profileRepositoryProvider).saveProfile(_buildProfile(uid));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _saveDrawnSignature() async {
    final l10n = AppLocalizations.of(context)!;
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    if (_signatureController.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.profileSignatureEmpty)));
      return;
    }
    final bytes = await _signatureController.toPngBytes();
    if (bytes == null) return;
    setState(() => _saving = true);
    try {
      final url = await ref
          .read(profileRepositoryProvider)
          .uploadSignature(uid, bytes);
      setState(() => _signatureUrl = url);
      _signatureController.clear();
      await ref.read(profileRepositoryProvider).saveProfile(_buildProfile(uid));
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.profileSignatureSaved)));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.profileUploadError),
            backgroundColor: Colors.red.shade800,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _pickSignatureImage() async {
    final l10n = AppLocalizations.of(context)!;
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final pick = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pick == null) return;
    final bytes = await pick.readAsBytes();
    setState(() => _saving = true);
    try {
      final url = await ref
          .read(profileRepositoryProvider)
          .uploadSignature(uid, bytes);
      setState(() => _signatureUrl = url);
      await ref.read(profileRepositoryProvider).saveProfile(_buildProfile(uid));
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.profileSignatureSaved)));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.profileUploadError),
            backgroundColor: Colors.red.shade800,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _removeSignature() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    setState(() => _saving = true);
    try {
      await ref.read(profileRepositoryProvider).clearSignatureUrl(uid);
      setState(() => _signatureUrl = null);
      _signatureController.clear();
      await ref.read(profileRepositoryProvider).saveProfile(_buildProfile(uid));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _pickAccentColor() {
    final l10n = AppLocalizations.of(context)!;
    var pickerColor = _accentColor ?? Theme.of(context).colorScheme.primary;
    showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(l10n.profileBrandingColor),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: pickerColor,
              onColorChanged: (c) => pickerColor = c,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(l10n.actionCancel),
            ),
            FilledButton(
              onPressed: () {
                setState(() => _accentColor = pickerColor);
                Navigator.pop(ctx);
              },
              child: Text(l10n.actionDone),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    ref.listen(userProfileStreamProvider, (prev, next) {
      next.whenData((p) {
        if (_syncedFromRemote) return;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          setState(() => _applyRemote(p));
        });
      });
    });

    ref.watch(userProfileStreamProvider);
    final complete = ref.watch(profileCompleteProvider).valueOrNull ?? false;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.screenProfile),
        actions: [
          if (_saving)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            TextButton(onPressed: _saveProfile, child: Text(l10n.actionSave)),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (!complete)
            Card(
              color: theme.colorScheme.errorContainer.withValues(alpha: 0.35),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: theme.colorScheme.error),
                    const SizedBox(width: 12),
                    Expanded(child: Text(l10n.profileIncompleteHint)),
                  ],
                ),
              ),
            ),
          Text(l10n.profileSectionLegal, style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          TextFormField(
            controller: _businessName,
            decoration: InputDecoration(
              labelText: l10n.profileFieldBusinessName,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _cin,
            decoration: InputDecoration(
              labelText: l10n.profileFieldCin,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _ice,
            decoration: InputDecoration(
              labelText: l10n.profileFieldIce,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _ifNumber,
            decoration: InputDecoration(
              labelText: l10n.profileFieldIf,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _cnss,
            decoration: InputDecoration(
              labelText: l10n.profileFieldCnss,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _taxProfessionnelle,
            decoration: InputDecoration(
              labelText: l10n.profileFieldTaxProfessionnelle,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _phone,
            decoration: InputDecoration(
              labelText: l10n.profileFieldPhone,
              border: const OutlineInputBorder(),
            ),
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _address,
            decoration: InputDecoration(
              labelText: l10n.profileFieldAddress,
              border: const OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 24),
          Text(l10n.profileSectionActivity, style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          SegmentedButton<ActivityCategory>(
            segments: [
              ButtonSegment(
                value: ActivityCategory.commercial,
                label: Text(l10n.activityCommercialShort),
              ),
              ButtonSegment(
                value: ActivityCategory.artisanal,
                label: Text(l10n.activityArtisanalShort),
              ),
              ButtonSegment(
                value: ActivityCategory.liberal,
                label: Text(l10n.activityLiberalShort),
              ),
            ],
            selected: {_category},
            onSelectionChanged: (s) {
              setState(() => _category = s.first);
            },
          ),
          const SizedBox(height: 8),
          _ActivityExplainer(category: _category),
          const SizedBox(height: 24),
          Text(l10n.profileSectionBranding, style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Row(
            children: [
              if (_logoUrl != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(
                    imageUrl: _logoUrl!,
                    width: 72,
                    height: 72,
                    fit: BoxFit.cover,
                  ),
                )
              else
                Container(
                  width: 72,
                  height: 72,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    border: Border.all(color: theme.dividerColor),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.image_outlined, color: theme.disabledColor),
                ),
              const SizedBox(width: 12),
              Expanded(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    FilledButton.tonal(
                      onPressed: _saving ? null : _pickLogo,
                      child: Text(l10n.profilePickLogo),
                    ),
                    if (_logoUrl != null)
                      TextButton(
                        onPressed: _saving ? null : _removeLogo,
                        child: Text(l10n.profileRemoveLogo),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.profileBrandingColor),
            subtitle: Text(l10n.profileBrandingColorHint),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color:
                        _accentColor ??
                        theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: theme.dividerColor),
                  ),
                ),
                IconButton(
                  onPressed: _pickAccentColor,
                  icon: const Icon(Icons.palette_outlined),
                ),
              ],
            ),
          ),
          DropdownButtonFormField<String>(
            value: {'default', 'bordered'}.contains(_templateId)
                ? _templateId
                : 'default',
            decoration: InputDecoration(
              labelText: l10n.profileInvoiceTemplate,
              border: const OutlineInputBorder(),
            ),
            items: [
              DropdownMenuItem(
                value: 'default',
                child: Text(l10n.templateDefault),
              ),
              DropdownMenuItem(
                value: 'bordered',
                child: Text(l10n.templateBordered),
              ),
            ],
            onChanged: (v) {
              if (v != null) setState(() => _templateId = v);
            },
          ),
          const SizedBox(height: 16),
          Text(
            l10n.profileBrandingPreviewHint,
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  if (_logoUrl != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: CachedNetworkImage(
                        imageUrl: _logoUrl!,
                        width: 40,
                        height: 40,
                        fit: BoxFit.cover,
                      ),
                    )
                  else
                    Icon(Icons.business, color: theme.disabledColor),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      height: 8,
                      decoration: BoxDecoration(
                        color: _accentColor ?? theme.colorScheme.primary,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            l10n.profileSectionSignature,
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          if (_signatureUrl != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
                      imageUrl: _signatureUrl!,
                      height: 64,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(width: 12),
                  TextButton(
                    onPressed: _saving ? null : _removeSignature,
                    child: Text(l10n.profileRemoveSignature),
                  ),
                ],
              ),
            ),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: theme.dividerColor),
              borderRadius: BorderRadius.circular(8),
            ),
            height: 200,
            child: Signature(
              key: const ValueKey('signature_pad'),
              controller: _signatureController,
              backgroundColor: Colors.grey.shade100,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton(
                onPressed: _saving ? null : () => _signatureController.clear(),
                child: Text(l10n.profileSignatureClear),
              ),
              FilledButton.tonal(
                onPressed: _saving ? null : _saveDrawnSignature,
                child: Text(l10n.profileSignatureSaveDrawn),
              ),
              FilledButton.tonal(
                onPressed: _saving ? null : _pickSignatureImage,
                child: Text(l10n.profileSignatureUpload),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActivityExplainer extends StatelessWidget {
  const _ActivityExplainer({required this.category});

  final ActivityCategory category;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final (title, body) = switch (category) {
      ActivityCategory.commercial => (
        l10n.activityCommercialTitle,
        l10n.activityCommercialBody,
      ),
      ActivityCategory.artisanal => (
        l10n.activityArtisanalTitle,
        l10n.activityArtisanalBody,
      ),
      ActivityCategory.liberal => (
        l10n.activityLiberalTitle,
        l10n.activityLiberalBody,
      ),
    };
    return ExpansionTile(
      title: Text(title),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(body, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ),
      ],
    );
  }
}
