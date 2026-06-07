// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
class ShowErrorMessage extends StatelessWidget {
  const ShowErrorMessage({
    super.key,
    required this.errorMessage,
  });

  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    if (errorMessage == null) {
      return Center();
    } else if (errorMessage!.isEmpty) {
      return Center();
    } else {
      return Center(
        child: Text(
          errorMessage!,
          style: GoogleFonts.poppins(color: Colors.red, fontSize: 14.0),
        ),
      );
    }
  }
}