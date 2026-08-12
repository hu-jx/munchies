import 'package:frontend_munchies/services/user_services.dart';
import 'package:frontend_munchies/models/record.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:frontend_munchies/services/records/record_services.dart';
import 'package:frontend_munchies/utils/auth_helper.dart';
import 'package:http/http.dart' as http;

Future<bool> userLiked(Record record) async {
  //check if the retrievedProfile mongo id is in the list of likes of the record
  //if it is, setState to change isLiked to true
  final retrievedProfile = await UserServices.getCurrentUP();
  return record.likes?.contains(retrievedProfile.mongo_id) ?? false;
}

Future<void> vmToggleLikes(
  Record record,
  bool isLiked, {
  FirebaseAuth? auth,
  http.Client? client,
}) async {
  final authInstance = auth ?? FirebaseAuth.instance;
  final firebaseInfo = await userIdToken(authInstance);
  final idToken = firebaseInfo.idToken;

  final recordId = record.record_id;
  if (recordId == null) {
    throw Exception("Record does not have an id");
  }

  if (isLiked) {
    await RecordServices.removeLike(idToken, recordId, client: client);
  } else {
    await RecordServices.addLike(idToken, recordId, client: client);
  }
}
