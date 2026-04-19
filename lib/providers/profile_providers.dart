import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/firebase_providers.dart';
import '../models/user_profile.dart';
import '../utils/profile_completion.dart';
import 'auth_provider.dart';

final userProfileStreamProvider = StreamProvider<UserProfile?>((ref) {
  final uid = ref.watch(authStateProvider).maybeWhen(
        data: (u) => u?.uid,
        orElse: () => null,
      );
  if (uid == null) {
    return Stream.value(null);
  }
  return ref.watch(profileRepositoryProvider).watchProfile(uid);
});

final profileCompleteProvider = Provider<AsyncValue<bool>>((ref) {
  final profileAsync = ref.watch(userProfileStreamProvider);
  return profileAsync.when(
    data: (p) => AsyncValue.data(isProfileComplete(p)),
    loading: () => const AsyncValue.loading(),
    error: (e, st) => AsyncValue.error(e, st),
  );
});
