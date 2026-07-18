import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:frontend_munchies/models/user_profile.dart';
import 'package:frontend_munchies/services/auth/api_services.dart';
import 'package:frontend_munchies/services/auth/auth_exception.dart';

abstract class ProfileVMRepo extends ChangeNotifier{
  String get name;
  String? get errorMessage;
  String get emailAddress;
  UserProfile? get profile;
}

class ProfileVM extends ChangeNotifier implements ProfileVMRepo {
  UserProfile? _profile;
  String? _errorMessage;
  

  ProfileVM() {
    getName();
  }

  void getName() async {
    debugPrint("ENTERED GET NAME");
    try {
      String? idToken = await FirebaseAuth.instance.currentUser!.getIdToken();
      if (idToken == null) throw AuthException('Network error');
      UserProfile profile = await AuthServices().fetchProfileData(idToken);
      _profile = profile;
      debugPrint("COMPLETED GET NAME. Profile is ${_profile?.firstName}");
    } catch (e) {
      debugPrint("ERROR OCCURRED AT GET NAME ${e.toString()}");
      _errorMessage = e.toString();
      _profile = null;
    }
  }

  @override
  UserProfile? get profile => _profile;
  @override
  String get name {
    if (_profile == null) {
      return "";
    } else {
      return "${_profile!.firstName} ${_profile!.lastName}";
    }
  }
  @override
  String? get errorMessage => _errorMessage;

  @override
  String get emailAddress {
    if (_profile == null) {
      return "";
    } else {
      return _profile!.emailAddress;
    }
  }
}