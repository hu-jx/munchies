//OLD DASHBOARD CODE
/*
import 'package:flutter/material.dart';
import 'package:frontend_munchies/styles/colours.dart';
import 'package:frontend_munchies/screens/dashboard_components/dashboard_old.dart';
import 'package:frontend_munchies/screens/dashboardFeature/viewOpt.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  ViewOpt selectedView = ViewOpt.weekly;
  DateTime selectedPeriod = DateTime.now();

  String getLabel(ViewOpt view) {
    switch (view) {
      case ViewOpt.weekly:
        return "Weekly";
      case ViewOpt.monthly:
        return "Monthly";
      case ViewOpt.annually:
        return "Annually";
      case ViewOpt.futureView:
        return "Future";
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    double height = size.height;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Container(color: Colours.lightBeige, height: height * 0.9),
          Dashboard(selectedView: selectedView, date: selectedPeriod),
        ],
      ),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Color(0xff696969).withValues(alpha: 0.1),
        title: const Align(
          alignment: Alignment.topLeft,
          child: Padding(
            padding: EdgeInsets.only(left: 10.0, right: 10.0),
            child: Text(
              "DASHBOARD",
              style: TextStyle(
                fontFamily: 'Cherry_Bomb_One',
                fontSize: 55,
                color: Colours.greyPink,
              ),
            ),
          ),
        ),
        bottom: PreferredSize(
          preferredSize:
              MediaQuery.of(context).orientation == Orientation.landscape
              ? Size.fromHeight(height * 0.22)
              : Size.fromHeight(95),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 10.0, left: 20.0),
                    child: Text(
                      "Visualise your sweet treat consumptions here!",
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        color: Colours.lightBrown,
                      ),
                    ),
                  ),
                ),
                //POP UP MENU BUTTON HERE
                viewSelector(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  //builds the PopUpMenuButton for the view changer
  Widget viewSelector() {
    return Padding(
      padding: const EdgeInsets.only(right: 20.0),
      child: PopupMenuButton<ViewOpt>(
        color: Colours.mutedPink,
        constraints: BoxConstraints(
          minWidth: MediaQuery.of(context).size.width,
        ),
        initialValue: selectedView,
        onSelected: (ViewOpt item) {
          setState(() {
            selectedView = item;
            //getData();
          });
        },
        itemBuilder: (BuildContext context) => <PopupMenuEntry<ViewOpt>>[
          const PopupMenuItem<ViewOpt>(
            value: ViewOpt.weekly,
            child: Padding(
              padding: EdgeInsets.only(left: 10.0),
              child: Text(
                'Weekly',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  color: Colours.lightBeige,
                ),
              ),
            ),
          ),
          const PopupMenuItem<ViewOpt>(
            value: ViewOpt.monthly,
            child: Padding(
              padding: EdgeInsets.only(left: 10.0),
              child: Text(
                'Monthly',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  color: Colours.lightBeige,
                ),
              ),
            ),
          ),
          const PopupMenuItem<ViewOpt>(
            value: ViewOpt.annually,
            child: Padding(
              padding: EdgeInsets.only(left: 10.0),
              child: Text(
                'Annually',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  color: Colours.lightBeige,
                ),
              ),
            ),
          ),
          const PopupMenuItem<ViewOpt>(
            value: ViewOpt.futureView,
            child: Padding(
              padding: EdgeInsets.only(left: 10.0),
              child: Text(
                'Future You',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  color: Colours.lightBeige,
                ),
              ),
            ),
          ),
        ],
        //customising button appearance
        child: Stack(
          alignment: AlignmentGeometry.centerEnd,
          children: [
            Container(
              width: 124,
              height: 40,
              decoration: BoxDecoration(
                color: Colours.mutedPink,
                borderRadius: BorderRadius.circular(12.0),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  getLabel(selectedView),
                  //selectedView.name[0].toUpperCase() + selectedView.name.substring(1),
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    color: Colours.lightBeige,
                  ),
                ),
                Icon(
                  Icons.arrow_drop_down_rounded,
                  size: 50,
                  color: Colours.lightBeige,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
*/