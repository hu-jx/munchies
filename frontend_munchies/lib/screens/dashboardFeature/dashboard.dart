import 'dart:async';

import 'package:flutter/material.dart';
import 'package:frontend_munchies/screens/activities/data/repositories/record_changer.dart';
import 'package:frontend_munchies/screens/dashboardFeature/dashboardViewModel/dashboard_view_model.dart';
import 'package:frontend_munchies/screens/dashboardFeature/view_opt.dart';
import 'package:frontend_munchies/screens/dashboardFeature/dashboardView/dashboard_base.dart';
import 'package:frontend_munchies/screens/activities/domain/repositories/record_repo.dart';
import 'package:frontend_munchies/screens/activities/domain/view_models/record_handler.dart';
import 'package:provider/provider.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final model = DashboardViewModel();
  late RecordRepository recordRepo;
  late StreamSubscription _subscription;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    /*further refinement ltr on
    Future.delayed(const Duration(milliseconds: 0), () async {
      await model.getData();
      setState(() {});
    });
    */

    Future.microtask(() async {
      await refreshData();
    });
    print("DASHBOARD set up");
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    final recordRepo = context.read<RecordRepository>();
    _subscription = recordRepo.recordStream.listen((r) {
      print("STREAM TRIGGERED");
      refreshData();
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
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

  Future<void> refreshData() async {
    print("REFRESH START");

    setState(() {
      isLoading = true;
    });
    await model.getData();
    print("DATA LOADED");

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
    print("SETSTATE DONE");
  }

  @override
  Widget build(BuildContext context) {
    return DashboardView(
      model: model,
      onChangeView: onChangeView,
      onBackButton: onBackButton,
      onForwardButton: onForwardButton,
      isLoading: isLoading,
    );
  }
}
