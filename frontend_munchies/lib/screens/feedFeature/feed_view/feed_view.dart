import 'package:flutter/material.dart';
import 'package:frontend_munchies/models/post.dart';
import 'package:frontend_munchies/screens/feedFeature/view_models/feed_view_model.dart';
import 'package:frontend_munchies/screens/feedFeature/view_models/post_view_model.dart';
import 'package:frontend_munchies/screens/friendsFeature/friends_view/friends_button.dart';
import 'package:frontend_munchies/styles/colours.dart';
import 'package:frontend_munchies/screens/feedFeature/feed_view/record_display.dart';
import 'dart:async';
import 'package:frontend_munchies/utils/streams.dart';

class FeedView extends StatefulWidget {
  const FeedView({super.key});

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
    final result = await getFriendsPosts();
    print("FETCHING FRIEND POSTS");

    /*transform Records into Post
    List<Post> newList = [];
    for (final record in result) {
      final mongo_id = record.mongo_user_id;
      //friendsPosts.add(new Post())
      if (mongo_id == null) {
        continue;
      } else {
        final poster = await findUserInfo(mongo_id);
        final liked = await userLiked(record);
        newList.add(
          Post(record: record, posterProfile: poster, isLiked: liked),
        );
      }
    }
    */

    final posts = await Future.wait(
      result.map((record) async {
        final user = await findUserInfo(record.mongo_user_id!);
        final liked = await userLiked(record);

        return Post(record: record, posterProfile: user, isLiked: liked, count: record.likes?.length ?? 0);
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
      return height * 0.20;
    } else if ((record.photo_URL != null) && (record.details == null)) {
      return height * 0.38;
    } else if ((record.photo_URL != null) && (record.details != null)) {
      return height * 0.40;
      // return 400;
    } else {
      return height * 0.15;
    }
  }

  //ScrollConfiguration(
  //behavior: ScrollBehavior().copyWith(overscroll: false),
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    double height = size.height;
    double width = size.width;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Container(color: Colours.lightBeige, height: height * 0.9),
          //LISTVIEW BUILT HERE
          ScrollConfiguration(
            behavior: ScrollBehavior().copyWith(overscroll: false),
            child: RefreshIndicator(
              onRefresh: () async {
                await loadFriendsPosts();
              },
              child: ((friendsPosts.isEmpty)
                  ? Text("No posts from friends")
                  : ListView.builder(
                      physics: ClampingScrollPhysics(),
                      padding: const EdgeInsets.all(8),
                      itemCount: friendsPosts.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Container(
                          //height: (friendsPosts[index].photo_URL == null) ? 120 : 350,
                          height: getHeight(friendsPosts[index], height),
                          child: Center(
                            child: RecordDisplay(
                              key: ValueKey(
                                friendsPosts[index].record.record_id,
                              ),
                              post: friendsPosts[index],
                              posterProfile: friendsPosts[index].posterProfile,
                              record: friendsPosts[index].record,
                              height: height,
                              width: width,
                            ),
                            //child: Text('Entry ${friendsPosts[index]}'),
                          ),
                        );
                      },
                    )),
            ),
          ),
        ],
      ),
      appBar: AppBar(
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
