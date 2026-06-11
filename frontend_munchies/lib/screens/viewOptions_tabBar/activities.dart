import 'package:flutter/material.dart';
import 'package:frontend_munchies/models/record.dart';
import 'package:frontend_munchies/services/records/record_changer.dart';
import 'package:frontend_munchies/styles/colours.dart';
import 'package:frontend_munchies/widgets/errorMessage.dart';
import 'package:frontend_munchies/widgets/activitiesView_widget/record_card.dart';
import 'package:provider/provider.dart';
import 'package:frontend_munchies/screens/viewOptions_bottomBar/homePageView.dart';

class ActivitiesView extends StatefulWidget {
  final ActivityFilter filter;
  const ActivitiesView({super.key, required this.filter});


  @override
  State<ActivitiesView> createState() => _ActivitiesViewState();
}

class _ActivitiesViewState extends State<ActivitiesView> {
  List<Record> _recordDetails = [];
  String? _errorMessage;
  bool _isLoading = false;
  RecordChanger? recordChanger;

  @override 
  void didChangeDependencies() {
    super.didChangeDependencies();
    RecordChanger recordChanger = context.read<RecordChanger>();
    recordChanger.addListener(refreshRecords);
  }
  @override
  void initState() {
    super.initState();
    _fetchRecords();
  }

  @override
  void dispose() {
    recordChanger?.removeListener(refreshRecords);
    super.dispose();
  }

  void refreshRecords() {
    if (!mounted) return;
    _fetchRecords();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    double height = size.height;
    double width = size.width;
    if (_errorMessage != null) {
      return Container(
        alignment: Alignment.center,
        width: width,
        height: height * 0.8,
        color: Colours.lightBeige,
        child: ShowErrorMessage(errorMessage: _errorMessage)
      );
    }

    return Container(
      alignment: (_isLoading || _recordDetails.isEmpty) ? Alignment.center : Alignment.topCenter,
      width: width,
      height: height * 0.80,
      color: Colours.lightBeige,
      child: _isLoading
           ? CircularProgressIndicator(color: const Color.fromARGB(255, 183, 115, 125),)
          : (_recordDetails.isNotEmpty
                ? ScrollConfiguration(
                  behavior: ScrollBehavior().copyWith(overscroll: false),
                  child: SingleChildScrollView(
                    physics: ClampingScrollPhysics(),
                    child: Column(
                      children: _recordDetails.map((rec) {
                        return RecordCard(
                          recordId: rec.record_id!,
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
                    "Nothing yet! \n Start tracking today!",
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
      List<Record>? data;
      setState(() {
        _isLoading = true;
      });
      Map<String, String>? query;
      if (widget.filter == ActivityFilter.all) {
        query = null;
      } else if (widget.filter == ActivityFilter.daily) {
        query = {'today': 'today'};
      } else if (widget.filter == ActivityFilter.weekly) {
        query = {'weekly': 'weekly'};
      }
      if (query != null) {
        data = await Provider.of<RecordChanger>(context, listen: false).getFilteredRecord(query);
      } else {
        data = await Provider.of<RecordChanger>(context, listen: false).fetchAllRecords();
      }
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        if (data != null) {
          if (data.isNotEmpty) _recordDetails = data;
        }
        
      });
    } on Exception catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
    }
  }
}
