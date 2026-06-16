// ignore_for_file: non_constant_identifier_names

import 'dart:io';
import 'package:frontend_munchies/models/category_item.dart';
import 'package:frontend_munchies/models/record.dart';
import 'package:flutter/material.dart';
import 'package:frontend_munchies/services/records/record_changer.dart';
import 'package:frontend_munchies/screens/loggingFeature/views/logging_widgets/fields/date.dart';

class LoggingViewModel extends ChangeNotifier {
  final Record? record;
  final RecordChanger recordChanger;
  LoggingViewModel({this.record, required this.recordChanger});

  String? _itemName;
  DateTime? _date;
  String? _cost;
  String? _details;
  String? _category;
  File? _existing_file;
  bool? _isFavourited;
  bool? _isVisible;
  String? _errorMessage;
  bool _isLoading = false;

  //RECORD DETAILS
  String? get itemName => checkIfUpdate(record?.itemName, _itemName);
  DateTime? get date => checkIfUpdate(record?.date, _date);
  String? get cost => record?.cost != null
      ? checkIfUpdate((record!.cost / 100).toStringAsFixed(2), _cost)
      : _cost;
  String? get details => checkIfUpdate(record?.details, _details);
  String? get category => checkIfUpdate(record?.category, _category);
  String? get existing_url => record?.photo_URL;
  File? get existing_file => checkIfUpdate(record?.photo_file, _existing_file);
  bool get isFavourited => checkIfUpdate(record?.isFavourited, _isFavourited) ?? false;
  bool get isVisible => checkIfUpdate(record?.isVisible, _isVisible) ?? false;

  //STATE DETAILS
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;

  dynamic checkIfUpdate(dynamic original, dynamic newVal) {
    if (original != newVal && newVal != null) {
      return newVal;
    } else {
      return original;
    }
  }

  void onLoading() {
    _isLoading = true;
    notifyListeners();
  }

  void offLoading() {
    _isLoading = false;
    notifyListeners();
  }

  void setNotFav() {
    _isFavourited = false;
    notifyListeners();
  }
  
  void setAsFav() {
    _isFavourited = true;
    notifyListeners();
  }

  void setItemName(String itemName) {
    _itemName = itemName;
  }

  void setDate(DateTime date) {
    _date = date;
    notifyListeners();
  }

  void setCost(String cost) {
    _cost = cost;
  }

  void setDetails(String details) {
    _details = details;
  }

  void setCat(CategoryItem category) {
    _category = category.labelText;
    notifyListeners();
  }

  void setPhotoFile(File photo_file) {
    _existing_file = photo_file;
    notifyListeners();
  }

  void setVisibility(bool visibility) {
    _isVisible = visibility;
    notifyListeners();
  }

  Future<void> onSavePressed() async {
    onLoading();
    _errorMessage = null;
    notifyListeners();

    //check using values if its an update or a new record
    if (record != null && record?.record_id != null) {
      await patchRecord();
    } else {
      await saveRecord();
    }
    offLoading();
  }

  Future<void> saveRecord() async {
    try {
      if (record?.record_id == null && record != null) {
        //saving from AI Scan OR Fill with Fav 
        if (_itemName == null) setItemName(record!.itemName);
        if (_date == null) setDate(record!.date);
        if (_cost == null) setCost((record!.cost / 100).toStringAsFixed(2));
        if (_existing_file == null && record!.photo_file != null) setPhotoFile(record!.photo_file!);
        if (_isFavourited == null) {
          if (record!.isFavourited) {
            setAsFav();
          } else { setNotFav();}
        }
      }
      await recordChanger.saveRecord(
        _itemName!,
        DateField.formatDate(_date!.toLocal())!,
        _cost!,
        _category ?? record?.category,
        _existing_file,
        _isFavourited ?? false,
        details,
        _isVisible ?? false,
      );
      _errorMessage = null;
      notifyListeners();
    } on FormatException {
      _errorMessage =
          "Remember: use date picker for Date and key in a valid value for cost.\n"
          "Example of valid values: 4.80, 4. Do not include special characters like -, \$";
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> patchRecord() async {
    try {
      onLoading();
      notifyListeners();

      final Map<String, dynamic> updates = {
        'itemName': _itemName,
        'date': _date,
        'cost': _cost,
        'photo_file': _existing_file,
        'category': _category,
        'isFavourited': _isFavourited,
        'details': _details,
        'isVisible': _isVisible,
      };
      await recordChanger.patchRecord(record!, updates);

      _errorMessage = null;
      offLoading();
      notifyListeners();
    } on FormatException {
      _errorMessage =
          "Remember: use date picker for Date and key in a valid value for cost.\n"
          "Example of valid values: 4.80, 4. Do not include special characters like -, \$";
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }
}
