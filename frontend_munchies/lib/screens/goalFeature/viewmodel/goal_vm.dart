// ignore_for_file: non_constant_identifier_names

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:frontend_munchies/models/goal.dart';
import 'package:frontend_munchies/screens/activities/domain/repositories/record_repo.dart';
import 'package:frontend_munchies/screens/goalFeature/repository/goal_repo_interface.dart';

class GoalViewModel extends ChangeNotifier {
  final GoalRepoInterface goalRepo;
  final RecordRepository recordRepo;

  GoalViewModel({required this.goalRepo, required this.recordRepo}) {
    goalRepo.goalStream.listen((r) {
      getLatestDetails();
    });
    recordRepo.recordStream.listen((r) {
      getLatestDetails();
    });
    getLatestDetails();
  }

  Goal? _latestGoal;
  String? _errorMessage;
  bool _isLoading = false;
  bool _isDisposed = false;
  int _streak = 0;
  int? _currentConsumption;
  int _reccGoal = 2;

  Goal? get latestGoal => _latestGoal;
  int get currentStreak => _streak;
  String? get errorMesage => _errorMessage;
  bool get loadingStatus => _isLoading;
  double get currentQuota {
    debugPrint("$_currentConsumption at VM");
    if (latestGoal == null || _currentConsumption == null) {
      return 0;
    }
     else if (latestGoal!.quantity == 0) {
      return 1;
    }
    return _currentConsumption! / latestGoal!.quantity;
  }
  int get remainingConsumption {
    debugPrint("${_currentConsumption.toString()} is current consump");
    if (latestGoal == null || _currentConsumption == null) return 0;
    int diff = latestGoal!.quantity - _currentConsumption!;
    // if (diff < 0) {
    //   return 0;
    // } else {
      return diff;
    // }
  }
  int get reccGoal => _reccGoal;

  void onLoading() {
    _isLoading = true;
    notifyListeners();
  }

  void offLoading() {
    _isLoading = false;
    notifyListeners();
  }

  @override
  void notifyListeners() {
    if (!_isDisposed) {
      super.notifyListeners();
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  Future<void> onSetNewGoalPressed() async {
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> getLatestDetails() async {
    try {
      onLoading();
      Goal? goal = await goalRepo.getLatestGoal();
      _latestGoal = goal;
      if (goal != null) {
        int streak = await goalRepo.getCurrentStreak();
      _streak = streak;
      debugPrint(_streak.toString());
      int currentFreq = await goalRepo.getCurrentConsumption();
      _currentConsumption = currentFreq;
      int adaptiveGoal = await goalRepo.getAdaptiveGoal();
      //add streak bonus 
      if (_streak >= 4 && adaptiveGoal > 2) {
        adaptiveGoal = (adaptiveGoal * 0.9).round();
      }
      _reccGoal = adaptiveGoal < 0 ? 0 : adaptiveGoal;
      }
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    } finally {
      offLoading();
    }
  }

  //the only thing a user can update is the quantity
  Future<void> updateLatestGoal(int quantity) async {
    debugPrint('ended at updateLatestGoal in vm');
    String? curr_goal_id = _latestGoal?.goal_id;
    if (curr_goal_id == null || _latestGoal == null) {
      throw Exception('Goal could not be accessed or no goals to update');
    }
    if (_latestGoal!.quantity == quantity) {
      return;
    }
    Map<String, dynamic> updates = {'quantity': quantity};
    await goalRepo.updateGoalById(curr_goal_id, updates);
  }

  Future<void> onSavePressed(int quantity) async {
    _errorMessage = null;
    try {
      if (quantity < 0) {
        throw Exception('Invalid value for goal');
      }
      onLoading();
      if (_latestGoal == null) {
        await goalRepo.createNewGoal(
          Goal(start_date: DateTime.now(), isActive: true, quantity: quantity),
        );
      } else {
        int curr_qty = _latestGoal!.quantity;
        if (quantity > curr_qty) {
          debugPrint('ended at createHigherGoal in vm');
          await goalRepo.createHigherGoal(
            Goal(
              start_date: DateTime.now(),
              isActive: true,
              quantity: quantity,
            ),
          );
        } else if (isSameWeek(_latestGoal!.start_date, DateTime.now())) {
          debugPrint('ended at updateGoalById in vm');
          debugPrint(_latestGoal?.goal_id.toString());
          //update goal by id
          await goalRepo.updateGoalById(_latestGoal!.goal_id!, {
            'quantity': quantity,
          });
        } else if (quantity < curr_qty) {
           debugPrint('ended at createNewGoal in vm');
          //create new higher goal
          await goalRepo.createNewGoal(
            Goal(
              start_date: DateTime.now(),
              isActive: true,
              quantity: quantity,
            ),
          );
        }
      }
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    } finally {
      offLoading();
    }
  }

  bool isSameWeek(DateTime date1, DateTime date2) {
    DateTime monday1 = date1.subtract(Duration(days: date1.weekday - 1));
    DateTime monday2 = date2.subtract(Duration(days: date1.weekday - 1));

    return monday1.year == monday2.year && monday1.month == monday2.month && monday1.day == monday1.day;
  }
}
