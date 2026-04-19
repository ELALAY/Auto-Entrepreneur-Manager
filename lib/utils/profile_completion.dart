import '../models/user_profile.dart';

/// Whether the user may create invoices (PROF-02). All legal identity fields must be filled.
bool isProfileComplete(UserProfile? profile) {
  if (profile == null) return false;
  bool ok(String s) => s.trim().isNotEmpty;
  return ok(profile.name) &&
      ok(profile.cin) &&
      ok(profile.ice) &&
      ok(profile.ifNumber) &&
      ok(profile.cnssNumber) &&
      ok(profile.address);
}
