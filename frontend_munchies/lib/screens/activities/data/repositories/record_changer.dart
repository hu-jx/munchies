import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:frontend_munchies/screens/activities/domain/repositories/record_repo.dart';
import 'package:frontend_munchies/services/auth/auth_exception.dart';
import 'package:frontend_munchies/services/records/record_services.dart';
import 'package:frontend_munchies/models/record.dart';

//Repository - handles business logic of whether or not something new has arrived and logic of what to pass to API Services
class RecordRepoImpl implements RecordRepository {
  final _recordStream = StreamController<void>.broadcast();

  @override
  Stream<void> get recordStream => _recordStream.stream;

  void dispose() {
    _recordStream.close();
  }

  String? idToken;

  Future<void> getUserToken() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw AuthException('Access Denied');
    String? newToken = await user.getIdToken(false);
    if (idToken != newToken || idToken == null) {
      idToken = newToken;
    }
    if (idToken == null) throw AuthException('Access Denied');
    if (idToken!.isEmpty) throw AuthException('Access Denied');
  }

  @override
  Future<void> deleteRec(String recordId) async {
    await getUserToken();
    await RecordServices.deleteRecord(idToken!, recordId);
    _recordStream.add(null);
  }

  @override
  Future<void> saveRecord(Record record) async {
    await getUserToken();
    User? usr = FirebaseAuth.instance.currentUser;
    if (usr == null) throw AuthException('Access denied.');
    record.user_uid = usr.uid;
    await RecordServices.createRecord(idToken!, record);
    _recordStream.add(null);
  }

  @override
  Future<void> patchRecord(
    String recordId,
    Map<String, dynamic> updates,
  ) async {
    await getUserToken();
    if (updates['cost'] != null) {
      updates['cost'] = (double.parse(updates['cost']) * 100).toInt();
    }
    await RecordServices.updateRecord(idToken!, recordId, updates);
    _recordStream.add(null);
  }

  @override
  Future<Record> getRecord(String recordId) async {
    await getUserToken();
    if (idToken == null) throw AuthException('Access Denied');
    return RecordServices.getRecord(idToken!, recordId);
  }

  @override
  Future<List<Record>> fetchAllRecords(Map<String, String>? query) async {
    await getUserToken();
    List<Record> data = await RecordServices.getAllRecords(idToken!, query);
    return List.unmodifiable(data);
  }
}
