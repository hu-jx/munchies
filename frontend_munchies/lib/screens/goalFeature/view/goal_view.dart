import 'package:flutter/material.dart';
import 'package:frontend_munchies/screens/activities/domain/repositories/record_repo.dart';
import 'package:frontend_munchies/screens/goalFeature/repository/goal_repository.dart';
import 'package:frontend_munchies/screens/goalFeature/viewmodel/goal_vm.dart';
import 'package:frontend_munchies/screens/loggingFeature/views/logging_widgets/fields/date.dart';
import 'package:frontend_munchies/styles/colours.dart';
import 'package:frontend_munchies/styles/logging_form_styles.dart';
import 'package:frontend_munchies/styles/textStyles.dart';
import 'package:frontend_munchies/widgets/button.dart';
import 'package:frontend_munchies/widgets/errorMessage.dart';
import 'package:percent_indicator/flutter_percent_indicator.dart';
import 'package:provider/provider.dart';
import 'package:tap_debouncer/tap_debouncer.dart';

class GoalPost extends StatelessWidget {
  const GoalPost({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => GoalViewModel(
        goalRepo: GoalRepoImpl(),
        recordRepo: context.read<RecordRepository>(),
      ),
      child: GoalPostView(),
    );
  }
}

class GoalPostView extends StatelessWidget {
  const GoalPostView({super.key});
  static final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final goalController = TextEditingController();
    final GoalViewModel viewModel = context.watch<GoalViewModel>();
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Container(
      alignment: Alignment.center,
      width: width * 0.9,
      // height: height * 0.57,
      decoration: BoxDecoration(
        color: Colours.darkerBeige,
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: viewModel.loadingStatus
          ? Container(
            height: height * 0.55,
              alignment: Alignment.center,
              child: CircularProgressIndicator(color: Colours.greyPink),
            )
          : viewModel.errorMesage != null 
          ? ShowErrorMessage(errorMessage: viewModel.errorMesage)
          : Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                spacing: 10,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(width: 10),
                      Text(
                        'GOALS',
                        style: TextStyle(
                          fontFamily: 'Cherry_Bomb_One',
                          color: Colours.darkBrown,
                          fontSize: 24,
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ],
                  ),
                  viewModel.latestGoal == null
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(height: height * 0.05,),
                            Text(
                              'No goals yet!\nCreate one today!',
                              style: backgroundTextStyle,
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: height * 0.05,),
                          ],
                        )
                      : GoalDisplay(viewModel: viewModel, height: height),
                  SizedBox(height: height * 0.01),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: AppButton(
    
                      text: 'Set new goal',
                      color: Colours.greyPink.withValues(alpha: 0.88),
                      textStyle: importantTextStyle.copyWith(color: Colours.lightBeige),
                      onPressed: () async {
                        await viewModel.onSetNewGoalPressed();
                        if (!context.mounted) return;
                        await _showSelection(
                          context,
                          width,
                          height,
                          viewModel,
                          goalController,
                        );
                      },
                      size: Size(width * 0.8, height * 0.055 ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Future<void> _showSelection(
    BuildContext context,
    double width,
    double height,
    GoalViewModel viewModel,
    TextEditingController goalController,
  ) async {
    await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return ChangeNotifierProvider.value(
          value: viewModel,
          builder: (context, child) {
            final viewModel = context.watch<GoalViewModel>();
            return AlertDialog(
              contentPadding: EdgeInsets.only(
                top: 30.0,
                left: 30.0,
                right: 30.0,
              ),
              actionsAlignment: MainAxisAlignment.center,
              actionsPadding: EdgeInsets.only(bottom: 20),
              backgroundColor: Colours.lightBeige,

              content: ScrollConfiguration(
                behavior: ScrollBehavior().copyWith(overscroll: false),
                child: SingleChildScrollView(
                  child: SizedBox(
                    width: width * 0.8,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 10.0,
                      children: [
                        Text(
                          'Our recommended goal:',
                          style: importantTextStyle,
                          textAlign: TextAlign.left,
                        ),
                        Center(
                          child: Text(
                            textAlign: TextAlign.center,
                            'MAX ${viewModel.reccGoal} TIMES / WEEK',
                            style: importantTextStyle.copyWith(
                              fontSize: 24,
                              fontFamily: 'Cherry_Bomb_One',
                            ),
                          ),
                        ),
                        SizedBox(height: height * 0.02, width: width * 0.8),
                        Text(
                          'Set a new goal below!',
                          style: importantTextStyle,
                        ),
                        GoalSettingForm(
                          formKey: _formKey,
                          viewModel: viewModel,
                          goalController: goalController,
                        ),
                        ShowErrorMessage(errorMessage: viewModel.errorMesage),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                TapDebouncer(
                  onTap: () async {
                    debugPrint("Reached onTap");
                    if (_formKey.currentState?.validate() == true) {
                      debugPrint("goalController text is ${goalController.text}");
                      await viewModel.onSavePressed(
                        int.parse(goalController.text),
                      );
                      if (viewModel.errorMesage == null && context.mounted) {
                        Navigator.popUntil(context, (route) {
                          return route.settings.name == '/home' ||
                              route.isFirst;
                        });
                      }
                    }
                  },
                  builder: (context, onTap) => TextButton(
                    onPressed: onTap,
                    child: Text(
                      'Save',
                      style: TextStyle(
                        fontFamily: 'Cherry_Bomb_One',
                        fontSize: 30,
                        color: Colours.greyPink,
                      ),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    if (!context.mounted) return;
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      fontFamily: 'Cherry_Bomb_One',
                      fontSize: 28,
                      color: Colours.greyPink.withValues(alpha: 0.6),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class GoalDisplay extends StatelessWidget {
  const GoalDisplay({super.key, required this.viewModel, required this.height});

  final GoalViewModel viewModel;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 12.0,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Consume treats max ${viewModel.latestGoal?.quantity ?? 0} times per week',
                style: importantTextStyle,
                textAlign: TextAlign.left,
              ),
            ),
          ],
        ),
        Row(
          children: [
            viewModel.currentStreak != 0
                ? Icon(
                    Icons.local_fire_department,
                    color: Colours.greyPink,
                    size: 100,
                  )
                : Icon(
                    Icons.local_fire_department,
                    color: Colours.greyPink.withValues(alpha: 0.4),
                    size: 100,
                  ),
            Flexible(
              child: Column(
                spacing: 0,
                children: [
                  Text(
                    '${viewModel.latestGoal == null ? DateField.formatDate(DateTime.now()) : DateField.formatDate(viewModel.latestGoal?.start_date)} -> ${DateField.formatDate(DateTime.now())}',
                    style: importantTextStyle,
                  ),
                  Text(
                    '${viewModel.currentStreak} WEEK STREAK',
                    style: TextStyle(
                      fontFamily: 'Cherry_Bomb_One',
                      color: viewModel.currentStreak != 0
                          ? Colours.greyPink
                          : Colours.greyPink.withValues(alpha: 0.7),
                      fontSize: 30,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        Column(
          spacing: 0,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  "This week's consumption",
                  style: importantTextStyle.copyWith(
                    decoration: TextDecoration.underline,
                  ),
                ),
              ],
            ),
            SizedBox(height: height * 0.01),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(left: 8.0, right: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularPercentIndicator(
                radius: height * 0.1,
                percent: viewModel.currentQuota 
                > 1
                    ? 1
                    : viewModel.currentQuota,
                // viewModel.currentQuota,
                progressColor: viewModel.currentQuota > 1
                    ? Colors.red.shade300
                    : Colours.greyPink,
                backgroundColor: Colours.greyPink.withValues(alpha: 0.2),
                center:  Text(
                  '${(viewModel.currentQuota * 100).toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontFamily: 'Cherry_Bomb_One',
                    fontSize: 28,
                    color: const Color.fromARGB(255, 171, 112, 111),
                  ),
                ),
              ),
              SizedBox(width: 40),
              Flexible(
                child: Text(
                  viewModel.remainingConsumption < 0
                      ? 'Exceeded'
                      : '${viewModel.remainingConsumption}\ntimes left',
                  style: importantTextStyle.copyWith(fontSize: 20),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class GoalSettingForm extends StatelessWidget {
  const GoalSettingForm({
    super.key,
    required GlobalKey<FormState> formKey,
    required this.viewModel,
    required this.goalController,
  }) : _formKey = formKey;

  final GlobalKey<FormState> _formKey;
  final GoalViewModel viewModel;
  final TextEditingController goalController;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUnfocus,
      child: TextFormField(
        controller: goalController,
        keyboardType: TextInputType.numberWithOptions(
          signed: false,
          decimal: false,
        ),
        decoration: basicBoxDeco('Maximum quantity').copyWith(
          suffixText: 'TIMES PER WEEK',
          suffixStyle: TextStyle(
            fontFamily: 'Cherry_Bomb_One',
            fontSize: 20,
            color: Colours.darkBrown,
          ),
        ),

        validator: (value) {
          if (value != null) {
            if (value.isNotEmpty) {
              if (int.tryParse(value) == null) {
                debugPrint('AT VALIDATOR $value');
                return 'Invalid value';
              } else {
                if (int.tryParse(value)! < 0 || int.tryParse(value)! >  2147483647 ) {
                  return 'Invalid value';
                }
              }
            } else {
              return 'Field cannot be empty';
            }
          } else {
            return 'Field cannot be empty';
          }
          return null;
        },
      ),
    );
  }
}
