import 'package:flutter/material.dart';
import 'package:frontend_munchies/styles/colours.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tap_debouncer/tap_debouncer.dart';

class AppButton extends StatefulWidget {
  final String text;
  final Future<void> Function() onPressed;
  final Size size;

  const AppButton({
    super.key,
    required this.text,
    required this.onPressed,
    required this.size,
  });

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  @override
  Widget build(BuildContext context) {
    return TapDebouncer(
      onTap: () async => await widget.onPressed(),
      builder: (BuildContext context, TapDebouncerFunc? onTap) => OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          backgroundColor: Colours.greyPink,
          fixedSize: widget.size,
          side: BorderSide(color: Colours.greyPink),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: Text(
          widget.text,
          style: GoogleFonts.poppins(color: Colors.white, fontSize: 16.0),
        ),
      ),
    );
  }
}
