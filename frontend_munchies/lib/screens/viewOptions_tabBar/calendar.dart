import 'package:flutter/material.dart';
import 'package:frontend_munchies/styles/colours.dart';

class CalendarView extends StatelessWidget {
  const CalendarView({super.key});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    double height = size.height;
    double width = size.width;
    
    return Container(
              alignment: Alignment.center,
              width: width,
              height: height * 0.85 - 92.0,
              color: Colours.lightBeige,
              child: Text("Calendar View"),
            );
  }
}