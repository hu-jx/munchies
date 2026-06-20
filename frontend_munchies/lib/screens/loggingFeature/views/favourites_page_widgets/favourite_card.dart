import 'package:flutter/material.dart';
import 'package:frontend_munchies/screens/activities/domain/repositories/record_repo.dart';
import 'package:frontend_munchies/screens/loggingFeature/view_models/logging_view_model.dart';
import 'package:frontend_munchies/screens/loggingFeature/views/tracking.dart';
import 'package:frontend_munchies/styles/colours.dart';
import 'package:provider/provider.dart';
import 'package:frontend_munchies/models/record.dart';

class FavCard extends StatelessWidget {
  const FavCard({super.key, required this.textStyle, required this.record});

  final TextStyle textStyle;
  final Record record;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChangeNotifierProvider(
                create: (_) => LoggingViewModel(
                  recordChanger: context.read<RecordRepository>(),
                  record: Record(
                    itemName: record.itemName,
                    date: DateTime.now(),
                    cost: record.cost,
                    category: record.category,
                    isFavourited: true,
                    isVisible: false,
                  ),
                ),
                child: TrackingPage(),
              ),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colours.darkerBeige,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          side: BorderSide(color: Color(0xffA98379)),
          foregroundColor: Color(0xffA98379),
        ),
        child: Padding(
          padding: const EdgeInsets.only(
            top: 12.0,
            right: 5.0,
            left: 5.0,
            bottom: 12.0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(child: Text(record.itemName, style: textStyle)),
              const SizedBox(width: 50),
              Text((record.cost / 100).toStringAsFixed(2), style: textStyle),
            ],
          ),
        ),
      ),
    );
  }
}