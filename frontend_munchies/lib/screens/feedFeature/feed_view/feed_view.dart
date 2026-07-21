import 'package:flutter/material.dart';
import 'package:frontend_munchies/models/post.dart';
import 'package:frontend_munchies/models/user_profile.dart';
import 'package:frontend_munchies/screens/feedFeature/view_models/feed_view_model.dart';
import 'package:frontend_munchies/screens/feedFeature/view_models/post_view_model.dart';
import 'package:frontend_munchies/screens/friendsFeature/friends_view/friends_button.dart';
import 'package:frontend_munchies/styles/colours.dart';
import 'package:frontend_munchies/screens/feedFeature/feed_view/record_display.dart';
import 'package:frontend_munchies/styles/textStyles.dart';
import 'dart:async';
import 'package:frontend_munchies/utils/streams.dart';
import 'package:frontend_munchies/models/record.dart';

class FeedView extends StatefulWidget {
  final Future<List<Record>> Function()? getFriendsPostsTest;
  final Future<UserProfile> Function(String)? findUserInfoTest;
  final Future<bool> Function(Record)? userLikedTest;

  const FeedView({
    super.key,
    this.getFriendsPostsTest,
    this.findUserInfoTest,
    this.userLikedTest,
  });

  @override
  State<FeedView> createState() => _FeedViewState();
}

class _FeedViewState extends State<FeedView> {
  List<Post> friendsPosts = [];
  bool friendsPostsLoading = true;
  late StreamSubscription _subscription;

  //initState, setState, helpers calling the getFriendsPosts function in the view model
  @override
  void initState() {
    super.initState();
    loadFriendsPosts();
    _subscription = friendsUpdatedStream.listen((_) async {
      await loadFriendsPosts();
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  Future<void> loadFriendsPosts() async {
    final List<Record> result = (widget.getFriendsPostsTest != null)
        ? await widget.getFriendsPostsTest!()
        : await getFriendsPosts();
    //final result = await getFriendsPosts();
    print("FETCHING FRIEND POSTS");

    final posts = await Future.wait(
      result.map((record) async {
        final user = widget.findUserInfoTest != null
            ? await widget.findUserInfoTest!(record.mongo_user_id!)
            : await findUserInfo(record.mongo_user_id!);

        final liked = widget.userLikedTest != null
            ? await widget.userLikedTest!(record)
            : await userLiked(record);

        return Post(
          record: record,
          posterProfile: user,
          isLiked: liked,
          count: record.likes?.length ?? 0,
        );
      }),
    );

    if (!mounted) return;

    setState(() {
      //friendsPosts = result;
      friendsPosts = posts;
      friendsPostsLoading = false;
    });
  }

  double getHeight(Post post, double height) {
    final record = post.record;
    if ((record.photo_URL == null) && (record.details != null)) {
      return height * 0.25;
    } else if ((record.photo_URL != null) && (record.details == null)) {
      return height * 0.40;
    } else if ((record.photo_URL != null) && (record.details != null)) {
      return height * 0.42;
      // return 400;
    } else {
      return height * 0.20;
    }
  }

  //ScrollConfiguration(
  //behavior: ScrollBehavior().copyWith(overscroll: false),
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    double height = size.height;
    double width = size.width;

    if (friendsPostsLoading) {
      return Container(
        width: width,
        height: height * 0.9,
        color: Colours.lightBeige,
        child: Center(child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colours.greyPink),
          ],
        )),
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Container(color: Colours.lightBeige, height: height * 0.9),
          //LISTVIEW BUILT HERE
          ScrollConfiguration(
            behavior: ScrollBehavior().copyWith(overscroll: false),
            child: RefreshIndicator(
              backgroundColor: Colours.darkerBeige,
              color: Colours.greyPink,
              onRefresh: () async {
                await loadFriendsPosts();
              },
              child: ((friendsPosts.isEmpty)
                  ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                      children: [Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Flexible(
                            child: Text(
                              "No posts from friends, or no friends added yet",
                              style: backgroundTextStyle,
                            ),
                          ),
                        ],
                      )],
                    )
                  : ListView.builder(
                      physics: AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(8),
                      itemCount: friendsPosts.length,
                      itemBuilder: (BuildContext context, int index) {
                        return
                        //height: (friendsPosts[index].photo_URL == null) ? 120 : 350,
                        // height: getHeight(friendsPosts[index], height),
                        Center(
                          child: RecordDisplay(
                            key: ValueKey(friendsPosts[index].record.record_id),
                            post: friendsPosts[index],
                            posterProfile: friendsPosts[index].posterProfile,
                            record: friendsPosts[index].record,
                            height: height,
                            width: width,
                          ),
                          //child: Text('Entry ${friendsPosts[index]}'),
                        );
                      },
                    )),
            ),
          ),
        ],
      ),
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        automaticallyImplyLeading: false,
        backgroundColor: Color(0xff696969).withValues(alpha: 0.1),
        title: const Align(
          alignment: Alignment.topLeft,
          child: Padding(
            padding: EdgeInsets.only(left: 10.0, right: 10.0),
            child: Text(
              "FEED",
              style: TextStyle(
                fontFamily: 'Cherry_Bomb_One',
                fontSize: 57,
                color: Colours.greyPink,
              ),
            ),
          ),
        ),
        bottom: PreferredSize(
          preferredSize:
              MediaQuery.of(context).orientation == Orientation.landscape
              ? Size.fromHeight(height * 0.2)
              : Size.fromHeight(95),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 20.0),
                  child: Text(
                    "View your friends' posts here!",
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      color: Colours.lightBrown,
                    ),
                  ),
                ),
                FriendsButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
