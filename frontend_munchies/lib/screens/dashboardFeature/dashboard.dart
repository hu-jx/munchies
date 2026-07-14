import 'dart:async';

import 'package:flutter/material.dart';
import 'package:frontend_munchies/screens/dashboardFeature/dashboardViewModel/dashboard_view_model.dart';
import 'package:frontend_munchies/screens/dashboardFeature/view_opt.dart';
import 'package:frontend_munchies/screens/dashboardFeature/dashboardView/dashboard_base.dart';
import 'package:frontend_munchies/screens/activities/domain/repositories/record_repo.dart';
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
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final recordRepo = context.read<RecordRepository>();
    _subscription = recordRepo.recordStream.listen((r) {
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
    setState(() {
      isLoading = true;
    });
    await model.getData();

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
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
