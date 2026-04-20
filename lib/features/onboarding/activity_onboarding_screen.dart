import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/firebase_providers.dart';
import '../../domain/tax/activity_category.dart';
import '../../l10n/app_localizations.dart';
import '../../models/user_profile.dart' show normalizeActivityCategories;
import '../../providers/auth_provider.dart';

/// Post sign-up: user picks activity categories with plain-language explanations (DECL-01).
class ActivityOnboardingScreen extends ConsumerStatefulWidget {
  const ActivityOnboardingScreen({super.key});

  @override
  ConsumerState<ActivityOnboardingScreen> createState() =>
      _ActivityOnboardingScreenState();
}

class _ActivityOnboardingScreenState extends ConsumerState<ActivityOnboardingScreen> {
  final Set<ActivityCategory> _selected = {ActivityCategory.commercial};
  bool _loading = false;

  String _shortLabel(AppLocalizations l10n, ActivityCategory c) {
    switch (c) {
      case ActivityCategory.commercial:
        return l10n.activityCommercialShort;
      case ActivityCategory.artisanal:
        return l10n.activityArtisanalShort;
      case ActivityCategory.liberal:
        return l10n.activityLiberalShort;
      case ActivityCategory.services:
        return l10n.activityServicesShort;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final uid = ref.watch(authStateProvider).valueOrNull?.uid;

    if (uid == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.onboardingActivityTitle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(
              l10n.onboardingActivitySubtitle,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.profileActivityCategoriesHint,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ActivityCategory.values.map((c) {
                final sel = _selected.contains(c);
                return FilterChip(
                  label: Text(_shortLabel(l10n, c)),
                  selected: sel,
                  showCheckmark: true,
                  onSelected: (_) {
                    setState(() {
                      if (sel) {
                        if (_selected.length > 1) _selected.remove(c);
                      } else {
                        _selected.add(c);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: ActivityCategory.values
                  .where(_selected.contains)
                  .map(
                    (c) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: _ActivityExplainer(category: c),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 28),
            FilledButton(
              onPressed: _loading ? null : () => _save(context, uid),
              child: _loading
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(l10n.onboardingContinue),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save(BuildContext context, String uid) async {
    final l10n = AppLocalizations.of(context)!;
    if (_selected.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.profileActivityCategoriesRequired)),
      );
      return;
    }
    setState(() => _loading = true);
    try {
      await ref.read(profileRepositoryProvider).saveActivityCategories(
            uid,
            normalizeActivityCategories(_selected).toList(),
          );
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.onboardingSaved)),
      );
      context.go('/dashboard');
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.onboardingError),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
}

class _ActivityExplainer extends StatelessWidget {
  const _ActivityExplainer({required this.category});

  final ActivityCategory category;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: theme.textTheme.titleSmall),
        const SizedBox(height: 8),
        Text(body, style: theme.textTheme.bodyMedium),
      ],
    );
  }
}
