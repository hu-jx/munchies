import 'package:flutter/material.dart';
import 'package:frontend_munchies/screens/homepage.dart';
import 'package:frontend_munchies/screens/login.dart';
import 'package:frontend_munchies/screens/register.dart';
// import 'package:google_fonts/google_fonts.dart';


void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      routes: {
        '/': (context)  => const LoginPage(),
        '/home': (context) => const Homepage(), 
        '/register': (context) => const RegisterPage()
      },
    );
  }
}
