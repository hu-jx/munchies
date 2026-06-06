import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:frontend_munchies/models/record.dart';
import 'package:frontend_munchies/services/auth_exception.dart';
import 'package:frontend_munchies/services/record_services.dart';
import 'package:frontend_munchies/styles/colours.dart';
import 'package:frontend_munchies/widgets/record_card.dart';

class ActivitiesView extends StatefulWidget {
  const ActivitiesView({super.key});

  @override
  State<ActivitiesView> createState() => _ActivitiesViewState();
}

class _ActivitiesViewState extends State<ActivitiesView> {
  List<Record> _recordDetails = [];
  String? _errorMessage;
  bool _isLoading = false;

  @override 
  void initState() {
    super.initState();
    _fetchRecords();
  }


  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    double height = size.height;
    double width = size.width;

    return Container(
      alignment: Alignment.center,
      width: width,
      height: height * 0.85 - 92.0,
      color: Colours.lightBeige,
      child: _isLoading ? 
      Text(
            'Loading.......',
              // "Nothing yet! \n Start tracking today!",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Poppins',
                color: Colours.darkBrown.withValues(alpha: 0.43),
              ),
            )
      : (_recordDetails.isNotEmpty
          ? ScrollConfiguration(
            behavior: ScrollBehavior().copyWith(overscroll: false),
            child: SingleChildScrollView(
              physics: ClampingScrollPhysics(),
                child: Column(
                  children: _recordDetails.map((rec) {
                    return RecordCard(
                      itemName: rec.itemName,
                      date: rec.date,
                      cost: rec.cost,
                      base64Image: rec.photo,
                    );
                  }).toList(),
                ),
              ),
          )
          : Text(
            _errorMessage ?? '',
              // "Nothing yet! \n Start tracking today!",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Poppins',
                color: Colours.darkBrown.withValues(alpha: 0.43),
              ),
            )),
    );
  }

  Future<void> _fetchRecords() async {
    try {
      User? usr = FirebaseAuth.instance.currentUser;
      if (usr == null) throw AuthException('No permission to access.');
      String? idToken = await usr.getIdToken();
      if (idToken == null || idToken.isEmpty) {
        throw AuthException('No permission to access. ');
      }
      setState(() {
        _isLoading = true;
      });
      List<Record> data = await RecordServices.getAllRecords(idToken);
      setState(() {
        _isLoading = false;
        _recordDetails = data;
      });
    } on Exception catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
    }
  }
}
