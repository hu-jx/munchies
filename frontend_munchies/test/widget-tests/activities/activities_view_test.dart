//test the functions in record card to ensure that functions are working.
//since VM has already been unit-tested for functional editing and deleting, widget test will focus on correct navigations.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_munchies/models/filters.dart';
import 'package:frontend_munchies/screens/activities/domain/repositories/record_repo.dart';
import 'package:frontend_munchies/screens/activities/view_models/activities_view_model.dart';
import 'package:frontend_munchies/screens/activities/views/activities.dart';
import 'package:frontend_munchies/screens/activities/views/activities_widgets/record_card.dart';
import 'package:frontend_munchies/screens/loggingFeature/views/logging_widgets/fields/item_name.dart';
import 'package:frontend_munchies/screens/loggingFeature/views/logging_widgets/logging_form.dart';
import 'package:frontend_munchies/screens/loggingFeature/views/tracking.dart';
import 'package:mocktail/mocktail.dart';
import 'package:frontend_munchies/models/record.dart';
import 'package:provider/provider.dart';

import '../../mocks/mock_navi_observer.dart';

class MockRecordRepo extends Mock implements RecordRepository {}

void main() {
  late List<Record> records;
  GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  late MockRecordRepo mockRepo;
  late StreamController<void> streamController;
  late ActivitiesViewModel viewModel;
  late MockNaviObserver mockObserver;
  late ActivityFilter filter;

  setUp(() async {
    records = [
      Record(
        record_id: 'id',
        itemName: 'Test',
        date: DateTime.now(),
        cost: 500,
        isFavourited: false,
        isVisible: false,
      ),
    ];
    mockRepo = MockRecordRepo();
    mockObserver = MockNaviObserver();
    streamController = StreamController<void>.broadcast();
    filter = ActivityFilter.all;
    when(
      () => mockRepo.recordStream,
    ).thenAnswer((_) => streamController.stream);
    when(() => mockRepo.fetchAllRecords(filter.query)).thenAnswer((_) async {
      return Future.delayed(Durations.medium4, () => records);
    });
    when(() => mockRepo.getRecord('id')).thenAnswer((_) async => records[0]);
    viewModel = ActivitiesViewModel(recordRepo: mockRepo, filter: filter);
  });

  Widget createActivitiesPage({
    List<NavigatorObserver> navigatorObs = const [],
  }) {
    return Provider<RecordRepository>(
      create: (_) => mockRepo,
      child: MaterialApp(
        navigatorKey: navigatorKey,
        home: ChangeNotifierProvider.value(
          value: viewModel,
          child: ActivitiesView(),
        ),
        navigatorObservers: navigatorObs,
      ),
    );
  }

  group('Record card functions', () {
    testWidgets(
      'tapping on record card opens the bottom sheet & pressing edit opens logging form',
      (tester) async {
        await tester.pumpWidget(
          createActivitiesPage(navigatorObs: [mockObserver]),
        );
        expect(find.byType(CircularProgressIndicator), findsOne);
        await tester.runAsync(() async {
          await Future.delayed(Durations.medium4);
        });
        await tester.pumpAndSettle();

        expect(find.byType(CircularProgressIndicator), findsNothing);
        expect(find.byType(RecordCard), findsOne);

        await tester.tap(find.byType(RecordCard));
        await tester.pumpAndSettle();
        expect(find.byType(BottomSheet), findsOne);

        await tester.tap(find.text('Edit'));
        await tester.pumpAndSettle();

        expect(find.byType(TrackingPage), findsOne);
        expect(find.widgetWithText(ItemName, 'Test'), findsOne);
        verify(() => mockRepo.fetchAllRecords(filter.query),).called(1);
      },
    );

    testWidgets('pressing delete closes bottom sheet and refetches the data', (
      tester,
    ) async {
      when(() => mockRepo.deleteRec('id')).thenAnswer((inv) async {
        // await Future.delayed(Durations.medium1, () {
          records.removeWhere((e) => e.record_id == 'id');
        streamController.add(null);
        // });
      });
      await tester.pumpWidget(
        createActivitiesPage(navigatorObs: [mockObserver]),
      );
      await tester.runAsync(() async {
          await Future.delayed(Durations.medium4);
        });
      await tester.pumpAndSettle();
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.byType(RecordCard), findsOne);

      await tester.tap(find.byType(RecordCard));
      await tester.pumpAndSettle();
      expect(find.byType(BottomSheet), findsOne);

      await tester.tap(find.text('Delete'));
      await tester.pump(); 
      await tester.pumpAndSettle();
      expect(find.byType(ActivitiesView), findsOne);
      expect(find.text("Nothing yet! \n Start tracking today!"), findsOne);
      verify(() => mockRepo.deleteRec('id')).called(1);
      verify(() => mockRepo.fetchAllRecords(filter.query),).called(2);
    });
  });
}
