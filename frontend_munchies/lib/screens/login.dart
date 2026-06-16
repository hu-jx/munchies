import 'package:flutter/material.dart';
// import 'package:frontend_munchies/models/user_profile.dart';
import 'package:frontend_munchies/screens/main_screen.dart';
import 'package:frontend_munchies/styles/colours.dart';
import 'package:frontend_munchies/widgets/pw_textfield.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frontend_munchies/widgets/general_textfield.dart';
import 'package:frontend_munchies/screens/register.dart';
import 'package:frontend_munchies/widgets/button.dart';
import 'package:frontend_munchies/services/auth/authentication.dart';
// Use GoogleFonts.font_family to obtain desired font (e.g. GoogleFonts.poppins)

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  final emailController = TextEditingController();
  final pwController = TextEditingController();
  String? errorMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: [buildBackground(), buildCenterBox()]),
    );
  }

  Widget buildBackground() {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/login_bg.png"),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget buildCenterBox() {
    return Center(
      child: Container(
        width: 342.0,
        height: 430.0,
        decoration: BoxDecoration(
          color: Colours.darkerBeige,
          borderRadius: BorderRadius.circular(25),
        ),
        child: buildCenter(),
      ),
    );
  }

  Widget buildCenter() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 5,),
          Text(
            'MUNCHIES',
            style: GoogleFonts.cherryBombOne(
              color: Colours.greyPink,
              fontSize: 52.0,
            ),
          ),
          Text(
            'You need an account to continue!',
            style: GoogleFonts.poppins(color: Colours.greyPink, fontSize: 16.0),
          ),
          SizedBox(height: 10.0),
          buildTextfields(),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  //redirect to reset pw page
                },
                child: Text(
                  'Forget password',
                  style: GoogleFonts.poppins(
                    color: Colours.grey,
                    decoration: TextDecoration.underline,
                    decorationColor: Colours.grey,
                  ),
                ),
              ),
            ],
          ),
          //disable button while trying to log in to prevent multiple navigation. 
          //enable button once logged in
          AppButton(
            text: 'Login',
            onPressed: tryLogin,
            size: Size(298, 48),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'New to Munchies?',
                style: GoogleFonts.poppins(color: Colours.grey),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RegisterPage()),
                  );
                  //redirect to sign up page
                },
                child: Text(
                  'Sign up now!',
                  style: GoogleFonts.poppins(
                    color: Colours.greyPink,
                    decorationColor: Colours.greyPink,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
          //Text("test"),
          Text(errorMessage ?? "", style: GoogleFonts.poppins(color: Colors.red, fontSize: 14.0)),
        ],
      ),
    );
  }

  Widget buildTextfields() {
    return Column(
      children: [
        GeneralTextfield(
          controller: emailController,
          labelText: 'Email Address',
        ),
        SizedBox(height: 10.0),
        PasswordTextfield(pwController: pwController, labelText: 'Password'),
      ],
    );
  }

  Future<void> tryLogin() async {
    try {
      debugPrint("CALLED");
      //if successful, route to homepage
      await Authentication().login(emailController.text, pwController.text);
      if (!mounted) return;
      setState(() {
        errorMessage = null;
      });
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Homepage(), 
        settings: RouteSettings(name: '/home')),
      );
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
      });
    }
  }

  /*
  Widget buildButton() {
    return OutlinedButton(
          onPressed: () {
            //logic here, call API to the server, pass pw and email to the server and check it, then code response
          },
          style: OutlinedButton.styleFrom(
            backgroundColor: Colours.greyPink,
            fixedSize: Size(298, 48),
          ),
          child: Text(
            'Login',
            style: GoogleFonts.poppins(color: Colors.white, fontSize: 16.0),
          ),
        );
  }
  */
}
