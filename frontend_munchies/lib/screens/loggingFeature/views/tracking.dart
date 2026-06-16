//this is the default tracking page
import 'package:flutter/material.dart';
import 'package:frontend_munchies/styles/colours.dart';
import 'package:frontend_munchies/screens/loggingFeature/views/logging_widgets/logging_form.dart';

class TrackingPage extends StatefulWidget {
  final LoggingForm? loggingForm;

  const TrackingPage({super.key, this.loggingForm});

  @override
  State<TrackingPage> createState() => _TrackingPageState();
}

class _TrackingPageState extends State<TrackingPage> {
  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;

    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
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
              'RECORD',
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
          color: Colours.lightBeige,
          height: height * 0.9,
          child: widget.loggingForm ?? LoggingForm(),
        ),
      ),
    );
  }
}
