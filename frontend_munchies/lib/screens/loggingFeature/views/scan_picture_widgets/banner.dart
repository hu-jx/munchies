import 'package:flutter/material.dart';
import 'package:frontend_munchies/styles/colours.dart';
import 'package:frontend_munchies/styles/textStyles.dart';

class BasicBanner extends StatelessWidget {
  final String label;
  final Function() onPressed;
  final Icon leadingIcon;
  final EdgeInsets padding;
  const BasicBanner({
    super.key,
    required this.label,
    required this.onPressed,
    required this.leadingIcon,
    required this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: MaterialBanner(
        dividerColor: const Color.fromARGB(255, 210, 200, 188),
        elevation: 4.0,
        leading: leadingIcon,
        backgroundColor: Colours.darkerBeige,
        content: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            label,
            style: importantTextStyle,
            textAlign: TextAlign.center,
          ),
        ),
        actions: [
          TextButton(
            onPressed: onPressed,
            child: Text('DISMISS', style: inputTextStyle),
          ),
        ],
      ),
    );
  }
}
