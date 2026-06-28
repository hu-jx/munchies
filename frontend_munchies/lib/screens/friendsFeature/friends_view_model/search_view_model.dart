// ignore_for_file: non_constant_identifier_names

import 'package:firebase_auth/firebase_auth.dart';
import 'package:frontend_munchies/models/user_profile.dart';
import 'package:frontend_munchies/services/request_services.dart';
import 'package:frontend_munchies/services/user_services.dart';
import 'package:frontend_munchies/utils/auth_helper.dart';
import 'package:http/http.dart' as http;

class SearchViewModel {
  final FirebaseAuth _auth;
  final http.Client? _client;

  UserProfile? foundUser;

  SearchViewModel({FirebaseAuth? auth, http.Client? client})
    : _auth = auth ?? FirebaseAuth.instance,
      _client = client;

  Future<void> findUsers(String emailAddress) async {
    final firebaseInfo = await userIdToken(_auth);
    final idToken = firebaseInfo.idToken;
    final usr = firebaseInfo.usr;

    foundUser = await UserServices.searchUser(
      emailAddress: emailAddress,
      user_uid: usr.uid,
      idToken: idToken,
      client: _client,
    );
  }
}

Future<String> checkStatus(
  String sender_id,
  String receiver_id, {
  FirebaseAuth? auth,
  http.Client? client,
}) async {
  final authInstance = auth ?? FirebaseAuth.instance;
  final firebaseInfo = await userIdToken(authInstance);
  final idToken = firebaseInfo.idToken;

  return RequestServices.checkStatus(
    sender_id: sender_id,
    receiver_id: receiver_id,
    idToken: idToken,
    client: client
  );
}

Future<void> sendRequest(
  String sender_id,
  String receiver_id, {
  FirebaseAuth? auth,
  http.Client? client,
}) async {
  final authInstance = auth ?? FirebaseAuth.instance;
  final firebaseInfo = await userIdToken(authInstance);
  final idToken = firebaseInfo.idToken;

  await RequestServices.sendRequest(
    sender_id: sender_id,
    receiver_id: receiver_id,
    idToken: idToken,
    client: client,
  );
}
