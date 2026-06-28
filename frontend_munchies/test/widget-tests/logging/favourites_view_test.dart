import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_munchies/models/filters.dart';
import 'package:frontend_munchies/screens/activities/domain/repositories/record_repo.dart';
import 'package:frontend_munchies/screens/loggingFeature/view_models/favourites_view_model.dart';
import 'package:frontend_munchies/screens/loggingFeature/views/favourites.dart';
import 'package:frontend_munchies/screens/loggingFeature/views/favourites_page_widgets/favourite_card.dart';
import 'package:frontend_munchies/screens/loggingFeature/views/logging_widgets/fields/cost.dart';
import 'package:frontend_munchies/screens/loggingFeature/views/logging_widgets/fields/date.dart';
import 'package:frontend_munchies/screens/loggingFeature/views/logging_widgets/fields/item_name.dart';
import 'package:frontend_munchies/screens/loggingFeature/views/tracking.dart';

import 'package:mocktail/mocktail.dart';
import 'package:frontend_munchies/models/record.dart';
import 'package:provider/provider.dart';

import '../../mocks/mock_navi_observer.dart';

class MockRecordRepo extends Mock implements RecordRepository {}
void main() {
  late List<Record> favRecords;
  late MockRecordRepo mockRecordRepo;
  late ActivityFilter filter;
  late FavouritesViewModel favouritesViewModel;
  late MockNaviObserver naviObserver;
  setUp(() {
    naviObserver = MockNaviObserver();
    favRecords = [
      Record(record_id: 'id',itemName: 'Test1', date: DateTime.now(), cost: 500, isFavourited: true, isVisible: false),
      Record(record_id: 'id',itemName: 'Test2', date: DateTime.now(), cost: 500, isFavourited: false, isVisible: false),
      Record(record_id: 'id',itemName: 'Test3', date: DateTime.now(), cost: 500, isFavourited: true, isVisible: false)
    ];
    mockRecordRepo = MockRecordRepo();
    filter = ActivityFilter.favouritedActivities;
    when(() => mockRecordRepo.fetchAllRecords(filter.query),).thenAnswer((_) async => favRecords.where((e) => e.isFavourited).toList());
    when(() => mockRecordRepo.getRecord('id'),).thenAnswer((_) async => favRecords[0]);
    favouritesViewModel = FavouritesViewModel(recordChanger: mockRecordRepo);
  });

  Widget createFavPage({List<NavigatorObserver> naviObs = const []}) {
    return Provider<RecordRepository>.value(value: mockRecordRepo, 
    child: ChangeNotifierProvider.value(value: favouritesViewModel, 
    child: MaterialApp(initialRoute: '/home' ,
    routes: {
      '/home': (_) => FavouritesPage()
    },
    navigatorObservers: naviObs,) 
    ),);
  }

  test('Check initial load on VM', () async {
    await pumpEventQueue();
    expect(favouritesViewModel.recordDetails.length, 2);
    expect(favouritesViewModel.recordDetails.map((e) => e.itemName).toList(), ['Test1', 'Test3']);
  });

  testWidgets('Set up favourites page', (tester) async {
    await tester.pumpWidget(createFavPage(naviObs: [naviObserver]));
    await tester.pumpAndSettle();

    //check that we are on the correct page and there is one favourite record found
    expect(find.byType(FavCard), findsNWidgets(2));
    expect(find.text('Test1'), findsOne);
    expect(find.text('Test3'), findsOne);
  });

  testWidgets('User brought to form with filled name and cost upon clicking specific favourite log', (tester) async {
    await tester.pumpWidget(createFavPage(naviObs: [naviObserver]));
    await tester.pumpAndSettle();

    //check that we are on the correct page and there is one favourite record found
    expect(find.byType(FavCard), findsNWidgets(2));

    await tester.tap(find.text('Test1'));
    await tester.pumpAndSettle();

    expect(find.byType(TrackingPage), findsOne);
    expect(find.widgetWithText(ItemName, 'Test1'), findsOne);
    expect(find.widgetWithText(CostField, '5.00'), findsOne);
    expect(find.widgetWithText(DateField, DateTime.now().toIso8601String().split('T')[0]), findsOne);

    //there is only one named route -> Favourites page == '/home'
    expect(naviObserver.pushed[naviObserver.pushed.length - 1].settings.name, null);
  });
}