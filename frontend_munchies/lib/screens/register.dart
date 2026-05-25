import 'package:flutter/material.dart';
import 'package:frontend_munchies/styles/colours.dart';
import 'package:frontend_munchies/widgets/general_textfield.dart';
import 'package:frontend_munchies/widgets/pw_textfield.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frontend_munchies/widgets/button.dart';
// Use GoogleFonts.font_family to obtain desired font (e.g. GoogleFonts.poppins)

class RegisterPage extends StatefulWidget {
  final emailController = TextEditingController();
  final confirmEmailController = TextEditingController();
  final pwController = TextEditingController();
  final confirmPwController = TextEditingController();
  final fNameController = TextEditingController();
  final lNameController = TextEditingController();

  final textStyle = GoogleFonts.poppins(
    color: Colours.greyPink,
    decorationColor: Colours.greyPink,
    fontSize: 16.0,
  );

  RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
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
        height: 700.0,
        decoration: BoxDecoration(
          color: Colours.darkerBeige,
          borderRadius: BorderRadius.circular(25),
        ),
        child: buildCenter(),
      ),
    );
  }

  Widget buildCenter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 10.0),
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
          controller: widget.emailController,
          labelText: 'Email Address',
        ),
        Padding(
          padding: const EdgeInsets.only(top: 10, left: 30, bottom: 5),
          child: Text('Confirm Email Address *', style: widget.textStyle),
        ),
        GeneralTextfield(
          controller: widget.confirmEmailController,
          labelText: 'Confirm Email Address',
        ),
        buildNameRow(),
        Padding(
          padding: const EdgeInsets.only(top: 10, left: 30, bottom: 5),
          child: Text('Enter Password *', style: widget.textStyle),
        ),
        PasswordTextfield(
          pwController: widget.pwController,
          labelText: 'Password',
        ),
        Padding(
          padding: const EdgeInsets.only(top: 10, left: 30, bottom: 5),
          child: Text('Confirm Password *', style: widget.textStyle),
        ),
        PasswordTextfield(
          pwController: widget.pwController,
          labelText: 'Confirm Password',
        ),
        Padding(
          padding: const EdgeInsets.only(top: 5, left: 30, bottom: 10),
          child: Text(
            'Fields marked * are compulsory',
            style: GoogleFonts.poppins(color: Colours.grey),
          ),
        ),
        Center(
          child: AppButton(text: 'Sign up now!', onPressed: () {}),
        ),
        Center(
          child: TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(
              'Back to login page',
              style: GoogleFonts.poppins(
                color: Colours.grey,
                decorationColor: Colours.grey,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildNameRow() {
    return Padding(
      padding: EdgeInsets.only(left: 22, right: 22, top: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('First Name *', style: widget.textStyle),
              SizedBox(
                height: 48.0,
                width: 140,
                child: TextField(
                  controller: widget.fNameController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    labelText: 'First Name',
                    labelStyle: GoogleFonts.poppins(color: Colours.grey),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colours.grey),
                    ),
                    suffixIcon: widget.fNameController.text.isEmpty
                        ? Container(width: 0.0)
                        : IconButton(
                            onPressed: () => widget.fNameController.clear(),
                            icon: Icon(Icons.close),
                          ),
                  ),
                  style: GoogleFonts.poppins(),
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Last Name', style: widget.textStyle),
              SizedBox(
                height: 48.0,
                width: 140,
                child: TextField(
                  controller: widget.lNameController,
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
                    suffixIcon: widget.lNameController.text.isEmpty
                        ? Container(width: 0.0)
                        : IconButton(
                            onPressed: () => widget.lNameController.clear(),
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
}
