import 'package:frontend_munchies/services/user_services.dart';
import 'package:frontend_munchies/models/record.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:frontend_munchies/services/auth/auth_exception.dart';
import 'package:frontend_munchies/services/records/record_services.dart';


Future<bool> userLiked(Record record) async {
  //check if the retrievedProfile mongo id is in the list of likes of the record
  //if it is, setState to change isLiked to true
  final retrievedProfile = await UserServices.getCurrentUP();
  return record.likes?.contains(retrievedProfile.mongo_id) ?? false;
}

/*
Future<void> addLike(Record record) async {
  User? usr = FirebaseAuth.instance.currentUser;
  if (usr == null) throw AuthException('No permission to access.');
  String? idToken = await usr.getIdToken();
  if (idToken == null || idToken.isEmpty) {
    throw AuthException('No permission to access. ');
  }

  final recordId = record.record_id ;
  if (recordId == null) {
    throw Exception("Record does not have an id");
  }
  RecordServices.addLike(idToken, recordId);
}

Future<void> removeLike(Record record) async {
  User? usr = FirebaseAuth.instance.currentUser;
  if (usr == null) throw AuthException('No permission to access.');
  String? idToken = await usr.getIdToken();
  if (idToken == null || idToken.isEmpty) {
    throw AuthException('No permission to access. ');
  }

  final recordId = record.record_id ;
  if (recordId == null) {
    throw Exception("Record does not have an id");
  }
  RecordServices.removeLike(idToken, recordId);
}
*/

Future<void> vmToggleLikes(Record record, bool isLiked) async {
  User? usr = FirebaseAuth.instance.currentUser;
  if (usr == null) throw AuthException('No permission to access.');
  String? idToken = await usr.getIdToken();
  if (idToken == null || idToken.isEmpty) {
    throw AuthException('No permission to access. ');
  }

  final recordId = record.record_id ;
  if (recordId == null) {
    throw Exception("Record does not have an id");
  }

  //if isLiked, unlike, if not liked, like
  if (isLiked) {
    await RecordServices.removeLike(idToken, recordId);
  } else {
    await RecordServices.addLike(idToken, recordId);
  }
}