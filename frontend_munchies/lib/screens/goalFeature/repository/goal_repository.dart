import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:frontend_munchies/models/goal.dart';
import 'package:frontend_munchies/screens/goalFeature/repository/goal_repo_interface.dart';
import 'package:frontend_munchies/services/auth/auth_exception.dart';
import 'package:frontend_munchies/services/goals/goal_services.dart';
import 'package:frontend_munchies/services/goals/goal_services_repo.dart';
import 'package:frontend_munchies/services/records/record_services.dart';

class GoalRepoImpl implements GoalRepoInterface {
  final _goalStream = StreamController<void>.broadcast();

  @override
  Stream<void> get goalStream => _goalStream.stream;

  void dispose() {
    _goalStream.close();
  }

  String? idToken;
  User? user;
  final GoalServicesRepo service = GoalServices();

  Future<void> getUserToken() async {
    user = FirebaseAuth.instance.currentUser;
    if (user == null) throw AuthException('Access Denied');
    String? newToken = await user!.getIdToken(false);
    if (idToken != newToken || idToken == null) {
      idToken = newToken;
    }
    if (idToken == null) throw AuthException('Access Denied');
    if (idToken!.isEmpty) throw AuthException('Access Denied');
  }

  @override
  Future<Goal?> getLatestGoal() async {
    await getUserToken();
    return service.getLatestGoal(null, idToken!);
  }

  @override
  Future<int> getCurrentStreak() async {
    await getUserToken();
    return service.getCurrentStreak(null, idToken!); 
  }

  @override
  Future<void> createNewGoal(Goal goal) async {
    await getUserToken();
    if (user == null) throw AuthException('Access Denied');
    goal.user_uid = user!.uid;
    await service.createNewGoal(null, idToken!, goal);
    //refetch streak and refetch latest goal when a new one is created
    _goalStream.add(null);
  }

  @override
  Future<void> updateGoalById(String goalId, Map<String, dynamic> updates) async {
    await getUserToken();
    await service.updateGoalById(null, idToken!, updates, goalId);
    _goalStream.add(null);
  }

  //wrap the higher goal logic in a singular repo method so that services change all to inactive is never called
  //by any VM directly 
  @override
  Future<void> createHigherGoal(Goal goal) async {
    await getUserToken();
    if (user == null) throw AuthException('Access Denied');
    goal.user_uid = user!.uid;
    await service.updateCurrentGoalsToInactive(null, idToken!);
    await service.createNewGoal(null, idToken!, goal);
    _goalStream.add(null);
  }

  @override
  Future<int> getCurrentConsumption() async {
    await getUserToken();
    return RecordServices.getCurrentConsumption(idToken!);
  }
}