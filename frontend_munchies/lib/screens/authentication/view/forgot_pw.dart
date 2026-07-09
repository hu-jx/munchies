import 'package:flutter/material.dart';
import 'package:frontend_munchies/screens/authentication/view_model/forgot_pw_vm.dart';
import 'package:frontend_munchies/styles/colours.dart';
import 'package:frontend_munchies/styles/logging_form_styles.dart';
import 'package:frontend_munchies/styles/textStyles.dart';
import 'package:frontend_munchies/widgets/button.dart';
import 'package:frontend_munchies/widgets/errorMessage.dart';
import 'package:provider/provider.dart';

class ResetPage extends StatelessWidget {
  const ResetPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(create: (_) => ForgotPwVm(), child: ForgotPW(),);
  }
}
class ForgotPW extends StatelessWidget {
  ForgotPW({super.key});
  final TextEditingController emailController = TextEditingController();
  

  @override
  Widget build(BuildContext context) {
    final ForgotPwVm viewModel = context.watch<ForgotPwVm>();
    double width = MediaQuery.of(context).size.width;
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/homepage_background.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: buildCenterBox(width, context, viewModel),
    );
  }

  // Widget buildBackground() {
  //   return Positioned.fill(
  //         child: Image.asset(
  //           'assets/images/homepage_background.png',
  //           fit: BoxFit.cover,
  //         ),
  //       );
  // }

  Widget buildCenterBox(double width, BuildContext context, ForgotPwVm viewModel) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text('RESET', style: titleStyle),
        toolbarHeight: 70.0,
        leading: IconButton(icon:Icon( Icons.arrow_back_rounded, color: Colours.greyPink), onPressed: () => Navigator.maybePop(context),),
      ),
      backgroundColor: Colors.transparent,
      body: Container(
        color: Colours.lightBeige,
        padding: EdgeInsets.symmetric(vertical: 30.0, horizontal: 20.0),
        // width: width,
        child: Column(
          spacing: 15.0,
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Flexible(
              child: Text(
                "Enter email address for password reset link:",
                style: importantTextStyle,
                textAlign: TextAlign.left,
              ),
            ),
            TextField(
              controller: emailController,
              decoration: InputDecoration()
                  .applyDefaults(optionalInputdecorationtheme)
                  .copyWith(
                    labelText: 'Email Address',
                    labelStyle: backgroundTextStyle,
                  ),
            ),
            AppButton(
              text: 'Send link',
              onPressed: () async =>
                  viewModel.sendResetLink(emailController.text),
              size: Size(width, 53),
            ),
            viewModel.status != null ? Text(viewModel.status!, style: inputTextStyle,) : ShowErrorMessage(errorMessage: viewModel.errorMessage)
          ],
        ),
      ),
    );
  }
}
