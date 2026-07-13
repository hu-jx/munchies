// ignore_for_file: non_constant_identifier_names

import 'package:firebase_auth/firebase_auth.dart';
import 'package:frontend_munchies/models/friend_request.dart';
import 'package:frontend_munchies/models/user_profile.dart';
import 'package:frontend_munchies/services/request_services.dart';
import 'package:frontend_munchies/services/user_services.dart';
import 'package:frontend_munchies/utils/auth_helper.dart';
import 'package:http/http.dart' as http;

Future<List<UserProfile>> getFriendsList({FirebaseAuth? auth, http.Client? client}) async {

  final authInstance = auth ?? FirebaseAuth.instance;
  final firebaseInfo = await userIdToken(authInstance);
  final idToken = firebaseInfo.idToken;

  return UserServices.getFriendsList(idToken, client: client);
}

Future<List<FriendRequest>> getPendingRequest({FirebaseAuth? auth, http.Client? client}) async {
  
  final authInstance = auth ?? FirebaseAuth.instance;
  final firebaseInfo = await userIdToken(authInstance);
  final idToken = firebaseInfo.idToken;

  return RequestServices.getPendingRequests(idToken, client: client);
}

Future<void> updateRequest(
  String sender_id,
  String receiver_id,
  String response, {
  FirebaseAuth? auth,
  http.Client? client
}) async {
  
  final authInstance = auth ?? FirebaseAuth.instance;
  final firebaseInfo = await userIdToken(authInstance);
  final idToken = firebaseInfo.idToken;

  await RequestServices.updateRequest(
    sender_id,
    receiver_id,
    response,
    idToken,
    client: client
  );
}

Future<void> removeFriend(
  String sender_id,
  String receiver_id, {
  FirebaseAuth? auth,
  http.Client? client,
}) async {
  final authInstance = auth ?? FirebaseAuth.instance;
  final firebaseInfo = await userIdToken(authInstance);
  final idToken = firebaseInfo.idToken;

  await UserServices.removeFriend(
    sender_id: sender_id,
    receiver_id: receiver_id,
    idToken: idToken,
    client: client,
  );
}
