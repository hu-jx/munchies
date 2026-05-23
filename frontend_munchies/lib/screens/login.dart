import 'package:flutter/material.dart';
import 'package:frontend_munchies/styles/colours.dart';
import 'package:google_fonts/google_fonts.dart';
// Use GoogleFonts.font_family to obtain desired font (e.g. GoogleFonts.poppins)

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('test', 
        style: GoogleFonts.poppins(color: Colours.greyPink),
        textAlign: TextAlign.center,),
      ],
    );
  }
}
