import 'package:flutter/material.dart';
import 'package:frontend_munchies/styles/logging_form_styles.dart';
import 'package:frontend_munchies/styles/textStyles.dart';
import 'package:google_fonts/google_fonts.dart';

class CostField extends StatelessWidget {
  final TextEditingController costController;
  const CostField({super.key, required this.costController});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Cost           ',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w500,
            fontSize: 16,
            color: Color(0xff795A52),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: TextFormField(
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            controller: costController,
            style: inputTextStyle,
            decoration: basicBoxDeco('How much did you spend?').copyWith(prefixText: '\$', prefixStyle: inputTextStyle),
            validator: (value) => ((value == null || value.isEmpty)
                ? "Field cannot be empty"
                : null),
          ),
        ),
      ],
    );
  }
}