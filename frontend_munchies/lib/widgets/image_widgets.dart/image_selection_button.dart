// ignore_for_file: non_constant_identifier_names

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:frontend_munchies/styles/colours.dart';
import 'package:frontend_munchies/styles/textStyles.dart';
import 'package:image_picker/image_picker.dart';

class ImageSelectionButton extends StatefulWidget {
  const ImageSelectionButton({
    super.key,
    required this.sendBack64,
    required this.boxSize,
    this.existing_base64
  });

  final Function(String? base64) sendBack64;
  final String? existing_base64;
  final Size boxSize;

  @override
  State<ImageSelectionButton> createState() => _ImageSelectionButtonState();
}

class _ImageSelectionButtonState extends State<ImageSelectionButton> {
  Image? image;
  void checkIfUpdate(double width, double height) {
    if (widget.existing_base64 != null) {
    setState(() {
      base64_image = widget.existing_base64;
      image = Image.memory(base64Decode(widget.existing_base64!), fit: BoxFit.contain);
    });
  }
}
  
  String? base64_image;

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    checkIfUpdate(width, height);

      return ElevatedButton(
        onPressed: () {
          _onImagePickerPressed(context);
        } ,
        style: ButtonStyle(
          backgroundColor: WidgetStatePropertyAll(Colours.lightBeige),
          fixedSize: WidgetStatePropertyAll(
            widget.boxSize,
          ),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(color: Colors.brown.withValues(alpha: 0.5)),
            ),
          ),
          elevation: WidgetStatePropertyAll(0.0),
        ),
        clipBehavior: Clip.antiAlias,
        child: (base64_image == null) ?
           Text(
          "Add a photo!",
          textAlign: TextAlign.center,
          style: backgroundTextStyle,)
        : Padding(
          padding: EdgeInsetsGeometry.all(8.0),
          child: image,
      ));
  }

  Future<void> _onImagePickerPressed(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return SizedBox(
          width: MediaQuery.of(context).size.width,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: .min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(Icons.close_rounded, color: Colours.greyPink),
                  onPressed: () => Navigator.pop(context),
                ),
                TextButton(
                  onPressed: () => _pickImage(ImageSource.camera),
                  child: Text(
                    'Pick from camera',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      color: Colours.darkBrown,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => _pickImage(ImageSource.gallery),
                  child: Text(
                    'Pick from gallery',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      color: Colours.darkBrown,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
      backgroundColor: Colours.darkerBeige,
    );
  }

  //image picker goes here
  Future<void> _pickImage(ImageSource source) async {
    final imagePicker = ImagePicker();
    XFile? selected = await imagePicker.pickImage(source: source);
    if (selected == null) return;
    Uint8List imageBytes = await (File(selected.path)).readAsBytes();
    String base64 = base64Encode(imageBytes);
    if (mounted) {
      setState(() {
      image = Image.file(File(selected.path), fit: BoxFit.contain);
      base64_image = base64;
    });
    }
    widget.sendBack64.call(base64);
  }
}
