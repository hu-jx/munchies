import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:frontend_munchies/screens/authentication/view_model/authentication.dart';
import 'package:frontend_munchies/services/auth/auth_exception.dart';

class ForgotPwVm extends ChangeNotifier {
  String? errorMessage;
  String? status;

  void sendResetLink(String? email) async {
    try {
      notifyListeners();
      if (email == null) {
        throw AuthException('No email address provided. Provide a valid email address and try again.');
      } else if (email.isEmpty) {
        throw AuthException('No email address provided. Provide a valid email address and try again.');
      }
      status = 'Loading...';
      notifyListeners();
      await Authentication.sendPasswordLink(email);
      errorMessage = null;
      status = 'Link sent!';
    } on FirebaseException catch (err) {
      status = null;
      switch (err.code) {
        case 'invalid-email':
          errorMessage = 
            'Invalid email address. Please enter a valid email.';
        default:
          throw Exception("Unexpected Error");
      }
    } on Exception catch (e) {
      status = null;
      errorMessage = e.toString();
    } finally {
      notifyListeners();
    }
  }
}
