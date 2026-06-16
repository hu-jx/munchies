// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:frontend_munchies/styles/colours.dart';
import 'package:frontend_munchies/widgets/activitiesView_widget/record_card_actions.dart';

class RecordCard extends StatelessWidget {
  final DateTime date;
  final int cost;
  final String itemName;
  final String? image_url;
  final String recordId;

  const RecordCard({
    super.key,
    required this.date,
    required this.cost,
    required this.itemName,
    required this.recordId,
    this.image_url,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 15.0,
        right: 15.0,
        top: 8.0,
        bottom: 8.0,
      ),
      child: ElevatedButton(
        onPressed: () {},
        onLongPress: () => _onRecordPressed(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colours.darkerBeige,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          side: BorderSide(color: Colours.darkerBeige),
          foregroundColor: Color(0xffA98379),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              image_url != null
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 200,
                          width: 278,
                          child: Image.network(
                            image_url!,
                            fit: BoxFit.contain,
                            alignment: Alignment.centerLeft,
                          ),
                        ),
                      ],
                    )
                  : Row(),
              image_url != null ? SizedBox(height: 10) : Row(),
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
