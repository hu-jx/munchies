import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;

class NotificationServices {
  //static const String _baseUrl = "http://localhost:3000/api";
  static const String _baseUrl = "https://munchies-5dvw.onrender.com/api";

  
  static Future<void> init() async {
    final notificationSettings = await FirebaseMessaging.instance
        .requestPermission(provisional: true);

    final idToken = await FirebaseAuth.instance.currentUser?.getIdToken();
    if (idToken != null) {
      await registerToken(idToken: idToken);
    }

    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      final idToken = await FirebaseAuth.instance.currentUser?.getIdToken();
      if (idToken != null) {
        await registerToken(idToken: idToken);
      } else {
      }
    });
  }
  

  static Future<void> registerToken({
    required String idToken,
    http.Client? client,
  }) async {
    String url = '$_baseUrl/add_token';

    final httpClient = client ?? http.Client();

    final fcmToken = await FirebaseMessaging.instance.getToken();

    final res = await httpClient.post(
      Uri.parse(url),
      headers: {
        'Accept': '*/*',
        'Authorization': 'Bearer $idToken',
        'Content-Type': '	application/json',
        'Connection': 'keep-alive',
      },
      body: jsonEncode({'token': fcmToken}),
    );
    if (res.statusCode != 200) {
      throw Exception('Failed to add FCM Token to the user');
    }
  }
}
