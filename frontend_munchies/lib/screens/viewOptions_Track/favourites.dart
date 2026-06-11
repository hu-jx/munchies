import 'package:flutter/material.dart';
import 'package:frontend_munchies/screens/viewOptions_Track/tracking.dart';
import 'package:frontend_munchies/services/records/record_changer.dart';
import 'package:frontend_munchies/styles/colours.dart';
import 'package:frontend_munchies/widgets/logging_widgets/logging_form.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:frontend_munchies/models/record.dart';

class FavouritesPage extends StatefulWidget {
  const FavouritesPage({super.key});

  @override
  State<FavouritesPage> createState() => _FavouritesPageState();
}

class _FavouritesPageState extends State<FavouritesPage> {
  List<Record> _recordDetails = [];
  String _errorMessage = '';
  bool _isLoading = false;
  TextStyle textStyle = TextStyle(
    color: Colours.darkBrown,
    fontSize: 18,
    fontFamily: 'Poppins',
  );

  @override
  void initState() {
    super.initState();
    _fetchFavRecords();
  }

  @override
  Widget build(BuildContext context) {
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
          alignment: _isLoading ? Alignment.center : Alignment.topCenter,
          width: width,
          height: height * 0.90,
          child: ScrollConfiguration(
            behavior: ScrollBehavior().copyWith(overscroll: false),
            child: SingleChildScrollView(
              physics: ClampingScrollPhysics(),
              child: _isLoading
                  ? CircularProgressIndicator(color: Colours.greyPink)
                  : _errorMessage.isNotEmpty
                  ? Center(
                      child: Text(
                        _errorMessage,
                        style: GoogleFonts.poppins(
                          color: Colors.red[400],
                          fontSize: 24,
                        ),
                      ),
                    )
                  : Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                      children: _recordDetails.map((singleRec) {
                        return _FavCard(
                          textStyle: textStyle,
                          record: singleRec,
                        );
                      }).toList(),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  void _fetchFavRecords() async {
    try {
      setState(() {
        _isLoading = true;
      });
      _recordDetails = await Provider.of<RecordChanger>(
        context,
        listen: false,
      ).getFilteredRecord({'favourites': 'favourites'});
      setState(() {
        _isLoading = false;
      });
    } on Exception catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    }
  }
}

class _FavCard extends StatelessWidget {
  const _FavCard({required this.textStyle, required this.record});

  final TextStyle textStyle;
  final Record record;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TrackingPage(
                loggingForm: LoggingForm(
                  record: Record(
                    user_uid: record.user_uid,
                    itemName: record.itemName,
                    date: DateTime.now(),
                    cost: record.cost,
                    isFavourited: true,
                    isVisible: false
                  ),
                ),
              ),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colours.darkerBeige,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          side: BorderSide(color: Color(0xffA98379)),
          foregroundColor: Color(0xffA98379),
        ),
        child: Padding(
          padding: const EdgeInsets.only(
            top: 12.0,
            right: 5.0,
            left: 5.0,
            bottom: 12.0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(child: Text(record.itemName, style: textStyle)),
              const SizedBox(width: 50,),
              Text((record.cost / 100).toStringAsFixed(2), style: textStyle),
            ],
          ),
        ),
      ),
    );
  }
}
