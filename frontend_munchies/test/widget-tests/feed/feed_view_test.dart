import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_munchies/models/user_profile.dart';
import 'package:frontend_munchies/screens/feedFeature/feed_view/feed_view.dart';
import 'package:frontend_munchies/screens/feedFeature/feed_view/record_display.dart';
import 'package:frontend_munchies/models/record.dart';

void main() {
  testWidgets("When feed posts is being fetched, loading indicator is displayed", (
    WidgetTester tester,
  ) async {
    final completer = Completer<List<Record>>();

    await tester.pumpWidget(
      MaterialApp(home: FeedView(getFriendsPostsTest: () => completer.future)),
    );

    final result = find.byType(CircularProgressIndicator);

    expect(result, findsOneWidget);
  });

  testWidgets("Correct display when there are no friend posts to be displayed", (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: FeedView(
          getFriendsPostsTest: () async => []
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text("No posts from friends, or no friends added yet"), findsOneWidget);
  });

  testWidgets("Correct display when there are friend posts to be displayed", (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: FeedView(
          getFriendsPostsTest: () async => [
            Record(
              record_id: "1",
              mongo_user_id: "test 1",
              itemName: "Test Record 1",
              date: DateTime.now(),
              cost: 2,
              isFavourited: false,
              isVisible: false,
            ),
            Record(
              record_id: "2",
              mongo_user_id: "test 2",
              itemName: "Test Record 2",
              date: DateTime.now(),
              cost: 2,
              isFavourited: false,
              isVisible: false,
            )
          ],
          findUserInfoTest: (p0) async => UserProfile(firebase_uid: "firebase_uid", emailAddress: "emailAddress", password: "password", firstName: "Mock User"),
          userLikedTest: (p0) async => false,
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(RecordDisplay), findsNWidgets(2));
    expect(find.text("Test Record 1"), findsOneWidget);
    expect(find.text("Test Record 2"), findsOneWidget);
  });


}
