import 'package:flutter/material.dart';
import 'package:frontend_munchies/services/records/record_changer.dart';

abstract class RecordHandler extends ChangeNotifier{
  RecordRepoImpl getRecordRepo();
  void onLoading();
  void offLoading();
  
  Future<void> onDeletePressed(String recordId) async {
    onLoading();
    RecordRepoImpl repo = getRecordRepo();
    await repo.deleteRec(recordId);
    offLoading();
  }
}