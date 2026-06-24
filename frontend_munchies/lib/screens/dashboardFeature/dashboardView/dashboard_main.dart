import 'package:flutter/material.dart';
import 'package:frontend_munchies/styles/colours.dart';
import 'package:frontend_munchies/screens/dashboardFeature/dashboardViewModel/dashboard_view_model.dart';
import 'package:frontend_munchies/screens/dashboardFeature/dashboardView/date_helpers.dart';
import 'package:frontend_munchies/screens/dashboardFeature/dashboardView/pie_chart_builder.dart';

class DashboardMain extends StatelessWidget {
  DashboardViewModel model;
  final Function(DateTime) onBackButton;
  final Function(DateTime) onForwardButton;

  DashboardMain({
    super.key,
    required this.model,
    required this.onBackButton,
    required this.onForwardButton,
  });

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    double height = size.height;

    return Scaffold(
      backgroundColor: Colors.transparent,
      //body: Text("dashboards here"),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Stack(
              alignment: AlignmentGeometry.center,
              children: [
                Container(
                  height: height * 0.05,
                  decoration: BoxDecoration(
                    color: Colours.darkerBeige,
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                ),
                dateNavigator(),
              ],
            ),
          ),
          Expanded(
            child: ScrollConfiguration(
              behavior: ScrollBehavior().copyWith(overscroll: false),
              child: SingleChildScrollView(
                child: (model.categoryData.isEmpty)
                    ? Text(
                        "No data. Please log your consumption first",
                        style: TextStyle(
                          fontFamily: "Poppins",
                          color: Colours.lightBrown,
                        ),
                      )
                    : Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 30,
                              vertical: 10,
                            ),
                            child: PieChartBuilder(
                              summaryData: model.summaryData,
                              categoryData: model.categoryData,
                              selectedView: model.selectedView,
                              sortBy: "numPerCat",
                              chosenDate: model.chosenDate,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 30,
                              vertical: 10,
                            ),
                            child: PieChartBuilder(
                              summaryData: model.summaryData,
                              categoryData: model.categoryData,
                              selectedView: model.selectedView,
                              sortBy: "costPerCat",
                              chosenDate: model.chosenDate,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),

          //(categoryData == []) ? Text("No Data available") : chartBuilder(),
        ],
      ),
    );
  }

  Widget chartFormat(double height, Widget widget) {
    return Container(
      height: height * 0.5,
      color: Colours.darkerBeige,
      child: widget,
    );
  }

  Widget dateNavigator() {
    if (model.selectedView.name == "futureView") {
      return Text(
        "Future 6 Months",
        style: TextStyle(color: Colours.greyPink, fontFamily: 'Poppins'),
      );
    } else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: () {
              onBackButton(goBack(model.selectedView, model.chosenDate));
            },
            icon: const Icon(Icons.arrow_left),
            iconSize: 30,
            color: Colours.greyPink,
          ),
          Text(
            displayRange(model.selectedView, model.chosenDate),
            style: TextStyle(color: Colours.greyPink, fontFamily: 'Poppins'),
          ),
          IconButton(
            onPressed: () {
              onForwardButton(goForward(model.selectedView, model.chosenDate));
            },
            icon: const Icon(Icons.arrow_right),
            iconSize: 30,
            color: Colours.greyPink,
          ),
        ],
      );
    }
  }
}
