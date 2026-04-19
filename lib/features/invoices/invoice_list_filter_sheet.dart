import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/tax/activity_category.dart';
import '../../l10n/app_localizations.dart';
import '../../models/catalog_item.dart';
import '../../models/invoice_summary.dart';
import '../../providers/catalog_providers.dart';
import '../../providers/invoice_providers.dart';
import 'invoice_list_filters.dart';

enum _DateMode { any, quarter, month, range, day }

class InvoiceListFilterSheet extends ConsumerStatefulWidget {
  const InvoiceListFilterSheet({
    super.key,
    required this.initial,
    required this.summaries,
  });

  final InvoiceListFilters initial;
  final List<InvoiceSummary> summaries;

  @override
  ConsumerState<InvoiceListFilterSheet> createState() =>
      _InvoiceListFilterSheetState();
}

class _InvoiceListFilterSheetState extends ConsumerState<InvoiceListFilterSheet> {
  late String? _clientId;
  late String? _catalogItemId;
  CatalogKind? _lineKind;
  ActivityCategory? _activity;
  late TextEditingController _minCtrl;
  late TextEditingController _maxCtrl;

  _DateMode _dateMode = _DateMode.any;
  int _qYear = DateTime.now().year;
  int _qQuarter = 1;
  int _mYear = DateTime.now().year;
  int _mMonth = DateTime.now().month;
  DateTime? _rangeStart;
  DateTime? _rangeEnd;
  DateTime? _singleDay;

  @override
  void initState() {
    super.initState();
    final i = widget.initial;
    _clientId = i.clientId;
    _catalogItemId = i.catalogItemId;
    _lineKind = i.catalogLineKind;
    _activity = i.activityCategory;
    _minCtrl = TextEditingController(text: i.minTotal?.toString() ?? '');
    _maxCtrl = TextEditingController(text: i.maxTotal?.toString() ?? '');

    if (i.exactDay != null) {
      _dateMode = _DateMode.day;
      _singleDay = i.exactDay;
    } else if (i.dateRangeStart != null || i.dateRangeEnd != null) {
      _dateMode = _DateMode.range;
      _rangeStart = i.dateRangeStart;
      _rangeEnd = i.dateRangeEnd;
    } else if (i.periodYear != null && i.periodQuarter != null) {
      _dateMode = _DateMode.quarter;
      _qYear = i.periodYear!;
      _qQuarter = i.periodQuarter!;
    } else if (i.periodYear != null && i.periodMonth != null) {
      _dateMode = _DateMode.month;
      _mYear = i.periodYear!;
      _mMonth = i.periodMonth!;
    } else {
      _dateMode = _DateMode.any;
    }
  }

  @override
  void dispose() {
    _minCtrl.dispose();
    _maxCtrl.dispose();
    super.dispose();
  }

  double? _parseAmount(String text) {
    final s = text.trim().replaceAll(',', '.');
    if (s.isEmpty) return null;
    return double.tryParse(s);
  }

  InvoiceListFilters _compile() {
    final minT = _parseAmount(_minCtrl.text);
    final maxT = _parseAmount(_maxCtrl.text);

    final clientRows = _sortedClients();
    final clientId = _clientId != null &&
            clientRows.any((e) => e.key == _clientId)
        ? _clientId
        : null;

    final catalogItems =
        ref.read(catalogItemsStreamProvider).valueOrNull ?? const [];
    final catalogItemId = _catalogItemId != null &&
            catalogItems.any((c) => c.id == _catalogItemId)
        ? _catalogItemId
        : null;

    switch (_dateMode) {
      case _DateMode.any:
        return InvoiceListFilters(
          clientId: clientId,
          catalogItemId: catalogItemId,
          catalogLineKind: _lineKind,
          activityCategory: _activity,
          minTotal: minT,
          maxTotal: maxT,
        );
      case _DateMode.quarter:
        return InvoiceListFilters(
          clientId: clientId,
          catalogItemId: catalogItemId,
          catalogLineKind: _lineKind,
          activityCategory: _activity,
          minTotal: minT,
          maxTotal: maxT,
          periodYear: _qYear,
          periodQuarter: _qQuarter,
        );
      case _DateMode.month:
        return InvoiceListFilters(
          clientId: clientId,
          catalogItemId: catalogItemId,
          catalogLineKind: _lineKind,
          activityCategory: _activity,
          minTotal: minT,
          maxTotal: maxT,
          periodYear: _mYear,
          periodMonth: _mMonth,
        );
      case _DateMode.range:
        return InvoiceListFilters(
          clientId: clientId,
          catalogItemId: catalogItemId,
          catalogLineKind: _lineKind,
          activityCategory: _activity,
          minTotal: minT,
          maxTotal: maxT,
          dateRangeStart: _rangeStart,
          dateRangeEnd: _rangeEnd,
        );
      case _DateMode.day:
        return InvoiceListFilters(
          clientId: clientId,
          catalogItemId: catalogItemId,
          catalogLineKind: _lineKind,
          activityCategory: _activity,
          minTotal: minT,
          maxTotal: maxT,
          exactDay: _singleDay,
        );
    }
  }

