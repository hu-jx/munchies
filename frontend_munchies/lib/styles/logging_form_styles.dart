import 'package:flutter/material.dart';
import 'package:frontend_munchies/styles/colours.dart';
import 'package:frontend_munchies/styles/textStyles.dart';
import 'package:google_fonts/google_fonts.dart';

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