// ignore_for_file: file_names
import 'package:flutter/material.dart';
import 'package:frontend_munchies/screens/activities/domain/repositories/record_repo.dart';
import 'package:frontend_munchies/screens/loggingFeature/views/tracking.dart';
import 'package:frontend_munchies/styles/colours.dart';
import 'package:frontend_munchies/models/record.dart';
import 'package:frontend_munchies/screens/loggingFeature/view_models/logging_view_model.dart';
import 'package:provider/provider.dart';
import 'package:tap_debouncer/tap_debouncer.dart';

class UpdateButton extends StatelessWidget {
  final String recordId;

  const UpdateButton({super.key, required this.recordId});

  @override
  Widget build(BuildContext context) {
    return TapDebouncer(
      onTap: () async {
        Record rec = await Provider.of<RecordRepository>(
          context,
          listen: false,
        ).getRecord(recordId);
        if (!context.mounted) return;
        Navigator.of(context).pop();
        Navigator.push(
          context,
          //tracking page takes in an optional logging form. if logging form exists, use as child, else create new one
          MaterialPageRoute(
            builder: (_) => ChangeNotifierProvider(
              create: (_) => LoggingViewModel(
                recordChanger: context.read<RecordRepository>(),
                record: rec,
              ),
              child: TrackingPage(),
            ),
          ),
        );
      },
      builder: (context, onTap) {
        return TextButton(
          onPressed: onTap,
          child: Row(
            mainAxisAlignment: .spaceBetween,
            children: [
              Icon(Icons.edit, size: 32, color: Colours.greyPink),
              Text(
                'Edit',
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
