// ignore_for_file: non_constant_identifier_names

import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:frontend_munchies/models/user_profile.dart';
import 'package:frontend_munchies/services/auth/api_services.dart';
import 'package:frontend_munchies/services/auth/auth_exception.dart';
import 'package:http/http.dart' as http;

class UserServices {
  static const String _baseUrl = "http://10.0.2.2:3000/api";
  //static const String _baseUrl = "https://munchies-5dvw.onrender.com/api";

  static Future<UserProfile?> searchUser({
    required String emailAddress,
    required String user_uid,
    required String idToken,
    http.Client? client,
  }) async {
    String url =
        '$_baseUrl/search?search_email=$emailAddress&user_uid=$user_uid';

    final httpClient = client ?? http.Client();

    final res = await httpClient.get(
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
      return UserProfile.fromJson(decoded);
    } else {
      if (res.statusCode == 204) {
        return null;
      }
      debugPrint(res.reasonPhrase);
      throw Exception('Failed to fetch records data');
    }
  }

  static Future<UserProfile> getCurrentUP() async {
    User? usr = FirebaseAuth.instance.currentUser;
    if (usr == null) throw AuthException('No permission to access.');
    String? idToken = await usr.getIdToken();
    if (idToken == null || idToken.isEmpty) {
      throw AuthException('No permission to access. ');
    }
    final authService = AuthServices();

    return await authService.fetchProfileData(idToken);
  }

  static Future<List<UserProfile>> getFriendsList(String idToken, {http.Client? client}) async {
    String url = '$_baseUrl/find_friends';

    final httpClient = client ?? http.Client();

    final res = await httpClient.get(
      Uri.parse(url),
      headers: {
        'Accept': '*/*',
        'Authorization': 'Bearer $idToken',
        'Content-Type': 'application/json',
        'Connection': 'keep-alive',
      },
    );
    if (res.statusCode == 200) {
      final decoded = jsonDecode(res.body);
      final List<UserProfile> friends = [];
      for (final item in decoded) {
        friends.add(UserProfile.fromJson(item as Map<String, dynamic>));
      }
      /*
      final List<UserProfile> friends = decoded
          .map((friend) => UserProfile.fromJson(friend))
          .toList();
          */
      return friends;
    } else {
      debugPrint(res.reasonPhrase);
      throw Exception('Failed to get friends list');
    }
  }

  static Future<UserProfile> findUserInfo(
    String idToken,
    String mongo_user_id,
  ) async {
    String url = '$_baseUrl/find_user_info?mongo_id=$mongo_user_id';

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
      return UserProfile.fromJson(decoded);
    } else {
      debugPrint(res.reasonPhrase);
      throw Exception('Failed to fetch records data');
    }
  }

  static Future<void> removeFriend({
    required String sender_id,
    required String receiver_id,
    required String idToken,
    http.Client? client,
  }) async {
    String url = '$_baseUrl/remove_friend';

    final httpClient = client ?? http.Client();

    final res = await httpClient.delete(
      Uri.parse(url),
      headers: {
        'Accept': '*/*',
        'Authorization': 'Bearer $idToken',
        'Content-Type': '	application/json',
        'Connection': 'keep-alive',
      },
      body: jsonEncode({'sender_id': sender_id, 'receiver_id': receiver_id}),
    );
    if (res.statusCode != 200) {
      throw Exception('Failed to remove friend');
    }
  }
}
