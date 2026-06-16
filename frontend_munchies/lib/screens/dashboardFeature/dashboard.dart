import 'package:flutter/material.dart';
//import 'package:frontend_munchies/screens/viewOptions_bottomBar/dashboard_view.dart';
import 'package:frontend_munchies/screens/dashboardFeature/dashboardViewModel/dashboard_view_model.dart';
import 'package:frontend_munchies/screens/dashboardFeature/viewOpt.dart';
import 'package:frontend_munchies/screens/dashboardFeature/dashboardView/dashboard_base.dart';

class Dashboard extends StatefulWidget {
  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final model = DashboardViewModel();

  void onChangeView(ViewOpt view) async {
    model.changeView(view);
    await model.getData();
    setState(() {});
  }

  void onBackButton(DateTime date) async {
    model.BackButton(date);
    await model.getData();
    setState(() {});
  }

  void onForwardButton(DateTime date) async {
    model.ForwardButton(date);
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
