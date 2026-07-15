// FOR THE FCM SERVICES HELPER FUNCTION
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:frontend_munchies/models/friend_request.dart';
// import 'package:frontend_munchies/models/user_profile.dart';
import 'package:frontend_munchies/services/notification_services.dart';
// import 'package:frontend_munchies/services/request_services.dart';
// import 'package:frontend_munchies/services/user_services.dart';
import 'package:frontend_munchies/utils/auth_helper.dart';
import 'package:http/http.dart' as http;

Future<void> registerToken({FirebaseAuth? auth, http.Client? client}) async {
  final authInstance = auth ?? FirebaseAuth.instance;
  final firebaseInfo = await userIdToken(authInstance);
  final idToken = firebaseInfo.idToken;

  print("NotifService registerToken called");
  await NotificationServices.registerToken(idToken: idToken);
}