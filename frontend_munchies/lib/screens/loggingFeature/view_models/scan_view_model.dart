import 'dart:convert';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:frontend_munchies/services/auth/auth_exception.dart';
import 'package:frontend_munchies/services/records/record_services.dart';

class ScanViewModel extends ChangeNotifier {
  File? _photoFile;
  bool _isLoading = false;
  bool _hasGeminiBanner = true;
  bool _hasImageTypeBanner = true;
  String? _itemName;
  String? _errorMessage;

  String? get itemName => _itemName;
  File? get photoFile  => _photoFile;
  bool get hasGeminiBanner => _hasGeminiBanner;
  bool get hasImageTypeBanner => _hasImageTypeBanner;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isValidItemName => _itemName != null && _itemName != "No food detected";

  void dismissGeiminiBanner() {
    _hasGeminiBanner = false;
    notifyListeners();
  }

  void dismissImageTypeBanner() {
    _hasImageTypeBanner = false;
    notifyListeners();
  }

  void onLoading() {
    _isLoading = true;
    notifyListeners();
  }

  void offLoading() {
    _isLoading = false;
    notifyListeners();
  }

  void setPhotoFile(File photoFile) {
    _photoFile = photoFile;
    notifyListeners();
  }

  Future<String?> _scanPicture(String base64) async {
    try {
      User? usr = FirebaseAuth.instance.currentUser;
      if (usr == null) throw AuthException('Access Denied');
      String? idToken = await usr.getIdToken(true);
      if (idToken == null) throw AuthException('Access Denied');
      var itemName = await RecordServices.scanPicture(idToken, base64);
      if (itemName == null) {
        throw Exception('Could not proceed. Please try again later.');
      }
      return itemName;
    } catch (e) {
      _errorMessage = e.toString();
    }
    return null;
  }

  Future<void> onScanPressed() async {
    if (_photoFile == null) {
        _errorMessage =
            'No image present for scanning. Add a photo and try again.';
      notifyListeners();
      return;
    }
    onLoading();
    
    String base64 = base64Encode(_photoFile!.readAsBytesSync());
    String? itemname = await _scanPicture(base64);
    _itemName = itemname?.trim();
    notifyListeners();

    offLoading();
  }
}