// FOR THE FCM SERVICES HELPER FUNCTION
import 'package:firebase_auth/firebase_auth.dart';
import 'package:frontend_munchies/services/notification_services.dart';
import 'package:frontend_munchies/utils/auth_helper.dart';
import 'package:http/http.dart' as http;

Future<void> registerToken({FirebaseAuth? auth, http.Client? client}) async {
  final authInstance = auth ?? FirebaseAuth.instance;
  final firebaseInfo = await userIdToken(authInstance);
  final idToken = firebaseInfo.idToken;

  await NotificationServices.registerToken(idToken: idToken);
}