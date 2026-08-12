import 'package:flutter/material.dart';
import 'package:frontend_munchies/models/post.dart';
import 'package:frontend_munchies/models/record.dart';
import 'package:frontend_munchies/models/user_profile.dart';
import 'package:frontend_munchies/screens/feedFeature/feed_view/like_button.dart';
import 'package:frontend_munchies/screens/feedFeature/view_models/post_view_model.dart';
import 'package:frontend_munchies/styles/colours.dart';
import 'package:frontend_munchies/styles/textStyles.dart';

class RecordDisplay extends StatefulWidget {
  Post post;
  final UserProfile posterProfile;
  final Record record;
  final double height;
  final double width;
  final Future<void> Function()? toggleLikesTest;

  RecordDisplay({
    super.key,
    required this.post,
    required this.posterProfile,
    required this.record,
    required this.height,
    required this.width,
    this.toggleLikesTest,
  });

  @override
  State<RecordDisplay> createState() => _RecordDisplayState();
}

class _RecordDisplayState extends State<RecordDisplay> {
  late var _isLiked = widget.post.isLiked;
  late var likesCount = widget.post.count;

  void toggleLikes() async {
    await vmToggleLikes(widget.record, _isLiked);
    setState(() {
      if (_isLiked) {
        likesCount -= 1;
      } else {
        likesCount += 1;
      }
      _isLiked = !_isLiked;
      widget.post.isLiked = _isLiked;
      widget.post.count = likesCount;
    });
  }

  @override
  Widget build(BuildContext context) {
    final imgUrl = widget.record.photo_URL;

    return Padding(
      padding: const EdgeInsets.only(
        left: 15.0,
        right: 15.0,
        top: 8.0,
        bottom: 8.0,
      ),
      child: Container(
        width: widget.width * 0.9,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          color: Colours.darkerBeige,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 15.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    LikeButton(
                      isLiked: _isLiked,
                      onPressed:
                          widget.toggleLikesTest ??
                          () {
                            toggleLikes();
                          },
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
                          widget.posterProfile.firstName.toString(),
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            color: Colours.darkBrown,
                            fontSize: 16,
                            fontWeight: FontWeight(600),
                          ),
                        ),
                        Text(
                          widget.record.date.toString().split(" ")[0],
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            color: Colours.darkBrown,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
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
                        Expanded(
                          child: Text(
                            widget.record.itemName,
                            style: TextStyle(
                              fontFamily: 'Cherry_Bomb_One',
                              color: Colours.darkBrown,
                              fontSize: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    //IMAGE HERE
                    imgUrl != null
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: widget.height * 0.25,
                                width: widget.width * 0.9 * 0.7,
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
                    (widget.record.details == null)
                        ? Row()
                        : widget.record.details!.isEmpty
                        ? Row()
                        : Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                widget.posterProfile.firstName.toString(),
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  color: Colours.darkBrown,
                                  fontSize: 16,
                                  fontWeight: FontWeight(600),
                                ),
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  widget.record.details!,
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
