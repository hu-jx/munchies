// ignore_for_file: non_constant_identifier_names

import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:frontend_munchies/models/record.dart';
import 'package:http/http.dart' as http;

class RecordServices {
  static const String _baseUrl = "http://10.0.2.2:3000/api";
  //static const String _baseUrl = "https://munchies-5dvw.onrender.com/api";

  //POST http request (createRec)
  static Future<void> createRecord(String idToken, Record record) async {
    var request = http.MultipartRequest('POST', Uri.parse('$_baseUrl/records'));
    var headers = {'Authorization': 'Bearer $idToken'};
    Map<String, String> data = {
      'user_uid': record.user_uid ?? '',
      'itemName': record.itemName,
      'cost': record.cost.toString(),
      'date': record.date.toIso8601String(),
      'isFavourited': record.isFavourited.toString(),
      'category': record.category ?? '',
      'details': record.details ?? '',
      'isVisible': record.isVisible.toString(),
    };
    data.removeWhere((key, val) => val.isEmpty);
    request.fields.addAll(data);
    if (record.photo_file?.path != null) {
      request.files.add(
        await http.MultipartFile.fromPath('photo', record.photo_file!.path),
      );
    }
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 201) {
      debugPrint(await response.stream.bytesToString());
    } else {
      debugPrint(response.reasonPhrase);
    }

    //   headers: {
    //     'Authorization': 'Bearer $idToken',
    //     'Content-type': 'application/json',
    //   },
    //   body: jsonEncode({
    //     'user_uid': record.user_uid,
    //     'itemName': record.itemName,
    //     'date': record.date.toIso8601String(),
    //     'cost': record.cost,
    //     'isFavourited': record.isFavourited,
    //     'category': record.category,
    //     'photo_URL': record.photo_URL,
    //     'details': record.details,
    //     'isVisible': record.isVisible
    //   }),
    // );

    if (response.statusCode != 201) {
      throw Exception('Failed to create record');
    }
  }

  //GET http req (getAllrec)
  static Future<List<Record>> getAllRecords(
    String idToken,
    Map<String, String>? query,
  ) async {
    String url = '$_baseUrl/records';
    if (query != null) {
      try {
        if (query.isNotEmpty) {
          if (query.containsKey('today')) {
            url = '$url?freq=today';
          } else if (query.containsKey('weekly')) {
            url = '$url?freq=weekly';
          } else if (query.containsKey('favourites')) {
            url = '$url?favourites=true';
          } else if (query.containsKey('monthly')) {
            List<String> month_year = query['monthly']!.split(',');
            if (month_year.length != 2) {
              throw Exception('Invalid date format when fetching records.');
            }
            String month = month_year[0];
            String year = month_year[1];
            url = '$url?month=$month&&year=$year';
          }
        }
      } on Exception catch (e) {
        debugPrint(e.toString());
      }
    }

    final res = await http.get(
      Uri.parse(url),
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
        if (singleRecData is! Map<String, dynamic>) {
          throw Exception('Unexpected data format');
        }
        return Record.fromJson(singleRecData);
      }).toList();
      return allRecs;
    } else {
      if (res.statusCode == 204) {
        return [];
      }
      debugPrint(res.reasonPhrase);
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
      debugPrint(res.reasonPhrase);
      throw Exception('Failed to fetch the record');
    }
  }

  //PATCH http req (updateRec)
  static Future<void> updateRecord(
    String idToken,
    String id,
    Map<String, dynamic> updates,
  ) async {
    debugPrint("AT RECORD SERVICES ${updates.toString()}");
    var headers = {
      'Authorization': 'Bearer $idToken',
      'Content-Type': 'application/json',
    };
    var request = http.MultipartRequest(
      'PATCH',
      Uri.parse('$_baseUrl/records/$id'),
    );
    if (updates.containsKey('photo_file') && updates['photo_file'] is File) {
      request.files.add(
        await http.MultipartFile.fromPath('photo', updates['photo_file'].path),
      );
    }
    updates['photo'] = null;
    updates.removeWhere((key, value) => value == null);
    Map<String, String> data = updates.map(
      (key, value) => MapEntry(key, value.toString()),
    );

    request.fields.addAll(data);
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode != 201) {
      debugPrint(response.reasonPhrase);
      throw Exception('Failed to update profile');
    }
  }

  //DELETE http req (delRec)
  static Future<void> deleteRecord(String idToken, String itemId) async {
    var headers = {'Authorization': 'Bearer $idToken'};
    var request = http.Request(
      'DELETE',
      Uri.parse('$_baseUrl/records/$itemId'),
    );

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode != 201) {
      debugPrint(response.reasonPhrase);
      throw Exception('Failed to delete record');
    }
  }

  static Future<String?> scanPicture(String idToken, String base64) async {
    final res = await http.post(
      Uri.parse('$_baseUrl/name'),
      headers: {
        'Accept': '*/*',
        'Authorization': 'Bearer $idToken',
        'Content-Type': '	application/json',
        'Connection': 'keep-alive',
      },
      body: jsonEncode({'base64_photo': base64}),
    );
    if (res.statusCode == 200) {
      var recordData = jsonDecode(res.body);
      if (recordData is! Map<String, dynamic>) {
        throw Exception('Unexpected data format');
      }
      return recordData['itemName'];
    } else {
      debugPrint(res.reasonPhrase);
      throw Exception('Failed to scan the picture');
    }
  }

  static Future<Map<String, dynamic>> getDashboardData({
    required String idToken,
    required String user_uid,
    required String startDate,
    required String endDate,
    required String view,
  }) async {
    //make API call here
    String url =
        '$_baseUrl/dashboard?startDate=$startDate&endDate=$endDate&view=$view&user_uid=$user_uid';
    final res = await http.get(
      Uri.parse(url),
      headers: {
        'Accept': '*/*',
        'Authorization': 'Bearer $idToken',
        'Content-Type': '	application/json',
        'Connection': 'keep-alive',
      },
    );
    // print("STATUS: ${res.statusCode}");
    // print("BODY: ${res.body}");
    //error here
    return jsonDecode(res.body);
  }
}
