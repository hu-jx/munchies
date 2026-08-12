import 'package:flutter/material.dart';
import 'package:frontend_munchies/models/friend_request.dart';
import 'package:frontend_munchies/models/user_profile.dart';
import 'package:frontend_munchies/screens/friendsFeature/friends_view/search_page.dart';
import 'package:frontend_munchies/screens/friendsFeature/friends_view_model/friends_page_vm.dart';
import 'package:frontend_munchies/screens/friendsFeature/friends_view_model/search_view_model.dart';
import 'package:frontend_munchies/services/user_services.dart';
import 'package:frontend_munchies/styles/colours.dart';
import 'package:frontend_munchies/styles/textStyles.dart';
import 'package:frontend_munchies/utils/streams.dart';

class FriendsPage extends StatefulWidget {
  final Future<List<UserProfile>> Function()? getFriendsListTest;
  final Future<List<FriendRequest>> Function()? getPendingRequestTest;

  const FriendsPage({
    super.key,
    this.getFriendsListTest,
    this.getPendingRequestTest,
  });

  @override
  State<FriendsPage> createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> {
  List<UserProfile> friendsList = [];
  bool friendsListLoading = true;
  List<FriendRequest> requestList = [];
  bool reqListLoading = true;

  @override
  void initState() {
    super.initState();
    loadFriends();
    loadRequests();
  }

  Future<void> loadFriends() async {
    final result = widget.getFriendsListTest != null
    ? await widget.getFriendsListTest!()
    : await getFriendsList();

    if (!mounted) return;
    setState(() {
      friendsList = result;
      friendsListLoading = false;
    });
  }

  Future<void> loadRequests() async {
    final requests = widget.getPendingRequestTest != null
    ? await widget.getPendingRequestTest!()
    : await getPendingRequest();

    if (!mounted) return;
    setState(() {
      requestList = requests;
      reqListLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: 0,
      length: 2,
      child: Scaffold(
        backgroundColor: Colours.lightBeige,
        appBar: AppBar(
          surfaceTintColor: Colors.transparent,
          title: Text("Friends", style: inputTextStyle),
          centerTitle: true,
          leading: backButton(),
          actions: [
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SearchPage(vm: SearchViewModel()),
                  ),
                );
              },
              icon: const Icon(Icons.search),
            ),
          ],
          backgroundColor: Colours.greyPink.withValues(alpha: 0.35),
          bottom: TabBar(
            indicator: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colours.darkBrown, width: 3),
              ),
            ),
            labelStyle: TextStyle(
              fontFamily: "Poppins",
              color: Colours.darkBrown,
            ),
            tabs: <Widget>[
              Tab(text: "Friend List"),
              Tab(text: "Friend Requests"),
            ],
          ),
        ),
        //body, navigate between current friends and friend requests
        body: TabBarView(
          children: [
            RefreshIndicator(
              onRefresh: () async {
                await loadFriends(); 
              },
              child: friendsDisplay(),
            ),
            requestsDisplay(),
          ],
        ),
      ),
    );
  }

  Widget backButton() {
    return IconButton(
      onPressed: () {
        Navigator.pop(context);
      },
      icon: const Icon(Icons.arrow_back),
    );
  }

  Widget removeFriendButton(UserProfile friend) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: Colours.lightBrown,
      ),
      onPressed: () async {
        confirmRemoveFriend(friend);
      },
      child: Text("Remove Friend", style: searchDisplayTS),
    );
  }

  Future<void> confirmRemoveFriend(UserProfile friend) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colours.darkerBeige,
        title: Text("Remove Friend", style: TextStyle(fontFamily: 'Poppins')),
        content: Text(
          "Are you sure you want to remove ${friend.firstName} as a friend?",
          style: TextStyle(fontFamily: 'Poppins'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false), // cancel
            child: Text("Cancel", style: TextStyle(fontFamily: 'Poppins')),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true), // confirm
            child: Text(
              "Remove",
              style: TextStyle(color: Colors.red, fontFamily: 'Poppins'),
            ),
          ),
        ],
      ),
    );

    final currentUser = await UserServices.getCurrentUP();
    final currentUserId = currentUser.mongo_id;
    final friendId = friend.mongo_id;
    if (currentUserId == null || friendId == null) {
      throw Exception('Invalid ids');
    }

    if (confirmed == true) {
      setState(() {
        friendsListLoading = true;
      });
      await removeFriend(currentUserId, friendId);
      friendsUpdatedController.add(null);
      await loadFriends();
    }
  }

  Widget friendsDisplay() {
    if (friendsListLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colours.greyPink),
      );
    } else if (friendsList.isEmpty) {
      return Center(child: Text("No friends yet", style: normalTextStyle));
    }
    return ListView.separated(
      physics: const ClampingScrollPhysics(),
      padding: const EdgeInsets.all(8),
      itemCount: friendsList.length,
      itemBuilder: (BuildContext context, int index) {
        final user = friendsList[index];
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colours.darkerBeige,
              borderRadius: BorderRadius.circular(25),
            ),
            child: Padding(
              padding: EdgeInsetsGeometry.symmetric(vertical: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Name: ${user.firstName}',
                    style: TextStyle(fontFamily: "Poppins", fontSize: 18),
                  ),
                  Text(
                    'Email: ${user.emailAddress}',
                    style: TextStyle(fontFamily: "Poppins", fontSize: 16),
                  ),
                  removeFriendButton(user),
                ],
              ),
            ),
          ),
        );
      },
      separatorBuilder: (BuildContext context, int index) => const Divider(),
    );
  }

  Widget requestsDisplay() {
    if (reqListLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colours.greyPink),
      );
    } else if (requestList.isEmpty) {
      return Center(
        child: Text("No friend requests currently", style: normalTextStyle),
      );
    }
    return ListView.separated(
      physics: const ClampingScrollPhysics(),
      padding: const EdgeInsets.all(8),
      itemCount: requestList.length,
      itemBuilder: (BuildContext context, int index) {
        final req = requestList[index];
        final senderProfile = req.senderId;
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            height: 150,
            decoration: BoxDecoration(
              color: Colours.darkerBeige,
              borderRadius: BorderRadius.circular(25),
            ),
            child: requestFormat(req, senderProfile),
          ),
        );
      },
      separatorBuilder: (BuildContext context, int index) => const Divider(),
    );
  }

  Widget requestFormat(FriendRequest req, UserProfile senderProfile) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Name: ${senderProfile.firstName}',
          style: TextStyle(fontFamily: "Poppins", fontSize: 18),
        ),
        Text(
          'Email: ${senderProfile.emailAddress}',
          style: TextStyle(fontFamily: "Poppins", fontSize: 16),
        ),
        SizedBox(height: 15),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: () async {
                await sendResponse(req, "accepted");
                friendsUpdatedController.add(null);
              },
              label: Text("Accept", style: normalTextStyle),
              icon: Icon(Icons.check),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colours.pieGreen,
                elevation: 0,
              ),
            ),
            SizedBox(width: 20),
            ElevatedButton.icon(
              onPressed: () {
                sendResponse(req, "declined");
              },
              label: Text("Decline", style: normalTextStyle),
              icon: Icon(Icons.close),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colours.pieRed,
                elevation: 0,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> sendResponse(FriendRequest request, String response) async {
    //to update the backend
    //Response should only be accepted or declined
    try {
      final senderMongoId = request.senderId.mongo_id;
      if (senderMongoId == null) {
        throw Exception("Sender ID is null");
      }
      await updateRequest(senderMongoId, request.receiverId, response);
      if (!mounted) return;

      //after responding, remove from pending list
      setState(() {
        requestList.removeWhere((item) => item.mongo_id == request.mongo_id);
      });
      if (response == "accepted") {
        await loadFriends();
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to update request, try again")),
      );
    }
  }
}
