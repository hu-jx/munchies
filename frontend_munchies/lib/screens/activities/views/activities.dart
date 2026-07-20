import 'package:flutter/material.dart';
import 'package:frontend_munchies/models/filters.dart';
import 'package:frontend_munchies/screens/activities/domain/repositories/record_repo.dart';
import 'package:frontend_munchies/screens/activities/domain/view_models/record_handler.dart';
import 'package:frontend_munchies/screens/activities/view_models/activities_view_model.dart';
import 'package:frontend_munchies/styles/colours.dart';
import 'package:frontend_munchies/widgets/errorMessage.dart';
import 'package:frontend_munchies/screens/activities/views/activities_widgets/record_card.dart';
import 'package:provider/provider.dart';

class ActivitiesPage extends StatelessWidget {
  final ActivityFilter filter;
  const ActivitiesPage({super.key, required this.filter});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ActivitiesViewModel>(
      create: (context) => ActivitiesViewModel(
        recordRepo: context.read<RecordRepository>(),
        filter: filter,
      ),
      child: const ActivitiesView(),
    );
  }
}

class ActivitiesView extends StatelessWidget {
  const ActivitiesView({super.key});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    double height = size.height;
    double width = size.width;
    final ActivitiesViewModel avm = context.watch<ActivitiesViewModel>();
    return (avm.errorMessage != null)
        ? Container(
            alignment: Alignment.center,
            width: width,
            height: height * 0.8,
            color: Colours.lightBeige,
            child: ShowErrorMessage(errorMessage: avm.errorMessage),
          )
        : Container(
            alignment:
                (avm.loadingStatus == true ||
                    avm.errorMessage != null ||
                    avm.recordDetails.isEmpty)
                ? Alignment.center
                : Alignment.topCenter,
            width: width,
            height: height * 0.80,
            color: Colours.lightBeige,
            child: avm.loadingStatus == true
                ? CircularProgressIndicator(
                    color: const Color.fromARGB(255, 183, 115, 125),
                  )
                : (avm.recordDetails.isNotEmpty
                      ? ScrollConfiguration( 
                          behavior: ScrollBehavior().copyWith(
                            overscroll: false,
                          ),
                          child: SingleChildScrollView(
                            physics: ClampingScrollPhysics(),
                            child: Column(
                              children: avm.recordDetails.map((rec) {
                                return ChangeNotifierProvider<RecordHandler>.value(
                                  value: avm,
                                  builder: (context, child) {
                                    return RecordCard(
                                      recordId: rec.record_id!,
                                      itemName: rec.itemName,
                                      date: rec.date,
                                      cost: rec.cost,
                                      //CHANGE THIS INTO URL
                                      image_url: rec.photo_URL,
                                      
                                    );
                                  }
                                );
                              }).toList(),
                            ),
                          ),
                        )
                      : Text(
                        // "${avm.recordDetails.length}",
                          "Nothing yet! \n Start tracking today!",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            color: Colours.darkBrown.withValues(alpha: 0.43),
                          ),
                        )),
          );
  }
}
