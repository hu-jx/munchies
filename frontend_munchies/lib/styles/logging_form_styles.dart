import 'package:flutter/material.dart';
import 'package:frontend_munchies/styles/colours.dart';
import 'package:google_fonts/google_fonts.dart';

final inputTextStyle = TextStyle(
    fontFamily: 'Poppins',
    color: Colours.darkBrown,
  );
  
final backgroundTextStyle = TextStyle(
    fontFamily: 'Poppins',
    color: Colours.darkBrown.withValues(alpha: 0.45),
  );

InputDecoration basicBoxDeco(String labelText) {
    return InputDecoration(
      filled: true,
      fillColor: Colours.lightBeige,
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colours.greyPink),
        borderRadius: BorderRadius.all(Radius.circular(5)),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colours.greyPink),
        borderRadius: BorderRadius.all(Radius.circular(5)),
      ),
      labelText: labelText,
      labelStyle: backgroundTextStyle,
      errorStyle: GoogleFonts.poppins(color: Colors.red),
    );
  }

  var optionalInputdecorationtheme = InputDecorationTheme(
      filled: true,
      fillColor: Colours.lightBeige,
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.brown.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.all(Radius.circular(5)),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.brown.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.all(Radius.circular(5)),
      ),
    );