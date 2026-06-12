import 'package:flutter/material.dart';
import 'package:frontend_munchies/styles/colours.dart';
import 'package:frontend_munchies/styles/logging_form_styles.dart';
import 'package:frontend_munchies/styles/textStyles.dart';

class VisibilityToggle extends StatefulWidget {
  final Function sendVisibility;
  final GlobalKey<FormState> formKey;
  final bool? original;

  const VisibilityToggle({
    super.key,
    this.original,
    required this.formKey,
    required this.sendVisibility,
  });

  @override
  State<VisibilityToggle> createState() => _VisibilityToggleState();
}

class _VisibilityToggleState extends State<VisibilityToggle> {
  late TextEditingController _visibilityController;
  @override
  initState() {
    super.initState();
    _visibilityController = TextEditingController(
      text: widget.original != null
          ? (widget.original! ? 'Public' : 'Private')
          : 'Private',
    );
  }

  bool _isVisible = false;
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      readOnly: true,
      style: inputTextStyle,
      controller: _visibilityController,
      onTap: _showVisibilityModal,
      decoration: InputDecoration(
        label: Text('Who can see your record?', style: backgroundTextStyle),
      ).applyDefaults(optionalInputdecorationtheme),
      validator: (value) =>
          ((value == null || value.isEmpty) ? "Field cannot be empty" : null),
    );
  }

  Future<void> _showVisibilityModal() async {
    await showModalBottomSheet(
      backgroundColor: Colours.lightBeige,
      context: context,
      builder: (context) {
        return SizedBox(
          width: MediaQuery.of(context).size.width,
          height: 200,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: Colours.lightBrown,
                ),
                onPressed: () {
                  setState(() {
                    _isVisible = false;
                    _visibilityController.text = 'Private';
                    Navigator.of(context).pop();
                    widget.sendVisibility(_isVisible);
                  });
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.lock_rounded,
                      color: Colours.lightBrown,
                      size: 30,
                    ),
                    SizedBox(width: 20),
                    Text(
                      'Private. \nOnly you can see this record.\nIt will not show up on feed',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        color: Colours.darkBrown,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: Colours.lightBrown,
                ),
                onPressed: () {
                  setState(() {
                    _isVisible = true;
                    _visibilityController.text = 'Public';
                    Navigator.of(context).pop();
                    widget.sendVisibility(_isVisible);
                  });
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.people_rounded,
                      color: Colours.lightBrown,
                      size: 30,
                    ),
                    SizedBox(width: 20),
                    Text(
                      "Public. The record will \nshow up on your friends' feeds.",
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        color: Colours.darkBrown,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
