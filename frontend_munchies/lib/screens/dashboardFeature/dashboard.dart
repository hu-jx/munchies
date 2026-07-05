import 'package:flutter/material.dart';
//import 'package:frontend_munchies/screens/viewOptions_bottomBar/dashboard_view.dart';
import 'package:frontend_munchies/screens/dashboardFeature/dashboardViewModel/dashboard_view_model.dart';
import 'package:frontend_munchies/screens/dashboardFeature/view_opt.dart';
import 'package:frontend_munchies/screens/dashboardFeature/dashboardView/dashboard_base.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final model = DashboardViewModel();

  @override
  void initState() {
    super.initState();
    //further refinement ltr on
    Future.delayed(const Duration(milliseconds: 0), () async {
      await model.getData();
      setState(() {});
    });
  }

  void onChangeView(ViewOpt view) async {
    model.changeView(view);
    await model.getData();
    setState(() {});
  }

  void onBackButton(DateTime date) async {
    model.backButton(date);
    await model.getData();
    setState(() {});
  }

  void onForwardButton(DateTime date) async {
    model.forwardButton(date);
    await model.getData();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return DashboardView(
      model: model,
      onChangeView: onChangeView,
      onBackButton: onBackButton,
      onForwardButton: onForwardButton,
    );
  }
}
