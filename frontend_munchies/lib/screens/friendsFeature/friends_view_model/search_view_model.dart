// ignore_for_file: non_constant_identifier_names

import 'package:firebase_auth/firebase_auth.dart';
import 'package:frontend_munchies/models/user_profile.dart';
import 'package:frontend_munchies/services/auth/auth_exception.dart';
import 'package:frontend_munchies/services/request_services.dart';
import 'package:frontend_munchies/services/user_services.dart';

class SearchViewModel {
  UserProfile? foundUser;

  Future<void> findUsers(String emailAddress) async {

    User? usr = FirebaseAuth.instance.currentUser;
    if (usr == null) throw AuthException('No permission to access.');
    String? idToken = await usr.getIdToken();
    if (idToken == null || idToken.isEmpty) {
      throw AuthException('No permission to access. ');
    }

    foundUser = await UserServices.searchUser(
      emailAddress,
      usr.uid,
      idToken
    );
  }
}

Future<String> checkStatus(String sender_id, String receiver_id) async {
  User? usr = FirebaseAuth.instance.currentUser;
  if (usr == null) throw AuthException('No permission to access.');
  String? idToken = await usr.getIdToken();
  if (idToken == null || idToken.isEmpty) {
    throw AuthException('No permission to access. ');
  }

  return RequestServices.checkStatus(sender_id, receiver_id, idToken);
}

Future<void> sendRequest(String sender_id, String receiver_id) async {
  User? usr = FirebaseAuth.instance.currentUser;
  if (usr == null) throw AuthException('No permission to access.');
  String? idToken = await usr.getIdToken();
  if (idToken == null || idToken.isEmpty) {
    throw AuthException('No permission to access. ');
  }

  await RequestServices.sendRequest(sender_id, receiver_id, idToken);
}
