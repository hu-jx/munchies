import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:frontend_munchies/models/filters.dart';
import 'package:frontend_munchies/screens/activities/domain/repositories/record_repo.dart';
import 'package:frontend_munchies/screens/activities/domain/view_models/record_handler.dart';
import 'package:frontend_munchies/models/record.dart';

class ActivitiesViewModel extends ChangeNotifier implements RecordHandler {
  final RecordRepository recordRepo;
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

  Future<void> loadAllRecords() async {
    try {
      onLoading();
      debugPrint('ON VIEWMODEL' + _isLoading.toString());
      debugPrint('reached loading with $_isLoading');
      List<Record> data = await recordRepo.fetchAllRecords(filter.query);
      debugPrint('after fetch');
      _records = data;
      notifyListeners();
    } catch (e) {
      debugPrint(e.toString());
      _errorMessage = e.toString();
      notifyListeners();
    } finally {
      debugPrint('does not reach offLoading');
      offLoading();
    }
  }

  @override
  Future<void> onDeletePressed(String recordId) async {
    try {
      debugPrint('delete in action');
      onLoading();
      await recordRepo.deleteRec(recordId);
      debugPrint('complete delete in action');
    } on Exception catch (e) {
      _errorMessage = e.toString();
    } finally {
      offLoading();
    }
  }

  @override
  void dispose() {
    _subscription.cancel();
    _isDisposed = true;
    super.dispose();
  }
}
