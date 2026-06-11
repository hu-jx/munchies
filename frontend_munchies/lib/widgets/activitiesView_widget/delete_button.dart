import 'package:flutter/material.dart';
import 'package:frontend_munchies/services/records/record_changer.dart';
import 'package:frontend_munchies/styles/colours.dart';
import 'package:provider/provider.dart';

class DeleteButton extends StatelessWidget {
  final String recordId;

  const DeleteButton( {
    super.key,
    required this.recordId
  });


  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () async {
        await Provider.of<RecordChanger>(context, listen: false).deleteRec(recordId);
        if (!context.mounted) {
          return;
        }
        Navigator.of(context).pop();
      },
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
    );
  }
}

