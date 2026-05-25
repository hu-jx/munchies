import 'package:flutter/material.dart';
import 'package:frontend_munchies/styles/colours.dart';
import 'package:google_fonts/google_fonts.dart';

class GeneralTextfield extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;

  const GeneralTextfield({
    super.key,
    required this.controller,
    required this.labelText,
  });

  @override
  State<StatefulWidget> createState() => _GeneralTextfield();
}

class _GeneralTextfield extends State<GeneralTextfield> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 22),
      child: TextField(
        controller: widget.controller,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 5),
          filled: true,
          fillColor: Colors.white,
          labelText: widget.labelText,
          labelStyle: GoogleFonts.poppins(color: Colours.grey),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colours.grey),
          ),
          suffixIcon: widget.controller.text.isEmpty
              ? Container(width: 0.0)
              : IconButton(
                  onPressed: () => widget.controller.clear(),
                  icon: Icon(Icons.close),
                ),
        ),
        style: GoogleFonts.poppins(),
      ),
    );
    /*
    return SizedBox(
      height: 48.0,
      width: 298.0,
      child: TextField(
        controller: widget.controller,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          labelText: widget.labelText,
          labelStyle: GoogleFonts.poppins(color: Colours.grey),
          enabledBorder: OutlineInputBorder(
            borderSide:BorderSide(color: Colours.grey)
          ),
          suffixIcon: widget.controller.text.isEmpty
              ? Container(width: 0.0)
              : IconButton(
                  onPressed: () => widget.controller.clear(),
                  icon: Icon(Icons.close),
                ),
        ),
        style: GoogleFonts.poppins(),
        keyboardType: TextInputType.emailAddress,
      ),
    );
    */
  }
}
