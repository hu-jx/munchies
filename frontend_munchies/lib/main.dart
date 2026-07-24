import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:frontend_munchies/screens/activities/domain/repositories/record_repo.dart';
import 'package:frontend_munchies/screens/main_screen.dart';
import 'package:frontend_munchies/screens/authentication/view/login.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:frontend_munchies/screens/activities/data/repositories/record_changer.dart';
import 'package:frontend_munchies/screens/authentication/view_model/authentication.dart';
import 'package:frontend_munchies/services/notification_services.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  if (kIsWeb) {}
  else if (Platform.isAndroid) {
    await initializeNotif();
  }
  runApp(
    Provider<RecordRepository>(
      create: (context) => RecordRepoImpl(),
      child: const MainApp(),
    ),
  );
}
Future<void> initializeNotif() async {
  
  FirebaseMessaging.onBackgroundMessage(backgroundHandler);

  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'This channel is used for important notifications.',
    importance: Importance.high,
  );

  await NotificationServices.init();

  await FlutterLocalNotificationsPlugin()
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >()
      ?.createNotificationChannel(channel);
}

@pragma('vm:entry-point')
Future<void> backgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Homepage();
            // return Homepage();
          }
          return LoginPage(authentication: Authentication.real());
        },
      ),
      routes: {'/home': (context) => const Homepage()},
    );
  }
}
