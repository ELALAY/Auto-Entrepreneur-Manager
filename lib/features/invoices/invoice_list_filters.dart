import 'package:flutter/foundation.dart';

import '../../domain/tax/activity_category.dart';
import '../../models/catalog_item.dart';
import '../../models/invoice_summary.dart';
import '../../utils/quarter_bounds.dart';

@immutable
class InvoiceListFilters {
  const InvoiceListFilters({
    this.clientId,
    this.catalogItemId,
    this.catalogLineKind,
    this.activityCategory,
    this.minTotal,
    this.maxTotal,
    this.periodYear,
    this.periodQuarter,
    this.periodMonth,
    this.dateRangeStart,
    this.dateRangeEnd,
    this.exactDay,
  });

  final String? clientId;
  final String? catalogItemId;
  final CatalogKind? catalogLineKind;
  final ActivityCategory? activityCategory;
  final double? minTotal;
  final double? maxTotal;
  final int? periodYear;
  final int? periodQuarter;
  final int? periodMonth;
  final DateTime? dateRangeStart;
  final DateTime? dateRangeEnd;
  final DateTime? exactDay;

  static const InvoiceListFilters empty = InvoiceListFilters();

  bool get hasAny =>
      (clientId != null && clientId!.isNotEmpty) ||
      (catalogItemId != null && catalogItemId!.isNotEmpty) ||
      catalogLineKind != null ||
      activityCategory != null ||
      minTotal != null ||
      maxTotal != null ||
      (periodYear != null && periodQuarter != null) ||
      (periodYear != null && periodMonth != null) ||
      dateRangeStart != null ||
      dateRangeEnd != null ||
      exactDay != null;

  InvoiceListFilters copyWith({
    String? clientId,
    String? catalogItemId,
    CatalogKind? catalogLineKind,
    ActivityCategory? activityCategory,
    double? minTotal,
    double? maxTotal,
    int? periodYear,
    int? periodQuarter,
    int? periodMonth,
    DateTime? dateRangeStart,
    DateTime? dateRangeEnd,
    DateTime? exactDay,
    bool clearClientId = false,
    bool clearCatalogItemId = false,
    bool clearCatalogLineKind = false,
    bool clearActivityCategory = false,
    bool clearMinTotal = false,
    bool clearMaxTotal = false,
    bool clearPeriod = false,
    bool clearDateRange = false,
    bool clearExactDay = false,
  }) {
    return InvoiceListFilters(
      clientId: clearClientId ? null : (clientId ?? this.clientId),
      catalogItemId:
          clearCatalogItemId ? null : (catalogItemId ?? this.catalogItemId),
      catalogLineKind: clearCatalogLineKind
          ? null
          : (catalogLineKind ?? this.catalogLineKind),
      activityCategory: clearActivityCategory
          ? null
          : (activityCategory ?? this.activityCategory),
      minTotal: clearMinTotal ? null : (minTotal ?? this.minTotal),
      maxTotal: clearMaxTotal ? null : (maxTotal ?? this.maxTotal),
      periodYear: clearPeriod ? null : (periodYear ?? this.periodYear),
      periodQuarter:
          clearPeriod ? null : (periodQuarter ?? this.periodQuarter),
      periodMonth: clearPeriod ? null : (periodMonth ?? this.periodMonth),
      dateRangeStart:
          clearDateRange ? null : (dateRangeStart ?? this.dateRangeStart),
      dateRangeEnd: clearDateRange ? null : (dateRangeEnd ?? this.dateRangeEnd),
      exactDay: clearExactDay ? null : (exactDay ?? this.exactDay),
    );
  }
}

DateTime _dayOnly(DateTime d) => DateTime(d.year, d.month, d.day);

bool _inAmountRange(InvoiceSummary inv, InvoiceListFilters f) {
  if (f.minTotal != null && inv.total < f.minTotal! - 0.005) return false;
  if (f.maxTotal != null && inv.total > f.maxTotal! + 0.005) return false;
  return true;
}

bool _issueDateMatches(InvoiceSummary inv, InvoiceListFilters f) {
  final d = _dayOnly(inv.issueDate);
  if (f.exactDay != null) {
    return d == _dayOnly(f.exactDay!);
  }
  if (f.dateRangeStart != null || f.dateRangeEnd != null) {
    final lo = f.dateRangeStart != null
        ? _dayOnly(f.dateRangeStart!)
        : DateTime(1970);
    final hi = f.dateRangeEnd != null
        ? _dayOnly(f.dateRangeEnd!)
        : DateTime(2100, 12, 31);
    return !d.isBefore(lo) && !d.isAfter(hi);
  }
  if (f.periodYear != null && f.periodQuarter != null) {
    return dateOnlyInQuarter(inv.issueDate, f.periodYear!, f.periodQuarter!);
  }
  if (f.periodYear != null && f.periodMonth != null) {
    return inv.issueDate.year == f.periodYear &&
        inv.issueDate.month == f.periodMonth;
  }
  return true;
}

ActivityCategory _effectiveActivity(
  InvoiceSummary inv,
  ActivityCategory profileFallback,
) {
  return inv.activityCategory ?? profileFallback;
}

bool invoicePassesListFilters(
  InvoiceSummary inv,
  InvoiceListFilters f,
  ActivityCategory profileActivityFallback,
  Map<String, CatalogItem> catalogById,
) {
  if (!f.hasAny) return true;

  if (f.clientId != null &&
      f.clientId!.isNotEmpty &&
      inv.clientId != f.clientId) {
    return false;
  }

  if (f.catalogItemId != null && f.catalogItemId!.isNotEmpty) {
    if (!inv.catalogLineIds.contains(f.catalogItemId)) return false;
  } else if (f.catalogLineKind != null) {
    var ok = false;
    for (final cid in inv.catalogLineIds) {
      final cat = catalogById[cid];
      if (cat != null && cat.kind == f.catalogLineKind) {
        ok = true;
        break;
      }
    }
    if (!ok) return false;
  }

  if (f.activityCategory != null) {
    if (_effectiveActivity(inv, profileActivityFallback) !=
        f.activityCategory) {
      return false;
    }
  }

  if (!_inAmountRange(inv, f)) return false;
  if (!_issueDateMatches(inv, f)) return false;

  return true;
}

List<InvoiceSummary> filterInvoiceSummaries(
  List<InvoiceSummary> all,
  InvoiceListFilters f,
  ActivityCategory profileActivityFallback,
  Map<String, CatalogItem> catalogById,
) {
  if (!f.hasAny) return all;
  return [
    for (final inv in all)
      if (invoicePassesListFilters(
        inv,
        f,
        profileActivityFallback,
        catalogById,
      ))
        inv,
  ];
}
