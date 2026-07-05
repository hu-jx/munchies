import 'package:firebase_auth/firebase_auth.dart';
import 'package:frontend_munchies/services/auth/auth_exception.dart';
import 'package:frontend_munchies/services/records/record_services.dart';

abstract class ScanRepository {
  Future<String> scanPicture(String base64);
}

class ScanRepoImpl implements ScanRepository {
  @override
  Future<String> scanPicture(String base64) async {
    User? usr = FirebaseAuth.instance.currentUser;
    if (usr == null) throw AuthException('Access Denied');
    String? idToken = await usr.getIdToken(true);
    if (idToken == null) throw AuthException('Access Denied');
    var itemName = await RecordServices.scanPicture(idToken, base64);
    if (itemName == null) {
      throw Exception('Could not proceed. Please try again later.');
    }
    return itemName;
  }
}
