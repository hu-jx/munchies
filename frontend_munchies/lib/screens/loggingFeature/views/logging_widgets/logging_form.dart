//this is the default tracking page

// ignore_for_file: non_constant_identifier_names

import 'dart:core';
import 'package:flutter/material.dart';
import 'package:frontend_munchies/styles/colours.dart';
import 'package:frontend_munchies/widgets/button.dart';
import 'package:frontend_munchies/widgets/errorMessage.dart';
import 'package:frontend_munchies/screens/loggingFeature/views/logging_widgets/image_widgets.dart/image_selection_button.dart';
import 'package:frontend_munchies/screens/loggingFeature/views/logging_widgets/fields/categories.dart';
import 'package:frontend_munchies/screens/loggingFeature/views/logging_widgets/fields/cost.dart';
import 'package:frontend_munchies/screens/loggingFeature/views/logging_widgets/fields/date.dart';
import 'package:frontend_munchies/screens/loggingFeature/views/logging_widgets/fields/details.dart';
import 'package:frontend_munchies/screens/loggingFeature/views/logging_widgets/fields/item_name.dart';
import 'package:frontend_munchies/screens/loggingFeature/views/logging_widgets/fields/others_row.dart';
import 'package:frontend_munchies/screens/loggingFeature/views/logging_widgets/fields/visibility_toggle.dart';
import 'package:frontend_munchies/screens/loggingFeature/view_models/logging_view_model.dart';
import 'package:frontend_munchies/models/record.dart';
import 'package:provider/provider.dart';

class LoggingForm extends StatelessWidget {
  final Record? record;
  static final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  LoggingForm({super.key, this.record});
  

  @override
  Widget build(BuildContext context) {
    print("BUILD TEST");
    final lvm = context.watch<LoggingViewModel>();
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return LayoutBuilder(
      builder: (context, constraints) {
        return Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUnfocus,
          child: ScrollConfiguration(
            behavior: ScrollBehavior().copyWith(overscroll: false),
            child: SingleChildScrollView(
              physics: ClampingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: const EdgeInsets.only(
                    top: 25.0,
                    bottom: 35.0,
                    right: 14.0,
                    left: 14.0,
                  ),
                  child: Column(
                    spacing: 12.0,
                    children: [
                      //ITEMNAME FIELD
                      ItemName(
                        itemNameController: TextEditingController(
                          text: lvm.itemName,
                        ),
                        lvm: lvm,
                      ),
                      //DATE ROW
                      DateField(
                        dateController: TextEditingController(
                          text: DateField.formatDate(lvm.date),
                        ),
                        sendBackDate: (date) => lvm.setDate(date),
                      ),
                      //COST ROW
                      CostField(
                        costController: TextEditingController(text: lvm.cost),
                        lvm: lvm,
                      ),
                      //OTHER DETAILS BEGIN
                      OthersRow(),
                      //DETAILS
                      DetailsField(
                        detailsController: TextEditingController(
                          text: lvm.details,
                        ),
                        lvm: lvm,
                      ),
                      //CATEGORY
                      CategoryMenu(
                        categoryController: TextEditingController(
                          text: lvm.category,
                        ),
                        sendBackCat: (cat) => lvm.setCat(cat),
                        maxWidth: constraints.maxWidth,
                      ),
                      ImageSelectionButton(
                        boxSize: Size(width * 0.95, height * 0.3),
                        existing_url: lvm.existing_url,
                        existing_photo_file: lvm.existing_file,
                        sendBackPhotoFile: (file) => lvm.setPhotoFile(file),
                      ),
                      VisibilityToggle(
                        original: lvm.isVisible,
                        formKey: _formKey,
                        sendVisibility: (boolean) => lvm.setVisibility(boolean),
                      ),
                      _buildActionRow(width, lvm, context),
                      ShowErrorMessage(errorMessage: lvm.errorMessage),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Row _buildActionRow(
    double width,
    LoggingViewModel lvm,
    BuildContext context,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        AppButton(
          text: 'Save',
          onPressed: () async {
            bool success = _formKey.currentState?.validate() ?? false;
            if (success) {
              showLoading(lvm, context);
              await lvm.onSavePressed();
              if (lvm.errorMessage == null && !lvm.isLoading) {
                if (!context.mounted) return;
                Navigator.popUntil(context, (route) {
                  return route.settings.name == '/home' || route.isFirst;
                });
              }
            }
          },
          size: Size(width * 0.75, 53),
        ),
        IconButton(
          onPressed: lvm.isFavourited ? lvm.setNotFav : lvm.setAsFav,
          icon: Icon(
            lvm.isFavourited
                ? Icons.favorite_rounded
                : Icons.favorite_border_rounded,
            color: lvm.isFavourited ? Colours.lightPink : Color(0xffA98379),
            size: 53,
          ),
        ),
      ],
    );
  }

  void showLoading(LoggingViewModel lvm, BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => ChangeNotifierProvider.value(
        value: lvm,
        builder: (context, child) {
          return (context.watch<LoggingViewModel>().isLoading)
              ? Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: Colours.greyPink),
                    ],
                  ),
                )
              : Center();
        },
      ),
      barrierDismissible: false,
    );
  }
}
