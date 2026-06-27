import 'package:flutter/material.dart';
import 'package:frontend_munchies/models/record.dart';
import 'package:frontend_munchies/models/user_profile.dart';
import 'package:frontend_munchies/screens/feedFeature/feed_view/like_button.dart';
import 'package:frontend_munchies/screens/feedFeature/view_models/feed_view_model.dart';
import 'package:frontend_munchies/screens/feedFeature/view_models/post_view_model.dart';
import 'package:frontend_munchies/styles/colours.dart';
import 'package:frontend_munchies/styles/textStyles.dart';

class RecordDisplay extends StatefulWidget {
  final Record record;
  final double height;
  final double width;

  const RecordDisplay({
    super.key,
    required this.record,
    required this.height,
    required this.width,
  });

  @override
  State<RecordDisplay> createState() => _RecordDisplayState();
}

class _RecordDisplayState extends State<RecordDisplay> {
  bool isLoading = true;
  UserProfile? posterProfile;
  bool isLiked = false;

  late var image_url = widget.record.photo_URL;
  late var date = widget.record.date;
  late var itemName = widget.record.itemName;
  late var cost = widget.record.cost;
  late var mongo_user_id = widget.record.mongo_user_id;
  late var likes = widget.record.likes;
  late var likesCount = likes?.length ?? 0;
  late var caption = widget.record.details;

  @override
  void initState() {
    super.initState();
    loadPosterProfile();
    checkIfLiked();
  }

  void loadPosterProfile() async {
    final mongo_id = mongo_user_id;
    if (mongo_id == null) {
      throw Exception("No mongo_user_id, bad record entry");
    } else {
      final result = await findUserInfo(mongo_id);
      print(result);

      if (!mounted) return;

      setState(() {
        posterProfile = result;
        isLoading = false;
      });
    }
  }

  void checkIfLiked() async {
    final result = await userLiked(widget.record);
    setState(() {
      isLiked = result;
    });
  }

  void toggleLikes() async {
    await vmToggleLikes(widget.record, isLiked);
    setState(() {
      if (isLiked) {
        likesCount -= 1;
      } else {
        likesCount += 1;
      }
      isLiked = !isLiked;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return CircularProgressIndicator();
    }
    return recordDisplay(widget.height, widget.width);
  }

  Widget recordDisplay(double height, double width) {
    //test return Text('Entry ${record}');
    final imgUrl = image_url;
    //final likesCount = likes?.length ?? 0;
    if (posterProfile == null) {
      return Text("posterProfile missing");
    }
    return Padding(
      padding: const EdgeInsets.only(
        left: 15.0,
        right: 15.0,
        top: 8.0,
        bottom: 8.0,
      ),
      child: Container(
        height: height * 0.40,
        width: width * 0.90,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          color: Colours.darkerBeige,
          //border: BoxBorder.all(color: Colours.darkBrown),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 15.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    LikeButton(
                      isLiked: isLiked,
                      onPressed: (() => toggleLikes()),
                    ),
                    Text(likesCount.toString()),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          posterProfile!.firstName.toString(),
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            color: Colours.darkBrown,
                            fontSize: 16,
                            fontWeight: FontWeight(600),
                          ),
                        ),
                        Text(
                          date.toString().split(" ")[0],
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            color: Colours.darkBrown,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          "Munched on... ",
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            color: Colours.darkBrown,
                            fontSize: 16,
                          ),
                        ),
                        Flexible(
                          child: Text(
                            itemName,
                            style: TextStyle(
                              fontFamily: 'Cherry_Bomb_One',
                              color: Colours.darkBrown,
                              fontSize: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10,),
                    //IMAGE HERE
                    imgUrl != null
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: 200,
                                width: 278,
                                child: Image.network(
                                  imgUrl,
                                  fit: BoxFit.cover,
                                  alignment: Alignment.centerLeft,
                                ),
                              ),
                            ],
                          )
                        : Row(),
                    imgUrl != null ? SizedBox(height: 10) : Row(),
                    //CAPTION HERE
                    (caption == null)
                        ? SizedBox(height: 0)
                        : Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                posterProfile!.firstName.toString(),
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  color: Colours.darkBrown,
                                  fontSize: 16,
                                  fontWeight: FontWeight(600),
                                ),
                              ),
                              SizedBox(width: 10,),
                              Expanded(
                                child: Text(
                                  caption!,
                                  style: normalTextStyle,
                                  maxLines: null,
                                ),
                              ),
                            ],
                          ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
