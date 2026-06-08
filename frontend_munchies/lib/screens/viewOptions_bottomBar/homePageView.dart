// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:frontend_munchies/screens/viewOptions_tabBar/activities.dart';
import 'package:frontend_munchies/screens/viewOptions_tabBar/calendar.dart';
import 'package:frontend_munchies/styles/colours.dart';

enum ActivityFilter { all, daily, weekly }

class HomePageView extends StatefulWidget {
  const HomePageView({super.key});

  @override
  State<HomePageView> createState() => _HomePageViewState();
}

class _HomePageViewState extends State<HomePageView>
    with SingleTickerProviderStateMixin {
  ActivityFilter _selectedFilter = ActivityFilter.all;

  late TabController _tabController;
  // bool _isExpanded = false;
  ActivitiesView currView = ActivitiesView(filter: ActivityFilter.all);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    double height = size.height;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Color(0xff696969).withValues(alpha: 0.1),
        title: const Align(
          alignment: Alignment.topLeft,
          child: Padding(
            padding: EdgeInsets.only(left:10.0, right: 10.0),
            child: Text(
              "HOME",
              style: TextStyle(
                fontFamily: 'Cherry_Bomb_One',
                fontSize: 60,
                color: Colours.greyPink,
              ),
            ),
          ),
        ),
        bottom: PreferredSize(
          preferredSize: MediaQuery.of(context).orientation == Orientation.landscape ? Size.fromHeight(height * 0.22) : Size.fromHeight(height * 0.1),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: TabBar(
                  dividerHeight: 0,
                  indicatorColor: Colours.greyPink,
                  controller: _tabController,
                  tabs: [
                    Tab(
                      child: Text(
                        "Activities",
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          color: Colours.greyPink,
                        ),
                      ),
                    ),
                    Tab(
                      child: Text(
                        "Calendar",
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          color: Colours.greyPink,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (_tabController.index == 0)
                PopupMenuButton<ActivityFilter>(
                  color: Colours.darkerBeige,
                  icon: Icon(
                    Icons.arrow_drop_down_rounded,
                    size: 75,
                    color: Colours.greyPink,
                  ),
                  initialValue: _selectedFilter,
                  //notify listener to call _fetch again when this change occurs 
                  onSelected: (ActivityFilter res) {
                    debugPrint(res.toString());
                    setState(() {
                      if (res != _selectedFilter) {
                        currView = ActivitiesView(filter: res);
                      }
                      _selectedFilter = res;

                    });
                    debugPrint(currView.filter.toString());
                  },
                  itemBuilder: (BuildContext context) =>
                      <PopupMenuEntry<ActivityFilter>>[
                        PopupMenuItem<ActivityFilter>(
                          value: ActivityFilter.daily,
                          child: Text(
                            'Daily',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              color: Colours.darkBrown,
                            ),
                          ),
                        ),
                        PopupMenuItem<ActivityFilter>(
                          value: ActivityFilter.weekly,
                          child: Text(
                            'Weekly',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              color: Colours.darkBrown,
                            ),
                          ),
                        ),
                        PopupMenuItem(
                          value: ActivityFilter.all,
                          child: Text(
                            'All',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              color: Colours.darkBrown,
                            ),
                          ),
                        ),
                      ],
                )
              else
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Icon(
                    Icons.calendar_month_rounded,
                    size: 59,
                    color: Colours.greyPink,
                  ),
                ),
            ],
          ),
        ),
      ),
      backgroundColor: Colors.transparent,
      body: TabBarView(
        key: ValueKey(currView),
        controller: _tabController,
        //tabbarview does not update automatically 
        children: [currView, CalendarView()],
      ),
    );
  }
}
