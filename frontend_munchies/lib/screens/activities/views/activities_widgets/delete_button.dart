import 'package:flutter/material.dart';
import 'package:frontend_munchies/screens/activities/domain/view_models/record_handler.dart';
// import 'package:frontend_munchies/screens/activities/view_models/activities_view_model.dart';
import 'package:frontend_munchies/styles/colours.dart';
import 'package:tap_debouncer/tap_debouncer.dart';

class DeleteButton extends StatelessWidget {
  final String recordId;
  final RecordHandler recordHandler;
  const DeleteButton({super.key, required this.recordId, required this.recordHandler});

  @override
  Widget build(BuildContext context) {
    return TapDebouncer(
      onTap: () async {
        //i need to start loading the moment delete is pressed. 
        Navigator.popUntil(context, (route) {
          return route.settings.name == '/home' || route.isFirst;
        });
        recordHandler.onDeletePressed(recordId);
        if (!context.mounted) {
          return;
        }
        
      },
      builder: (BuildContext context, TapDebouncerFunc? onTap) {
        return TextButton(
          onPressed: onTap,
          child: Row(
            mainAxisAlignment: .spaceBetween,
            children: [
              Icon(Icons.delete_rounded, size: 32, color: Colours.greyPink),
              Text(
                'Delete',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  color: Colours.darkBrown,
                  fontSize: 22,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
