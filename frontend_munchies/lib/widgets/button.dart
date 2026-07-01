import 'package:flutter/material.dart';
import 'package:frontend_munchies/styles/colours.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tap_debouncer/tap_debouncer.dart';

class AppButton extends StatefulWidget {
  final String text;
  final Future<void> Function() onPressed;
  final Size size;
  final Color? color;
  final TextStyle? textStyle;

  const AppButton({
    super.key,
    required this.text,
    required this.onPressed,
    required this.size,
    this.color,
    this.textStyle,
  });

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  @override
  Widget build(BuildContext context) {
    return TapDebouncer(
      onTap: widget.onPressed,
      builder: (BuildContext context, TapDebouncerFunc? onTap) => OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          backgroundColor: widget.color ?? Colours.greyPink,
          fixedSize: widget.size,
          side: BorderSide(color: widget.color != null ? Colors.transparent : Colours.greyPink),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: Text(
          widget.text,
          style: widget.textStyle ?? GoogleFonts.poppins(color: Colors.white, fontSize: 16.0),
        ),
      ),
    );
  }
}
