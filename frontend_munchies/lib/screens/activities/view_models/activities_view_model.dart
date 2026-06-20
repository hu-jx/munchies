import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:frontend_munchies/models/filters.dart';
import 'package:frontend_munchies/screens/activities/domain/view_models/record_handler.dart';
import 'package:frontend_munchies/screens/activities/data/repositories/record_changer.dart';
import 'package:frontend_munchies/models/record.dart';

class ActivitiesViewModel extends ChangeNotifier implements RecordHandler {
  final RecordRepoImpl recordRepo;
  final ActivityFilter filter;
  late StreamSubscription _subscription;

  ActivitiesViewModel({required this.recordRepo, required this.filter}) {
    _subscription = recordRepo.recordStream.listen((r) {
      loadAllRecords();
    });
    loadAllRecords();
  }

  bool _isLoading = false;
  bool _isDisposed = false;
  String? _errorMessage;
  List<Record> _records = [];

  bool? get loadingStatus => _isLoading;
  String? get errorMessage => _errorMessage;
  List<Record> get recordDetails => _records;

  @override
  void onLoading() {
    _isLoading = true;
    notifyListeners();
  }

  @override
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

  void loadAllRecords() async {
    onLoading();
    try {
      List<Record> data = await recordRepo.fetchAllRecords(filter.query);
      _records = data;
      notifyListeners();
      debugPrint(data.map((r) => r.itemName).toList().toString());
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    } finally {
      offLoading();
    }
  }

  @override
  Future<void> onDeletePressed(String recordId) async {
    onLoading();
    await recordRepo.deleteRec(recordId);
    offLoading();
  }

  @override
  void dispose() {
    _subscription.cancel();
    _isDisposed = true;
    super.dispose();
  }
}
