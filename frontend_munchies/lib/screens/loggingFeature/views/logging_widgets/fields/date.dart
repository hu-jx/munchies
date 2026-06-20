import 'package:flutter/material.dart';
import 'package:frontend_munchies/styles/logging_form_styles.dart';
import 'package:frontend_munchies/styles/textStyles.dart';
import 'package:google_fonts/google_fonts.dart';

class DateField extends StatelessWidget {
  final DateTime? originalDate;
  final TextEditingController dateController;
  final Function(DateTime date) sendBackDate;
  const DateField({
    super.key,
    required this.dateController,
    required this.sendBackDate,
    required this.originalDate
  });

  static String? formatDate(DateTime? date) {
    if (date == null) return null;
    String month = date.month >= 10 ? "${date.month}" : "0${date.month}";
    String day = date.day >= 10 ? "${date.day}" : "0${date.day}";
    return "${date.year}-$month-$day";
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Date           ',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w500,
            fontSize: 16,
            color: Color(0xff795A52),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: TextFormField(
            controller: dateController,
            style: inputTextStyle,
            readOnly: true,
            onTap: () => _selectDate(context),
            decoration: basicBoxDeco('Click to enter date!'),
            validator: (value) => ((value == null || value.isEmpty)
                ? "Field cannot be empty"
                : null),
          ),
        ),
      ],
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      initialDate: originalDate ?? DateTime.now(),
    );
    if (date != null) {
      sendBackDate.call(date);
    }
  }
}
