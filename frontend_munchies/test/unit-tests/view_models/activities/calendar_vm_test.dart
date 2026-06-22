import 'dart:async';
import 'package:async/async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_munchies/screens/activities/domain/repositories/record_repo.dart';
import 'package:frontend_munchies/screens/activities/view_models/calendar_view_model.dart';
import 'package:mocktail/mocktail.dart';
import 'package:frontend_munchies/models/record.dart';
import 'package:table_calendar/table_calendar.dart';

class MockRecordRepo extends Mock implements RecordRepository {}

void main() {
  late MockRecordRepo mockRepo;
  late StreamController<void> streamController;
  late List<Record> mockRecords;
  late List<Record> mayRecords;
  late List<Record> juneRecords;
  late List<Record> julyRecords;
  late Map<String, String> mayQuery;
  late Map<String, String> juneQuery;
  late Map<String, String> julyQuery;
  late Map<String, String> aprilQuery;

  setUp(() {
    mockRecords = [
        Record(
          itemName: 'May test',
          date: DateTime(2026, 5, 1),
          cost: 500,
          isFavourited: false,
          isVisible: false,
        ),
        Record(
          itemName: 'June test',
          date: DateTime(2026, 6, 22),
          cost: 500,
          isFavourited: false,
          isVisible: false,
        ),
        Record(
          itemName: 'July test',
          date: DateTime(2026, 7, 1),
          cost: 500,
          isFavourited: false,
          isVisible: false,
        ),
      ];
      mayRecords = mockRecords.sublist(0, 1);
      juneRecords = mockRecords.sublist(1, 2);
      julyRecords = mockRecords.sublist(2, 3);
      aprilQuery = {'monthly': '4,2026'};
      mayQuery = {'monthly': '5,2026'};
      juneQuery = {'monthly': '6,2026'};
      julyQuery = {'monthly': '7,2026'};
    mockRepo = MockRecordRepo();
    streamController = StreamController<void>.broadcast();
    when(
      () => mockRepo.recordStream,
    ).thenAnswer((_) => streamController.stream);
  });

  //test loading status (onLoading and offLoading)
  group('Loading status', () {
    late CalendarViewModel viewModel;

    setUp(() {
      when(
        () => mockRepo.fetchAllRecords({'monthly': '6,2026'}),
      ).thenAnswer((_) async => mockRecords);
      viewModel = CalendarViewModel(recordRepo: mockRepo);
    });
    test('onLoading changes loading flag to true', () {
      viewModel.onLoading();
      expect(viewModel.isLoading, true);
    });
    test('onLoading notifies listeners that loading flag has changed', () {
      var notified = false;
      viewModel.addListener(() => notified = true);
      viewModel.onLoading();
      expect(notified, true);
    });
    test('offLoading changes loading flag to false', () {
      viewModel.offLoading();
      expect(viewModel.isLoading, false);
    });
    test('offLoading notifies listeners that loading flag has changed', () {
      var notified = true;
      viewModel.addListener(() => notified = true);
      viewModel.offLoading();
      expect(notified, true);
    });
  });

  //test setSelectedDay
  group('setSelectedDay', () {
    late CalendarViewModel viewModel;

    setUp(() async {
      when(
        () => mockRepo.fetchAllRecords({'monthly': '6,2026'}),
      ).thenAnswer((_) async => mockRecords);
      viewModel = CalendarViewModel(recordRepo: mockRepo);
      await pumpEventQueue();
    });

    test(
      'Initial selected day is null and initial list of records is all from current month',
      () {
        expect(viewModel.selectedDay, null);
        expect(viewModel.errorMessage, null);
        expect(viewModel.datesWithRecord, [
          DateTime(2026, 5, 1),
          DateTime(2026, 6, 22),
          DateTime(2026, 7, 1)
        ]);
        expect(viewModel.recordDetails, mockRecords);
      },
    );

    test(
      'Setting selected day changes selectedDay,'
      'notifies listeners of new selected day and changes recordDetails output',
      () {
        var notified = false;
        viewModel.addListener(() => notified = true);
        viewModel.setSelectedDay(DateTime(2026, 5, 1));
        expect(viewModel.selectedDay, DateTime(2026, 5, 1));
        expect(notified, true);

        //we also expect record details shown to change (to be only from selected day)
        expect(viewModel.recordDetails.length, 1);
      },
    );
  });

  //test getMonthlyRecords
  //verify that only one async operation runs and completes after instantiation
  //verify that focused day changes when the month on which one gets records from changes to ensure consistency
  group('getMonthlyRecords', () {
    late List<Record> mockRecords;
    late List<DateTime> mockDateList;
    late Map<String, String> query;

    setUp(() {
      mockRecords = [
        Record(
          itemName: 'Monthly test',
          date: DateTime(2026, 6, 22),
          cost: 500,
          isFavourited: false,
          isVisible: false,
        ),
        Record(
          itemName: 'Selected day test',
          date: DateTime(2026, 6, 1),
          cost: 500,
          isFavourited: false,
          isVisible: false,
        ),
      ];
      mockDateList = [DateTime(2026, 6, 22), DateTime(2026, 6, 1)];
      query = {'monthly': '6,2026'};
    });
    //test on success
    test(
      'getMonthlyRecords updates _records to be all records from queried month on success',
      () async {
        when(
          () => mockRepo.fetchAllRecords(query),
        ).thenAnswer((_) async => mockRecords);
        CalendarViewModel viewModel = CalendarViewModel(recordRepo: mockRepo);
        viewModel.getMonthlyRecords(DateTime(2026, 6, 1));
        await pumpEventQueue();

        expect(viewModel.recordDetails, mockRecords);
        expect(viewModel.focusedDay, DateTime(2026, 6, 1));
        expect(viewModel.isLoading, false);
        expect(viewModel.errorMessage, null);
        expect(viewModel.selectedDay, null);
        expect(viewModel.datesWithRecord, mockDateList);
        verify(() => mockRepo.fetchAllRecords(query)).called(2);
      },
    );

    //test on multiple parallel async functions - current fetches should be cancelled and debugPrint statement shows.
    test(
      'Ongoing fetch operations are cancelled before a new one is called and state updated to the latest version.',
      () async {
        final firstFetch = Completer<List<Record>>();
        List<Record> firstFetchResult = mockRecords.sublist(0, 1);

        final secondFetch = Completer<List<Record>>();
        List<Record> secondFetchResult = mockRecords.sublist(1, 2);
        int counter = 0;

        when(() => mockRepo.fetchAllRecords(query)).thenAnswer((_) async {
          counter++;
          return counter == 1 ? firstFetch.future : secondFetch.future;
        });

        //ACT
        //first fetch triggered at instantiation. execute fetchOperation assignment by pumping event queue
        CalendarViewModel viewModel = CalendarViewModel(recordRepo: mockRepo);
        await pumpEventQueue();
        final CancelableOperation? firstOperation = viewModel.fetchOperation;

        //second fetch triggered here. execute fetchOperation assignment by pumping event queue
        viewModel.getMonthlyRecords(DateTime(2026, 6, 1));
        await pumpEventQueue();
        final CancelableOperation? secondOperation = viewModel.fetchOperation;

        //ASSERT - CHECK THAT RECORD DETAILS IS NOT UPDATED MIDWAY DUE TO CANCELLED OPERATION.
        expect(viewModel.recordDetails, isNot(firstFetchResult));

        //complete the fetches for .fetchAllRecords() to check if final data state is correct.
        firstFetch.complete(firstFetchResult);
        secondFetch.complete(secondFetchResult);
        await pumpEventQueue();

        //ASSERT
        //called twice - once at VM instantiation, once bec I called it again
        verify(() => mockRepo.fetchAllRecords(query)).called(2);
        expect(firstOperation?.isCanceled, true);
        expect(viewModel.recordDetails, secondFetchResult);
        expect(secondOperation?.isCanceled, false);
        expect(viewModel.fetchOperation?.isCompleted, true);

        //check that other states (error and loading) are back to original state
        expect(viewModel.isLoading, false);
        expect(viewModel.errorMessage, null);
        expect(viewModel.selectedDay, null);
        expect(viewModel.datesWithRecord, mockDateList.sublist(1, 2));
      },
    );

    //test on failure
    test(
      'No updates made to _records on failure and error message is returned',
      () async {
        when(
          () => mockRepo.fetchAllRecords(query),
        ).thenThrow(Exception('Test Exception'));
        CalendarViewModel viewModel = CalendarViewModel(recordRepo: mockRepo);
        await pumpEventQueue();

        viewModel.getMonthlyRecords(DateTime(2026, 6, 1));
        await pumpEventQueue();

        expect(viewModel.errorMessage, 'Exception: Test Exception');
        expect(viewModel.isLoading, false);
        expect(viewModel.recordDetails, []);
        expect(viewModel.datesWithRecord, []);
        expect(isSameDay(viewModel.focusedDay, DateTime.now()), true);
      },
    );
  });

  //test onPageChanged
  group('onPageChanged', () {
    late CalendarViewModel viewModel;

    setUp(() async {
      when(
        () => mockRepo.fetchAllRecords({'monthly': '6,2026'}),
      ).thenAnswer((_) async => juneRecords);
      viewModel = CalendarViewModel(recordRepo: mockRepo);
      await pumpEventQueue();
    });

    test('Initial state on current month June', () {
      expect(viewModel.recordDetails, mockRecords.sublist(1, 2));
      expect(viewModel.errorMessage, null);
    });

    //test on success
    test(
      'onPageChanged reveals logs from the month of new page on success',
      () async {
        when(
          () => mockRepo.fetchAllRecords({'monthly': '5,2026'}),
        ).thenAnswer((_) async => mayRecords);
        viewModel.onPageChanged(DateTime(2026, 5, 1));
        //wait for debouncer's timer to clear first
        await Future.delayed(Duration(seconds: 2));

        expect(viewModel.recordDetails, mayRecords);
        expect(isSameDay(viewModel.focusedDay, DateTime(2026, 5, 1)), true);
        expect(viewModel.isLoading, false);
        expect(viewModel.errorMessage, null);
      },
    );

    //test on failure
    test(
      'onPageChanged does not update recordDetails on failure and reveals error message',
      () async {
        when(
          () => mockRepo.fetchAllRecords({'monthly': '5,2026'}),
        ).thenThrow(Exception('Test Exception'));
        viewModel.onPageChanged(DateTime(2026, 5, 1));
        //wait for debouncer's timer to clear first
        await Future.delayed(Duration(seconds: 1));
        await pumpEventQueue();

        expect(viewModel.recordDetails, juneRecords);
        expect(isSameDay(viewModel.dataAsOfDay, DateTime.now()), true);
        expect(viewModel.isLoading, false);
        expect(viewModel.errorMessage, 'Exception: Test Exception');
        verify(
          () => mockRepo.fetchAllRecords(any<Map<String, String>>()),
        ).called(2);
      },
    );

    //verify debouncer working - rapid changes should not fire operations -> only the operation right after debounce delay
    test(
      'onPageChanged triggers record fetching only after the fixed timeout delay has passed.',
      () async {
        when(
          () => mockRepo.fetchAllRecords(aprilQuery),
        ).thenAnswer((_) async => []);
        when(
          () => mockRepo.fetchAllRecords(mayQuery),
        ).thenAnswer((_) async => mayRecords);
        when(
          () => mockRepo.fetchAllRecords(juneQuery),
        ).thenAnswer((_) async => juneRecords);
        when(
          () => mockRepo.fetchAllRecords(julyQuery),
        ).thenAnswer((_) async => julyRecords);
        CancelableOperation? beforePageChangeOp = viewModel.fetchOperation;

        //check that the fetchOperation is NOT reassigned -> it should be the instance before any page change is called
        viewModel.onPageChanged(DateTime(2026, 7, 1));
        await Future.delayed(Duration(milliseconds: 100));
        CancelableOperation? firstPageChangeOp = viewModel.fetchOperation;
        viewModel.onPageChanged(DateTime(2026, 6, 1));
        await Future.delayed(Duration(milliseconds: 100));
        CancelableOperation? secondPageChangeOp = viewModel.fetchOperation;
        viewModel.onPageChanged(DateTime(2026, 4, 1));
        await Future.delayed(Duration(milliseconds: 100));
        CancelableOperation? thirdPageChangeOp = viewModel.fetchOperation;

        //expect that there are no other fetchOperations occurring - no other assignments occur
        expect(
          [
            firstPageChangeOp,
            secondPageChangeOp,
            thirdPageChangeOp,
          ].map((e) => identical(e, beforePageChangeOp)).toSet(),
          {true},
        );

        //cancel debouncer to execute debounced action immediately
        viewModel.onPageChanged(DateTime(2026, 5, 1));
        await Future.delayed(Duration(milliseconds: 2000));
        CancelableOperation? finalPageChangeOp = viewModel.fetchOperation;

        //expect that the final data details are that of debounced action only.
        expect(viewModel.recordDetails, mayRecords);
        expect(identical(beforePageChangeOp, finalPageChangeOp), false);

        //expect that the total number of times fetchAllRecords is 2: At Instantiation, then at final page change
        verify(
          () => mockRepo.fetchAllRecords(any()),
        ).called(2);
      },
    );
  });

  //test disposal
  group('ViewModel is properly disposed along with subscriptions', () {
    late CalendarViewModel viewModel;
    setUp(() async {
      when(() => mockRepo.fetchAllRecords({'monthly': '6,2026'}),).thenAnswer((_) async => juneRecords);
      viewModel = CalendarViewModel(recordRepo: mockRepo);
      await pumpEventQueue();
    });
    test("ViewModel's subscription should be cancelled after disposal", () async {
      viewModel.dispose();
      await pumpEventQueue();
      expect(streamController.hasListener, false);
    });
    test('No function is able to notify listeners after disposal', () async {
      var notified = false;
      viewModel.addListener(() => notified = true);

      viewModel.onPageChanged(DateTime(2026, 7, 1));
      viewModel.dispose();

      await pumpEventQueue();
      expect(notified, false);
    });
  });

  //test onDeletePressed - this has been tested in Activities VM and has passed the tests
  //TODO: This method should be abstracted to its parent class, but how?
  group('onDeletePressed', () {});
}
