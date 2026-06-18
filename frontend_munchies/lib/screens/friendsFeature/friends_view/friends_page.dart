import 'package:flutter/material.dart';
import 'package:frontend_munchies/screens/friendsFeature/friends_view/search_page.dart';
import 'package:frontend_munchies/styles/colours.dart';
import 'package:frontend_munchies/styles/textStyles.dart';

class FriendsPage extends StatefulWidget {
  const FriendsPage({super.key});

  @override
  State<FriendsPage> createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: 1,
      length: 2,
      child: Scaffold(
        backgroundColor: Colours.lightBeige,
        appBar: AppBar(
          title: Text("Friends", style: inputTextStyle),
          centerTitle: true,
          leading: backButton(),
          actions: [
            IconButton(
              onPressed: () {
                
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SearchPage()),
                );
                
              },
              icon: const Icon(Icons.search),
            ),
          ],
          backgroundColor: Colours.greyPink.withValues(alpha: 0.35),
          bottom: TabBar(
            indicator: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colours.darkBrown, width: 3)),
            ),
            labelStyle: TextStyle(
              fontFamily: "Poppins",
              color: Colours.darkBrown,
            ),
            tabs: <Widget>[
              Tab(text: "Friend List"),
              Tab(text: "Friend Requests"),
            ],
          ),
        ),
        //body, navigate between current friends and friend requests
        body: TabBarView(
          children: <Widget>[
            Center(child: Text("Friends displayed here. WIP")),
            Center(child: Text("Friend requests displayed here. WIP")),
          ],
        ),
      ),
    );
  }

  Widget backButton() {
    return IconButton(
      onPressed: () {
        Navigator.pop(context);
        /*
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ProfileView()),
        );
        */
      },
      icon: const Icon(Icons.arrow_back),
    );
  }
}

