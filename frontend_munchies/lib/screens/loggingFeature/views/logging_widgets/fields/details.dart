import 'package:flutter/material.dart';
import 'package:frontend_munchies/styles/logging_form_styles.dart';
import 'package:frontend_munchies/styles/textStyles.dart';
import 'package:frontend_munchies/screens/loggingFeature/view_models/logging_view_model.dart';

class DetailsField extends StatelessWidget {
  final TextEditingController detailsController;
  final LoggingViewModel lvm;
  const DetailsField({super.key, required this.detailsController, required this.lvm});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      onChanged: (value) {
        // debugPrint(value);
        lvm.setDetails(value);
      } ,
      style: inputTextStyle,
      controller: detailsController,
      decoration: InputDecoration(
        labelText: 'Description',
        labelStyle: backgroundTextStyle,
      ).applyDefaults(optionalInputdecorationtheme),
    );
  }
}