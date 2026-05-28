import 'package:flutter/material.dart';
import 'package:frontend_munchies/styles/colours.dart';
import 'package:frontend_munchies/widgets/record_card.dart';

class ActivitiesView extends StatelessWidget {
  const ActivitiesView({super.key});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    double height = size.height;
    double width = size.width;

    bool hasRecords = false;
    return Container(
      alignment: Alignment.center,
      width: width,
      height: height * 0.85 - 92.0,
      color: Colours.lightBeige,
      child: hasRecords ? 
      // ignore: dead_code
      ListView(
        padding: EdgeInsets.only(top: 20.0, left: 12.0, right: 12.0),
        physics: ClampingScrollPhysics(),
        children: [
          RecordCard(date: DateTime.now() , cost: 480, itemName: "Luckin",),
          RecordCard(date: DateTime.now() , cost: 670, itemName: "Acai",),
          RecordCard(date: DateTime.now() , cost: 620, itemName: "Molly Tea",)
        ],
      ) : Text(
        "Nothing yet! \n Start tracking today!",
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: 'Poppins',
          color: Colours.darkBrown.withValues(alpha: 0.43),
        )),
      );
  }
}