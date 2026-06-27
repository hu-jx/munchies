import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_munchies/screens/dashboardFeature/dashboardViewModel/dashboard_view_model.dart';
import 'package:frontend_munchies/screens/dashboardFeature/view_opt.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:mocktail/mocktail.dart';
import 'package:http/http.dart' as http;

class MockClient extends Mock implements http.Client {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() {
    registerFallbackValue(Uri.parse('https://api'));
  });

  group('DashboardViewModel pure function tests', () {
    test(
      'selectedView is updated correctly when changeView is called',
      () async {
        final mockAuth = MockFirebaseAuth(
          mockUser: MockUser(uid: 'emptyUser'),
          signedIn: true,
        );

        final vm = DashboardViewModel(auth: mockAuth);

        try {
          vm.changeView(ViewOpt.monthly);
        } catch (_) {}

        expect(vm.selectedView, ViewOpt.monthly);
      },
    );

    test('chosenDate is updated correctly when backButton is called', () async {
      final mockAuth = MockFirebaseAuth(
        mockUser: MockUser(uid: 'emptyUser'),
        signedIn: true,
      );

      final vm = DashboardViewModel(auth: mockAuth);

      try {
        vm.backButton(DateTime(2026, 7, 1));
      } catch (_) {}

      expect(vm.chosenDate, DateTime(2026, 7, 1));
    });

    test(
      'chosenDate is updated correctly when forwardButton is called',
      () async {
        final mockAuth = MockFirebaseAuth(
          mockUser: MockUser(uid: 'emptyUser'),
          signedIn: true,
        );

        final vm = DashboardViewModel(auth: mockAuth);

        try {
          vm.forwardButton(DateTime(2026, 5, 1));
        } catch (_) {}

        expect(vm.chosenDate, DateTime(2026, 5, 1));
      },
    );
  });

  test("getData fetches and stores the dashboard data in dashboardViewModel correctly", () async {
    final mockUser = MockUser(uid: 'test-uid');
    final mockAuth = MockFirebaseAuth(mockUser: mockUser, signedIn: true);
    final mockClient = MockClient();

    //fake http response with some data
    when(
      () => mockClient.get(any(), headers: any(named: 'headers')),
    ).thenAnswer(
      (_) async => http.Response('''{
  "summary": [
    {
      "_id": "2026-06-21T00:00:00.000Z",
      "totalCost": 1740,
      "totalNum": 4
    },
    {
      "_id": "2026-06-14T00:00:00.000Z",
      "totalCost": 2090,
      "totalNum": 6
    }
  ],
  "catData": [
    {
      "_id": {
        "category": "Confectionery"
      },
      "costPerCat": 1090,
      "numPerCat": 2
    },
    {
      "_id": {
        "category": "Pastry"
      },
      "costPerCat": 500,
      "numPerCat": 1
    },
    {
      "_id": {
        "category": "null"
      },
      "costPerCat": 800,
      "numPerCat": 3
    }
  ]
}''', 200),
    );

    final vm = DashboardViewModel(auth: mockAuth, client: mockClient);

    await vm.getData();

    expect(vm.summaryData.length, 2);
    expect(vm.summaryData[0]["totalCost"], 1740);
    expect(vm.categoryData.length, 3);
    expect(vm.categoryData[0]["_id"]["category"], "Confectionery");
    expect(vm.categoryData[0]["costPerCat"], 1090);
  });
}
