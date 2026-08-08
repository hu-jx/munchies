import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_munchies/models/goal.dart';
import 'package:frontend_munchies/models/user_profile.dart';
import 'package:frontend_munchies/screens/activities/domain/repositories/record_repo.dart';
import 'package:frontend_munchies/screens/goalFeature/repository/goal_repo_interface.dart';
import 'package:frontend_munchies/screens/goalFeature/view/goal_view.dart';
import 'package:frontend_munchies/screens/goalFeature/viewmodel/goal_vm.dart';
import 'package:frontend_munchies/screens/profile/profile_view.dart';
import 'package:frontend_munchies/screens/profile/profile_vm.dart';
import 'package:frontend_munchies/services/goals/goal_services_repo.dart';
import 'package:frontend_munchies/widgets/button.dart';
import 'package:frontend_munchies/widgets/errorMessage.dart';
import 'package:mocktail/mocktail.dart';
import 'package:frontend_munchies/models/record.dart';
// import 'package:percent_indicator/flutter_percent_indicator.dart';
import 'package:provider/provider.dart';

import '../../mocks/mock_navi_observer.dart';

class MockGoalRepo extends Mock implements GoalRepoInterface {}

class MockGoalService extends Mock implements GoalServicesRepo {}

class MockRecordRepo extends Mock implements RecordRepository {}
class MockProfileVM extends Mock implements ProfileVMRepo {}

void main() {
  late RecordRepository mockRecordRepo;
  late GoalRepoInterface mockGoalRepo;
  late GoalViewModel viewModel;
  late MockNaviObserver naviObs;
  late Goal mockGoal;
  late StreamController recordSC;
  late StreamController goalSC;
  late MockProfileVM profileVM;

  setUpAll(() {
    registerFallbackValue( Goal(start_date: DateTime.now(), isActive: true, quantity: 4));
  });
  setUp(() {
    recordSC = StreamController<void>.broadcast();
    goalSC = StreamController<void>.broadcast();
    mockGoal = Goal(start_date: DateTime.now(), isActive: true, quantity: 2);
    mockRecordRepo = MockRecordRepo();
    mockGoalRepo = MockGoalRepo();
    when(() => mockGoalRepo.goalStream).thenAnswer((_) => goalSC.stream);
    when(() => mockRecordRepo.recordStream).thenAnswer((_) =>recordSC.stream);
    naviObs = MockNaviObserver();

    //stubbing methods for get latest details
    when(() => mockGoalRepo.getLatestGoal()).thenAnswer((_) async {
      await Future.delayed(Durations.extralong4);
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

    //instantiate VM
    viewModel = GoalViewModel(
      goalRepo: mockGoalRepo,
      recordRepo: mockRecordRepo,
    );
    final UserProfile mockUser = UserProfile(firebase_uid: 'uid', emailAddress: 'email', password: 'pw', firstName: 'name');

    profileVM = MockProfileVM();
    when(() => profileVM.emailAddress).thenReturn("email");
    when(() => profileVM.name).thenReturn("name");
    when(() => profileVM.profile).thenReturn(mockUser);
  });
  Widget createProfilePage() {
    return Provider<RecordRepository>.value(
      value: mockRecordRepo,
      child: MultiProvider(
        providers: [ChangeNotifierProvider<ProfileVMRepo>.value(value: profileVM), ChangeNotifierProvider.value(value: viewModel), ],
        child: MaterialApp(
          initialRoute: '/home',
          routes: {
            '/home': (_) =>
                ProfileView(pageWidgets: [GoalPostView(), const Placeholder()]),
          },
          navigatorObservers: [naviObs],
        ),
      ),
    );
  }

  testWidgets('loading initial profile page fetches details once and displays correct view', (tester) async {
    await tester.pumpWidget(createProfilePage());
    await tester.runAsync(() async => await Future.delayed(Duration(seconds: 2)));
    await tester.pumpAndSettle();

    expect(find.byType(GoalPostView), findsOneWidget);
    expect(find.widgetWithText(AppButton, 'Set new goal'), findsOneWidget);
    verify(() => mockGoalRepo.getLatestGoal(),).called(1);
  });

  Future<void> loadProfilePage(WidgetTester tester) async {
    await tester.pumpWidget(createProfilePage());
    await tester.runAsync(() async => await Future.delayed(Duration(seconds: 2)));
    await tester.pumpAndSettle();
  }

  Future<void> submitNewGoal(WidgetTester tester) async {
    await tester.tap(find.widgetWithText(AppButton, 'Set new goal'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField), '4');
    await tester.pumpAndSettle();

    await tester.tapAt(Offset.zero);
    await tester.pumpAndSettle();
    
    await tester.tap(find.widgetWithText(TextButton, 'Save'));
  }

  testWidgets('Setting goal on success triggers refetch', (tester) async {
    when(() => mockGoalRepo.createHigherGoal(any()),).thenAnswer((_) async {
      goalSC.add(null);
    },);
    await loadProfilePage(tester);
    // expect(find.byType(AlertDialog), findsOneWidget);
    // expect(find.text('MAX 2 TIMES / WEEK'), findsOneWidget);
    await submitNewGoal(tester);
    final Finder targetFinder = find.byType(AlertDialog);

    while (tester.widgetList(targetFinder).isNotEmpty) {
      await tester.pumpAndSettle(Durations.medium1);
    }

    //expect no more dialog, expect one popped screen, expect refetch
    expect(find.byType(AlertDialog), findsNothing);
    expect(find.byType(GoalPostView), findsOne);
    verify(() => mockGoalRepo.getLatestGoal(),).called(2);
    expect(naviObs.popped.first.settings.name, '/home');

  });
  testWidgets('Goal view on goal absence shows comment', (tester) async {
    when(() => mockGoalRepo.getLatestGoal(),).thenAnswer((_) async {
      return null;
    });
    viewModel = GoalViewModel(goalRepo: mockGoalRepo, recordRepo: mockRecordRepo);
    await loadProfilePage(tester);

    expect(find.text('No goals yet!\nCreate a new daily maximum consumption goal!'), findsOne);
    expect(find.byType(AppButton), findsOne);
  });

  testWidgets('Setting goal on error shows error message', (tester) async {
    when(() => mockGoalRepo.createHigherGoal(any()),).thenThrow(Exception('Test'));
    await loadProfilePage(tester);
    await submitNewGoal(tester);
    await tester.pumpAndSettle();
    expect(find.byType(ShowErrorMessage), findsOne);
    expect(find.text('Exception: Test'), findsOne);
  });

  testWidgets('Creating new record refetches goal details', (tester) async {
    Record mockRecord = Record(record_id: 'id',itemName: 'Test', date: DateTime.now(), cost: 500, isFavourited: false, isVisible: false);
    when(() => mockRecordRepo.saveRecord(mockRecord,)).thenAnswer((_) async {
      debugPrint("CALLED");
      recordSC.add(null);
    });
    await loadProfilePage(tester);

    await mockRecordRepo.saveRecord(mockRecord);
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOne);
    verify(() => mockGoalRepo.getLatestGoal(),).called(2);
  });
}
