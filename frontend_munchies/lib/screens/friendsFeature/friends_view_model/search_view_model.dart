import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:frontend_munchies/models/user_profile.dart';
import 'package:frontend_munchies/services/auth/auth_exception.dart';
import 'package:frontend_munchies/services/user_services.dart';

class SearchViewModel {
      List<UserProfile> usersFound = [];

  Future<void> findUsers(String emailAddress) async {

    User? usr = FirebaseAuth.instance.currentUser;
    if (usr == null) throw AuthException('No permission to access.');
    String? idToken = await usr.getIdToken();
    if (idToken == null || idToken.isEmpty) {
      throw AuthException('No permission to access. ');
    }

    print("SEARCH START");

    List<UserProfile> userList = await UserServices.searchUser(
      emailAddress,
      usr.uid,
      idToken
    );
    print("SEARCH END");

    usersFound = userList;
  }
}
