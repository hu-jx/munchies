import 'package:flutter/material.dart';
import 'package:frontend_munchies/styles/logging_form_styles.dart';
import 'package:frontend_munchies/styles/textStyles.dart';

class DetailsField extends StatelessWidget {
  final TextEditingController detailsController;
  const DetailsField({super.key, required this.detailsController});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      style: inputTextStyle,
      controller: detailsController,
      decoration: InputDecoration(
        labelText: 'Description',
        labelStyle: backgroundTextStyle,
      ).applyDefaults(optionalInputdecorationtheme),
    );
  }
}