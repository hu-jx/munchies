// ignore_for_file: non_constant_identifier_names

import 'package:firebase_auth/firebase_auth.dart';
import 'package:frontend_munchies/models/friend_request.dart';
import 'package:frontend_munchies/models/user_profile.dart';
import 'package:frontend_munchies/services/auth/auth_exception.dart';
import 'package:frontend_munchies/services/request_services.dart';
import 'package:frontend_munchies/services/user_services.dart';


Future<List<UserProfile>> getFriendsList() async {
  User? usr = FirebaseAuth.instance.currentUser;
  if (usr == null) throw AuthException('No permission to access.');
  String? idToken = await usr.getIdToken();
  if (idToken == null || idToken.isEmpty) {
    throw AuthException('No permission to access. ');
  }

  return UserServices.getFriendsList(idToken);
}

Future<List<FriendRequest>> getPendingRequest() async {
  User? usr = FirebaseAuth.instance.currentUser;
  if (usr == null) throw AuthException('No permission to access.');
  String? idToken = await usr.getIdToken();
  if (idToken == null || idToken.isEmpty) {
    throw AuthException('No permission to access. ');
  }

  return RequestServices.getPendingRequests(idToken);
}

Future<void> updateRequest(String sender_id, String receiver_id, String response) async {
  User? usr = FirebaseAuth.instance.currentUser;
  if (usr == null) throw AuthException('No permission to access.');
  String? idToken = await usr.getIdToken();
  if (idToken == null || idToken.isEmpty) {
    throw AuthException('No permission to access. ');
  }

  await RequestServices.updateRequest(sender_id, receiver_id, response, idToken);
}