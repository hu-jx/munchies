import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend_munchies/styles/colours.dart';
import 'package:frontend_munchies/widgets/activitiesView_widget/record_card_actions.dart';

class RecordCard extends StatelessWidget {
  final DateTime date;
  final int cost;
  final String itemName;
  final String? base64Image;
  final String recordId;

  const RecordCard({
    super.key,
    required this.date,
    required this.cost,
    required this.itemName,
    required this.recordId,
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
          side: BorderSide(color: Colours.darkerBeige),
          foregroundColor: Color(0xffA98379)),
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
                  Flexible(
                    child: Text(
                      itemName,
                      style: TextStyle(
                        fontFamily: 'Cherry_Bomb_One',
                        color: Colours.darkBrown,
                        fontSize: 20,
                      ),
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
        return ShowRecordActions(recordId: recordId);
      },
      backgroundColor: Colours.darkerBeige,
    );
  }
}

