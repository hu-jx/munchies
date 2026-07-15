import 'package:flutter/material.dart';
import 'package:frontend_munchies/screens/authentication/view/login.dart';
import 'package:frontend_munchies/screens/authentication/view_model/authentication.dart';
import 'package:frontend_munchies/styles/colours.dart';
import 'package:frontend_munchies/styles/textStyles.dart';

class LogoutButton extends StatefulWidget {
  const LogoutButton({super.key});

  @override
  State<LogoutButton> createState() => _LogoutButtonState();
}

class _LogoutButtonState extends State<LogoutButton> {
  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        PopupMenuItem(value: 'Log out', child: Text('Log out', style: inputTextStyle,)),
      ],
      onSelected: (value) async {
        if (value == 'Log out') {
          await _showConfirmationModal();
        }
      },
      color: Colours.lightBeige,
      icon: Icon(Icons.person),
    );

    // Padding(
    //   padding: const EdgeInsets.only(left: 12.0),
    //   child: Row(
    //     mainAxisAlignment: MainAxisAlignment.start,
    //     children: [
    //       TextButton(
    //         onPressed: _showConfirmationModal,
    //         child: Text('Log Out', style: importantTextStyle),
    //       ),
    //     ],
    //   ),
    // );
  }

  Future<void> _onLogoutPressed() async {
    await Authentication.logout();
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LoginPage(authentication: Authentication.real()),
      ),
    );
  }

  Future<void> _showConfirmationModal() async {
    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colours.darkerBeige,
          title: Text('Are you sure you want to log out?'),
          titleTextStyle: importantTextStyle,
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            TextButton(
              onPressed: _onLogoutPressed,
              style: TextButton.styleFrom(foregroundColor: Colours.lightBrown),
              child: Text(
                'Log Out',
                style: TextStyle(
                  color: Colors.red[400],
                  fontFamily: 'Poppins',
                  fontSize: 18,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(foregroundColor: Colours.lightBrown),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Colours.darkBrown,
                  fontFamily: 'Poppins',
                  fontSize: 18,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
