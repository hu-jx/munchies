/*
functions to be added here:

getFriendsPosts()

feedView likePost => addLike()

feedView unlikePost => removeLike()

*/
import 'package:firebase_auth/firebase_auth.dart';
import 'package:frontend_munchies/models/user_profile.dart';
import 'package:frontend_munchies/services/auth/auth_exception.dart';
import 'package:frontend_munchies/services/records/record_services.dart';
import 'package:frontend_munchies/models/record.dart';
import 'package:frontend_munchies/services/user_services.dart';


Future<List<Record>> getFriendsPosts() async {
  User? usr = FirebaseAuth.instance.currentUser;
  if (usr == null) throw AuthException('No permission to access.');
  String? idToken = await usr.getIdToken();
  if (idToken == null || idToken.isEmpty) {
    throw AuthException('No permission to access. ');
  }

  return RecordServices.getFriendsPosts(idToken: idToken);
}

Future<UserProfile> findUserInfo(String mongo_user_id) async {
  User? usr = FirebaseAuth.instance.currentUser;
  if (usr == null) throw AuthException('No permission to access.');
  String? idToken = await usr.getIdToken();
  if (idToken == null || idToken.isEmpty) {
    throw AuthException('No permission to access. ');
  }

  return UserServices.findUserInfo(idToken, mongo_user_id);
}

Future<void> addLike(String recordId) async {
  User? usr = FirebaseAuth.instance.currentUser;
  if (usr == null) throw AuthException('No permission to access.');
  String? idToken = await usr.getIdToken();
  if (idToken == null || idToken.isEmpty) {
    throw AuthException('No permission to access. ');
  }

  return RecordServices.addLike(idToken, recordId);
}

Future<void> removeLike(String recordId) async {
  User? usr = FirebaseAuth.instance.currentUser;
  if (usr == null) throw AuthException('No permission to access.');
  String? idToken = await usr.getIdToken();
  if (idToken == null || idToken.isEmpty) {
    throw AuthException('No permission to access. ');
  }

  return RecordServices.removeLike(idToken, recordId);
}