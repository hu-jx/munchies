import 'package:flutter/material.dart';
import 'package:frontend_munchies/screens/goalFeature/view/goal_view.dart';
import 'package:frontend_munchies/screens/profile/profile_vm.dart';
import 'package:frontend_munchies/screens/recommendationFeature/view/rec_view.dart';
import 'package:frontend_munchies/styles/colours.dart';
import 'package:frontend_munchies/styles/textStyles.dart';
import 'package:frontend_munchies/widgets/errorMessage.dart';
import 'package:frontend_munchies/widgets/profile_widgets/logout_button.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatelessWidget {
  final List<Widget>? pageWidgets;
  final ProfileVMRepo? viewModel;
  const ProfilePage({super.key, this.pageWidgets, this.viewModel});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ProfileVMRepo>(
      create: (_) => viewModel ?? ProfileVM(),
      child: ProfileView(pageWidgets: pageWidgets),
    );
  }
}

class ProfileView extends StatelessWidget {
  final List<Widget>? pageWidgets;
  const ProfileView({super.key, this.pageWidgets});

  @override
  Widget build(BuildContext context) {
    final ProfileVMRepo viewModel = context.watch<ProfileVMRepo>();
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colours.lightBeige,
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.only(left: 20.0, right: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Profile', style: importantTextStyle.copyWith(fontSize: 24)),
              LogoutButton(),
            ],
          ),
        ),
        automaticallyImplyLeading: false,
        // leading: LogoutButton(),
        // Icon(Icons.person),
        backgroundColor: Colours.lightPink.withValues(alpha: 0.3),
        toolbarHeight: 80,
      ),
      body: Container(
        color: Colours.lightBeige,
        width: MediaQuery.of(context).size.width,
        height: height,
        child:
            // Padding(
            //   padding: const EdgeInsets.only(top:12.0),
            // child:
            ScrollConfiguration(
              behavior: ScrollBehavior().copyWith(overscroll: false),
              child: SingleChildScrollView(
                child: Column(
                  children:
                      pageWidgets ??
                      [
                        SizedBox(height: 20),
                        viewModel.profile != null
                            ? buildUserNameRow(viewModel)
                            : ShowErrorMessage(
                                errorMessage: viewModel.errorMessage,
                              ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18.0,
                            vertical: 10.0,
                          ),
                          child: Divider(color: Colours.greyPink),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 25.0,
                                vertical: 0.0,
                              ),
                              child: Text('FOR YOU', style: titleStyle),
                            ),
                          ],
                        ),
                        SizedBox(height: 15),
                        //FriendsButton(),
                        GoalPost(),
                        SizedBox(height: 15),
                        RecView(),
                        // Text('Set goal here. Not yet implemented.'),
                        //Text("Search for friends here"),
                        // LogoutButton(),
                      ],
                ),
              ),
            ),
      ),
    );
    // );
  }

  Widget buildUserNameRow(ProfileVMRepo viewModel) {
    if (viewModel.isLoading) {
      return Center(child: CircularProgressIndicator(color: Colours.greyPink),);
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          viewModel.name,
          style: importantTextStyle.copyWith(
            fontSize: 24,
            fontFamily: 'Cherry_Bomb_One',
          ),
        ),
        Text(viewModel.emailAddress, style: backgroundTextStyle),
      ],
    );
  }
}
