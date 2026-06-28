import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:frontend_munchies/models/friend_request.dart';
import 'package:frontend_munchies/models/user_profile.dart';
import 'package:frontend_munchies/screens/friendsFeature/friends_view_model/friends_page_vm.dart';
import 'package:frontend_munchies/screens/friendsFeature/friends_view_model/search_view_model.dart';
import 'package:mocktail/mocktail.dart';
import 'package:http/http.dart' as http;

class MockClient extends Mock implements http.Client {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() {
    registerFallbackValue(Uri.parse('https://api'));
    registerFallbackValue('');
  });

  test('getFriendsList returns a list of Users', () async {
    final mockUser = MockUser(uid: 'test-uid');
    final mockAuth = MockFirebaseAuth(mockUser: mockUser, signedIn: true);
    final mockClient = MockClient();
    final mockResponse = """
[
  {
    "_id": "friend-test",
    "firebase_uid": "friend-firebase",
    "emailAddress": "friend@gmail.com",
    "firstName": "friend",
    "lastName": "",
    "createdAt": "2026-05-28T06:04:10.347Z",
    "updatedAt": "2026-06-19T14:07:54.401Z",
    "__v": 0,
    "friends": [
      "6a1847a77201fb95c1657fa3"
    ]
  }
]
""";

    when(
      () => mockClient.get(any(), headers: any(named: 'headers')),
    ).thenAnswer((_) async => http.Response(mockResponse, 200));

    final listRes = await getFriendsList(auth: mockAuth, client: mockClient);

    expect(listRes.runtimeType, List<UserProfile>);
    expect(listRes[0].mongo_id, "friend-test");
  });

  test('getPendingRequests returns a list of pending requests', () async {
    final mockUser = MockUser(uid: 'test-uid');
    final mockAuth = MockFirebaseAuth(mockUser: mockUser, signedIn: true);
    final mockClient = MockClient();

    final mockResponse = """
[
  {
    "_id": "request-id",
    "sender_id": {
      "_id": "sender-id",
      "firebase_uid": "sender-firebase",
      "emailAddress": "sender@gmail.com",
      "firstName": "sen",
      "lastName": "der",
      "friends": [],
      "createdAt": "2026-06-25T12:28:43.485Z",
      "updatedAt": "2026-06-25T12:41:11.141Z",
      "__v": 0
    },
    "receiver_id": "receiver-id",
    "status": "pending",
    "createdAt": "2026-06-25T12:39:18.133Z",
    "updatedAt": "2026-06-25T12:39:18.133Z",
    "__v": 0
  }
]
""";

    when(
      () => mockClient.get(any(), headers: any(named: 'headers')),
    ).thenAnswer((_) async => http.Response(mockResponse, 200));

    final listRes = await getPendingRequest(auth: mockAuth, client: mockClient);

    expect(listRes.runtimeType, List<FriendRequest>);
    expect(listRes[0].senderId.mongo_id, "sender-id");
    expect(listRes[0].receiverId, "receiver-id");
  });

  test('updateRequest updates Request in the database', () async {
    final mockUser = MockUser(uid: 'test-uid');
    final mockAuth = MockFirebaseAuth(mockUser: mockUser, signedIn: true);
    final mockClient = MockClient();

    when(
      () => mockClient.patch(any(), headers: any(named: 'headers')),
    ).thenAnswer(
      (_) async =>
          http.Response(' { "messsage": "Successfully changed status" }', 201),
    );

    await updateRequest(
      "sender-id",
      "receiver-id",
      "accepted",
      auth: mockAuth,
      client: mockClient,
    );

    verify(
      () => mockClient.patch(
        any(),
        headers: any(named: 'headers'),
      ),
    ).called(1);
  });
}
