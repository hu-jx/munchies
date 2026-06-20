import 'package:flutter/material.dart';
import 'package:frontend_munchies/models/filters.dart';
import 'package:frontend_munchies/screens/activities/data/repositories/record_changer.dart';
import 'package:frontend_munchies/models/record.dart';

class FavouritesViewModel extends ChangeNotifier {
  final RecordRepoImpl recordChanger;

  List<Record> _recordDetails = [];
  String? _errorMessage;
  bool _isLoading = false;

  List<Record> get recordDetails => _recordDetails;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  FavouritesViewModel({required this.recordChanger}) {
    _fetchFavRecords();
  }

  void onLoading() {
    _isLoading = true;
    notifyListeners();
  }

  void offLoading() {
    _isLoading = false;
    notifyListeners();
  }

  Future<void> _fetchFavRecords() async {
    try {
      onLoading();
      _recordDetails = await recordChanger.fetchAllRecords(
        ActivityFilter.favouritedActivities.query,
      );
      notifyListeners();
      offLoading();
    } on Exception catch (e) {
      _errorMessage = e.toString();
    }
  }
}
