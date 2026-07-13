import 'package:flutter/material.dart';
import 'package:frontend_munchies/screens/friendsFeature/friends_view/friends_page.dart';
import 'package:frontend_munchies/styles/textStyles.dart';

class FriendsButton extends StatefulWidget {
  const FriendsButton({super.key});

  @override
  State<FriendsButton> createState() => _FriendsButtonState();
}

class _FriendsButtonState extends State<FriendsButton> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => FriendsPage()),
              );
            },
            child: Text('Manage friends', style: importantTextStyle),
          ),
        ],
      ),
    );
  }
}

