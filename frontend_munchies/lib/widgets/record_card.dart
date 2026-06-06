import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:frontend_munchies/screens/tracking.dart';
import 'package:frontend_munchies/styles/colours.dart';

class RecordCard extends StatelessWidget {
  final DateTime date;
  final int cost;
  final String itemName;
  final String? base64Image;

  const RecordCard({
    super.key,
    required this.date,
    required this.cost,
    required this.itemName,
    this.base64Image,
  });

  Image convertBase64(String base64) {
    return Image.memory(base64Decode(base64), width: 100,);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ElevatedButton(
        onPressed: () {},
        onLongPress: () => _onRecordPressed(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colours.darkerBeige,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0),),
          side: BorderSide(color: Colours.darkerBeige)),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              base64Image != null
                  ? Row(children: [convertBase64(base64Image!)])
                  : Row(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    date.toString().split(" ")[0],
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      color: Colours.darkBrown,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    "\$${(cost / 100).toStringAsFixed(2)}",
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      color: Colours.darkBrown,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    "Munched on... ",
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      color: Colours.darkBrown,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    itemName,
                    style: TextStyle(
                      fontFamily: 'Cherry_Bomb_One',
                      color: Colours.darkBrown,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _onRecordPressed(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return SizedBox(
          width: MediaQuery.of(context).size.width,
          child: Padding(
            padding: const EdgeInsets.only(top: 18.0, bottom: 30.0, left:30.0, right: 30.0),
            child: Column(
              mainAxisSize: .min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(Icons.close_rounded, color: Colours.greyPink),
                  onPressed: () => Navigator.pop(context),
                ),
                TextButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => TrackingPage()),
                  ),
                  child: Row(
                    mainAxisAlignment: .spaceBetween,
                    children: [
                      Icon(Icons.edit, size: 32,color: Colours.greyPink,),
                      Text(
                        'Edit',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          color: Colours.darkBrown,
                          fontSize: 22
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => TrackingPage()),
                  ),
                  child: Row(
                    mainAxisAlignment: .spaceBetween,
                    children: [
                      Icon(Icons.delete_rounded, size: 32,color: Colours.greyPink,),
                      Text(
                        'Delete',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          color: Colours.darkBrown,
                          fontSize: 22
                        ),
                      ),
                    ],
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
}
