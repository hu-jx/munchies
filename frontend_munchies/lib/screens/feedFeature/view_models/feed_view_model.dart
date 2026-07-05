import 'package:firebase_auth/firebase_auth.dart';
import 'package:frontend_munchies/models/user_profile.dart';
import 'package:frontend_munchies/services/records/record_services.dart';
import 'package:frontend_munchies/models/record.dart';
import 'package:frontend_munchies/services/user_services.dart';
import 'package:frontend_munchies/utils/auth_helper.dart';

Future<List<Record>> getFriendsPosts({FirebaseAuth? auth}) async {
  final authInstance = auth ?? FirebaseAuth.instance;
  final firebaseInfo = await userIdToken(authInstance);
  final idToken = firebaseInfo.idToken;

  return RecordServices.getFriendsPosts(idToken: idToken);
}

Future<UserProfile> findUserInfo(
  String mongoUserId, {
  FirebaseAuth? auth,
}) async {
  final authInstance = auth ?? FirebaseAuth.instance;
  final firebaseInfo = await userIdToken(authInstance);
  final idToken = firebaseInfo.idToken;

  return UserServices.findUserInfo(idToken, mongoUserId);
}

Future<void> addLike(String recordId, {FirebaseAuth? auth}) async {
  final authInstance = auth ?? FirebaseAuth.instance;
  final firebaseInfo = await userIdToken(authInstance);
  final idToken = firebaseInfo.idToken;

  return RecordServices.addLike(idToken, recordId);
}

Future<void> removeLike(String recordId, {FirebaseAuth? auth}) async {
  final authInstance = auth ?? FirebaseAuth.instance;
  final firebaseInfo = await userIdToken(authInstance);
  final idToken = firebaseInfo.idToken;

  return RecordServices.removeLike(idToken, recordId);
}
