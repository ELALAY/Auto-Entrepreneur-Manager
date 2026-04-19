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
import '../../models/brand_logo.dart';
import '../../models/branding_config.dart';
import '../../models/invoice_number_config.dart';
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
  final _invoicePrefix = TextEditingController(text: 'INV');
  final _invoicePattern =
      TextEditingController(text: '{prefix}_{year}_{count}');
  final _invoiceCountDigits = TextEditingController(text: '3');
  final _nextInvoiceNumber = TextEditingController();
  final _nextInvoiceNumberFocus = FocusNode();

  late final SignatureController _signatureController;
  ActivityCategory _category = ActivityCategory.commercial;
  bool _hasCnss = false;
  Color? _accentColor;
  String _templateId = 'default';
  /// Text fields and activity/branding choices are filled once from Firestore;
  /// [brandLogos] and [signatureUrl] stay in sync on every profile snapshot so a
  /// delayed initial sync cannot wipe a signature that was just uploaded.
  bool _profileHydrated = false;
  bool _saving = false;
  List<BrandLogo> _brandLogos = [];
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
    _invoicePrefix.dispose();
    _invoicePattern.dispose();
    _invoiceCountDigits.dispose();
    _nextInvoiceNumber.dispose();
    _nextInvoiceNumberFocus.dispose();
    _signatureController.dispose();
    super.dispose();
  }

  void _hydrateFromProfile(UserProfile p) {
    _businessName.text = p.name;
    _cin.text = p.cin;
    _ice.text = p.ice;
    _ifNumber.text = p.ifNumber;
    _cnss.text = p.cnssNumber;
    _taxProfessionnelle.text = p.taxProfessionnelle;
    _phone.text = p.phone;
    _address.text = p.address;
    _category = p.activityCategory;
    _hasCnss = p.hasCnss;
    _brandLogos = List<BrandLogo>.from(p.brandLogos);
    _signatureUrl = p.signatureUrl;
    _templateId = p.branding.templateId ?? 'default';
    final argb = p.branding.accentColorArgb;
    _accentColor = argb != null ? Color(argb) : null;
    _invoicePrefix.text = p.invoiceNumberConfig.prefix;
    _invoicePattern.text = p.invoiceNumberConfig.pattern;
    _invoiceCountDigits.text =
        p.invoiceNumberConfig.countDigits.clamp(1, 12).toString();
    _nextInvoiceNumber.text = p.nextInvoiceNumber ?? '';
  }

  void _syncBrandingUrlsFrom(UserProfile p) {
    _brandLogos = List<BrandLogo>.from(p.brandLogos);
    _signatureUrl = p.signatureUrl;
  }

  bool _sameBrandingSnapshot(UserProfile p) {
    if (_signatureUrl != p.signatureUrl) return false;
    if (_brandLogos.length != p.brandLogos.length) return false;
    for (var i = 0; i < _brandLogos.length; i++) {
      if (_brandLogos[i].id != p.brandLogos[i].id ||
          _brandLogos[i].url != p.brandLogos[i].url) {
        return false;
      }
    }
    return true;
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
      hasCnss: _hasCnss,
      address: _address.text,
      brandLogos: _brandLogos,
      signatureUrl: _signatureUrl,
      branding: BrandingConfig(
        // ignore: deprecated_member_use
        accentColorArgb: _accentColor?.value,
        templateId: _templateId == 'default' ? null : _templateId,
      ),
      invoiceNumberConfig: InvoiceNumberConfig(
        prefix: _invoicePrefix.text,
        pattern: _invoicePattern.text,
        countDigits: (int.tryParse(_invoiceCountDigits.text) ?? 3).clamp(1, 12),
      ),
      nextInvoiceNumber: () {
        final t = _nextInvoiceNumber.text.trim();
        return t.isEmpty ? null : t;
      }(),
    );
  }

  String _previewInvoiceNumber() {
    final cfg = normalizeInvoiceNumberConfig(
      InvoiceNumberConfig(
        prefix: _invoicePrefix.text,
        pattern: _invoicePattern.text,
        countDigits: int.tryParse(_invoiceCountDigits.text) ?? 3,
      ),
    );
    return formatInvoiceNumber(
      cfg,
      year: DateTime.now().year,
      count: 45,
    );
  }

  Future<void> _saveProfile() async {
    final l10n = AppLocalizations.of(context)!;
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final pattern = _invoicePattern.text.trim();
    if (!isValidInvoiceNumberPattern(pattern)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.profileInvoicePatternInvalid)),
      );
      return;
    }
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

  Future<String?> _askOptionalBrandLogoLabel() async {
    final l10n = AppLocalizations.of(context)!;
    final c = TextEditingController();
    final result = await showDialog<String?>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.profileLogoNameDialogTitle),
        content: TextField(
          controller: c,
          decoration: InputDecoration(
            hintText: l10n.profileLogoOptionalNameHint,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop<String?>(ctx, null),
            child: Text(l10n.actionCancel),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.pop<String?>(ctx, c.text.trim()),
            child: Text(l10n.profileLogoNameDialogSave),
          ),
        ],
      ),
    );
    return result;
  }

  Future<void> _pickLogo() async {
    final l10n = AppLocalizations.of(context)!;
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final pick = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pick == null) return;
    final labelRaw = await _askOptionalBrandLogoLabel();
    if (!mounted) return;
    if (labelRaw == null) return;
    final bytes = await pick.readAsBytes();
    final mime = pick.name.toLowerCase().endsWith('.png')
        ? 'image/png'
        : 'image/jpeg';
    setState(() => _saving = true);
    try {
      final logo = await ref.read(profileRepositoryProvider).uploadBrandLogo(
            uid,
            bytes,
            mime,
            label: labelRaw.isEmpty ? null : labelRaw,
          );
      setState(() {
        _brandLogos = [..._brandLogos, logo];
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

  Future<void> _removeBrandLogoAt(int index) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final logo = _brandLogos[index];
    setState(() => _saving = true);
    try {
      await ref.read(profileRepositoryProvider).deleteBrandLogoInStorage(logo.url);
      setState(() {
        _brandLogos = [..._brandLogos]..removeAt(index);
      });
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

    final profileAsync = ref.watch(userProfileStreamProvider);
    if (!_profileHydrated) {
      profileAsync.whenData((_) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted || _profileHydrated) return;
          final latest = ref.read(userProfileStreamProvider).valueOrNull;
          if (latest == null) return;
          setState(() {
            _profileHydrated = true;
            _hydrateFromProfile(latest);
          });
        });
      });
    }
    ref.listen<AsyncValue<UserProfile?>>(userProfileStreamProvider, (prev, next) {
      if (!_profileHydrated) return;
      final p = next.valueOrNull;
      if (!mounted || p == null) return;
      if (!_sameBrandingSnapshot(p)) {
        setState(() => _syncBrandingUrlsFrom(p));
      }
      if (!_nextInvoiceNumberFocus.hasFocus) {
        final server = (p.nextInvoiceNumber ?? '').trim();
        final local = _nextInvoiceNumber.text.trim();
        if (server != local) {
          setState(() => _nextInvoiceNumber.text = server);
        }
      }
    });
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
              ButtonSegment(
                value: ActivityCategory.services,
                label: Text(l10n.activityServicesShort),
              ),
            ],
            selected: {_category},
            onSelectionChanged: (s) {
              setState(() => _category = s.first);
            },
          ),
          const SizedBox(height: 8),
          _ActivityExplainer(category: _category),
          const SizedBox(height: 16),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.profileHasCnssLabel),
            subtitle: Text(l10n.profileHasCnssHint),
            value: _hasCnss,
            onChanged: (v) => setState(() => _hasCnss = v),
          ),
          const SizedBox(height: 24),
          Text(
            l10n.profileSectionInvoiceNumbers,
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _invoicePrefix,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              labelText: l10n.profileInvoicePrefixLabel,
              helperText: l10n.profileInvoicePrefixHint,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _invoicePattern,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              labelText: l10n.profileInvoicePatternLabel,
              helperText: l10n.profileInvoicePatternHint,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _invoiceCountDigits,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              labelText: l10n.profileInvoiceCountDigitsLabel,
              helperText: l10n.profileInvoiceCountDigitsHint,
              border: const OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _nextInvoiceNumber,
            focusNode: _nextInvoiceNumberFocus,
            decoration: InputDecoration(
              labelText: l10n.profileNextInvoiceNumberLabel,
              helperText: l10n.profileNextInvoiceNumberHint,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${l10n.profileInvoicePreview}: ${_previewInvoiceNumber()}',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 24),
          Text(l10n.profileSectionBranding, style: theme.textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(
            l10n.profileBrandLogosTitle,
            style: theme.textTheme.titleSmall,
          ),
          const SizedBox(height: 4),
          Text(
            l10n.profileBrandLogosHint,
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 108,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _brandLogos.length + 1,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (ctx, i) {
                if (i >= _brandLogos.length) {
                  return Material(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                    child: InkWell(
                      onTap: _saving ? null : _pickLogo,
                      borderRadius: BorderRadius.circular(8),
                      child: SizedBox(
                        width: 96,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_photo_alternate_outlined,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(height: 4),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 6),
                              child: Text(
                                l10n.profilePickLogo,
                                textAlign: TextAlign.center,
                                style: theme.textTheme.labelSmall,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }
                final logo = _brandLogos[i];
                return ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CachedNetworkImage(
                        imageUrl: logo.url,
                        width: 96,
                        height: 96,
                        fit: BoxFit.cover,
                      ),
                      Positioned(
                        top: 2,
                        right: 2,
                        child: Material(
                          color: Colors.black54,
                          shape: const CircleBorder(),
                          child: IconButton(
                            visualDensity: VisualDensity.compact,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                              minWidth: 28,
                              minHeight: 28,
                            ),
                            icon: const Icon(
                              Icons.close,
                              size: 16,
                              color: Colors.white,
                            ),
                            onPressed: _saving ? null : () => _removeBrandLogoAt(i),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: ColoredBox(
                          color: Colors.black.withValues(alpha: 0.55),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 4,
                            ),
                            child: Text(
                              logo.displayName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
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
                  if (_brandLogos.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: CachedNetworkImage(
                        imageUrl: _brandLogos.first.url,
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
                      errorWidget: (_, __, ___) => const Icon(
                        Icons.broken_image_outlined,
                        size: 48,
                      ),
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
      ActivityCategory.services => (
        l10n.activityServicesTitle,
        l10n.activityServicesBody,
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
