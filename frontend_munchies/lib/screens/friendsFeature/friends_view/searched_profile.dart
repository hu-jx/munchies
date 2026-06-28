// for profile display after searching

// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:frontend_munchies/models/user_profile.dart';
import 'package:frontend_munchies/screens/friendsFeature/friends_view_model/search_view_model.dart';
import 'package:frontend_munchies/services/user_services.dart';
import 'package:frontend_munchies/styles/colours.dart';
import 'package:frontend_munchies/styles/textStyles.dart';

class SearchedProfile extends StatefulWidget {
  final UserProfile userProfile;

  const SearchedProfile({super.key, required this.userProfile});

  @override
  State<SearchedProfile> createState() => _SearchedProfileState();
}

class _SearchedProfileState extends State<SearchedProfile> {
  UserProfile? currUser;
  late UserProfile foundUser;
  String status = "loading";

  Future<void> loadCurrentUP() async {
    final retrievedProfile = await UserServices.getCurrentUP();

    final newStatus = await checkStatus(
      retrievedProfile.mongo_id!,
      widget.userProfile.mongo_id!,
    );

    //check if widget was changed before calling setState
    if (!mounted) return;

    setState(() {
      currUser = retrievedProfile;
      if (currUser?.mongo_id == foundUser.mongo_id) {
        status = "Own user";
      } else {
        status = newStatus;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    loadCurrentUP();
    foundUser = widget.userProfile;
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    double height = size.height;
    double width = size.width;

    final currentUser = currUser;

    if (currentUser == null) {
      return Center(child: CircularProgressIndicator(color: Colours.greyPink,));
    }

    return Container(
      height: height * 0.195,
      width: width * 0.85,
      decoration: BoxDecoration(
        color: Colours.darkerBeige,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Padding(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text("Name: ", style: importantTextStyle),
                Text(foundUser.firstName, style: normalTextStyle),
              ],
            ),
            Text("Email Address: ", style: importantTextStyle),
            Text(foundUser.emailAddress, style: normalTextStyle),
            //BUTTONS FOR REQUESTING
            SizedBox(height: 10),
            Center(child: friendStatus(status, currentUser, foundUser)),
          ],
        ),
      ),
    );
    //return Center(child: Text(widget.firstName + ": " + widget.emailAddress + "IN SEARCHEDPROFILECLASS"),);
  }

  Widget friendStatus(String status, UserProfile sender, UserProfile receiver) {
    //based on the returned status, determine which buttons to show
    if (status == "Accepted") {
      return reuseContainer(400, "Friends");
    } else if (status == "From user") {
      return reuseContainer(400, "Requested");
    } else if (status == "To user") {
      return reuseContainer(400, "Requested by friend");
    } else if (status == "Declined") {
      //change to RequestButton, when allowing for resending is added into the app
      return reuseContainer(400, "Declined, resending not available ");
    } else if (status == "Own user") {
      return reuseContainer(400, "Your own user!");
    } else if (status == "Request does not exist") {
      //Request Button
      return requestButton(sender, receiver);
    } else {
      return Text("Unknown error");
    }
  }

  Widget requestButton(UserProfile sender, UserProfile receiver) {
    final sender_id = sender.mongo_id;
    final receiver_id = receiver.mongo_id;

    if (sender_id == null || receiver_id == null) {
      return Text("Error: Invalid IDs");
    }

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: Colours.lightBrown,
      ),
      onPressed: () async {
        try {
          //if (!mounted) return;
          await sendRequest(sender_id, receiver_id);
          if (!mounted) return;
          setState(() {
            status = "From user";
          });
        } catch (e) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Failed to send request, try again")),
          );
        }
      },
      child: Text("Send friend request", style: searchDisplayTS),
    );
  }

  Widget reuseContainer(double width, String text) {
    return Container(
      height: 40,
      width: width,
      decoration: BoxDecoration(
        color: Colours.lightBrown,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Center(child: Text(text, style: searchDisplayTS)),
    );
  }
}
