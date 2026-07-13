import 'package:flutter/material.dart';
import 'package:frontend_munchies/styles/textStyles.dart';
import 'package:frontend_munchies/services/recommendation_services.dart';
import 'package:frontend_munchies/screens/recommendationFeature/view_model/rec_view_model.dart';
import 'package:frontend_munchies/styles/colours.dart';

class RecView extends StatefulWidget {
  const RecView({super.key});

  @override
  State<RecView> createState() => _RecViewState();
}

class _RecViewState extends State<RecView> {
  Map<String, dynamic>? info;
  bool recsLoading = true;
  String errorMessage = "";
  bool showDefault = false;

  @override
  void initState() {
    super.initState();
    loadRecs();
  }

  Future<void> loadRecs() async {
    final recs = await getRec();
    if (!mounted) return;

    if (recs == null || recs['error'] == true) {
      setState(() {
        errorMessage = "Something went wrong, please try again later";
        recsLoading = false;
        showDefault = true;
      });
    } else if (recs.containsKey('message')) {
      setState(() {
        recsLoading = false;
        showDefault = true;
      });
    }
    setState(() {
      info = recs;
      recsLoading = false;
    });
  }

  Widget content() {
    if (recsLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colours.greyPink),
      );
    }
    return Column(
      children: [
        Text(
          'PERSONALISED RECOMMENDATIONS',
          style: TextStyle(
            fontFamily: 'Cherry_Bomb_One',
            color: Colours.darkBrown,
            fontSize: 24,
          ),
          textAlign: TextAlign.left,
        ),
        SizedBox(height: 10),
        Text(
          "Healthier recommendations based on your taste preferences",
          style: TextStyle(
            fontFamily: "Poppins",
            color: Colours.lightBrown,
            fontSize: 16,
          ),
        ),
        SizedBox(height: 10),
        recsFormat(),
      ],
    );
  }

  Widget recsFormat() {
    if (showDefault) {
      //default recommendations, plus a little message
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "We'd require some data to give you personalised recommendations! For now, here are some general recommendations.",
            style: recStyle,
          ),
          //ONE REC ITEM
          SizedBox(height: 10),
          Text(
            "1. Smoothie Bowl with Mixed Berries",
            style: TextStyle(
              fontFamily: "Poppins",
              color: Colours.darkBrown,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text("  - Fruity, creamy, refreshing, thick, sweet ", style: recStyle),
          Text("  - Rich in vitamins and antioxidants with natural fruit sugars. ", style: recStyle),
          SizedBox(height: 5,),
          //NEXT REC ITEM
          Text(
            "2. Dark Chocolate with Nuts",
            style: TextStyle(
              fontFamily: "Poppins",
              color: Colours.darkBrown,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text("  - Bitter-sweet, rich, crunchy, nutty, smooth ", style: recStyle),
          Text("  - Contains antioxidants and healthy fats, lower sugar than milk chocolate. ", style: recStyle),
          SizedBox(height: 5,),
        ],
      );
    } else {
      //return Text(info.toString());
      return Column(
        children: [
          Text(info!["tastePreference"], style: recStyle),
          SizedBox(height: 10),
          Column(children: buildRec()),
        ],
      );
    }
  }

  List<Widget> buildRec() {
    final List recommendations = info!["recommendations"];
    return recommendations.map((item) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "${recommendations.indexOf(item)+1}.  ${item["name"]} ",
            style: TextStyle(
              fontFamily: "Poppins",
              color: Colours.darkBrown,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text("  - ${item["flavours"]}", style: recStyle),
          Text("  - ${item["benefit"]}", style: recStyle),
          SizedBox(height: 5,)
        ],
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    double height = size.height;
    double width = size.width;

    return Container(
      alignment: Alignment.center,
      width: width * 0.9,
      // height: height * 0.57,
      decoration: BoxDecoration(
        color: Colours.darkerBeige,
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Padding(padding: const EdgeInsets.all(20.0), child: content()),
    );
  }
}
