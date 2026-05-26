import 'package:flutter/material.dart';
import 'package:frontend_munchies/styles/colours.dart';

class ActivitiesView extends StatelessWidget {
  const ActivitiesView({super.key});

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
              child: Text("Nothing yet! \n Start tracking today!", 
              textAlign: TextAlign.center,
              style: TextStyle(fontFamily: 'Poppins', color: Colours.darkBrown.withValues(alpha: 0.43))),
            );
  }
}