// ignore_for_file: constant_identifier_names

import 'dart:convert';
import 'package:frontend_munchies/models/user_profile.dart';
import 'package:frontend_munchies/services/auth/auth_services_repo.dart';
import 'package:http/http.dart' as http;

class AuthServices implements AuthServicesRepo {
  //static const String _baseUrl = "http://localhost:3000/api";
  static const String _baseUrl = "https://munchies-5dvw.onrender.com/api";

  //GET http request
  @override
  Future<UserProfile> fetchProfileData(String idToken) async {
    final res = await http.get(
      Uri.parse('$_baseUrl/profile'),
      headers: {
        'Authorization': 'Bearer $idToken',
        'Content-type': 'application/json',
      },
    );

    if (res.statusCode == 200) {
      var data = jsonDecode(res.body);
      if (data is! Map<String, dynamic>) {
        throw Exception("Unexpected data format.");
      }
      return UserProfile.fromJson(data);
    } else {
      throw Exception('Failed to load data');
    }
  }

  //POST http request
  @override
  Future<void> createProfile(String idToken, UserProfile profile) async {
    final res = await http.post(
      Uri.parse('$_baseUrl/profile'),
      headers: {
        'Authorization': 'Bearer $idToken',
        'Content-type': 'application/json',
      },
      body: jsonEncode({
        'firebase_uid': profile.firebase_uid,
        'emailAddress': profile.emailAddress,
        'firstName': profile.firstName,
        'lastName': profile.lastName,
      }),
    );

    if (res.statusCode != 201) {
      throw Exception('Failed to create profile');
    }
  }
}
