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
  String? _imageField;
  String _errorMessage = '';
  bool _isLoading = false;
  bool _hasBanner = true;
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
                spacing: 15,
                children: [
                  if (_hasBanner)
                    Padding(
                      padding: const EdgeInsets.all(10.0),
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
                              fontSize: 18,
                              color: Colours.darkBrown,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ImageSelectionButton(
                    boxSize: Size(width * 0.95, height * 0.55),
                    sendBack64: (base64) {
                      setState(() {
                        _imageField = base64;
                      });
                    },
                  ),
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
                      : Row(),
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
      var itemName = await RecordServices.scanPicture(idToken, _imageField!);
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
            children: [CircularProgressIndicator(color: Colours.greyPink,backgroundColor: Colours.lightBeige,)],
          ),
        ),
        barrierDismissible: false
      );
    }
    String? itemname = await _scanPicture(_imageField ?? '');
    if (!mounted) return;
    setState(() {
      _isLoading = false;
    });
     //closing the loading screen dialog and so that when press back go back to home not scan again 
    Navigator.of(context)..pop()..pop();
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
              photo: _imageField,
              isVisible: false
            ),
          ),
        ),
      ),
    );
  }
}
