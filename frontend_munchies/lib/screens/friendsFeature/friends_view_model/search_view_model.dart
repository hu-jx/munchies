// ignore_for_file: non_constant_identifier_names

import 'package:firebase_auth/firebase_auth.dart';
import 'package:frontend_munchies/models/user_profile.dart';
import 'package:frontend_munchies/services/request_services.dart';
import 'package:frontend_munchies/services/user_services.dart';
import 'package:frontend_munchies/utils/auth_helper.dart';

class SearchViewModel {
  final FirebaseAuth _auth;

  UserProfile? foundUser;

  SearchViewModel({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;

  Future<void> findUsers(String emailAddress) async {
    /*
    User? usr = FirebaseAuth.instance.currentUser;
    if (usr == null) throw AuthException('No permission to access.');
    String? idToken = await usr.getIdToken();
    if (idToken == null || idToken.isEmpty) {
      throw AuthException('No permission to access. ');
    }
    */

    final firebaseInfo = await userIdToken(_auth);
    final idToken = firebaseInfo.idToken;
    final usr = firebaseInfo.usr;

    foundUser = await UserServices.searchUser(emailAddress, usr.uid, idToken);
  }
}

Future<String> checkStatus(
  String sender_id,
  String receiver_id, {
  FirebaseAuth? auth,
}) async {
  /*
  User? usr = FirebaseAuth.instance.currentUser;
  if (usr == null) throw AuthException('No permission to access.');
  String? idToken = await usr.getIdToken();
  if (idToken == null || idToken.isEmpty) {
    throw AuthException('No permission to access. ');
  }
  */

  final authInstance = auth ?? FirebaseAuth.instance;
  final firebaseInfo = await userIdToken(authInstance);
  final idToken = firebaseInfo.idToken;

  return RequestServices.checkStatus(sender_id, receiver_id, idToken);
}

Future<void> sendRequest(
  String sender_id,
  String receiver_id, {
  FirebaseAuth? auth,
}) async {
  /*
  User? usr = FirebaseAuth.instance.currentUser;
  if (usr == null) throw AuthException('No permission to access.');
  String? idToken = await usr.getIdToken();
  if (idToken == null || idToken.isEmpty) {
    throw AuthException('No permission to access. ');
  }
  */
  final authInstance = auth ?? FirebaseAuth.instance;
  final firebaseInfo = await userIdToken(authInstance);
  final idToken = firebaseInfo.idToken;

  await RequestServices.sendRequest(sender_id, receiver_id, idToken);
}
