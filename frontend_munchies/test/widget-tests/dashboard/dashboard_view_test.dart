import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_munchies/screens/dashboardFeature/dashboardView/dashboard_base.dart';
import 'package:frontend_munchies/screens/dashboardFeature/dashboardView/dashboard_main.dart';
import 'package:frontend_munchies/screens/dashboardFeature/dashboardView/pie_chart_builder.dart';
import 'package:frontend_munchies/screens/dashboardFeature/dashboardViewModel/dashboard_view_model.dart';
import 'package:frontend_munchies/screens/dashboardFeature/view_opt.dart';

import '../auth/login_view_test.dart';

void main() {
  testWidgets("Dashboard displays Circular Progress Indicator when loading", (
    WidgetTester tester,
  ) async {
    final mockAuth = MockFirebaseAuth();

    await tester.pumpWidget(
      MaterialApp(
        home: DashboardView(
          model: DashboardViewModel(
            auth: mockAuth,
            testCategoryData: [],
            testSummaryData: [],
          ),
          onChangeView: (ViewOpt view) {},
          onBackButton: (DateTime date) {},
          onForwardButton: (DateTime date) {},
          isLoading: true,
        ),
      ),
    );

    await tester.pump(const Duration(milliseconds: 100));
    expect(find.byType(CircularProgressIndicator), findsOne);
  });

  testWidgets("Dashboard displays message when no data is available ", (
    WidgetTester tester,
  ) async {
    final mockAuth = MockFirebaseAuth();

    await tester.pumpWidget(
      MaterialApp(
        home: DashboardView(
          model: DashboardViewModel(
            auth: mockAuth,
            testCategoryData: [],
            testSummaryData: [],
          ),
          onChangeView: (ViewOpt view) {},
          onBackButton: (DateTime date) {},
          onForwardButton: (DateTime date) {},
          isLoading: false,
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.text("No data. Please log your consumption first"), findsOne);
  });

  testWidgets("Dashboard displays 2 pie charts when data is available ", (
    WidgetTester tester,
  ) async {
    final mockAuth = MockFirebaseAuth();

    DashboardViewModel vm = DashboardViewModel(
      auth: mockAuth,
      testCategoryData: [
        {
          "_id": {"category": "Pastry"},
          "costPerCat": 1000,
          "numPerCat": 1,
        },
        {
          "_id": {"category": "Cakes"},
          "costPerCat": 1600,
          "numPerCat": 3,
        },
      ],
      testSummaryData: [
        {"_id": "2026-06-30T00:00:00.000Z", "totalCost": 450, "totalNum": 1},
      ],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: DashboardView(
          model: vm,
          onChangeView: (ViewOpt view) {},
          onBackButton: (DateTime date) {},
          onForwardButton: (DateTime date) {},
          isLoading: false,
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.byType(PieChartBuilder), findsExactly(2));
  });

  testWidgets("PopupMenuButton has correct view options displayed", (WidgetTester tester) async {
    final mockAuth = MockFirebaseAuth();

    DashboardViewModel vm = DashboardViewModel(
      auth: mockAuth,
      testCategoryData: [],
      testSummaryData: [],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: DashboardView(
          model: vm,
          onChangeView: (ViewOpt view) async {
            vm.changeView(view);
            await vm.getData();
          },
          onBackButton: (DateTime date) {},
          onForwardButton: (DateTime date) {},
          isLoading: false,
        ),
      ),
    );

    await tester.pumpAndSettle();

    await tester.tap(find.byType(PopupMenuButton<ViewOpt>));
    await tester.pumpAndSettle();
    expect(find.text("Monthly"), findsOneWidget);
    expect(find.text("Yearly"), findsOneWidget);
    expect(find.text("Future You"), findsOneWidget);
  });

  testWidgets("FutureView displays message when there is no data available", (WidgetTester tester) async {
    final mockAuth = MockFirebaseAuth();

    DashboardViewModel vm = DashboardViewModel(
      auth: mockAuth,
      testCategoryData: [],
      testSummaryData: [],
    );

    vm.changeView(ViewOpt.futureView);

    await tester.pumpWidget(
      MaterialApp(
        home: DashboardView(
          model: vm,
          onChangeView: (ViewOpt view) async {},
          onBackButton: (DateTime date) {},
          onForwardButton: (DateTime date) {},
          isLoading: false,
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(vm.selectedView, ViewOpt.futureView);

    expect(
      find.text(
        "Not enough data for a prediction. A minimum of 3 months worth of data entered is required to make a prediction",
      ),
      findsOne,
    );
  });

}
