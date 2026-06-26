import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:frontend_munchies/screens/loggingFeature/repository/scan_repository.dart';
import 'package:mime/mime.dart';

class ScanViewModel extends ChangeNotifier {
  final ScanRepository scanRepo;
  ScanViewModel({required this.scanRepo});
  File? _photoFile;
  bool _isLoading = false;
  bool _hasGeminiBanner = true;
  bool _hasImageTypeBanner = true;
  String? _itemName;
  String? _errorMessage;

  String? get itemName => _itemName;
  File? get photoFile => _photoFile;
  bool get hasGeminiBanner => _hasGeminiBanner;
  bool get hasImageTypeBanner => _hasImageTypeBanner;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isValidItemName =>
      _itemName != null && _itemName != "No food detected";

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

  //expose for testing

  Future<void> onScanPressed() async {
    if (_photoFile == null || _photoFile is! File) {
      _errorMessage =
          'No image present for scanning. Add a photo and try again.';
      notifyListeners();
      return;
    }


    try {
      onLoading();
      //check that the photo file bytes are non-empty 
      final List<int> fileBytes = _photoFile!.readAsBytesSync();
      if (fileBytes.isEmpty) {
        throw Exception('File is unsupported or corrupted.');
      } 
      
      //check that the photo file type is accepted, else do not proceed to HTTP call 
      final numHeaderBytes = fileBytes.length < 24 ? fileBytes.length : 24;
      final headerBytes = fileBytes.sublist(0, numHeaderBytes);
      String? mimeType = lookupMimeType(_photoFile!.path, headerBytes: headerBytes);
      if (mimeType == null) throw Exception('No files found');
      final List<String> acceptedMimeTypes = ['image/jpeg', 'image/webp', 'image/png',];
      if (!acceptedMimeTypes.contains(mimeType)) throw Exception('File is unsupported or corrupted.');

      String base64 = base64Encode(fileBytes);
      String itemname = await scanRepo.scanPicture(base64);
      _itemName = itemname.trim();
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      debugPrint(e.toString());
      _errorMessage = e.toString();
    } finally {
      offLoading();
    }
  }
}
