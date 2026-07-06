import 'package:firebase_auth/firebase_auth.dart';
import 'package:frontend_munchies/services/recommendation_services.dart';
import 'package:frontend_munchies/utils/auth_helper.dart';
import 'package:http/http.dart' as http;

Future<Map<String, dynamic>> getRec({FirebaseAuth? auth, http.Client? client}) async {
  final authInstance = auth ?? FirebaseAuth.instance;
  final firebaseInfo = await userIdToken(authInstance);
  final idToken = firebaseInfo.idToken;

  return RecommendationServices.getRecommendation(idToken: idToken);
}
