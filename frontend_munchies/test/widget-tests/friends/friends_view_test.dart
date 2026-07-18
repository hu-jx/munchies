import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_munchies/models/friend_request.dart';
import 'package:frontend_munchies/models/user_profile.dart';
import 'package:frontend_munchies/screens/friendsFeature/friends_view/friends_page.dart';

void main() {
  testWidgets("Displays correct message when friends list is empty", (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: FriendsPage(
          getFriendsListTest: () async => [],
          getPendingRequestTest: () async => [],
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text("No friends yet"), findsOne);
  });

  testWidgets("Displays List View when friends list is not empty", (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: FriendsPage(
          getFriendsListTest: () async => [
            UserProfile(
              firebase_uid: "firebase_uid",
              emailAddress: "test1_address@gmail.com",
              password: "password",
              firstName: "test1",
              mongo_id: "valid_mongo_id",
            ),
            UserProfile(
              firebase_uid: "firebase_uid",
              emailAddress: "test2_address@gmail.com",
              password: "password",
              firstName: "test2",
              mongo_id: "valid_mongo_id",
            ),
          ],
          getPendingRequestTest: () async => [],
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(ListView), findsOne);
    expect(find.text("Name: test1"), findsOne);
    expect(find.text("Name: test2"), findsOne);
  });

  testWidgets("Remove friend button present in each friend display", (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: FriendsPage(
          getFriendsListTest: () async => [
            UserProfile(
              firebase_uid: "firebase_uid",
              emailAddress: "test1_address@gmail.com",
              password: "password",
              firstName: "test1",
              mongo_id: "valid_mongo_id",
            ),
            UserProfile(
              firebase_uid: "firebase_uid",
              emailAddress: "test2_address@gmail.com",
              password: "password",
              firstName: "test2",
              mongo_id: "valid_mongo_id",
            ),
          ],
          getPendingRequestTest: () async => [],
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(ElevatedButton), findsExactly(2));
    expect(find.text("Remove Friend"), findsExactly(2));
  });

  //test for friend requests
  testWidgets("Displays correct message when friends requests list is empty", (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: FriendsPage(
          getFriendsListTest: () async => [],
          getPendingRequestTest: () async => [],
        ),
      ),
    );

    await tester.pumpAndSettle();

    await tester.tap(find.text("Friend Requests"));
    await tester.pumpAndSettle();

    expect(find.text("No friend requests currently"), findsOne);
  });

  testWidgets("Displays friend requests", (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: FriendsPage(
          getFriendsListTest: () async => [],
          getPendingRequestTest: () async => [
            FriendRequest(
              mongo_id: "mongo_id",
              senderId: UserProfile(
                firebase_uid: "firebase_uid",
                emailAddress: "test1_address@gmail.com",
                password: "password",
                firstName: "friend 1",
                mongo_id: "valid_mongo_id",
              ),
              receiverId: "friend 4",
              status: "pending",
            ),
            FriendRequest(
              mongo_id: "mongo_id",
              senderId: UserProfile(
                firebase_uid: "firebase_uid",
                emailAddress: "test1_address@gmail.com",
                password: "password",
                firstName: "friend 2",
                mongo_id: "valid_mongo_id",
              ),
              receiverId: "friend 4",
              status: "pending",
            ),
            FriendRequest(
              mongo_id: "mongo_id",
              senderId: UserProfile(
                firebase_uid: "firebase_uid",
                emailAddress: "test1_address@gmail.com",
                password: "password",
                firstName: "friend 3",
                mongo_id: "valid_mongo_id",
              ),
              receiverId: "friend 4",
              status: "pending",
            ),
          ],
        ),
      ),
    );

    await tester.pumpAndSettle();

    await tester.tap(find.text("Friend Requests"));
    await tester.pumpAndSettle();

    expect(find.byType(ListView), findsOne);
    expect(find.text("Name: friend 1"), findsOne);
    expect(find.text("Name: friend 2"), findsOne);
    expect(find.text("Name: friend 3"), findsOne);
  });

  testWidgets("Accept and remove buttons present for each friend", (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: FriendsPage(
          getFriendsListTest: () async => [],
          getPendingRequestTest: () async => [
            FriendRequest(
              mongo_id: "mongo_id",
              senderId: UserProfile(
                firebase_uid: "firebase_uid",
                emailAddress: "test1_address@gmail.com",
                password: "password",
                firstName: "friend 1",
                mongo_id: "valid_mongo_id",
              ),
              receiverId: "friend 4",
              status: "pending",
            ),
            FriendRequest(
              mongo_id: "mongo_id",
              senderId: UserProfile(
                firebase_uid: "firebase_uid",
                emailAddress: "test1_address@gmail.com",
                password: "password",
                firstName: "friend 2",
                mongo_id: "valid_mongo_id",
              ),
              receiverId: "friend 4",
              status: "pending",
            ),
          ],
        ),
      ),
    );

    await tester.pumpAndSettle();

    await tester.tap(find.text("Friend Requests"));
    await tester.pumpAndSettle();

    expect(find.byType(ElevatedButton), findsExactly(4));
    expect(find.text("Accept"), findsExactly(2));
    expect(find.text("Decline"), findsExactly(2));
  });
}
