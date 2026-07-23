import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_munchies/screens/activities/domain/repositories/record_repo.dart';
import 'package:frontend_munchies/screens/activities/views/activities_widgets/record_card.dart';
import 'package:frontend_munchies/screens/authentication/view/login.dart';
import 'package:frontend_munchies/screens/loggingFeature/views/logging_widgets/fields/categories.dart';
import 'package:frontend_munchies/screens/loggingFeature/views/logging_widgets/fields/cost.dart';
import 'package:frontend_munchies/screens/loggingFeature/views/logging_widgets/fields/date.dart';
import 'package:frontend_munchies/screens/loggingFeature/views/logging_widgets/fields/details.dart';
import 'package:frontend_munchies/screens/loggingFeature/views/logging_widgets/fields/item_name.dart';
import 'package:frontend_munchies/screens/loggingFeature/views/logging_widgets/fields/visibility_toggle.dart';
import 'package:frontend_munchies/screens/loggingFeature/views/logging_widgets/image_widgets.dart/image_selection_button.dart';
import 'package:frontend_munchies/screens/loggingFeature/views/tracking.dart';
import 'package:frontend_munchies/screens/main_screen.dart';
import 'package:frontend_munchies/widgets/button.dart';
import 'package:frontend_munchies/widgets/ignore_widgets/record_changer.dart';
import 'package:frontend_munchies/main.dart' as app;
import 'package:provider/provider.dart';

void main() {
  setUp(() async {
    if (Firebase.apps.isNotEmpty) {
      await FirebaseAuth.instance.signOut();
    } else {
      await Firebase.initializeApp();
    }
  });

  Future<void> loadPastAuth(WidgetTester tester) async {
    await tester.pumpWidget(
      Provider<RecordRepository>(
        create: (context) => RecordRepoImpl(),
        child: app.MainApp(),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(app.MainApp), findsOne);
    expect(find.byType(LoginPage), findsOne);

    await tester.enterText(
      find.byType(TextFormField).first,
      'jxtest@gmail.com',
    );
    await tester.pumpAndSettle();

    await tester.tapAt(Offset.zero);
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).last, '1234567');
    await tester.pumpAndSettle();
    await tester.tapAt(Offset.zero);
    await tester.pumpAndSettle();
    await tester.tap(find.byType(AppButton));
    await tester.pumpAndSettle();
  }

  tearDown(() async {
    await FirebaseAuth.instance.signOut();
  });

  group('test', () {
    testWidgets('login authentication works as required', (tester) async {
      await tester.pumpWidget(
        Provider<RecordRepository>(
          create: (context) => RecordRepoImpl(),
          child: app.MainApp(),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(app.MainApp), findsOne);
      expect(find.byType(LoginPage), findsOne);

      await tester.enterText(
        find.byType(TextFormField).first,
        'jxtest@gmail.com',
      );
      await tester.pumpAndSettle();

      await tester.tapAt(Offset.zero);
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).last, '1234567');
      await tester.pumpAndSettle();
      await tester.tapAt(Offset.zero);
      await tester.pumpAndSettle();
      await tester.tap(find.byType(AppButton));
      await tester.pumpAndSettle();

      expect(find.byType(Homepage), findsOne);
    });
  });

  testWidgets('fetching of records works as expected', (tester) async {
    await loadPastAuth(tester);
    expect(find.byType(RecordCard), findsNWidgets(11));
  });

  testWidgets('Fetching a single record produces all the details as expected', (
    tester,
  ) async {
    await loadPastAuth(tester);
    await tester.tap(find.widgetWithText(RecordCard, 'kopi pengg').last);
    await tester.pumpAndSettle();
    expect(find.byType(BottomSheet), findsOne);

    await tester.tap(find.text('Edit'));
    for (
      int i = 0;
      i < 10 && find.byType(TrackingPage).evaluate().isEmpty;
      i++
    ) {
      await tester.pump(const Duration(milliseconds: 500));
    }

    expect(find.byType(TrackingPage), findsOneWidget);
    expect(find.widgetWithText(ItemName, 'kopi pengg'), findsOne);
    expect(find.widgetWithText(CostField, '2.20'), findsOne);
    expect(find.widgetWithText(DateField, '2026-07-20'), findsOne);
    expect(find.byType(ImageSelectionButton), findsOne);
    expect(find.widgetWithText(DetailsField, 'i hate work'), findsOne);

    final beveragesText = find.descendant(
      of: find.byType(CategoryMenu),
      matching: find.byWidgetPredicate(
        (widget) => widget is Text && widget.data == 'Beverages',
      ),
    );
    expect(beveragesText, findsOneWidget);

    await tester.scrollUntilVisible(
      find.byType(VisibilityToggle),
      200.0,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.pumpAndSettle();
    expect(find.byType(VisibilityToggle), findsOne);
  });
}
