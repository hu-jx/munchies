import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_munchies/screens/dashboardFeature/dashboardViewModel/date_helpers.dart';
import 'package:frontend_munchies/screens/dashboardFeature/view_opt.dart';

void main() {
  group('Test date helpers for weekly view', () {
    test(
      'goFoward function correctly returns updated date for weekly view',
      () async {
        final newDate = goForward(ViewOpt.weekly, DateTime(2026, 6, 21));
        expect(newDate, DateTime(2026, 6, 28));
      },
    );

    test(
      'goBack function correctly returns updated date for weekly view',
      () async {
        final newDate = goBack(ViewOpt.weekly, DateTime(2026, 6, 21));
        expect(newDate, DateTime(2026, 6, 14));
      },
    );

    test('findStart function returns the correct start date of week', () async {
      final startDate = findStart(ViewOpt.weekly, DateTime(2026, 6, 24));
      expect(startDate, DateTime(2026, 6, 22).toIso8601String().split('T')[0]);
    });

    test('findEnd function returns the correct start date of week', () async {
      final endDate = findEnd(ViewOpt.weekly, DateTime(2026, 6, 24));
      expect(endDate, DateTime(2026, 6, 28).toIso8601String().split('T')[0]);
    });

    test('displayRange is correct for weekly view', () async {
      final range = displayRange(ViewOpt.weekly, DateTime(2026, 6, 24));
      expect(range, '2026-06-22 to 2026-06-28');
    });
  });

  group('Test date helpers for monthly view, using June', () {
    test(
      'goFoward function correctly returns updated date(July) for monthly view',
      () async {
        final newDate = goForward(ViewOpt.monthly, DateTime(2026, 6, 21));
        expect(newDate, DateTime(2026, 7, 1));
      },
    );

    test(
      'goBack function correctly returns updated date(May) for monthly view',
      () async {
        final newDate = goBack(ViewOpt.monthly, DateTime(2026, 6, 21));
        expect(newDate, DateTime(2026, 5, 1));
      },
    );

    test(
      'findStart function returns the correct start date of month',
      () async {
        final startDate = findStart(ViewOpt.monthly, DateTime(2026, 6, 24));
        expect(startDate, DateTime(2026, 6, 1).toIso8601String().split('T')[0]);
      },
    );

    test('findEnd function returns the correct start date of month', () async {
      final endDate = findEnd(ViewOpt.monthly, DateTime(2026, 6, 24));
      expect(endDate, DateTime(2026, 7, 0).toIso8601String().split('T')[0]);
    });

    test('displayRange is correct for monthly view', () async {
      final range = displayRange(ViewOpt.monthly, DateTime(2026, 6, 24));
      expect(range, 'June 2026');
    });
  });

  group('Test date helpers for yearly view, using 2026', () {
    test(
      'goFoward function correctly returns updated date for yearly view',
      () async {
        final newDate = goForward(ViewOpt.annually, DateTime(2026, 6, 21));
        expect(newDate, DateTime(2027, 1, 1));
      },
    );

    test(
      'goBack function correctly returns updated date(May) for monthly view',
      () async {
        final newDate = goBack(ViewOpt.annually, DateTime(2026, 6, 21));
        expect(newDate, DateTime(2025, 1, 1));
      },
    );

    test('findStart function returns the correct start date of year', () async {
      final startDate = findStart(ViewOpt.annually, DateTime(2026, 6, 24));
      expect(startDate, DateTime(2026, 1, 1).toIso8601String().split('T')[0]);
    });

    test('findEnd function returns the correct start date of year', () async {
      final endDate = findEnd(ViewOpt.annually, DateTime(2026, 6, 24));
      expect(endDate, DateTime(2026, 12, 31).toIso8601String().split('T')[0]);
    });

    test('displayRange is correct for yearly view', () async {
      final range = displayRange(ViewOpt.annually, DateTime(2026, 6, 24));
      expect(range, '2026');
    });
  });

  group('Edge cases tests', () {
    test('correct range displayed for a week in between 2 months', () async {
      final range = displayRange(ViewOpt.weekly, DateTime(2026, 7, 1));
      expect(range, '2026-06-29 to 2026-07-05');
    });

    test('correct endDate for a leap year Feburary', () async {
      final endDate = findEnd(ViewOpt.monthly, DateTime(2024, 2, 1));
      expect(endDate, DateTime(2024, 2, 29).toIso8601String().split('T')[0]);
    });


  });
}

/* test template
test('desc', () async {
});
*/
