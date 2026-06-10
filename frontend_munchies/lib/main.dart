import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:frontend_munchies/screens/main_screen.dart';
import 'package:frontend_munchies/screens/login.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:frontend_munchies/services/records/record_changer.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(ChangeNotifierProvider(
    create: (context) => RecordChanger(),
    child: const MainApp()));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: StreamBuilder(stream: FirebaseAuth.instance.authStateChanges(), 
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Homepage();
        }
        return LoginPage();
      }),
    );
  }
}
