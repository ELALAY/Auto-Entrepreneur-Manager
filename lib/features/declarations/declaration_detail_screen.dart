import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../data/firebase_providers.dart';
import '../../domain/tax/activity_category.dart';
import '../../domain/tax/tax_calculator.dart';
import '../../domain/tax/tax_rates_config.dart';
import '../../l10n/app_localizations.dart';
import '../../models/declaration.dart';
import '../../models/enums.dart';
import '../../providers/auth_provider.dart';
import '../../providers/declaration_providers.dart';
import '../../providers/profile_providers.dart';

class DeclarationDetailScreen extends ConsumerStatefulWidget {
  const DeclarationDetailScreen({
    super.key,
    required this.year,
    required this.quarter,
  });

  final int year;
  final int quarter;

  @override
  ConsumerState<DeclarationDetailScreen> createState() =>
      _DeclarationDetailScreenState();
}

class _DeclarationDetailScreenState extends ConsumerState<DeclarationDetailScreen> {
  bool _actionLoading = false;

  String get _periodKey => declarationPeriodKey(widget.year, widget.quarter);

  String _formatMad(BuildContext context, double v) {
    final loc = Localizations.localeOf(context).toString();
    final n = NumberFormat.decimalPatternDigits(locale: loc, decimalDigits: 2);
    return '${n.format(v)} MAD';
  }

  Future<void> _onRefresh() async {
    ref.invalidate(quarterPaidRevenueProvider(_periodKey));
    await ref.read(quarterPaidRevenueProvider(_periodKey).future);
  }

