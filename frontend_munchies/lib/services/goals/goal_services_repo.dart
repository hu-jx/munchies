import 'package:frontend_munchies/models/goal.dart';
import 'package:http/http.dart' as http;

abstract class GoalServicesRepo {
  Future<Goal?> getLatestGoal(http.Client? client, String idToken);
  Future<void> createNewGoal(http.Client? client, String idToken, Goal goal);
  Future<void> updateGoalById(http.Client? client, String idToken, Map<String, dynamic> updates, String goalId);
  Future<void> updateCurrentGoalsToInactive(http.Client? client, String idToken);
  Future<int> getCurrentStreak(http.Client? client, String idToken);
}