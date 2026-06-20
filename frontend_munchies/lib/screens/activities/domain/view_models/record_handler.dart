import 'package:flutter/material.dart';

abstract class RecordHandler extends ChangeNotifier{
  void onLoading();
  void offLoading();
  
  Future<void> onDeletePressed(String recordId);
}