import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:frontend_munchies/screens/viewOptions_Track/tracking.dart';
import 'package:frontend_munchies/services/auth/auth_exception.dart';
import 'package:frontend_munchies/services/records/record_services.dart';
import 'package:frontend_munchies/styles/colours.dart';
import 'package:frontend_munchies/styles/textStyles.dart';
import 'package:frontend_munchies/widgets/errorMessage.dart';
import 'package:frontend_munchies/widgets/image_widgets.dart/image_selection_button.dart';
import 'package:frontend_munchies/widgets/logging_widgets/logging_form.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frontend_munchies/models/record.dart';

class ScanPicture extends StatefulWidget {
  const ScanPicture({super.key});

  @override
  State<ScanPicture> createState() => _ScanPictureState();
}

class _ScanPictureState extends State<ScanPicture> {
  File? _imageField;
  String _errorMessage = '';
  bool _isLoading = false;
  bool _hasBanner = true;
  bool _hasImageTypeBanner = true;
  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/homepage_background.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          iconTheme: IconThemeData(
            color: Colours.greyPink, //change your color here
          ),
          backgroundColor: Color(0xff696969).withValues(alpha: 0.1),
          title: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'SCAN ITEM',
              style: TextStyle(
                fontFamily: 'Cherry_Bomb_One',
                fontSize: 36,
                color: Colours.greyPink,
              ),
            ),
          ),
          toolbarHeight: height * 0.10,
          titleSpacing: 18.0,
        ),
        body: Container(
          width: width,
          height: height,
          color: Colours.lightBeige,
          child: ScrollConfiguration(
            behavior: ScrollBehavior().copyWith(overscroll: false),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  if (_hasBanner)
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0, left: 8.0, right: 8.0),
                      child: MaterialBanner(
                        dividerColor: const Color.fromARGB(255, 210, 200, 188),
                        elevation: 4.0,
                        leading: Icon(
                          Icons.info_rounded,
                          color: Colors.red[400],
                          size: 30,
                        ),
                        backgroundColor: Colours.darkerBeige,
                        content: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'This feature is powered by Gemini.  Do not upload sensitive pictures.',
                            style: importantTextStyle,
                            textAlign: TextAlign.center,
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _hasBanner = false;
                              });
                            },
                            child: Text('DISMISS', style: inputTextStyle),
                          ),
                        ],
                      ),
                    ),
                    if (_hasImageTypeBanner) 
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 2.0),
                      child: MaterialBanner(
                        dividerColor: const Color.fromARGB(255, 210, 200, 188),
                        elevation: 4.0,
                        leading: Icon(
                          Icons.photo,
                          color: Colours.greyPink,
                          size: 30,
                        ),
                        backgroundColor: Colours.darkerBeige,
                        content: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'Supported image files:\n .png, .jpeg, .webp',
                            style: importantTextStyle,
                            textAlign: TextAlign.center,
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _hasImageTypeBanner = false;
                              });
                            },
                            child: Text('DISMISS', style: inputTextStyle),
                          ),
                        ],
                      ),
                    ) 
                    else
                    Padding(
                      padding: const EdgeInsets.only(left: 20.0, top: 20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text( 
                            'Preview your image: ',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 16,
                              color: Colours.darkBrown,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 15,),
                  ImageSelectionButton(
                    boxSize: Size(width * 0.95, height * 0.55),
                    //TODO: CHANGE TO SENDBACKFILE. WHEN WE PREPARE TO SCAN, WE WILL CONVERT TO BASE64
                    sendBackPhotoFile: (photo_file) {
                      setState(() {
                        _imageField = photo_file;
                      });
                      // debugPrint(_imageField.toString());
                    },
                  ),
                  SizedBox(height: 20,),
                  TextButton(
                    onPressed: () => _onScanButtonPressed(),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colours.greyPink,
                      fixedSize: Size(width * 0.75, 53),
                      side: BorderSide(color: Colours.greyPink),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      'Scan',
                      style: GoogleFonts.poppins(color: Colours.lightBeige),
                    ),
                  ),
                  _errorMessage.isNotEmpty
                      ? Padding(
                          padding: const EdgeInsets.only(
                            left: 40.0,
                            right: 40.0,
                          ),
                          child: ShowErrorMessage(errorMessage: _errorMessage),
                        )
                      : SizedBox(height: 50,),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<String?> _scanPicture(String base64) async {
    try {
      User? usr = FirebaseAuth.instance.currentUser;
      if (usr == null) throw AuthException('Access Denied');
      String? idToken = await usr.getIdToken(true);
      if (idToken == null) throw AuthException('Access Denied');
      var itemName = await RecordServices.scanPicture(idToken, base64);
      if (itemName == null) {
        throw Exception('Could not proceed. Please try again later.');
      }
      return itemName;
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    }
    return null;
  }

  void _onScanButtonPressed() async {
    if (_imageField == null) {
      setState(() {
        _errorMessage =
            'No image present for scanning. Add a photo and try again.';
      });
      return;
    }
    setState(() {
      _isLoading = true;
    });
    if (_isLoading) {
      showDialog(
        context: context,
        builder: (context) => Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                color: Colours.greyPink,
                backgroundColor: Colours.lightBeige,
              ),
            ],
          ),
        ),
        barrierDismissible: false,
      );
    }
    String base64 = base64Encode(_imageField!.readAsBytesSync());
    String? itemname = await _scanPicture(base64);
    itemname = itemname?.trim();
    if (!mounted) return;
    if (itemname == null || itemname == "No food detected") {
        Navigator.of(context).pop();
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              content: Text(
                'No food was detected in the image.\n Either try again or record manually',
              ),
            );
          },
        );
        return;
      }
    if (!mounted) return;
    setState(() {
      _isLoading = false;
    });
    // debugPrint("POST SCAN ${_imageField.toString()}");
    //closing the loading screen dialog and so that when press back go back to home not scan again
    Navigator.of(context)
      ..pop()
      ..pop();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TrackingPage(
          loggingForm: LoggingForm(
            record: Record(
              itemName: itemname ?? 'null',
              date: DateTime.now(),
              cost: 0,
              isFavourited: false,
              //FIXME: THIS WILL BE A PHOTO_FILE SENT TO THE LOGGING FORM. 
              photo_file: _imageField,
              isVisible: false,
            ),
          ),
        ),
      ),
    );
  }
}
