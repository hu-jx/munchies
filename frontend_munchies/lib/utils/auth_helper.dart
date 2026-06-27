
import 'package:firebase_auth/firebase_auth.dart';
import 'package:frontend_munchies/services/auth/auth_exception.dart';

class FirebaseAuthInfo {
  final String idToken;
  final User usr;
  
  FirebaseAuthInfo({required this.idToken, required this.usr});

}

Future<FirebaseAuthInfo> userIdToken(FirebaseAuth auth) async {
  User? usr = auth.currentUser;
  if (usr == null) throw AuthException('No permission to access.');
  String? idToken = await usr.getIdToken();
  if (idToken == null || idToken.isEmpty) {
    throw AuthException('No permission to access. ');
  }
  return FirebaseAuthInfo(idToken: idToken, usr: usr);
}