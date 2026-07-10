import 'package:flutter/material.dart';
import 'package:frontend_munchies/screens/authentication/notif_helper.dart';
// import 'package:frontend_munchies/models/user_profile.dart';
import 'package:frontend_munchies/screens/main_screen.dart';
import 'package:frontend_munchies/styles/colours.dart';
import 'package:frontend_munchies/widgets/errorMessage.dart';
import 'package:frontend_munchies/widgets/pw_textfield.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frontend_munchies/widgets/general_textfield.dart';
import 'package:frontend_munchies/screens/authentication/register.dart';
import 'package:frontend_munchies/widgets/button.dart';
import 'package:frontend_munchies/services/auth/authentication.dart';
// Use GoogleFonts.font_family to obtain desired font (e.g. GoogleFonts.poppins)

class LoginPage extends StatefulWidget {
  final Authentication authentication;
  final Homepage? homepage;
  const LoginPage({super.key, required this.authentication, this.homepage});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final pwController = TextEditingController();
  String? errorMessage;
  bool _isLoading = false;

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
        padding: EdgeInsets.only(top:12.0, bottom: 20.0, left: 12.0, right: 12.0),
        width: 342.0,
        // height: 430.0,
        decoration: BoxDecoration(
          color: Colours.darkerBeige,
          borderRadius: BorderRadius.circular(25),
        ),
        child: buildCenter(),
      ),
    );
  }

  Widget buildCenter() {
    return SizedBox(
      width: 342.0,
      // height
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 5),
          Text(
            'MUNCHIES',
            style: GoogleFonts.cherryBombOne(
              color: Colours.greyPink,
              fontSize: 52.0,
            ),
          ),
          Text(
            'You need an account to continue!',
            style: GoogleFonts.poppins(
              color: Colours.greyPink,
              fontSize: 16.0,
            ),
          ),
          SizedBox(height: 10.0),
          buildTextfields(),
          _isLoading
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // SizedBox(height: MediaQuery.of(context).size.height * 0.02,),
                    Padding(
                      padding: const EdgeInsets.all(40),
                      child: SizedBox(
                        height: 10,
                        width: 298,
                        child: LinearProgressIndicator(
                          color: Colours.greyPink,
                          backgroundColor: Colours.darkerBeige,
                          // strokeWidth: 6.0,
                        ),
                        // height: 60,
                        //   width: 60,
                        //   child: CircularProgressIndicator(
                        //     color: Colours.greyPink,
                        //     backgroundColor: Colours.darkerBeige,
                        //     strokeWidth: 6.0,)
                      ),
                    ),
                  ],
                )
              : Column(
                  children: [
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
                      onPressed: () async {
                        if (formKey.currentState?.validate() == true) {
                          await tryLogin();
                        }
                      },
                      size: Size(298, 48),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          fit: FlexFit.loose,
                          child: Text(
                            'New to Munchies?',
                            style: GoogleFonts.poppins(color: Colours.grey),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => RegisterPage(
                                  authentication: Authentication.real(),
                                ),
                              ),
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
                  ],
                ),
          //Text("test"),
          ShowErrorMessage(errorMessage: errorMessage),
          // Text(
          //   errorMessage ?? "",
          //   style: GoogleFonts.poppins(color: Colors.red, fontSize: 14.0),
          // ),
        ],
      ),
    );
  }

  Widget buildTextfields() {
    return Form(
      key: formKey,
      child: Column(
        children: [
          GeneralTextfield(
            controller: emailController,
            labelText: 'Email Address',
          ),
          SizedBox(height: 10.0),
          PasswordTextfield(pwController: pwController, labelText: 'Password'),
        ],
      ),
    );
  }

  Future<void> tryLogin() async {
    try {
      setState(() {
        errorMessage = null;
        _isLoading = true;
      });
      //if successful, route to homepage
      await widget.authentication.login(
        emailController.text,
        pwController.text,
      );
      // TO DO: IF SUCCESSFUL, add the FCM Token to the User profile(call addFCMToken in the backend)
      print("helper registerToken function called");
      await registerToken();
      // if (!mounted) return;
      // setState(() {
      //   errorMessage = null;
      // });
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      widget.homepage != null ? Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => widget.homepage!,
          settings: RouteSettings(name: '/home'),
        ),
        (Route<dynamic> route) => false,
      ) : Navigator.pushNamedAndRemoveUntil(context, '/home', (Route<dynamic> route) => false);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
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
