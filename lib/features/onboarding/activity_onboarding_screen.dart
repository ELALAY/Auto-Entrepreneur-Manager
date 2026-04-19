import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/firebase_providers.dart';
import '../../domain/tax/activity_category.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/auth_provider.dart';

/// Post sign-up: user picks activity category with plain-language explanations (DECL-01).
class ActivityOnboardingScreen extends ConsumerStatefulWidget {
  const ActivityOnboardingScreen({super.key});

  @override
  ConsumerState<ActivityOnboardingScreen> createState() =>
      _ActivityOnboardingScreenState();
}

class _ActivityOnboardingScreenState extends ConsumerState<ActivityOnboardingScreen> {
  ActivityCategory _selected = ActivityCategory.commercial;
  bool _loading = false;

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
            const SizedBox(height: 24),
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
              selected: {_selected},
              onSelectionChanged: (s) {
                setState(() => _selected = s.first);
              },
            ),
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: _ActivityExplainer(category: _selected),
              ),
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
    setState(() => _loading = true);
    try {
      await ref.read(profileRepositoryProvider).saveActivityCategory(uid, _selected);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.onboardingSaved)),
      );
      context.go('/dashboard');
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.onboardingError),
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