  void _resetAll() {
    setState(() {
      _clientId = null;
      _catalogItemId = null;
      _lineKind = null;
      _activity = null;
      _minCtrl.clear();
      _maxCtrl.clear();
      _dateMode = _DateMode.any;
      _qYear = DateTime.now().year;
      _qQuarter = 1;
      _mYear = DateTime.now().year;
      _mMonth = DateTime.now().month;
      _rangeStart = null;
      _rangeEnd = null;
      _singleDay = null;
    });
  }

  List<MapEntry<String, String>> _sortedClients() {
    final m = <String, String>{};
    for (final s in widget.summaries) {
      if (s.clientId.isEmpty) continue;
      final label = s.clientName.isEmpty ? s.clientId : s.clientName;
      m[s.clientId] = label;
    }
    final list = m.entries.toList()
      ..sort((a, b) => a.value.toLowerCase().compareTo(b.value.toLowerCase()));
    return list;
  }

  List<int> _yearChoices() {
    final y = DateTime.now().year;
    final years = <int>{y - 2, y - 1, y, y + 1};
    for (final s in widget.summaries) {
      years.add(s.issueDate.year);
    }
    final list = years.toList()..sort();
    return list;
  }

  Future<void> _pickRange() async {
    final now = DateTime.now();
    final initialStart = _rangeStart ?? now;
    final initialEnd = _rangeEnd ?? now;
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(now.year + 2),
      initialDateRange: DateTimeRange(start: initialStart, end: initialEnd),
    );
    if (picked != null && mounted) {
      setState(() {
        _rangeStart = picked.start;
        _rangeEnd = picked.end;
      });
    }
  }

  Future<void> _pickSingleDay() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _singleDay ?? now,
      firstDate: DateTime(2000),
      lastDate: DateTime(now.year + 2),
    );
    if (picked != null && mounted) {
      setState(() => _singleDay = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final catalogAsync = ref.watch(catalogItemsStreamProvider);
    final clients = _sortedClients();
    final years = _yearChoices();
    final clientFieldValue =
        _clientId != null && clients.any((e) => e.key == _clientId)
            ? _clientId
            : null;

    return Material(
      color: theme.colorScheme.surface,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.invoiceFilterTitle,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView(
                  children: [
                    Text(
                      l10n.invoiceFilterClient,
                      style: theme.textTheme.labelLarge,
                    ),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String?>(
                      value: clientFieldValue,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      items: [
                        DropdownMenuItem<String?>(
                          value: null,
                          child: Text(l10n.invoiceFilterAllClients),
                        ),
                        ...clients.map(
                          (e) => DropdownMenuItem<String?>(
                            value: e.key,
                            child: Text(e.value, overflow: TextOverflow.ellipsis),
                          ),
                        ),
                      ],
                      onChanged: (v) => setState(() => _clientId = v),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.invoiceFilterCatalogItem,
                      style: theme.textTheme.labelLarge,
                    ),
                    const SizedBox(height: 6),
                    catalogAsync.when(
                      loading: () => const LinearProgressIndicator(),
                      error: (_, __) => Text(l10n.clientListError),
                      data: (items) {
                        final catalogValue =
                            _catalogItemId != null &&
                                    items.any((c) => c.id == _catalogItemId)
                                ? _catalogItemId
                                : null;
                        return DropdownButtonFormField<String?>(
                          value: catalogValue,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                          items: [
                            DropdownMenuItem<String?>(
                              value: null,
                              child: Text(l10n.invoiceFilterAnyCatalogItem),
                            ),
                            ...items.map(
                              (c) => DropdownMenuItem<String?>(
                                value: c.id,
                                child: Text(
                                  c.kind == CatalogKind.product
                                      ? '[P] ${c.description}'
                                      : '[S] ${c.description}',
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ],
                          onChanged: (v) => setState(() => _catalogItemId = v),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.invoiceFilterLineKind,
                      style: theme.textTheme.labelLarge,
                    ),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<CatalogKind?>(
                      value: _lineKind,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      items: [
                        DropdownMenuItem<CatalogKind?>(
                          value: null,
                          child: Text(l10n.invoiceFilterLineKindAny),
                        ),
                        DropdownMenuItem(
                          value: CatalogKind.product,
                          child: Text(l10n.invoiceFilterLineKindProduct),
                        ),
                        DropdownMenuItem(
                          value: CatalogKind.service,
                          child: Text(l10n.invoiceFilterLineKindService),
                        ),
                      ],
                      onChanged: (v) => setState(() => _lineKind = v),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.invoiceFilterActivity,
                      style: theme.textTheme.labelLarge,
                    ),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<ActivityCategory?>(
                      value: _activity,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      items: [
                        DropdownMenuItem<ActivityCategory?>(
                          value: null,
                          child: Text(l10n.invoiceFilterActivityAny),
                        ),
                        DropdownMenuItem(
                          value: ActivityCategory.commercial,
                          child: Text(l10n.activityCommercialShort),
                        ),
                        DropdownMenuItem(
                          value: ActivityCategory.artisanal,
                          child: Text(l10n.activityArtisanalShort),
                        ),
                        DropdownMenuItem(
                          value: ActivityCategory.liberal,
                          child: Text(l10n.activityLiberalShort),
                        ),
                        DropdownMenuItem(
                          value: ActivityCategory.services,
                          child: Text(l10n.activityServicesShort),
                        ),
                      ],
                      onChanged: (v) => setState(() => _activity = v),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _minCtrl,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: InputDecoration(
                              labelText: l10n.invoiceFilterAmountMin,
                              border: const OutlineInputBorder(),
                              isDense: true,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _maxCtrl,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: InputDecoration(
                              labelText: l10n.invoiceFilterAmountMax,
                              border: const OutlineInputBorder(),
                              isDense: true,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.invoiceFilterIssueDate,
                      style: theme.textTheme.labelLarge,
                    ),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<_DateMode>(
                      value: _dateMode,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      items: [
                        DropdownMenuItem(
                          value: _DateMode.any,
                          child: Text(l10n.invoiceFilterDateAny),
                        ),
                        DropdownMenuItem(
                          value: _DateMode.quarter,
                          child: Text(l10n.invoiceFilterDateQuarter),
                        ),
                        DropdownMenuItem(
                          value: _DateMode.month,
                          child: Text(l10n.invoiceFilterDateMonth),
                        ),
                        DropdownMenuItem(
                          value: _DateMode.range,
                          child: Text(l10n.invoiceFilterDateRange),
                        ),
                        DropdownMenuItem(
                          value: _DateMode.day,
                          child: Text(l10n.invoiceFilterDateSingle),
                        ),
                      ],
                      onChanged: (m) {
                        if (m == null) return;
                        setState(() => _dateMode = m);
                      },
                    ),
                    if (_dateMode == _DateMode.quarter) ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<int>(
                              value: _qYear,
                              decoration: InputDecoration(
                                labelText: l10n.declYear,
                                border: const OutlineInputBorder(),
                                isDense: true,
                              ),
                              items: years
                                  .map(
                                    (y) => DropdownMenuItem(
                                      value: y,
                                      child: Text('$y'),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (y) {
                                if (y != null) setState(() => _qYear = y);
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonFormField<int>(
                              value: _qQuarter,
                              decoration: InputDecoration(
                                labelText: l10n.declQuarter,
                                border: const OutlineInputBorder(),
                                isDense: true,
                              ),
                              items: List.generate(
                                4,
                                (i) => DropdownMenuItem(
                                  value: i + 1,
                                  child: Text('Q${i + 1}'),
                                ),
                              ),
                              onChanged: (q) {
                                if (q != null) setState(() => _qQuarter = q);
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (_dateMode == _DateMode.month) ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<int>(
                              value: _mYear,
                              decoration: InputDecoration(
                                labelText: l10n.declYear,
                                border: const OutlineInputBorder(),
                                isDense: true,
                              ),
                              items: years
                                  .map(
                                    (y) => DropdownMenuItem(
                                      value: y,
                                      child: Text('$y'),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (y) {
                                if (y != null) setState(() => _mYear = y);
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonFormField<int>(
                              value: _mMonth,
                              decoration: InputDecoration(
                                labelText: l10n.invoiceFilterDateMonth,
                                border: const OutlineInputBorder(),
                                isDense: true,
                              ),
                              items: List.generate(
                                12,
                                (i) => DropdownMenuItem(
                                  value: i + 1,
                                  child: Text('${i + 1}'),
                                ),
                              ),
                              onChanged: (mo) {
                                if (mo != null) setState(() => _mMonth = mo);
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (_dateMode == _DateMode.range) ...[
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: _pickRange,
                        icon: const Icon(Icons.date_range_rounded),
                        label: Text(
                          _rangeStart != null && _rangeEnd != null
                              ? '${MaterialLocalizations.of(context).formatShortDate(_rangeStart!)} — ${MaterialLocalizations.of(context).formatShortDate(_rangeEnd!)}'
                              : l10n.invoiceFilterDateRange,
                        ),
                      ),
                    ],
                    if (_dateMode == _DateMode.day) ...[
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: _pickSingleDay,
                        icon: const Icon(Icons.calendar_today_rounded),
                        label: Text(
                          _singleDay != null
                              ? MaterialLocalizations.of(context)
                                  .formatMediumDate(_singleDay!)
                              : l10n.invoiceFilterPickDay,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  TextButton(
                    onPressed: _resetAll,
                    child: Text(l10n.invoiceFilterReset),
                  ),
                  const Spacer(),
                  FilledButton(
                    onPressed: () {
                      if (_dateMode == _DateMode.range &&
                          (_rangeStart == null || _rangeEnd == null)) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(l10n.invoiceFilterDateRange)),
                        );
                        return;
                      }
                      if (_dateMode == _DateMode.day && _singleDay == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(l10n.invoiceFilterPickDay)),
                        );
                        return;
                      }
                      ref.read(invoiceListFilterProvider.notifier).state =
                          _compile();
                      Navigator.pop(context);
                    },
                    child: Text(l10n.invoiceFilterApply),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
