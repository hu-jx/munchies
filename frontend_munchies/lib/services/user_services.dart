import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:frontend_munchies/models/record.dart';
import 'package:frontend_munchies/models/user_profile.dart';
import 'package:http/http.dart' as http;

class UserServices {
  static const String _baseUrl = "http://10.0.2.2:3000/api";
  //static const String _baseUrl = "https://munchies-5dvw.onrender.com/api";

  static Future<List<UserProfile>> searchUser(
    String emailAddress,
    String user_uid,
    String idToken
  ) async {
    String url =
        '$_baseUrl/search?search_email=$emailAddress&user_uid=$user_uid';

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

      //change this to return a list of user profiles????
      List<UserProfile> allRecs = decoded.map((singleUserData) {
        if (singleUserData is! Map<String, dynamic>) {
          throw Exception('Unexpected data format');
        }
        return UserProfile.fromJson(singleUserData);
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
}
