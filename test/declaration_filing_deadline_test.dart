import 'package:auto_entrepreneur_manager/utils/declaration_filing_deadline.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('declaration filing deadlines', () {
    test('April — latest ended Q1; first unfiled is Q1', () {
      final now = DateTime(2026, 4, 19);
      final s = outstandingDeclarationFiling(
        now: now,
        isQuarterFiled: (_, __) => false,
      );
      expect(s, isNotNull);
      expect(s!.declarationQuarter, 1);
      expect(s.declarationYear, 2026);
      expect(s.deadline, DateTime(2026, 4, 30));
      expect(s.daysRemaining, 11);
    });

    test('July — latest ended Q2 first if unfiled', () {
      final now = DateTime(2026, 7, 8);
      final s = outstandingDeclarationFiling(
        now: now,
        isQuarterFiled: (_, __) => false,
      );
      expect(s!.declarationQuarter, 2);
      expect(s.declarationYear, 2026);
    });

    test('May — latest ended Q1 overdue if still unfiled', () {
      final now = DateTime(2026, 5, 15);
      final s = outstandingDeclarationFiling(
        now: now,
        isQuarterFiled: (_, __) => false,
      );
      expect(s!.declarationQuarter, 1);
      expect(s.daysRemaining, lessThan(0));
    });

    test('January — latest ended prior calendar Q4', () {
      final now = DateTime(2027, 1, 15);
      final s = outstandingDeclarationFiling(
        now: now,
        isQuarterFiled: (_, __) => false,
      );
      expect(s!.declarationQuarter, 4);
      expect(s.declarationYear, 2026);
      expect(s.deadline, DateTime(2027, 1, 31));
    });

    test('March — latest ended Q4 prior year', () {
      final now = DateTime(2027, 3, 15);
      final s = outstandingDeclarationFiling(
        now: now,
        isQuarterFiled: (_, __) => false,
      );
      expect(s!.declarationQuarter, 4);
      expect(s.declarationYear, 2026);
    });

    test('after latest-ended quarter filed, do not nag older quarters', () {
      final now = DateTime(2026, 4, 19);
      final s = outstandingDeclarationFiling(
        now: now,
        isQuarterFiled: (y, q) => y == 2026 && q == 1,
      );
      expect(s, isNull);
    });

    test('next countdown skips filed quarters', () {
      final now = DateTime(2026, 4, 19);
      final next = nextDeclarationFilingCountdown(
        now,
        isQuarterFiled: (y, q) => y == 2026 && q == 1,
      );
      expect(next!.declarationQuarter, 2);
      expect(next.deadline, DateTime(2026, 7, 31));
    });

    test('declarationPeriodKey matches providers', () {
      expect(declarationPeriodKey(2026, 1), '2026-1');
    });

    test('latestEndedQuarter April 19 is Q1 same year', () {
      final q = latestEndedQuarter(DateTime(2026, 4, 19));
      expect(q.year, 2026);
      expect(q.quarter, 1);
    });
  });
}
