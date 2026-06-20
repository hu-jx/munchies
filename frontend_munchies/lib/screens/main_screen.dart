import 'package:flutter/material.dart';
//import 'package:frontend_munchies/screens/viewOptions_bottomBar/dashboard_view.dart';
import 'package:frontend_munchies/screens/dashboardFeature/dashboard.dart';
import 'package:frontend_munchies/screens/viewOptions_bottomBar/homePageView.dart';
import 'package:frontend_munchies/screens/viewOptions_bottomBar/profile_view.dart';
import 'package:frontend_munchies/screens/activities/data/repositories/record_changer.dart';
import 'package:frontend_munchies/styles/colours.dart';
import 'package:frontend_munchies/screens/loggingFeature/views/logging_widgets/logging_options.dart';
import 'package:popover/popover.dart';
import 'package:provider/provider.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  int _selectedIndex = 0;
  

  void _onItemTapped(int index) {
    setState(() {
      if (index != 2) {
        _selectedIndex = index;
      }
    });
  }

  final List<Widget> _viewOptions = [
    HomePageView(),
    //DashboardView(),
    Dashboard(),
    //const Center(child: Text('Dashboard. Not yet implemented.')),
    const Center(child: Text('Track. Not yet implemented.')),
    const Center(child: Text('Feed. Not yet implemented.')),
    ProfileView(),
  ];

  @override
  void initState() {
    super.initState();
    Provider.of<RecordRepoImpl>(context, listen: false);

  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    double height = size.height;
    double width = size.width;
    return Stack(
      children: [
        // Background image — always has finite constraints from the Stack
        Positioned.fill(
          child: Image.asset(
            'assets/images/homepage_background.png',
            fit: BoxFit.cover,
          ),
        ),
      Scaffold(
        backgroundColor: Colors.transparent,
    
        body: IndexedStack(index: _selectedIndex,children: _viewOptions,),
    
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: TextStyle(fontFamily: 'Poppins', height: 1),
          unselectedLabelStyle: TextStyle(
            fontFamily: 'Poppins',
            height: 1,
            color: Colours.greyPink.withValues(alpha: 0.75),
          ),
          selectedItemColor: Colours.greyPink,
          unselectedItemColor: Colours.greyPink.withValues(alpha: 0.4),
          selectedIconTheme: IconThemeData(color: Colours.lightPink, size: 40),
          unselectedIconTheme: IconThemeData(
            color: Colours.lightPink.withValues(alpha: 0.4),
            size: 30,
          ),
          backgroundColor: Colours.lightBeige,
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              label: "Home",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart_rounded),
              label: "Dashboard",
            ),
            BottomNavigationBarItem(
              icon: Builder(
                builder: (context) {
                  return GestureDetector(
                    onTap: () => showPopover(
                      context: context,
                      bodyBuilder: (context) => LoggingOptions(),
                      width: width *0.757,
                      height: height * 0.181,
                      direction: PopoverDirection.top,
                      backgroundColor: Color(0xffD0A09F),
                      barrierDismissible: true
                    ),
                    child: Icon(
                      Icons.add_circle_rounded,
                      color: Colours.greyPink,
                      size: 40,
                    ),
                  );
                }
              ),
              label: 'Track',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.article_rounded),
              label: "Feed",
            ),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
          ],
          onTap: _onItemTapped,
        ),
      )],
    );
  }
}
