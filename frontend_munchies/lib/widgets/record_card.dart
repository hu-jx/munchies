import 'package:flutter/material.dart';
import 'package:frontend_munchies/styles/colours.dart';

class RecordCard extends StatelessWidget {
  final DateTime date;
  final int cost;
  final String itemName;
  final bool _hasPicture = false;

  const RecordCard({
    super.key,
    required this.date,
    required this.cost,
    required this.itemName
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Card(
        color: Colours.darkerBeige,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
            _hasPicture ? Row(children: [Image.asset('assets/images/homepage_background.png', width: 100)],) : Row(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(date.toString().split(" ")[0], style: TextStyle(fontFamily: 'Poppins', color: Colours.darkBrown, fontSize: 16)),
                Text("\$${(cost / 100).toStringAsFixed(2)}", style: TextStyle(fontFamily: 'Poppins', color: Colours.darkBrown, fontSize: 16))
              ],
            )  ,
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text("Munched on... ", style: TextStyle(fontFamily: 'Poppins', color: Colours.darkBrown, fontSize: 16)),
                Text(itemName, style: TextStyle(fontFamily: 'Cherry_Bomb_One', color: Colours.darkBrown, fontSize: 20))
              ],
            ),
          ],),
        )
      ),
    );
  }
}