  Future<void> _saveDeclaration({
    required String uid,
    required TaxComputation computation,
  }) async {
    setState(() => _actionLoading = true);
    try {
      await ref.read(declarationRepositoryProvider).saveDeclaration(
            uid: uid,
            year: widget.year,
            quarter: widget.quarter,
            totalRevenue: computation.totalRevenue,
            irAmount: computation.irAmount,
            cnssAmount: computation.cnssAmount,
            status: DeclarationStatus.readyToFile,
            taxRatesVersion: computation.ratesVersion,
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.declSaved)),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.declSaveError),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _actionLoading = false);
    }
  }

  Future<void> _markFiled(String uid) async {
    final l10n = AppLocalizations.of(context)!;
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      helpText: l10n.declChooseFiledDate,
    );
    if (picked == null || !mounted) return;

    setState(() => _actionLoading = true);
    try {
      await ref.read(declarationRepositoryProvider).markFiled(
            uid: uid,
            year: widget.year,
            quarter: widget.quarter,
            filedDate: picked,
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.declSaved)),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.declSaveError),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _actionLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).toString();
    final dateFmt = DateFormat.yMMMd(locale);

    final taxRatesAsync = ref.watch(taxRatesStreamProvider);
    final revenueAsync = ref.watch(quarterPaidRevenueProvider(_periodKey));
    final savedAsync = ref.watch(declarationForPeriodStreamProvider(_periodKey));
    final profileAsync = ref.watch(userProfileStreamProvider);
    final uid = ref.watch(authStateProvider).valueOrNull?.uid;

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.year} · Q${widget.quarter} · ${l10n.screenDeclarationDetail}'),
      ),
      body: uid == null
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _onRefresh,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: taxRatesAsync.when(
                  loading: () => const Padding(
                    padding: EdgeInsets.all(48),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (_, __) => Text(l10n.declLoadError),
                  data: (rates) {
                    if (rates == null) {
                      return Card(
                        color: theme.colorScheme.errorContainer,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            l10n.declTaxConfigMissing,
                            style: TextStyle(color: theme.colorScheme.onErrorContainer),
                          ),
                        ),
                      );
                    }
                    return revenueAsync.when(
                      loading: () => const Padding(
                        padding: EdgeInsets.all(48),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                      error: (_, __) => Text(l10n.declLoadError),
                      data: (revenue) {
                        final profile = profileAsync.valueOrNull;
                        final category = profile?.activityCategory ??
                            ActivityCategory.commercial;
                        final computation = computeQuarterlyTax(
                          totalRevenue: revenue,
                          category: category,
                          rates: rates,
                          hasCnss: profile?.hasCnss ?? false,
                        );
                        return savedAsync.when(
                          loading: () => const Padding(
                            padding: EdgeInsets.all(48),
                            child: Center(child: CircularProgressIndicator()),
                          ),
                          error: (_, __) => Text(l10n.declLoadError),
                          data: (saved) => _buildContent(
                            context,
                            l10n,
                            theme,
                            dateFmt,
                            uid,
                            rates,
                            computation,
                            saved,
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    AppLocalizations l10n,
    ThemeData theme,
    DateFormat dateFmt,
    String uid,
    TaxRatesConfig rates,
    TaxComputation computation,
    Declaration? saved,
  ) {
    final filed = saved?.status == DeclarationStatus.filed;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (saved != null && saved.status == DeclarationStatus.filed && saved.filedDate != null)
          Card(
            child: ListTile(
              leading: const Icon(Icons.check_circle_outline),
              title: Text(l10n.declStatusFiled),
              subtitle: Text(l10n.declFiledOn(dateFmt.format(saved.filedDate!))),
            ),
          ),
        if (saved != null && saved.status != DeclarationStatus.filed)
          Card(
            child: ListTile(
              leading: const Icon(Icons.edit_note_outlined),
              title: Text(_statusLabel(l10n, saved.status)),
              subtitle: Text(l10n.declRatesVersion(saved.taxRatesVersion ?? rates.version)),
            ),
          ),
        const SizedBox(height: 8),
        _amountTile(
          context,
          l10n.declRevenueQuarter,
          _formatMad(context, computation.totalRevenue),
          subtitle: l10n.declRevenueHint,
        ),
        _amountTile(
          context,
          l10n.declIrDue,
          _formatMad(context, computation.irAmount),
        ),
        _amountTile(
          context,
          l10n.declCnssDue,
          _formatMad(context, computation.cnssAmount),
          subtitle: computation.cnssExempt ? l10n.declCnssExempt : null,
        ),
        const SizedBox(height: 8),
        Text(
          l10n.declRatesVersion(rates.version),
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              l10n.declDisclaimer,
              style: theme.textTheme.bodySmall,
            ),
          ),
        ),
        const SizedBox(height: 16),
        ExpansionTile(
          title: Text(l10n.declFilingGuideTitle),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: () => launchUrl(
                      Uri.parse('https://ae.gov.ma'),
                      mode: LaunchMode.externalApplication,
                    ),
                    borderRadius: BorderRadius.circular(4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            '1. ${l10n.declFilingStep1}',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Icon(
                            Icons.open_in_new,
                            size: 14,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('2. ${l10n.declFilingStep2}'),
                  const SizedBox(height: 8),
                  Text('3. ${l10n.declFilingStep3}'),
                  const SizedBox(height: 8),
                  Text('4. ${l10n.declFilingStep4}'),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        if (!filed) ...[
          FilledButton(
            onPressed: _actionLoading
                ? null
                : () => _saveDeclaration(uid: uid, computation: computation),
            child: Text(l10n.declSaveRecord),
          ),
          const SizedBox(height: 12),
          if (saved != null)
            OutlinedButton(
              onPressed: _actionLoading ? null : () => _markFiled(uid),
              child: Text(l10n.declMarkFiled),
            ),
        ],
      ],
    );
  }

  String _statusLabel(AppLocalizations l10n, DeclarationStatus s) {
    return switch (s) {
      DeclarationStatus.draft => l10n.declStatusDraft,
      DeclarationStatus.readyToFile => l10n.declStatusReady,
      DeclarationStatus.filed => l10n.declStatusFiled,
    };
  }

  Widget _amountTile(
    BuildContext context,
    String title,
    String value, {
    String? subtitle,
  }) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: theme.textTheme.titleSmall),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            const SizedBox(height: 8),
            Text(
              value,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
