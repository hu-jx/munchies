import 'package:frontend_munchies/models/goal.dart';
//for easier testing of VM in the future
abstract class GoalRepoInterface {
  Stream<void> get goalStream;
  Future<Goal?> getLatestGoal();
  Future<void> createNewGoal(Goal goal);
  Future<void> updateGoalById(String goalId, Map<String, dynamic> updates);
  Future<void> createHigherGoal(Goal goal);
  Future<List> getCurrentStreak();
  Future<int> getCurrentConsumption();
  Future<int> getAdaptiveGoal();
}