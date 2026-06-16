import 'package:flutter/material.dart';
import 'package:frontend_munchies/styles/colours.dart';
import 'package:frontend_munchies/styles/logging_form_styles.dart';
import 'package:frontend_munchies/styles/textStyles.dart';
import 'package:frontend_munchies/screens/loggingFeature/view_models/logging_view_model.dart';

class ItemName extends StatelessWidget {
  final TextEditingController itemNameController;
  final LoggingViewModel lvm;
  const ItemName({super.key, required this.itemNameController, required this.lvm});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          "munched",
          style: TextStyle(
            fontFamily: 'Cherry_Bomb_One',
            fontSize: 24,
            color: Colours.greyPink,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: TextFormField(
            onChanged: (value) => lvm.setItemName(value),
            controller: itemNameController,
            style: inputTextStyle,
            decoration: basicBoxDeco('What did you have?'),
            validator: (value) => ((value == null || value.isEmpty)
                ? "Field cannot be empty"
                : null),
          ),
        ),
      ],
    );
  }
}