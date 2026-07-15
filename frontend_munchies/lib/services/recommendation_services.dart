import 'dart:convert';
// import 'package:flutter/foundation.dart';
// import 'package:frontend_munchies/models/friend_request.dart';
import 'package:http/http.dart' as http;

class RecommendationServices {
  // static const String _baseUrl = "http://10.0.2.2:3000/api";
  static const String _baseUrl = "https://munchies-5dvw.onrender.com/api";

  //RETURNED null in this function
  static Future<Map<String, dynamic>> getRecommendation({
    required String idToken,
    http.Client? client,
  }) async {
    String url =
        '$_baseUrl/recommendations';

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
      return decoded as Map<String, dynamic>;
    } else {
      //Gemini server error, view handles display of this error
      return {'error': true};
    }
  }
}
