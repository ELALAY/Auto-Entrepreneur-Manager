class BrandLogo {
  const BrandLogo({
    required this.id,
    required this.url,
    this.label,
  });

  final String id;
  final String url;
  final String? label;

  String get displayName {
    final t = label?.trim();
    if (t != null && t.isNotEmpty) return t;
    return id;
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'url': url,
        if (label != null && label!.trim().isNotEmpty) 'label': label!.trim(),
      };

  static BrandLogo? fromFirestore(Object? raw) {
    if (raw is! Map) return null;
    final m = Map<String, dynamic>.from(raw);
    final id = m['id'] as String?;
    final url = m['url'] as String?;
    if (id == null || id.isEmpty || url == null || url.isEmpty) return null;
    return BrandLogo(
      id: id,
      url: url,
      label: m['label'] as String?,
    );
  }
}
