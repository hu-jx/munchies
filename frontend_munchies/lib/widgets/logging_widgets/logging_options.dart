import 'package:flutter/material.dart';
import 'package:frontend_munchies/screens/viewOptions_Track/scan_picture.dart';
import 'package:frontend_munchies/screens/viewOptions_Track/favourites.dart';
import 'package:frontend_munchies/screens/viewOptions_Track/tracking.dart';
import 'package:frontend_munchies/screens/viewOptions_tabBar/activities.dart';
import 'package:frontend_munchies/styles/colours.dart';

import '../../screens/viewOptions_bottomBar/homePageView.dart';

class LoggingOptions extends StatefulWidget {
  const LoggingOptions({super.key});

  @override
  State<LoggingOptions> createState() => _LoggingOptionsState();
}

class _LoggingOptionsState extends State<LoggingOptions> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: ClampingScrollPhysics(),
      padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
      children: [
        TextButton(
          onPressed: (() {
            Navigator.pop(context); 
            Navigator.push(context, 
            MaterialPageRoute(builder: (context) => TrackingPage()))
            .then((value) => value == true ? ActivitiesView(filter: ActivityFilter.all) : null,);
          }),
          style: ButtonStyle(
            shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.zero)) ,
            foregroundColor: getColor(Colours.lightBeige, Colours.darkBrown),
            backgroundColor: getColor(Color(0xffD0A09F), Colours.greyPink.withValues(alpha: 0.5)),
          ),
          child: Text("Manual Record", style: TextStyle(fontFamily: 'Poppins', fontSize: 18)),
        ),
    
        TextButton(
          onPressed: (() {
            Navigator.push(context, 
            MaterialPageRoute(builder: (context) => FavouritesPage()));
          }),
          style: ButtonStyle(
            shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.zero)) ,
            foregroundColor: getColor(Colours.lightBeige, Colours.darkBrown),
            backgroundColor: getColor(Color(0xffD0A09F), Colours.greyPink.withValues(alpha: 0.5)),
          ),
          child: Text("Fill with favourites", style: TextStyle(fontFamily: 'Poppins', fontSize: 18)),
        ),
    
        TextButton(
          onPressed: (() {
            Navigator.push(context, 
            MaterialPageRoute(builder: (context) => ScanPicture()));
          }),
          style: ButtonStyle(
            shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.zero)),
            foregroundColor: getColor(Colours.lightBeige, Colours.darkBrown),
            backgroundColor: getColor(Color(0xffD0A09F), Colours.greyPink.withValues(alpha: 0.5)),
          ),
          child: Text("Fill with AI", style: TextStyle(fontFamily: 'Poppins', fontSize: 18)),
        )
      ],
    );
  }
  
  WidgetStateProperty<Color> getColor(Color color, Color colorPressed) {
    Color getColor(Set<WidgetState> state) {
      if (state.contains(WidgetState.pressed)) {
        return colorPressed;
      } 
      return color;
    }

    return WidgetStateProperty.resolveWith(getColor);
  }
}