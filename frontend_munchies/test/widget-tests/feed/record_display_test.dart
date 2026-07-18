import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_munchies/models/post.dart';
import 'package:frontend_munchies/models/user_profile.dart';
import 'package:frontend_munchies/screens/feedFeature/feed_view/like_button.dart';
import 'package:frontend_munchies/screens/feedFeature/feed_view/record_display.dart';
import 'package:frontend_munchies/models/record.dart';

void main() {
  testWidgets("Shows favorited icon when liked", (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(home: LikeButton(isLiked: true, onPressed: () {})),
    );
    await tester.pump();

    expect(find.byIcon(Icons.favorite), findsOne);
    expect(find.byIcon(Icons.favorite_border_outlined), findsNothing);
  });

  testWidgets("Shows favorite_border_outlined icon when not liked", (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(home: LikeButton(isLiked: false, onPressed: () {})),
    );
    await tester.pump();

    expect(find.byIcon(Icons.favorite), findsNothing);
    expect(find.byIcon(Icons.favorite_border_outlined), findsOne);
  });

  testWidgets("Liking: Like button changes isLiked state", (
    WidgetTester tester,
  ) async {
    var liked = false;

    await tester.pumpWidget(
      MaterialApp(
        home: LikeButton(
          isLiked: false,
          onPressed: () {
            liked = true;
          },
        ),
      ),
    );

    await tester.tap(find.byType(LikeButton));
    await tester.pump();

    expect(liked, true);
  });

  testWidgets("Unliking: Like button changes isLiked state", (
    WidgetTester tester,
  ) async {
    var liked = true;

    await tester.pumpWidget(
      MaterialApp(
        home: LikeButton(
          isLiked: true,
          onPressed: () {
            liked = false;
          },
        ),
      ),
    );

    await tester.tap(find.byType(LikeButton));
    await tester.pump();

    expect(liked, false);
  });

  testWidgets("Like button pressed in a record display", (
    WidgetTester tester,
  ) async {
    var likeButtonPressed = false;

    UserProfile user = UserProfile(
      firebase_uid: "firebase_uid",
      emailAddress: "emailAddress",
      password: "password",
      firstName: "test",
    );
    Record record = Record(
      record_id: "1",
      mongo_user_id: "test 1",
      itemName: "Test Record 1",
      date: DateTime.now(),
      cost: 2,
      isFavourited: false,
      isVisible: false,
    );
    Post post = Post(
      record: record,
      posterProfile: user,
      isLiked: false,
      count: 0,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: RecordDisplay(
          post: post,
          posterProfile: user,
          record: record,
          height: 200,
          width: 400,
          toggleLikesTest: () async {
            likeButtonPressed = true;
          },
        ),
      ),
    );

    await tester.tap(find.byType(LikeButton));
    await tester.pump();

    expect(likeButtonPressed, true);
  });
}
