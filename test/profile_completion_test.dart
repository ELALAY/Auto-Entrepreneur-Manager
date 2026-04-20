import 'package:auto_entrepreneur_manager/domain/tax/activity_category.dart';
import 'package:auto_entrepreneur_manager/models/user_profile.dart';
import 'package:auto_entrepreneur_manager/utils/profile_completion.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('isProfileComplete is false for null', () {
    expect(isProfileComplete(null), false);
  });

  test('isProfileComplete is false when any legal field empty', () {
    const p = UserProfile(
      uid: 'u1',
      name: 'Co',
      cin: '',
      ice: 'ICE',
      ifNumber: 'IF',
      cnssNumber: 'CNSS',
      activityCategories: [ActivityCategory.commercial],
      address: 'Addr', taxProfessionnelle: '32546', phone: '+1234567890',
    );
    expect(isProfileComplete(p), false);
  });

  test('isProfileComplete is true when all required fields non-empty', () {
    const p = UserProfile(
      uid: 'u1',
      name: 'Company',
      cin: 'AB123',
      ice: '001234567000089',
      ifNumber: '12345678',
      cnssNumber: '1234567',
      activityCategories: [ActivityCategory.liberal],
      address: 'Casablanca', taxProfessionnelle: '32546', phone: '+1234567890',
    );
    expect(isProfileComplete(p), true);
  });
}
