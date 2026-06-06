import 'dart:convert';
import 'package:frontend_munchies/models/record.dart';
import 'package:http/http.dart' as http;

class RecordServices {
  //TODO: REMEMBER TO CHANGE BASEURL BACK TO RENDER AFTW
  static const String _baseUrl = "http://10.0.2.2:3000/api";

  //POST http request (createRec)
  static Future<void> createRecord(String idToken, Record record) async {
    final res = await http.post(
      Uri.parse('$_baseUrl/records'),
      headers: {
        'Authorization': 'Bearer $idToken',
        'Content-type': 'application/json',
      },
      body: jsonEncode({
        'user_uid': record.user_uid,
        'itemName': record.itemName,
        'date': record.date.toIso8601String(),
        'cost': record.cost,
        'isFavourited': record.isFavourited,
        'category': record.category,
        'photo': record.photo,
        'details': record.details
      }),
    );

    if (res.statusCode != 201) {
      throw Exception('Failed to create profile');
    }
  }

  //GET http req (getAllrec)
  static Future<List<Record>> getAllRecords(String idToken) async {
    final res = await http.get(
      Uri.parse('$_baseUrl/records'),
      headers: {
        'Accept': '*/*',
        'Authorization': 'Bearer $idToken',
        'Content-Type': '	application/json',
        'Connection': 'keep-alive',
      },
    );
    if (res.statusCode == 200) {
      final decoded = jsonDecode(res.body);
      //expected shape: [ {str: val}]
      if (decoded is! List) {
        throw Exception('Unexpected data format');
      }

      List<Record> allRecs = decoded.map((singleRecData) {
        if (singleRecData is! Map<String, dynamic> ) {
          throw Exception('Unexpected data format');
        }
        return Record.fromJson(singleRecData);
      }).toList();
      return allRecs;
    } else {
      throw Exception('Failed to fetch records data');
    }
  }

  //GET http req (getRec)
  static Future<Record> getRecord(String idToken, String id) async {
    final res = await http.get(
      Uri.parse('$_baseUrl/records/$id'),
      headers: {
        'Accept': '*/*',
        'Authorization': 'Bearer $idToken',
        'Content-Type': '	application/json',
        'Connection': 'keep-alive',
      },
    );
    if (res.statusCode == 200) {
      var recordData = jsonDecode(res.body);
      if (recordData is! Map<String, dynamic>) {
        throw Exception('Unexpected data format');
      }
      return Record.fromJson(recordData);
    } else {
      throw Exception('Failed to fetch the record');
    }
  }

  //PATCH http req (updateRec)
  Future<void> updateRecord(
    String idToken,
    String id,
    Map<String, dynamic> updates,
  ) async {
    var headers = {
      'Authorization': 'Bearer $idToken',
      'Content-Type': 'application/json',
    };
    var request = http.Request('PATCH', Uri.parse('$_baseUrl/records/$id'));
    request.body = json.encode(updates);
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode != 201) {
      //print(response.reasonPhrase);
      throw Exception('Failed to update profile');
    }
  }

  //DELETE http req (delRec)
  Future<void> deleteRecord(String idToken, String itemId) async {
    var headers = {'Authorization': 'Bearer $idToken'};
    var request = http.Request(
      'DELETE',
      Uri.parse('$_baseUrl/records/$itemId'),
    );

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode != 200) {
      //print(response.reasonPhrase);
      throw Exception('Failed to delete profile');
    }
  }
}
