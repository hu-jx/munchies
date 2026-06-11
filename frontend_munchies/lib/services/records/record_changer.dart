import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:frontend_munchies/services/auth/auth_exception.dart';
import 'package:frontend_munchies/services/records/record_services.dart';
import 'package:frontend_munchies/models/record.dart';

class RecordChanger extends ChangeNotifier {
  String? idToken;

  Future<void> getUserToken() async {
    FirebaseAuth.instance.idTokenChanges().listen((User? usr) async {
      if (usr == null) {
        throw AuthException('Access Denied');
      } else {
        idToken = await usr.getIdToken(true);
      }
    });
  }

  RecordChanger() {
    getUserToken();
  }
  //get user token once, store it here and use it through out 

  Future<void> deleteRec(String recordId) async {
    if (idToken!.isNotEmpty) {
      await RecordServices.deleteRecord(idToken!, recordId);
      notifyListeners();
    } else {
      throw AuthException('Access Denied.');
    }
  }

  //add save here
  Future<void> saveRecord(
    String itemName,
    String date,
    String cost,
    String? selectedCategory,
    String? imageField,
    bool isFavourited,
    String? details,
    bool isVisible
  ) async {
    User? usr = FirebaseAuth.instance.currentUser;
    if (usr == null) throw AuthException('Access denied.');
      Record rec = Record(
        user_uid: usr.uid,
        itemName: itemName,
        date: DateTime.parse(date),
        cost: (double.parse(cost) * 100).toInt(),
        category: selectedCategory.toString(),
        photo: imageField,
        isFavourited: isFavourited,
        details: details,
        isVisible: isVisible
      );
      await RecordServices.createRecord(idToken!, rec);
      notifyListeners();
  }

  Future<void> patchRecord(Record record, Map<String, dynamic> updates) async {
    if (idToken != null) {
      if (updates['cost'] != null) {
        updates['cost'] = (double.parse(updates['cost']) * 100).toInt();
      }
      await RecordServices.updateRecord(idToken!, record.record_id!, updates);
      notifyListeners();
    }
  }

  Future<Record> getRecord(String recordId) async {
    try {
      if (idToken == null) throw AuthException('Access Denied');
      return RecordServices.getRecord(idToken!, recordId);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<List<Record>> getFilteredRecord(Map<String, String> query) async {
    try {
      if (idToken == null) throw AuthException('Access Denied');
      if (idToken!.isEmpty) throw AuthException('Access Denied');
      Map<String, dynamic> validQueries = {
        'today': 'today',
        'weekly': 'weekly',
        'favourites': 'favourites',
        'monthly': 'month,year'
      };
      if (query.keys.length > 1 ) throw Exception('Access Denied in querying records.');
      if (!validQueries.keys.contains(query.keys.toList()[0])) {
        throw Exception('Not a valid query.');
      }
      return RecordServices.getAllRecords(idToken!, query);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<List<Record>> fetchAllRecords() async {
    if (idToken == null) throw AuthException('Access Denied');
    if (idToken!.isEmpty) throw AuthException('Access Denied');
    return RecordServices.getAllRecords(idToken!, null);
  }
}
