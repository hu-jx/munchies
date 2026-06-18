import 'package:flutter/material.dart';
import 'package:frontend_munchies/screens/friendsFeature/friends_view/friends_button.dart';
import 'package:frontend_munchies/styles/colours.dart';
import 'package:frontend_munchies/styles/textStyles.dart';
import 'package:frontend_munchies/widgets/profile_widgets/logout_button.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colours.lightBeige,
      appBar: AppBar(
        titleSpacing:0,
        title: Text('Profile', style: inputTextStyle),
        automaticallyImplyLeading: false,
        leading: Icon(Icons.person),
        backgroundColor: Colours.greyPink.withValues(alpha: 0.35),
        toolbarHeight: 80,
      ),
      body: Container(
        color: Colours.lightBeige,
        width: MediaQuery.of(context).size.width,
        height: height,
        child: Padding(
          padding: const EdgeInsets.only(top:12.0),
          child: Column(
            children: [
              Text('Set goal here. Not yet implemented.'),
              //Text("Search for friends here"),
              FriendsButton(),
              LogoutButton(),
            ],
          ),
        ),
      ),
    );
  }
}
