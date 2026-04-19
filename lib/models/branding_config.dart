/// Invoice PDF/template branding (colors, template id).
class BrandingConfig {
  const BrandingConfig({
    this.accentColorArgb,
    this.templateId,
  });

  /// Optional 32-bit ARGB (e.g. 0xFF006A4E) for template accent.
  final int? accentColorArgb;
  final String? templateId;

  BrandingConfig copyWith({
    int? accentColorArgb,
    String? templateId,
    bool clearAccentColor = false,
    bool clearTemplateId = false,
  }) {
    return BrandingConfig(
      accentColorArgb:
          clearAccentColor ? null : (accentColorArgb ?? this.accentColorArgb),
      templateId: clearTemplateId ? null : (templateId ?? this.templateId),
    );
  }
}
