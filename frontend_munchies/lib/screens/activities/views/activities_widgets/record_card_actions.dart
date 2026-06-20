import 'package:flutter/material.dart';
import 'package:frontend_munchies/screens/activities/domain/view_models/record_handler.dart';
import 'package:frontend_munchies/styles/colours.dart';
import 'package:frontend_munchies/screens/activities/views/activities_widgets/delete_button.dart';
import 'package:frontend_munchies/screens/activities/views/activities_widgets/updateButton.dart';
import 'package:provider/provider.dart';
class ShowRecordActions extends StatelessWidget {
  const ShowRecordActions({
    super.key,
    required this.recordId,
  });

  final String recordId;

  @override
  Widget build(BuildContext context) {
    final RecordHandler avm = context.watch<RecordHandler>();
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
            UpdateButton(recordId: recordId,),
            DeleteButton(recordId: recordId, recordHandler: avm,),
          ],
        ),
      ),
    );
  }
}