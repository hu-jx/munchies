// ignore_for_file: non_constant_identifier_names

import 'dart:io';
import 'package:frontend_munchies/models/category_item.dart';
import 'package:frontend_munchies/models/record.dart';
import 'package:flutter/material.dart';
import 'package:frontend_munchies/screens/activities/domain/repositories/record_repo.dart';
// ViewModel -> handles state changes and values at point of saving AKA what appears on screen.

class LoggingViewModel extends ChangeNotifier {
  final Record? record;
  final RecordRepository recordChanger;
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
  bool _isDisposed = false;
  static String invalidFormatErrorMessage = "One or more fields have an invalid value.\n"
          "Remember: use date picker for Date and key in a valid value for cost.\n"
          "Example of valid values: 4.80, 4. Do not include special characters like -, \$";

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
  bool get isFavourited =>
      checkIfUpdate(record?.isFavourited, _isFavourited) ?? false;
  bool get isVisible => checkIfUpdate(record?.isVisible, _isVisible) ?? false;

  //STATE DETAILS
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;

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

  //validators used in TextEditingControllers.  
  static String? requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Field cannot be empty';
    }
    return null;
  }

  static String? costValidator(String? value) {
    if (requiredValidator(value) == null) {
      if (double.tryParse(value!) == null) {
        return 'Invalid value for cost.';
      }
      return null;
    }
    return null;
  }

  //check state of values in record
  static dynamic checkIfUpdate(dynamic original, dynamic newVal) {
    if (original != null && newVal == null) {
      return original;
    } else {
      return newVal;
    }
  }

  void onLoading() {
    if (_isDisposed) return;
    _isLoading = true;
    notifyListeners();
  }

  void offLoading() {
    if (_isDisposed) return;
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
    _cost = cost.trim();
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

  //Functionalities of "SAVE" - either update or save
  Future<void> onSavePressed() async {
    if (_isLoading || _isDisposed) return;
    onLoading();
    _errorMessage = null;
    notifyListeners();

    //check using values if its an update or a new record
    if (record != null && record?.record_id != null) {
      await patchRecord();
    } else {
      await saveRecord();
    }
    if (_isDisposed) return;
    offLoading();
  }

  Future<void> saveRecord() async {
    try {
      if (_isDisposed) return;
      if (record?.record_id == null && record != null) {
        //saving from AI Scan OR Fill with Fav
        if (_itemName == null) setItemName(record!.itemName);
        if (_date == null) setDate(record!.date);
        if (_cost == null) setCost((record!.cost / 100).toStringAsFixed(2));
        if (_existing_file == null && record!.photo_file != null) {
          setPhotoFile(record!.photo_file!);
        }
        if (_isFavourited == null) {
          if (record!.isFavourited) {
            setAsFav();
          } else {
            setNotFav();
          }
        }
      } else if (_itemName == null || _date == null || _cost == null) {
        throw FormatException('One or more required fields have a null value');
      }

      if (_isDisposed) return;
      await recordChanger.saveRecord(
        Record(
          itemName: _itemName!.trim(),
          date: _date!.toLocal(),
          cost: (double.parse(_cost!) * 100).toInt(),
          isFavourited: _isFavourited ?? false,
          isVisible: _isVisible ?? false,
          photo_file: _existing_file,
          category: _category ?? record?.category,
          details: details,
        ),
      );
      _errorMessage = null;
      notifyListeners();
    } on FormatException {
      _errorMessage = invalidFormatErrorMessage;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> patchRecord() async {
    try {
      if (record?.record_id == null) {
        throw Exception('No record id linked to edit.');
      }
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
      if (updates.entries.every((val) => val.value == null)) {
        offLoading();
        debugPrint('Nothing to update');
        return;
      }
      await recordChanger.patchRecord(record!.record_id!, updates);

      _errorMessage = null;
      // notifyListeners();
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
