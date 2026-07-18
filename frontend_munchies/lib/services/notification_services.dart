import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;

class NotificationServices {
  // static const String _baseUrl = "http://10.0.2.2:3000/api";
  static const String _baseUrl = "https://munchies-5dvw.onrender.com/api";

  static Future<void> init() async {
    final notificationSettings = await FirebaseMessaging.instance
        .requestPermission(provisional: true);

    final fcmToken = await FirebaseMessaging.instance.getToken();
    print("FCM TOKEN: $fcmToken");

    //added for error
    final idToken = await FirebaseAuth.instance.currentUser?.getIdToken();
    if (idToken != null) {
      await registerToken(idToken: idToken);
      print("FCM Token updated and readded");
    }

    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      print("Token refreshed: $newToken");
      final idToken = await FirebaseAuth.instance.currentUser?.getIdToken();
      if (idToken != null) {
        await registerToken(idToken: idToken);
      } else {
      }
    });

    FirebaseMessaging.onMessage.listen((message) {
      print("Notification received: ${message.notification}");
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      print("Notification clicked");
    });
  }

  static Future<void> registerToken({
    required String idToken,
    http.Client? client,
  }) async {
    String url = '$_baseUrl/add_token';

    final httpClient = client ?? http.Client();

    final fcmToken = await FirebaseMessaging.instance.getToken();
    print("FCM Token is $fcmToken");

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
    if (res.statusCode == 200) {
      print("FCM Token added to the user");
    }
    if (res.statusCode != 200) {
      print("Failed to add FCM token: ${res.statusCode} - ${res.body}");
      throw Exception('Failed to add FCM Token to the user');
    }
  }
}
