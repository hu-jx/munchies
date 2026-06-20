
import 'package:flutter/material.dart';
import 'package:frontend_munchies/screens/activities/domain/repositories/record_repo.dart';
import 'package:frontend_munchies/screens/loggingFeature/view_models/scan_view_model.dart';
import 'package:frontend_munchies/screens/loggingFeature/views/scan_picture_widgets/banner.dart';
import 'package:frontend_munchies/screens/loggingFeature/views/tracking.dart';
import 'package:frontend_munchies/styles/colours.dart';
import 'package:frontend_munchies/styles/textStyles.dart';
import 'package:frontend_munchies/widgets/button.dart';
import 'package:frontend_munchies/widgets/errorMessage.dart';
import 'package:frontend_munchies/screens/loggingFeature/views/logging_widgets/image_widgets.dart/image_selection_button.dart';
import 'package:frontend_munchies/screens/loggingFeature/view_models/logging_view_model.dart';
import 'package:frontend_munchies/models/record.dart';
import 'package:provider/provider.dart';

class ScanPicture extends StatelessWidget {
  const ScanPicture({super.key});

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    final ScanViewModel svm = context.watch<ScanViewModel>();

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/homepage_background.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          iconTheme: IconThemeData(
            color: Colours.greyPink, //change your color here
          ),
          backgroundColor: Color(0xff696969).withValues(alpha: 0.1),
          title: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'SCAN ITEM',
              style: TextStyle(
                fontFamily: 'Cherry_Bomb_One',
                fontSize: 36,
                color: Colours.greyPink,
              ),
            ),
          ),
          toolbarHeight: height * 0.10,
          titleSpacing: 18.0,
        ),
        body: Container(
          width: width,
          height: height,
          color: Colours.lightBeige,
          child: ScrollConfiguration(
            behavior: ScrollBehavior().copyWith(overscroll: false),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  if (svm.hasGeminiBanner)
                    BasicBanner(
                      label:
                          'This feature is powered by Gemini.  Do not upload sensitive pictures.',
                      onPressed: svm.dismissGeiminiBanner,
                      leadingIcon: Icon(
                        Icons.info_rounded,
                        color: Colors.red[400],
                        size: 30,
                      ),
                      padding: const EdgeInsets.only(
                        top: 10.0,
                        left: 8.0,
                        right: 8.0,
                      ),
                    ),
                  if (svm.hasImageTypeBanner)
                    BasicBanner(
                      label: 'Supported image files:\n .png, .jpeg, .webp',
                      onPressed: svm.dismissImageTypeBanner,
                      leadingIcon: Icon(
                        Icons.photo,
                        color: Colours.greyPink,
                        size: 30,
                      ),
                      padding: const EdgeInsets.only(
                        left: 8.0,
                        right: 8.0,
                        top: 2.0,
                      ),
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.only(left: 20.0, top: 20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            'Preview your image: ',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 16,
                              color: Colours.darkBrown,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  SizedBox(height: 15),
                  ImageSelectionButton(
                    boxSize: Size(width * 0.95, height * 0.55),
                    sendBackPhotoFile: (photoFile) =>
                        svm.setPhotoFile(photoFile),
                  ),
                  SizedBox(height: 20),
                  AppButton(
                    text: 'Scan',
                    onPressed: () => _onScanButtonPressed(svm, context),
                    size: Size(width * 0.75, 53),
                  ),
                  svm.errorMessage != null
                      ? Padding(
                          padding: const EdgeInsets.only(
                            left: 40.0,
                            right: 40.0,
                          ),
                          child: ShowErrorMessage(errorMessage: svm.errorMessage),
                        )
                      : SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  //TODO: ABSTRACT OUT THE SHOWLOADING FOR ALL FEATURES 
  void showLoading(ScanViewModel svm, BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => ChangeNotifierProvider.value(
        value: svm,
        builder: (context, child) {
          if ((context.watch<ScanViewModel>().isLoading)) {
            return PopScope(
              canPop: false,
              child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: Colours.greyPink),
                      ],
                    ),
                  ),
            );
          } else {
            return Center();
          }
        },
      ),
      barrierDismissible: false,
    );
  }

  Future<void> _onScanButtonPressed(ScanViewModel svm, BuildContext context) async {
    showLoading(svm, context);
    await svm.onScanPressed();
    if (!context.mounted) return;
    if (context.mounted && svm.errorMessage != null) {
      Navigator.of(context).pop();
      return;
    }
    if (!svm.isValidItemName) {
      {
        Navigator.of(context).pop();
        showDialog(
          barrierDismissible: true,
          context: context,
          builder: (context) {
            return AlertDialog(
              content: Text(
                'No food was detected in the image.\n Either try again or record manually',
                style: importantTextStyle,
                textAlign: TextAlign.center,
              ),
              backgroundColor: Colours.darkerBeige,
            );
          },
        );
        return;
      }
    }
     Navigator.popUntil(context, (route) {
          return route.settings.name == '/home' || route.isFirst;
        });
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider(
          create: (_) => LoggingViewModel(
            recordChanger: context.read<RecordRepository>(),
            record: Record(
              itemName: svm.itemName ?? 'null',
              date: DateTime.now(),
              cost: 0,
              isFavourited: false,
              photo_file: svm.photoFile,
              isVisible: false,
            ),
          ),
          child: TrackingPage(),
        ),
      ),
    );
  }
}
