import 'package:flutter/material.dart';
import 'package:frontend_munchies/screens/viewOptions_bottomBar/homePageView.dart';
import 'package:frontend_munchies/styles/colours.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  final List<Widget> _viewOptions = [
    HomePageView(), 
    const Center(child: Text('Dashboard. Not yet implemented.')), 
    const Center(child: Text('Track. Not yet implemented.')), 
    const Center(child: Text('Feed. Not yet implemented.')), 
    const Center(child: Text('Profile. Not yet implemented.'))
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/homepage_background.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,

        body: _viewOptions[_selectedIndex],

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
              icon: Icon(Icons.add_circle_rounded, color: Colours.greyPink),
              label: "Track",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.article_rounded),
              label: "Feed",
            ),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
          ],
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}
