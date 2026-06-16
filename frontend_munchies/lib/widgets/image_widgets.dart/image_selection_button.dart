// ignore_for_file: non_constant_identifier_names

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:frontend_munchies/styles/colours.dart';
import 'package:frontend_munchies/styles/textStyles.dart';
import 'package:image_picker/image_picker.dart';

class ImageSelectionButton extends StatefulWidget {
  const ImageSelectionButton({
    super.key,
    required this.sendBackPhotoFile,
    required this.boxSize,
    this.existing_url,
    this.existing_photo_file
  });

  final Function(File? photo_file) sendBackPhotoFile;
  final String? existing_url;
  final Size boxSize;
  final File? existing_photo_file;

  @override
  State<ImageSelectionButton> createState() => _ImageSelectionButtonState();
}

class _ImageSelectionButtonState extends State<ImageSelectionButton> {
  Image? image;
  void checkIfUpdate() {
    // debugPrint(widget.existing_photo_file.toString());
    if (widget.existing_url != null) {
    setState(() {
      image = Image.network(widget.existing_url!, fit: BoxFit.contain);
    });
  }
  if (widget.existing_photo_file != null) {
    setState(() {
      image = Image.file(widget.existing_photo_file!);
    });
  }
}

@override
  void initState() {
    super.initState();
    // if (widget.existing_photo_file != null) {
    //     widget.sendBackPhotoFile.call(widget.existing_photo_file);
    }
  

  @override
  Widget build(BuildContext context) {
    checkIfUpdate();
    
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
        child: (image == null) ?
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
    if (mounted) {
      setState(() {
      image = Image.file(File(selected.path), fit: BoxFit.contain);
    });
    }

    //TODO: SEND BACK THE FILE TO LOGGING FORM
    widget.sendBackPhotoFile.call(File(selected.path));
  }
}
