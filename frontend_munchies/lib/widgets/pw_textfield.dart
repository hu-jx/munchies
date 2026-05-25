import 'package:flutter/material.dart';
import 'package:frontend_munchies/styles/colours.dart';
import 'package:google_fonts/google_fonts.dart';

class PasswordTextfield extends StatefulWidget {
  final TextEditingController pwController;
  final String labelText;

  const PasswordTextfield({
    super.key,
    required this.pwController,
    required this.labelText,
  });

  @override
  State<StatefulWidget> createState() => _PasswordTextfield();
}

class _PasswordTextfield extends State<PasswordTextfield> {
  String password = '';
  bool isPwVisible = false;
  bool keepLoggedIn = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 22),
      child: TextField(
        controller: widget.pwController,
        onChanged: (value) => setState(() => password = value),
        onSubmitted: (value) => setState(() => password = value),
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 5),
          filled: true,
          fillColor: Colors.white,
          labelText: widget.labelText,
          labelStyle: GoogleFonts.poppins(color: Colours.grey),
          //errorText: 'Password is wrong',
          suffixIcon: IconButton(
            icon: isPwVisible
                ? Icon(Icons.visibility_off)
                : Icon(Icons.visibility),
            onPressed: () => setState(() => isPwVisible = !isPwVisible),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colours.grey),
          ),
        ),
        obscureText: isPwVisible,
        style: GoogleFonts.poppins(),
      ),
    );
  }
}
