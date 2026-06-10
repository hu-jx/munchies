import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_debouncer/flutter_debouncer.dart';
import 'package:frontend_munchies/models/record.dart';
import 'package:frontend_munchies/services/records/record_changer.dart';
import 'package:frontend_munchies/styles/colours.dart';
import 'package:frontend_munchies/styles/textStyles.dart';
import 'package:frontend_munchies/widgets/activitiesView_widget/record_card.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarView extends StatefulWidget {
  const CalendarView({super.key});

  @override
  State<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView> {
  DateTime _focusedDay = DateTime.now();
  List<Record> _recordDetails = [];
  bool _isLoading = false;
  List<DateTime>? _dates;
  final Debouncer _debouncer = Debouncer();

  @override
  void initState() {
    super.initState();
    getMonthlyRecords(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    double height = size.height;
    double width = size.width;

    return Container(
      alignment: Alignment.topCenter,
      width: width,
      height: height * 0.85 - 92.0,
      color: Colours.lightBeige,
      child: ScrollConfiguration(
        behavior: ScrollBehavior().copyWith(overscroll: false),
        child: SingleChildScrollView(
          physics: ClampingScrollPhysics(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  top: 14.0,
                  right: 12.0,
                  left: 12.0,
                  bottom: 10.0,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: Color(0xffF0E6D8),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: TableCalendar(
                    calendarBuilders: CalendarBuilders(
                      defaultBuilder: (context, day, focusedDay) {
                        if (_dates != null) {
                          if (_dates!.any((date) => sameDate(date, day))) {
                            debugPrint('Entered contains ');
                            return Center(child: Icon(Icons.cookie_rounded, size: 30, color: Colours.greyPink,));
                          }
                        }
                        return null;
                      },
                    ),
                    focusedDay: _focusedDay,
                    firstDay: DateTime(2000),
                    lastDay: DateTime(2100),
                    calendarFormat: CalendarFormat.month,
                    headerStyle: HeaderStyle(
                      titleTextStyle: GoogleFonts.poppins(
                        color: Colours.darkBrown,
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                      ),
                      formatButtonVisible: false,
                      titleCentered: true,
                    ),
                    calendarStyle: CalendarStyle(
                      defaultTextStyle: inputTextStyle,
                      weekendTextStyle: inputTextStyle,
                      todayTextStyle: GoogleFonts.poppins(
                        color: Colours.darkerBeige,
                        fontWeight: FontWeight(500),
                      ),
                      outsideTextStyle: backgroundTextStyle,
                      todayDecoration: BoxDecoration(
                        color: Colours.lightBrown.withValues(alpha: 0.8),
                        shape: BoxShape.circle,
                      ),
                    ),
                    availableGestures: AvailableGestures.horizontalSwipe,
                    onPageChanged: (focusedDay) {
                      _debouncer.debounce(duration: Duration(milliseconds: 500), 
                      onDebounce: () {
                        setState(() {
                        _focusedDay = focusedDay;
                        getMonthlyRecords(_focusedDay);
                      });
                      debugPrint('${_focusedDay.month}-${_focusedDay.year}');
                      });
              
                    },
                    startingDayOfWeek: StartingDayOfWeek.sunday,
                    daysOfWeekStyle: DaysOfWeekStyle(
                      weekdayStyle: inputTextStyle,
                      weekendStyle: inputTextStyle,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10.0),

              Padding(
                padding: const EdgeInsets.only(left: 12.0, right: 12.0),
                child: Row(
                  children: [
                    Text(
                      'Logs',
                      style: TextStyle(
                        color: Colours.darkBrown,
                        fontFamily: 'Poppins',
                        fontSize: 24,
                      ),
                    ),
                  ],
                ),
              ),

              Divider(
                thickness: 2,
                indent: 12,
                endIndent: 18,
                color: Colours.darkBrown,
              ),

              Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: _isLoading
                      ? [Text('Loading....', style: backgroundTextStyle)]
                      : _recordDetails.isEmpty
                      ? [
                          Text(
                            'No records found this month!',
                            style: backgroundTextStyle,
                          ),
                        ]
                      : _recordDetails.map((record) {
                          return RecordCard(
                            date: record.date,
                            cost: record.cost,
                            itemName: record.itemName,
                            recordId: record.record_id!,
                          );
                        }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  //get records monthly. if more than one that day -> use generic emoji
  Future<void> getMonthlyRecords(DateTime date) async {
    String month = date.month.toString();
    String year = date.year.toString();
    String query = '$month,$year';
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });
    List<Record> data = await Provider.of<RecordChanger>(
      context,
      listen: false,
    ).getFilteredRecord({'monthly': query});
    List<DateTime> dates = data.map((rec) {
      return rec.date;
    }).toSet().toList() ;
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _recordDetails = data;
      _dates = dates;
    });
  }

  bool sameDate(DateTime date1, DateTime date2) {
    return date1.day == date2.day && date1.month == date2.month && date1.year == date2.year;
  }
}
