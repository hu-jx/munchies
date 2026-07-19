import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:frontend_munchies/models/goal.dart';
import 'package:frontend_munchies/services/goals/goal_services_repo.dart';
import 'package:http/http.dart' as http;

class GoalServices implements GoalServicesRepo {
  // static const String _baseUrl = "http://10.0.2.2:3000/api";
  static const String _baseUrl = "https://munchies-5dvw.onrender.com/api";

  @override
  Future<Goal?> getLatestGoal(http.Client? client, String idToken) async {
    final httpClient = client ?? http.Client();
    final response = await httpClient.get(
      Uri.parse('$_baseUrl/goal'),
      headers: {'Authorization': 'Bearer $idToken'},
    );

    if (response.statusCode == 200) {
      var goal = jsonDecode(response.body);
      if (goal is! List) {
        throw Exception('Unexpected data format');
      } else if (goal.isEmpty) {
        return null;
      } else if (goal[0] is! Map<String, dynamic>) {
          throw Exception('Unexpected data format');
      }
      debugPrint("THE LATEST GOAL IS $goal");
      return Goal.fromJson(goal[0]);
    } else if (response.statusCode == 204) {
      return null;
    }
    else {
      debugPrint(response.reasonPhrase);
      throw Exception('Unexpected server error');
    }
  }

  //STREAK GET
  @override
  Future<List> getCurrentStreak(http.Client? client, String idToken) async {
    final httpClient = client ?? http.Client();
    final response = await httpClient.get(
      Uri.parse('$_baseUrl/streak'),
      headers: {'Authorization': 'Bearer $idToken'},
    );

    if (response.statusCode == 204) {
      return [];
    } else if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      if (data is! Map<String, dynamic>) {
        throw Exception('Unexpected data format');
      } else if (data['streak'] == null || data['last_success'] == null) {
        throw Exception('Unexpected data format');
      }
      data.map((key, val) {
          debugPrint("TYPES ARE $val");
          return MapEntry(key, val);
        } );
      return [data['streak'], data['last_success']];
    } else {
      debugPrint(response.reasonPhrase);
      throw Exception('Failed to get current streak');
    }
  }

  //POST 
  @override
  Future<void> createNewGoal(http.Client? client, String idToken, Goal goal) async {
    final httpClient = client ?? http.Client();
    final response = await httpClient.post(
      Uri.parse('$_baseUrl/goal'),
      headers: {'Authorization': 'Bearer $idToken'},
      body: goal.toJson()
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to create new goal');
    }
  }

  @override
  Future<void> updateGoalById(http.Client? client, String idToken, Map<String, dynamic> updates, String goalId) async {
    debugPrint('reached services');
    final httpClient = client ?? http.Client();
    updates.removeWhere((key, value) => value == null);
    updates = updates.map((key, value) => MapEntry(key.toString(), value.toString()),);
    final response = await httpClient.patch(
      Uri.parse('$_baseUrl/goal/$goalId'),
      headers: {'Authorization': 'Bearer $idToken',
      },
      body: updates
    );
    debugPrint('completed http call');

    if (response.statusCode != 201) {
      throw Exception('Failed to update current goal');
    }
  }

  @override
  Future<void> updateCurrentGoalsToInactive(http.Client? client, String idToken) async {
    final httpClient = client ?? http.Client();
    final response = await httpClient.patch(
      Uri.parse('$_baseUrl/goal?activeStatus=false'),
      headers: {'Authorization': 'Bearer $idToken'},
    );

    if (response.statusCode == 500) {
      throw Exception('Failed to deactivate old goals');
    }
  }
  //no HTTP call created for deleteGoalById -> unsure if necessary 

  @override
  Future<int> getAdaptiveGoal(http.Client? client, String idToken) async {
    final httpClient = client ?? http.Client();
    final response = await httpClient.get(
      Uri.parse('$_baseUrl/adaptive-goal'),
      headers: {'Authorization': 'Bearer $idToken'},
    );

    if (response.statusCode == 204) {
      return 2;
    } else if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      if (data is! Map<String, dynamic>) {
        throw Exception('Unexpected data format');
      }
      int goal = data['goal'] ?? 2;
      return goal;
    } else {
      debugPrint(response.reasonPhrase);
      throw Exception('Failed to get current streak');
    }
  }
}
