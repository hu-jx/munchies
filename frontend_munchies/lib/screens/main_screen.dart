import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:frontend_munchies/screens/activities/domain/repositories/record_repo.dart';
//import 'package:frontend_munchies/screens/viewOptions_bottomBar/dashboard_view.dart';
import 'package:frontend_munchies/screens/dashboardFeature/dashboard.dart';
import 'package:frontend_munchies/screens/feedFeature/feed_view/feed_view.dart';
import 'package:frontend_munchies/screens/activities/views/homePageView.dart';
import 'package:frontend_munchies/screens/profile/profile_view.dart';
import 'package:frontend_munchies/styles/colours.dart';
import 'package:frontend_munchies/screens/loggingFeature/views/logging_widgets/logging_options.dart';
import 'package:popover/popover.dart';
import 'package:provider/provider.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class Homepage extends StatefulWidget {
  final List<Widget> viewOptions;
  final FirebaseMessaging? messaging; 
  const Homepage({
    super.key,
    this.viewOptions = const [
      HomePageView(),
      //DashboardView(),
      Dashboard(),
      //const Center(child: Text('Dashboard. Not yet implemented.')),
      Center(child: Text('Track.')),
      //const Center(child: Text('Feed. Not yet implemented.')),
      FeedView(),
      ProfilePage(),
    ],
    this.messaging
  });

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

  //REMOVE AFT JS TO GET TOKENS FOR NOTIF
  void getToken() async {
    if (widget.messaging != null) {
      // debugPrint("GOT HERE");
      return;
    } else {
      // debugPrint("ENTERED NORMAL FIREBASE MESSAGING");
    await FirebaseMessaging.instance.deleteToken();
    String? token = await FirebaseMessaging.instance.getToken();
    // debugPrint("FCM TOKEN: $token");
    }
  }

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {}
    else if (Platform.isAndroid) {
      getToken();
    }
    Provider.of<RecordRepository>(context, listen: false);
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

          body: IndexedStack(
            index: _selectedIndex,
            children: widget.viewOptions,
          ),

          bottomNavigationBar: BottomNavigationBar(
            // showUnselectedLabels: false,
            currentIndex: _selectedIndex,
            
            type: BottomNavigationBarType.fixed,
            selectedLabelStyle: TextStyle(fontFamily: 'Poppins', height: 1, overflow: TextOverflow.visible),
            unselectedLabelStyle: TextStyle(
              fontSize: 12,
              fontFamily: 'Poppins',
              height: 1,
              color: Colours.greyPink.withValues(alpha: 0.75),
              overflow: TextOverflow.visible
            ),
            selectedItemColor: Colours.greyPink,
            unselectedItemColor: Colours.greyPink.withValues(alpha: 0.4),
            selectedIconTheme: IconThemeData(
              color: Colours.lightPink,
              size: 40,
            ),
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
                        width: width * 0.757,
                        height: height * 0.181,
                        direction: PopoverDirection.top,
                        backgroundColor: Color(0xffD0A09F),
                        barrierDismissible: true,
                      ),
                      child: Icon(
                        Icons.add_circle_rounded,
                        color: Colours.greyPink,
                        size: 40,
                      ),
                    );
                  },
                ),
                label: 'Track',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.article_rounded),
                label: "Feed",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: "Profile",
              ),
            ],
            onTap: _onItemTapped,
          ),
        ),
      ],
    );
  }
}
