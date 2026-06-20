// ignore_for_file: non_constant_identifier_names

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:frontend_munchies/models/friend_request.dart';
import 'package:http/http.dart' as http;

class RequestServices {
  static const String _baseUrl = "http://10.0.2.2:3000/api";
  //static const String _baseUrl = "https://munchies-5dvw.onrender.com/api";

  //RETURNED null in this function
  static Future<String> checkStatus(
    String sender_id,
    String receiver_id,
    String idToken,
  ) async {
    String url =
        '$_baseUrl/check_status?sender_id=$sender_id&receiver_id=$receiver_id';

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
      final status = jsonDecode(res.body);
      return status["message"];
    } else {
      if (res.statusCode == 204) {
        return "";
      }
      debugPrint(res.reasonPhrase);
      throw Exception('Failed to fetch user profile data');
    }
  }

  //calls sendRequest API
  static Future<void> sendRequest(
    String sender_id,
    String receiver_id,
    String idToken,
  ) async {
    String url = '$_baseUrl/send_req';

    final res = await http.post(
      Uri.parse(url),
      headers: {
        'Accept': '*/*',
        'Authorization': 'Bearer $idToken',
        'Content-Type': '	application/json',
        'Connection': 'keep-alive',
      },
      body: jsonEncode({'sender_id': sender_id, 'receiver_id': receiver_id}),
    );
    if (res.statusCode != 201) {
      throw Exception('Failed to send request');
    }
  }

  //calls getPendingRequests API
  static Future<List<FriendRequest>> getPendingRequests(String idToken) async {
    String url = '$_baseUrl/get_pending_req';

    final res = await http.get(
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
      final List<FriendRequest> pendingReq = [];
      for (final item in decoded) {
        pendingReq.add(FriendRequest.fromJson(item as Map<String, dynamic>));
      }
      return pendingReq;
    } else {
      debugPrint(res.reasonPhrase);
      throw Exception('Failed to get friends list');
    }
  }

  //calls updateRequest API
  static Future<void> updateRequest(
    String sender_id,
    String receiver_id,
    String response,
    String idToken,
  ) async {
    String url = '$_baseUrl/update_req?sender_id=$sender_id&receiver_id=$receiver_id&response=$response';

    final res = await http.patch(
      Uri.parse(url),
      headers: {
        'Accept': '*/*',
        'Authorization': 'Bearer $idToken',
        'Content-Type': '	application/json',
        'Connection': 'keep-alive',
      },
    );
    if (res.statusCode != 201) {
      throw Exception('Failed to update request');
    }
  }
}
