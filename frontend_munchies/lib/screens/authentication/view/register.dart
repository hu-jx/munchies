import 'package:flutter/material.dart';
import 'package:frontend_munchies/screens/authentication/view_model/authentication.dart';
import 'package:frontend_munchies/styles/colours.dart';
import 'package:frontend_munchies/widgets/errorMessage.dart';
import 'package:frontend_munchies/widgets/general_textfield.dart';
import 'package:frontend_munchies/widgets/pw_textfield.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frontend_munchies/widgets/button.dart';
import 'package:frontend_munchies/screens/main_screen.dart';

// Use GoogleFonts.font_family to obtain desired font (e.g. GoogleFonts.poppins)

class RegisterPage extends StatefulWidget {
  final Authentication authentication;
  final Homepage? homepage;
  RegisterPage({super.key, required this.authentication, this.homepage});

  final textStyle = GoogleFonts.poppins(
    color: Colours.greyPink,
    decorationColor: Colours.greyPink,
    fontSize: 16.0,
  );

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController confirmEmailController = TextEditingController();
  TextEditingController pwController = TextEditingController();
  TextEditingController confirmPwController = TextEditingController();
  TextEditingController fNameController = TextEditingController();
  TextEditingController lNameController = TextEditingController();

  String? errorMessage;
  bool _isLoading = false;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

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
    return ScrollConfiguration(
      behavior: ScrollBehavior().copyWith(overscroll: false),
      child: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height,
          ),
          child: Center(
            child: Container(
              width: 342.0,
              height: 710.0,
              decoration: BoxDecoration(
                color: Colours.darkerBeige,
                borderRadius: BorderRadius.circular(25),
              ),
              alignment: Alignment.center,
              child: buildCenter(),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildCenter() {
    return ScrollConfiguration(
      behavior: ScrollBehavior().copyWith(overscroll: false),
      child: SingleChildScrollView(
        child: Form(
          key: formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // SizedBox(height: 5.0),
              Center(
                child: Text(
                  'MUNCHIES',
                  style: GoogleFonts.cherryBombOne(
                    color: Colours.greyPink,
                    fontSize: 52.0,
                  ),
                ),
              ),
              Center(
                child: Text(
                  'Create an account with munchies',
                  style: widget.textStyle,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10, left: 30, bottom: 5),
                child: Text('Enter Email Address *', style: widget.textStyle),
              ),
              GeneralTextfield(
                controller: emailController,
                labelText: 'Email Address',
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10, left: 30, bottom: 5),
                child: Text('Confirm Email Address *', style: widget.textStyle),
              ),
              GeneralTextfield(
                controller: confirmEmailController,
                labelText: 'Confirm Email Address',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Field cannot be empty.";
                  }
                  if (emailController.text != confirmEmailController.text) {
                    return "Email did not match";
                  }
                  return null;
                },
              ),
              buildNameRow(),
              Padding(
                padding: const EdgeInsets.only(top: 10, left: 30, bottom: 5),
                child: Text('Enter Password *', style: widget.textStyle),
              ),
              PasswordTextfield(
                pwController: pwController,
                labelText: 'Password',
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10, left: 30, bottom: 5),
                child: Text('Confirm Password *', style: widget.textStyle),
              ),
              PasswordTextfield(
                pwController: confirmPwController,
                labelText: 'Confirm Password',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Field cannot be empty.";
                  }
                  if (pwController.text != confirmPwController.text) {
                    return "Password did not match";
                  }
                  return null;
                },
              ),
              Padding(
                padding: const EdgeInsets.only(top: 5, left: 30, bottom: 10),
                child: Text(
                  'Fields marked * are compulsory',
                  style: GoogleFonts.poppins(color: Colours.grey),
                ),
              ),
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
                          ),
                        ),
                      ],
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Center(
                          child: AppButton(
                            text: 'Sign up now!',
                            onPressed: () async {
                              if (formKey.currentState?.validate() == true) {
                                await tryRegister();
                              }
                            },
                            size: Size(298, 48),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Already have an account?',
                              style: GoogleFonts.poppins(color: Colours.grey),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text(
                                'Login now!',
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
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: ShowErrorMessage(errorMessage: errorMessage),
              ),
              // Center(
              //   child: Text(
              //     errorMessage ?? "",
              //     style: GoogleFonts.poppins(color: Colors.red, fontSize: 14.0),
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildNameRow() {
    return Padding(
      padding: EdgeInsets.only(left: 22, right: 22, top: 10),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('First Name *', style: widget.textStyle),
              SizedBox(
                // height: 48.0,
                width: 140,
                child: TextFormField(
                  
                  // maxLines: 3,
                  keyboardType: TextInputType.multiline,
                  controller: fNameController,
                  decoration: InputDecoration(
                    isDense: true, 
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 5,
                      horizontal: 16,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    labelText: 'First Name',
                    labelStyle: GoogleFonts.poppins(color: Colours.grey),
                    errorStyle: GoogleFonts.poppins(color: Colors.red,height:  1.0),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colours.grey),
                    ),
                    errorMaxLines: 3,
                    suffixIcon: fNameController.text.isEmpty
                        ? Container(width: 0.0)
                        : IconButton(
                            onPressed: () => fNameController.clear(),
                            icon: Icon(Icons.close),
                          ),
                  ),
                  style: GoogleFonts.poppins(),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Field cannot be empty.";
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Last Name', style: widget.textStyle),
              SizedBox(
                height: 48.0,
                width: 140,
                child: TextFormField(
                  controller: lNameController,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 5,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    labelText: 'Last Name *',
                    labelStyle: GoogleFonts.poppins(color: Colours.grey),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colours.grey),
                    ),
                    suffixIcon: lNameController.text.isEmpty
                        ? Container(width: 0.0)
                        : IconButton(
                            onPressed: () => lNameController.clear(),
                            icon: Icon(Icons.close),
                          ),
                  ),
                  style: GoogleFonts.poppins(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> tryRegister() async {
    try {
      setState(() {
        _isLoading = true;
        errorMessage = null;
      });
      await widget.authentication.register(
        emailController.text,
        pwController.text,
        fNameController.text,
        lNameController.text,
      );
      if (!mounted) return;
      setState(() {
        // errorMessage = null;
        _isLoading = false;
      });
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => widget.homepage ?? Homepage(),
          settings: RouteSettings(name: '/home'),
        ),
      );
    } catch (e) {
      debugPrint('caught error $e');
      setState(() {
        _isLoading = false;
        errorMessage = e.toString();
      });
    }
  }
}
