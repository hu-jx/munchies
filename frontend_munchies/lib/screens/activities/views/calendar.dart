import 'package:flutter/material.dart';
import 'package:frontend_munchies/screens/activities/domain/view_models/record_handler.dart';
import 'package:frontend_munchies/screens/activities/view_models/calendar_view_model.dart';
import 'package:frontend_munchies/screens/activities/data/repositories/record_changer.dart';
import 'package:frontend_munchies/styles/colours.dart';
import 'package:frontend_munchies/styles/textStyles.dart';
import 'package:frontend_munchies/screens/activities/views/activities_widgets/record_card.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

class Calendar extends StatelessWidget {
  const Calendar({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) =>
          CalendarViewModel(recordRepo: context.read<RecordRepoImpl>()),
      child: CalendarView(),
    );
  }
}

class CalendarView extends StatelessWidget {
  const CalendarView({super.key});
  // @override
  @override
  Widget build(BuildContext context) {
    final CalendarViewModel vm = context.watch<CalendarViewModel>();
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
                        if (vm.datesWithRecord.isNotEmpty) {
                          if (vm.datesWithRecord.any(
                            (date) => isSameDay(date, day),
                          )) {
                            return Center(
                              child: Icon(
                                Icons.cookie_rounded,
                                size: 30,
                                color: Colours.greyPink,
                              ),
                            );
                          }
                        }
                        return null;
                      },
                    ),
                    focusedDay: vm.focusedDay,
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
                      selectedDecoration: BoxDecoration(
                        color: Colours.darkBrown.withValues(alpha: 0.8),
                        shape: BoxShape.circle,
                      ),
                    ),
                    availableGestures: AvailableGestures.horizontalSwipe,
                    onPageChanged: (focusedDay) => vm.onPageChanged(focusedDay),
                    selectedDayPredicate: (day) {
                      return isSameDay(vm.selectedDay, day);
                    },
                    onDaySelected: (selectedDay, focusedDay) =>
                        vm.onDaySelected(focusedDay, selectedDay),

                    startingDayOfWeek: StartingDayOfWeek.monday,
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Monthly Logs',
                      style: TextStyle(
                        color: Colours.darkBrown,
                        fontFamily: 'Poppins',
                        fontSize: 24,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        vm.setSelectedDay(null);
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: Colours.lightBrown,
                      ),
                      child: Text('All', style: importantTextStyle),
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
                  children: vm.isLoading
                      ? [Text('Loading....', style: backgroundTextStyle)]
                      : vm.recordDetails.isEmpty
                      ? [Text('No records found!', style: backgroundTextStyle)]
                      : vm.recordDetails.map((rec) {
                          return ChangeNotifierProvider<RecordHandler>.value(
                            value: vm,
                            child: RecordCard(
                              date: rec.date,
                              cost: rec.cost,
                              itemName: rec.itemName,
                              recordId: rec.record_id!,
                            ),
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
}
