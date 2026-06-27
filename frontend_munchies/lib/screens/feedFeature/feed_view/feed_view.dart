import 'package:flutter/material.dart';
import 'package:frontend_munchies/screens/feedFeature/view_models/feed_view_model.dart';
import 'package:frontend_munchies/styles/colours.dart';
import 'package:frontend_munchies/models/record.dart';
import 'package:frontend_munchies/screens/feedFeature/feed_view/record_display.dart';

class FeedView extends StatefulWidget {
  const FeedView({super.key});

  @override
  State<FeedView> createState() => _FeedViewState();
}

class _FeedViewState extends State<FeedView> {
  List<Record> friendsPosts = [];
  bool friendsPostsLoading = true;

  //initState, setState, helpers calling the getFriendsPosts function in the view model
  @override
  void initState() {
    super.initState();
    loadFriendsPosts();
  }

  Future<void> loadFriendsPosts() async {
    final result = await getFriendsPosts();

    if (!mounted) return;
    setState(() {
      friendsPosts = result;
      friendsPostsLoading = false;
    });
  }

  double getHeight(Record record) {
    if ((record.photo_URL == null) && (record.details != null)) {
      return 160;
    } else if ((record.photo_URL != null) && (record.details == null)) {
      return 350;
    } else if ((record.photo_URL != null) && (record.details != null)) {
      return 400;
    } else {
      return 120;
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
            child: (friendsPosts == [])
                ? Text("No posts from friends")
                : ListView.builder(
                    physics: ClampingScrollPhysics(),
                    padding: const EdgeInsets.all(8),
                    itemCount: friendsPosts.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Container(
                        //height: (friendsPosts[index].photo_URL == null) ? 120 : 350,
                        height: getHeight(friendsPosts[index]),
                        child: Center(
                          child: RecordDisplay(
                            record: friendsPosts[index],
                            height: height,
                            width: width,
                          ),
                          //child: Text('Entry ${friendsPosts[index]}'),
                        ),
                      );
                    },
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
              : Size.fromHeight(70),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 10.0, left: 20.0),
                    child: Text(
                      "View your friends' posts here!",
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        color: Colours.lightBrown,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
