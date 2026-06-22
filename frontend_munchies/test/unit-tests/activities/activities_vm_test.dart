import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_munchies/models/filters.dart';
import 'package:frontend_munchies/screens/activities/domain/repositories/record_repo.dart';
import 'package:frontend_munchies/screens/activities/view_models/activities_view_model.dart';
import 'package:mocktail/mocktail.dart';
import 'package:frontend_munchies/models/record.dart';

class MockRecordRepo extends Mock implements RecordRepository {}

void main() {
  late MockRecordRepo mockRepo;
  late StreamController<void> streamController;
  late ActivityFilter filter;
  late List<ActivityFilter> filters;

  setUp(() {
    mockRepo = MockRecordRepo();
    streamController = StreamController<void>.broadcast();
    when(() => mockRepo.recordStream,).thenAnswer((_) => streamController.stream);
    filters = [ActivityFilter.all, ActivityFilter.daily, ActivityFilter.weekly];
    filter = filters[0];
  });

  //test onLoading
  group('Loading status', () {
    late ActivitiesViewModel avm;

    setUp(() {
      List<Record> mockRecords = [];
      when(
        () => mockRepo.fetchAllRecords(filter.query),
      ).thenAnswer((_) async => mockRecords);
      avm = ActivitiesViewModel(recordRepo: mockRepo, filter: filter);
    });
    test('onLoading changes loading flag to true', () {
      avm.onLoading();
      expect(avm.loadingStatus, true);
    });
    test('onLoading notifies listeners that loading flag has changed', () {
      var notified = false;
      avm.addListener(() => notified = true);
      avm.onLoading();
      expect(notified, true);
    });
    test('offLoading changes loading flag to false', () {
      avm.offLoading();
      expect(avm.loadingStatus, false);
    });
    test('offLoading notifies listeners that loading flag has changed', () {
      var notified = true;
      avm.addListener(() => notified = true);
      avm.offLoading();
      expect(notified, true);
    });
  });

  //test loadAllRecords()
  group('loadAllRecords on success', () {
    late ActivitiesViewModel avm;
    late List<Record> mockRecords;

    setUp(() {
      mockRecords = [
        Record(record_id: 'id',itemName: 'Test', date: DateTime.now(), cost: 500, isFavourited: false, isVisible: false)
      ];
    });
    test('Initially loading is false and error message is null', () async {
      when(
        () => mockRepo.fetchAllRecords(filter.query),
      ).thenAnswer((_) async => mockRecords);
      avm = ActivitiesViewModel(recordRepo: mockRepo, filter: filter);
      await pumpEventQueue();
      expect(avm.loadingStatus, false);
      expect(avm.errorMessage, null);
    });
    test(
      'sets state to loading then offLoading and stores record details on success',
      
      () async {
      when(
        () => mockRepo.fetchAllRecords(filter.query),
      ).thenAnswer((_) async => mockRecords);
      avm = ActivitiesViewModel(recordRepo: mockRepo, filter: filter);
        await avm.loadAllRecords();

        //check that loading status is turned off
        expect(avm.loadingStatus, false);
        expect(avm.recordDetails, mockRecords);
        verify(() => mockRepo.fetchAllRecords(filter.query)).called(2);
      },
    );
    test(
      'records unsaved if repository method throws error and error message is saved correctly',
      () async {
        when(
          () => mockRepo.fetchAllRecords(filter.query),
        ).thenThrow(Exception('Test Exception'));
        avm = ActivitiesViewModel(recordRepo: mockRepo, filter: filter);
        await avm.loadAllRecords();
        expect(avm.loadingStatus, false);
        expect(avm.recordDetails, []);
        expect(avm.errorMessage, 'Exception: Test Exception');
        verify(() => mockRepo.fetchAllRecords(filter.query)).called(2);
      },
    );
  });

  //test onDeletePressed
  group('onDeletePressed', () {
    late ActivitiesViewModel avm;
    late List<Record> mockRecords;

    setUp(() {
      mockRecords = [
        Record(record_id: 'id',itemName: 'Test', date: DateTime.now(), cost: 500, isFavourited: false, isVisible: false)
      ];
      when(
        () => mockRepo.fetchAllRecords(filter.query),
      ).thenAnswer((_) async => mockRecords);
      avm = ActivitiesViewModel(recordRepo: mockRepo, filter: filter);
    });
    test(
      'Initial loading state is (not loading) and initial error message is null. Initial load occurs.',
      () {
        expect(avm.loadingStatus, false);
        expect(avm.errorMessage, null);
        verify(() => avm.loadAllRecords()).called(1);
      },
    );
    test('onDeletePressed calls the repository method deleteRecord', () async {
      when(() => mockRepo.deleteRec(('id'))).thenAnswer((_) async {
        mockRecords.removeWhere((rec) => rec.record_id == 'id');
        streamController.add(null);
      });

      await avm.onDeletePressed('id');

      expect(avm.loadingStatus, false);
      expect(avm.recordDetails, []);
      expect(avm.errorMessage, null);
      verify(() => mockRepo.deleteRec('id')).called(1);
      //verify that fetching of records occurs twice: once at instantiation and once after deleting occurs
      verify(() => avm.loadAllRecords()).called(2);
    });

    test('Deletion failure sets error message and does not refetch records', () async {
      when(() => mockRepo.deleteRec('id')).thenThrow(Exception('Test Exception'));
      await avm.onDeletePressed('id');
      expect(avm.loadingStatus, false);
      expect(avm.recordDetails, mockRecords);
      expect(avm.errorMessage, 'Exception: Test Exception');
      verify(() => mockRepo.deleteRec('id')).called(1);
      verify(() => avm.loadAllRecords()).called(1);
    });
  });
}
