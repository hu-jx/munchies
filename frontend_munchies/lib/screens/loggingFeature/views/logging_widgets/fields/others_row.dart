import 'package:flutter/material.dart';
import 'package:frontend_munchies/styles/colours.dart';

class OthersRow extends StatelessWidget {
  const OthersRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 17.0, bottom: 0.0),
          child: Text(
            "OTHERS",
            style: TextStyle(
              fontFamily: 'Cherry_Bomb_One',
              color: Colours.darkBrown,
              fontSize: 26,
            ),
          ),
        ),
      ],
    );
  }
}