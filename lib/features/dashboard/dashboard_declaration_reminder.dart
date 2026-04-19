import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../l10n/app_localizations.dart';
import '../../models/declaration.dart';
import '../../models/enums.dart';
import '../../providers/auth_provider.dart';
import '../../providers/declaration_providers.dart';
import '../../utils/declaration_filing_deadline.dart';

/// Banner between hero and stats; filing state comes from `users/{uid}/declarations`
/// with [DeclarationStatus.filed], only for the latest civil quarter that has ended.
class DashboardDeclarationReminder extends ConsumerWidget {
  const DashboardDeclarationReminder({super.key});

  String _formatDeadline(BuildContext context, DateTime date) {
    final locale = Localizations.localeOf(context).toLanguageTag();
    return DateFormat.yMMMMd(locale).format(date);
  }

  String _bannerText(AppLocalizations l10n, DeclarationFilingStatus s, String dl) {
    if (s.daysRemaining < 0) {
      return l10n.dashboardDeclarationBannerOverdue(
        s.declarationQuarter,
        s.declarationYear,
        -s.daysRemaining,
        dl,
      );
    }
    if (s.daysRemaining == 0) {
      return l10n.dashboardDeclarationBannerLastDay(
        s.declarationQuarter,
        s.declarationYear,
        dl,
      );
    }
    return l10n.dashboardDeclarationBannerActive(
      s.declarationQuarter,
      s.declarationYear,
      s.daysRemaining,
      dl,
    );
  }

  bool _isQuarterFiled(List<Declaration> list, int y, int q) {
    for (final d in list) {
      if (d.year == y && d.quarter == q && d.status == DeclarationStatus.filed) {
        return true;
      }
    }
    return false;
  }

  void _openDeclaration(BuildContext context, DeclarationFilingStatus status) {
    context.push('/declarations/${status.declarationYear}/${status.declarationQuarter}');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uid = ref.watch(authStateProvider).valueOrNull?.uid;
    final declarationsAsync = ref.watch(declarationsListStreamProvider);

    if (uid == null) {
      return const SizedBox.shrink();
    }

    final status = declarationsAsync.maybeWhen(
      data: (list) => outstandingDeclarationFiling(
        now: DateTime.now(),
        isQuarterFiled: (y, q) => _isQuarterFiled(list, y, q),
      ),
      orElse: () => null,
    );

    if (status == null) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final dl = _formatDeadline(context, status.deadline);
    final text = _bannerText(l10n, status, dl);

    final Color bg;
    final Color fg;
    if (status.daysRemaining < 0) {
      bg = scheme.errorContainer;
      fg = scheme.onErrorContainer;
    } else if (status.daysRemaining <= 14) {
      bg = scheme.errorContainer.withValues(alpha: 0.78);
      fg = scheme.onErrorContainer;
    } else {
      bg = scheme.secondaryContainer;
      fg = scheme.onSecondaryContainer;
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Material(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => _openDeclaration(context, status),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Icon(Icons.event_repeat_rounded, color: fg, size: 22),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    text,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: fg,
                      height: 1.35,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => _openDeclaration(context, status),
                  child: Text(
                    l10n.dashboardDeclarationBannerOpen,
                    style: TextStyle(color: fg, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
