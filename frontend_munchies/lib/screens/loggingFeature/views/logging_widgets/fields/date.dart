import 'package:flutter/material.dart';
import 'package:frontend_munchies/styles/logging_form_styles.dart';
import 'package:frontend_munchies/styles/textStyles.dart';
import 'package:google_fonts/google_fonts.dart';

class DateField extends StatefulWidget {
  final TextEditingController dateController;
  final Function(DateTime date) sendBackDate;
  const DateField({
    super.key,
    required this.dateController,
    required this.sendBackDate,
  });

  static String? formatDate(DateTime? date) {
    if (date == null) return null;
    String month = date.month >= 10 ? "${date.month}" : "0${date.month}";
    String day = date.day >= 10 ? "${date.day}" : "0${date.day}";
    return "${date.year}-$month-$day";
  }

  @override
  State<DateField> createState() => _DateFieldState();
}

class _DateFieldState extends State<DateField> {
  DateTime? _selectedDate;
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
            controller: widget.dateController,
            style: inputTextStyle,
            readOnly: true,
            onTap: () => _selectDate(),
            decoration: basicBoxDeco('Click to enter date!'),
            validator: (value) => ((value == null || value.isEmpty)
                ? "Field cannot be empty"
                : null),
          ),
        ),
      ],
    );
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      initialDate: _selectedDate ?? DateTime.now(),
    );
    if (date != null) {
      widget.sendBackDate.call(date);
    }
  }
}
