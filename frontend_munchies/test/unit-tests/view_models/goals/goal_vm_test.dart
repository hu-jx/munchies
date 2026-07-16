//test onSavePressed functionalities as it contains the most business logic 

import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_munchies/models/goal.dart';
import 'package:frontend_munchies/screens/activities/domain/repositories/record_repo.dart';
import 'package:frontend_munchies/screens/goalFeature/repository/goal_repo_interface.dart';
import 'package:frontend_munchies/screens/goalFeature/viewmodel/goal_vm.dart';
import 'package:mocktail/mocktail.dart';

class MockRecordRepo extends Mock implements RecordRepository {}
class MockGoalRepo extends Mock implements GoalRepoInterface {}

void main() {
  late RecordRepository mockRecordRepo;
  late GoalRepoInterface mockGoalRepo;
  late GoalViewModel viewModel;
  late Goal mockGoal;
  late StreamController recordSC;
  late StreamController goalSC;


  setUp(() {
    mockGoal = Goal(start_date: DateTime.now(), isActive: true, quantity: 2, goal_id: 'id');
    mockGoalRepo = MockGoalRepo();
    mockRecordRepo = MockRecordRepo();
    recordSC = StreamController<void>.broadcast();
    goalSC = StreamController<void>.broadcast();

    //stub the methods used in getLatestDetails 
    when(() => mockGoalRepo.goalStream).thenAnswer((_) => goalSC.stream);
    when(() => mockRecordRepo.recordStream).thenAnswer((_) =>recordSC.stream);

    //stubbing methods for get latest details
    when(() => mockGoalRepo.getLatestGoal()).thenAnswer((_) async {
      return mockGoal;
    });
    when(
      () => mockGoalRepo.getCurrentStreak(),
    ).thenAnswer((_) async => [1, DateTime.now().toIso8601String()]);
    when(() => mockGoalRepo.getCurrentConsumption()).thenAnswer((_) async {
      await Future.delayed(Duration(seconds: 1));
      return 0;
    });
    when(() => mockGoalRepo.getAdaptiveGoal()).thenAnswer((_) async => 2);


    viewModel = GoalViewModel(goalRepo: mockGoalRepo, recordRepo: mockRecordRepo);
  });

  group('OnSavePressed on success', () {
    final Goal lowerGoal = Goal(start_date: DateTime(2026,6,1), isActive: true, quantity: 0);
    final Goal higherGoal = Goal(start_date: DateTime(2026,6,1), isActive: true, quantity: 4);
    // final Goal sameWeekGoal = Goal(start_date: DateTime.now(), isActive: true, quantity: 4);
    Map<String, dynamic> updates = {
      'quantity': 4
    };
    setUp(() {
      when(() => mockGoalRepo.createNewGoal(lowerGoal)).thenAnswer((_) async {});
      when(() => mockGoalRepo.createHigherGoal(higherGoal)).thenAnswer((_) async {});
      when(() => mockGoalRepo.updateGoalById('id', updates)).thenAnswer((_) async {});
    });

    setUpAll(() {
      registerFallbackValue(lowerGoal);
    });
    test('If new goal quantity < previous, it goes to createNewGoal', () async {
      await viewModel.onSavePressed(0, start_date: DateTime(2026,6,1));
      verify(() => mockGoalRepo.createNewGoal(any())).called(1);
      verifyNever(() => mockGoalRepo.createHigherGoal(any()));
      verifyNever(() => mockGoalRepo.updateGoalById(any(), any()));
    });
    test('If new goal quantity > previous, it goes to createHigherGoal', () async {
       await viewModel.onSavePressed(4, start_date: DateTime(2026,6,1));
       verify(() => mockGoalRepo.createHigherGoal(any())).called(1);
       verifyNever(() => mockGoalRepo.updateGoalById(any(), any()));
       verifyNever(() => mockGoalRepo.createNewGoal(any()));

    });
    test('Regardless of quantity, if new goal is created in the same week as previous goal, it goes to updateGoal', () async {
      await viewModel.onSavePressed(1);
      verify(() => mockGoalRepo.updateGoalById(any(), any())).called(1);
      verifyNever(() => mockGoalRepo.createNewGoal(any()));
      verifyNever(() => mockGoalRepo.createHigherGoal(any()));
    });
  });
}