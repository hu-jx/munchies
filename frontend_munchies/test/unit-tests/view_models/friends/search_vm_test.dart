import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
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

  test('findUsers returns correct User Profile', () async {
    final mockUser = MockUser(uid: 'test-uid');
    final mockAuth = MockFirebaseAuth(mockUser: mockUser, signedIn: true);
    final mockClient = MockClient();

    final mockResponse = '''
{ "_id": "test-id",
  "firebase_uid": "test-firebase-id",
  "emailAddress": "findUser_test@gmail.com",
  "firstName": "findUserTest",
  "lastName": "",
  "createdAt": "2026-05-28T06:04:10.347Z",
  "updatedAt": "2026-06-19T14:07:54.401Z",
  "__v": 0,
  "friends": []
}
''';

  when(
      () => mockClient.get(any(), headers: any(named: 'headers')),
    ).thenAnswer(
      (_) async => http.Response(mockResponse, 200),
    );

  final vm = SearchViewModel(auth: mockAuth, client: mockClient);

  await vm.findUsers("findUser_test@gmail.com");

  expect(vm.foundUser?.firebase_uid, "test-firebase-id");
  expect(vm.foundUser?.emailAddress, "findUser_test@gmail.com");
  expect(vm.foundUser?.mongo_id, "test-id");
  });

  test('checkStatus returns correct friend status', () async {
    final mockUser = MockUser(uid: "test-uid");
    final mockAuth = MockFirebaseAuth(mockUser: mockUser, signedIn: true);
    final mockClient = MockClient();

    final mockResponse = '{ "message": "Accepted" }';

    when(
      () => mockClient.get(any(), headers: any(named: 'headers')),
    ).thenAnswer(
      (_) async => http.Response(mockResponse, 200),
    );

    final results = await checkStatus("test-sender-uid", "test-receiver-uid", auth: mockAuth, client: mockClient);

    expect(results, "Accepted");

  });

  test('sendRequest works properly', () async {
    final mockUser = MockUser(uid: "test-uid");
    final mockAuth = MockFirebaseAuth(mockUser: mockUser, signedIn: true);
    final mockClient = MockClient();

    final mockResponse = '{ "message": "Successfully sent request" }';

    when(
      () => mockClient.post(any(), headers: any(named: 'headers'),  body: any(named: 'body')),
    ).thenAnswer(
      (_) async => http.Response(mockResponse, 201),
    );

    await sendRequest("test-sender-uid", "test-receiver-uid", auth: mockAuth, client: mockClient);

    verify(() => mockClient.post(any(), headers: any(named: 'headers'), body: any(named: 'body'))).called(1);

  });
}
