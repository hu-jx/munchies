import 'package:flutter/material.dart';
import 'package:frontend_munchies/screens/loggingFeature/view_models/favourites_view_model.dart';
import 'package:frontend_munchies/screens/loggingFeature/views/favourites_page_widgets/favourite_card.dart';
import 'package:frontend_munchies/styles/colours.dart';
import 'package:frontend_munchies/styles/textStyles.dart';
import 'package:frontend_munchies/widgets/errorMessage.dart';
import 'package:provider/provider.dart';

class FavouritesPage extends StatelessWidget {
  const FavouritesPage({super.key});

  final TextStyle textStyle = const TextStyle(
    color: Colours.darkBrown,
    fontSize: 18,
    fontFamily: 'Poppins',
  );

  @override
  Widget build(BuildContext context) {
    final FavouritesViewModel fvm = context.watch<FavouritesViewModel>();
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/homepage_background.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          surfaceTintColor: Colors.transparent,
          iconTheme: IconThemeData(
            color: Colours.greyPink, //change your color here
          ),
          backgroundColor: Color(0xff696969).withValues(alpha: 0.1),
          title: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'FAVOURITES',
              style: TextStyle(
                fontFamily: 'Cherry_Bomb_One',
                fontSize: 36,
                color: Colours.greyPink,
              ),
            ),
          ),
          toolbarHeight: height * 0.10,
          titleSpacing: 18.0,
        ),
        body: Container(
          color: Colours.lightBeige,
          alignment: fvm.isLoading || fvm.recordDetails.isEmpty
              ? Alignment.center
              : Alignment.topCenter,
          width: width,
          height: height * 0.90,
          child: ScrollConfiguration(
            behavior: ScrollBehavior().copyWith(overscroll: false),
            child: SingleChildScrollView(
              physics: ClampingScrollPhysics(),
              child: fvm.isLoading
                  ? CircularProgressIndicator(color: Colours.greyPink)
                  : fvm.errorMessage != null
                  ? ShowErrorMessage(errorMessage: fvm.errorMessage)
                  : fvm.recordDetails.isEmpty
                  ? Center(
                      child: Text(
                        'No favourites found',
                        style: backgroundTextStyle,
                        textAlign: TextAlign.center,
                      ),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: fvm.recordDetails.map((singleRec) {
                        return FavCard(textStyle: textStyle, record: singleRec);
                      }).toList(),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
