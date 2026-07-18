import 'dart:async';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_munchies/models/user_profile.dart';
import 'package:frontend_munchies/screens/friendsFeature/friends_view/search_page.dart';
import 'package:frontend_munchies/screens/friendsFeature/friends_view/searched_profile.dart';
import 'package:frontend_munchies/screens/friendsFeature/friends_view_model/search_view_model.dart';

void main() {
  testWidgets("Displays requestButton for user who is not a friend", (
    WidgetTester tester,
  ) async {
    final user = UserProfile(
      firebase_uid: "firebase_uid",
      emailAddress: "test_address@gmail.com",
      password: "password",
      firstName: "test",
      mongo_id: "valid_mongo_id",
    );
    final otherUser = UserProfile(
      firebase_uid: "firebase_uid",
      emailAddress: "other_address@gmail.com",
      password: "password",
      firstName: "other_test",
      mongo_id: "other_valid_mongo_id",
    );

    final mockAuth = MockFirebaseAuth();

    final vm = SearchViewModel(auth: mockAuth);

    vm.findUsersTest = (query) async {
      vm.foundUser = otherUser;
    };

    await tester.binding.setSurfaceSize(
    const Size(412, 915),
  );

    await tester.pumpWidget(
      MaterialApp(
        home: SearchPage(
          vm: vm,
          getCurrentUPTest: () async {
            return user;
          },
          checkStatusTest: (_, __) async => "Request does not exist",
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), "test_address@gmail.com");

    await tester.pumpAndSettle();

    expect(find.byType(SearchedProfile), findsOne);
    expect(find.byType(ElevatedButton), findsOne);
    expect(find.text("Send friend request"), findsOne);
  });

  testWidgets("Displays Friends status for user is already a friend", (
    WidgetTester tester,
  ) async {
    final user = UserProfile(
      firebase_uid: "firebase_uid",
      emailAddress: "test_address@gmail.com",
      password: "password",
      firstName: "test",
      mongo_id: "valid_mongo_id",
    );
    final otherUser = UserProfile(
      firebase_uid: "firebase_uid",
      emailAddress: "other_address@gmail.com",
      password: "password",
      firstName: "other_test",
      mongo_id: "other_valid_mongo_id",
    );

    final mockAuth = MockFirebaseAuth();

    final vm = SearchViewModel(auth: mockAuth);

    vm.findUsersTest = (query) async {
      vm.foundUser = otherUser;
    };

    await tester.pumpWidget(
      MaterialApp(
        home: SearchPage(
          vm: vm,
          getCurrentUPTest: () async {
            return user;
          },
          checkStatusTest: (_, __) async => "Accepted",
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), "test_address@gmail.com");

    await tester.pumpAndSettle();

    expect(find.byType(SearchedProfile), findsOne);
    expect(find.byType(ElevatedButton), findsNothing);
    expect(find.text("Friends"), findsOne);
  });

  testWidgets("Displays Requested status when a request has been sent", (
    WidgetTester tester,
  ) async {
    final user = UserProfile(
      firebase_uid: "firebase_uid",
      emailAddress: "test_address@gmail.com",
      password: "password",
      firstName: "test",
      mongo_id: "valid_mongo_id",
    );
    final otherUser = UserProfile(
      firebase_uid: "firebase_uid",
      emailAddress: "other_address@gmail.com",
      password: "password",
      firstName: "other_test",
      mongo_id: "other_valid_mongo_id",
    );

    final mockAuth = MockFirebaseAuth();

    final vm = SearchViewModel(auth: mockAuth);

    vm.findUsersTest = (query) async {
      vm.foundUser = otherUser;
    };

    await tester.pumpWidget(
      MaterialApp(
        home: SearchPage(
          vm: vm,
          getCurrentUPTest: () async {
            return user;
          },
          checkStatusTest: (_, __) async => "From user",
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), "test_address@gmail.com");

    await tester.pumpAndSettle();

    expect(find.byType(SearchedProfile), findsOne);
    expect(find.byType(ElevatedButton), findsNothing);
    expect(find.text("Requested"), findsOne);
  });

  testWidgets("Displays Requested by friend status when a request has been received", (
    WidgetTester tester,
  ) async {
    final user = UserProfile(
      firebase_uid: "firebase_uid",
      emailAddress: "test_address@gmail.com",
      password: "password",
      firstName: "test",
      mongo_id: "valid_mongo_id",
    );
    final otherUser = UserProfile(
      firebase_uid: "firebase_uid",
      emailAddress: "other_address@gmail.com",
      password: "password",
      firstName: "other_test",
      mongo_id: "other_valid_mongo_id",
    );

    final mockAuth = MockFirebaseAuth();

    final vm = SearchViewModel(auth: mockAuth);

    vm.findUsersTest = (query) async {
      vm.foundUser = otherUser;
    };

    await tester.pumpWidget(
      MaterialApp(
        home: SearchPage(
          vm: vm,
          getCurrentUPTest: () async {
            return user;
          },
          checkStatusTest: (_, __) async => "To user",
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), "test_address@gmail.com");

    await tester.pumpAndSettle();

    expect(find.byType(SearchedProfile), findsOne);
    expect(find.byType(ElevatedButton), findsNothing);
    expect(find.text("Requested by friend"), findsOne);
  });

  testWidgets("Displays Your Own User when searched profile is the user's", (
    WidgetTester tester,
  ) async {
    final user = UserProfile(
      firebase_uid: "firebase_uid",
      emailAddress: "test_address@gmail.com",
      password: "password",
      firstName: "test",
      mongo_id: "valid_mongo_id",
    );

    final mockAuth = MockFirebaseAuth();

    final vm = SearchViewModel(auth: mockAuth);

    vm.findUsersTest = (query) async {
      vm.foundUser = user;
    };

    await tester.pumpWidget(
      MaterialApp(
        home: SearchPage(
          vm: vm,
          getCurrentUPTest: () async {
            return user;
          },
          checkStatusTest: (_, __) async => "Own user",
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), "test_address@gmail.com");

    await tester.pumpAndSettle();

    expect(find.byType(SearchedProfile), findsOne);
    expect(find.byType(ElevatedButton), findsNothing);
    expect(find.text("Your own user!"), findsOne);
  });
}
