// ignore_for_file: prefer_interpolation_to_compose_strings

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:frontend_munchies/styles/colours.dart';
import 'package:frontend_munchies/screens/dashboardFeature/view_opt.dart';

class PieChartBuilder extends StatefulWidget {
  final List summaryData;
  final List categoryData;
  final ViewOpt selectedView;
  final String sortBy;
  final DateTime chosenDate;

  const PieChartBuilder({
    super.key,
    required this.summaryData,
    required this.categoryData,
    required this.selectedView,
    required this.sortBy,
    required this.chosenDate,
  });

  @override
  State<PieChartBuilder> createState() => _PieChartBuilderState();
}

class _PieChartBuilderState extends State<PieChartBuilder> {
  //sortBy options, only can be costPerCat or numPerCat
  List<Color> colourList = [
    Colours.pieRed,
    Colours.pieOrange,
    Colours.pieYellow,
    Colours.pieGreen,
    Colours.pieBlue,
    Colours.piePurple,
    Colours.piePink,
    Colours.pieRed,
  ];

  Map<String, Color> colourMap = {"Beverages": Colours.pieRed};

  List<dynamic> prepPieData(List listCopy, String sortBy) {
    listCopy = listCopy.map((entry) {
      return {
        "_id": {
          "category":
              (entry["_id"]["category"] == "null" ||
                  entry["_id"]["category"] == null)
              ? "Uncategorised"
              : entry["_id"]["category"],
        },
        "costPerCat": entry["costPerCat"],
        "numPerCat": entry["numPerCat"],
      };
    }).toList();

    listCopy.sort((a, b) => b[sortBy].compareTo(a[sortBy]));
    return listCopy;
  }

  num calcTotal(List list) {
    num total = 0;
    for (final item in list) {
      total += item[widget.sortBy];
    }
    return total;
  }

  String freqDesc(ViewOpt viewOpt) {
    if (viewOpt.name == "weekly") {
      return "Number purchased per week";
    } else if (viewOpt.name == "monthly") {
      return "Number purchased per month";
    } else if (viewOpt.name == "annually") {
      return "Number purchased per year";
    } else {
      return "Projected number of sweet treats";
    }
  }

  String expensesDesc(ViewOpt viewOpt) {
    if (viewOpt.name == "weekly") {
      return "Amount spent per week";
    } else if (viewOpt.name == "monthly") {
      return "Amount spent per month";
    } else if (viewOpt.name == "annually") {
      return "Amount spent per year";
    } else {
      return "Projected amount spent on sweet treats";
    }
  }

  @override
  Widget build(BuildContext context) {
    final listCopy = List<dynamic>.from(widget.categoryData);

    Size size = MediaQuery.of(context).size;
    double height = size.height;

    List<dynamic> preppedData = List<dynamic>.from(
      prepPieData(listCopy, widget.sortBy),
    );

    num total = calcTotal(listCopy);

    List<PieChartSectionData> sectionList = preppedData.map((cate) {
      return PieChartSectionData(
        value: cate[widget.sortBy].toDouble(),
        //title: cate["_id"]["category"],
        title: (total == 0)
            ? "0"
            : ((cate[widget.sortBy].toDouble() / total * 100)
                      .round()
                      .toString() +
                  "%"),
        color: colourList[preppedData.indexOf(cate)],
        radius: 100,
      );
    }).toList();

    List<Widget> legend = prepPieData(listCopy, widget.sortBy).map((cate) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 70.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              height: 10,
              // width: 10,
              //color: colourList[preppedData.indexOf(cate) + 1],
            ),
            Text(
              cate["_id"]["category"].toString(),
              style: TextStyle(
                fontFamily: "Poppins",
                color: Colours.lightBrown,
              ),
            ),
            Text(
              (widget.sortBy == "costPerCat")
                  ? "\$" + (cate[widget.sortBy] / 100).toStringAsFixed(2)
                  : cate[widget.sortBy].round().toString(),
              style: TextStyle(
                fontFamily: "Poppins",
                color: Colours.lightBrown,
              ),
            ),
          ],
        ),
      );
    }).toList();

    return Container(
      //height: height * (0.35 + sectionList.length * 0.02),
      color: Colours.darkerBeige,
      child: Column(
        children: [
          SizedBox(height: 15),
          Text(
            (widget.sortBy == "costPerCat") ? "Expenses" : "Frequency",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              fontFamily: "Poppins",
              color: Colours.darkBrown,
            ),
          ),
          Text(
            (widget.sortBy == "costPerCat")
                ? expensesDesc(widget.selectedView)
                : freqDesc(widget.selectedView),
            style: TextStyle(fontFamily: "Poppins", color: Colours.lightBrown),
          ),
          SizedBox(height: 15),
          SizedBox(
            height: (total == 0) ? 20 : 200,
            child: (total == 0)
                ? Text(
                    "\$0 spent!",
                    style: TextStyle(
                      fontFamily: "Poppins",
                      color: Colours.darkBrown,
                    ),
                  )
                : PieChart(
                    //issue fixing
                    key: ValueKey(
                      widget.selectedView.toString() +
                          widget.chosenDate.toString(),
                    ),
                    PieChartData(sections: sectionList),
                  ),
          ),
          SizedBox(height: 15),
          ...legend,
          //for testing Text("legend"),
          SizedBox(height: 20),
        ],
      ),
    );
  }
}
