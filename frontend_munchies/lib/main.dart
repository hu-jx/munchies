import 'package:flutter/material.dart';
import 'package:frontend_munchies/screens/homepage.dart';
import 'package:frontend_munchies/screens/login.dart';
import 'package:frontend_munchies/screens/register.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
// import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginPage(),
        '/home': (context) => const Homepage(),
        '/register': (context) => RegisterPage(),
      },
    );
  }
}
