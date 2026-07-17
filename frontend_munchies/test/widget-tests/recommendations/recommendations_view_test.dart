import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_munchies/screens/recommendationFeature/view/rec_view.dart';

void main() {
  testWidgets("When data is being fetched, loading indicator is displayed", (
    WidgetTester tester,
  ) async {
    final completer = Completer<Map<String, dynamic>>();

    await tester.pumpWidget(
      MaterialApp(home: RecView(getRecTest: () => completer.future)),
    );

    final result = find.byType(CircularProgressIndicator);

    expect(result, findsOneWidget);
  });

  testWidgets("After data is being fetched, recommendations are shown", (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: RecView(
          getRecTest: () async => {
            "tastePreference":
                "We noticed that you prefer sweet and creamy treats.",
            "recommendations": [
              {
                "name": "Greek Yogurt",
                "flavours": "creamy, tangy",
                "benefit": "High protein",
              },
              {
                "name": "Dark Chocolate",
                "flavours": "rich, bittersweet",
                "benefit": "Antioxidants",
              },
              {
                "name": "Frozen Banana",
                "flavours": "sweet, creamy, cold",
                "benefit": "Natural sugars",
              },
            ],
          },
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.textContaining("We noticed that you prefer"), findsOneWidget);
    expect(find.text("1. Greek Yogurt "), findsOneWidget);
    expect(find.text("2. Dark Chocolate "), findsOneWidget);
  });
}
