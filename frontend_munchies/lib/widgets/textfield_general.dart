//no longer used but not deleting in case i needa refer to it again!
import 'package:flutter/material.dart';
import 'package:frontend_munchies/styles/colours.dart';
import 'package:google_fonts/google_fonts.dart';

class TextfieldGeneral extends StatefulWidget {
  const TextfieldGeneral({super.key});

  @override
  State<StatefulWidget> createState() => _TextfieldGeneralState();
}

class _TextfieldGeneralState extends State<TextfieldGeneral> {
  final emailController = TextEditingController();
  String password = '';
  bool isPwVisible = false;
  bool keepLoggedIn = false;

  @override
  void initState() {
    super.initState();
    emailController.addListener(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        buildEmail(),
        SizedBox(height: 10.0),
        buildPw(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Transform.scale(
                  scale: 0.8,
                  child: Checkbox(
                    value: keepLoggedIn,
                    onChanged: (value) {
                      setState(() {
                        keepLoggedIn = value!;
                      });
                    },
                  ),
                ),

                Text(
                  'Keep me logged in',
                  style: GoogleFonts.poppins(color: Colours.grey),
                ),
              ],
            ),
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

        OutlinedButton(
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
        ),
      ],
    );
  }

  Widget buildEmail() {
    return SizedBox(
      height: 48.0,
      width: 298.0,
      child: TextField(
        controller: emailController,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          labelText: 'Email Address',
          labelStyle: GoogleFonts.poppins(color: Colours.grey),
          enabledBorder: OutlineInputBorder(
            borderSide:BorderSide(color: Colours.grey)
          ),
          suffixIcon: emailController.text.isEmpty
              ? Container(width: 0.0)
              : IconButton(
                  onPressed: () => emailController.clear(),
                  icon: Icon(Icons.close),
                ),
        ),
        style: GoogleFonts.poppins(),
        keyboardType: TextInputType.emailAddress,
      ),
    );
  }

  Widget buildPw() {
    return SizedBox(
      height: 48.0,
      width: 298.0,
      child: TextField(
        onChanged: (value) => setState(() => password = value),
        onSubmitted: (value) => setState(() => password = value),
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          labelText: 'Password',
          labelStyle: GoogleFonts.poppins(color: Colours.grey),
          //errorText: 'Password is wrong',
          suffixIcon: IconButton(
            icon: isPwVisible
                ? Icon(Icons.visibility_off)
                : Icon(Icons.visibility),
            onPressed: () => setState(() => isPwVisible = !isPwVisible),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide:BorderSide(color: Colours.grey)
          ),
        ),
        obscureText: isPwVisible,
        style: GoogleFonts.poppins(),
      ),
    );
  }
}
