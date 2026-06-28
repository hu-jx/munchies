import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:mocktail/mocktail.dart';
import 'package:http/http.dart' as http;
import 'package:frontend_munchies/models/record.dart';
import 'package:frontend_munchies/screens/feedFeature/view_models/post_view_model.dart';

class MockClient extends Mock implements http.Client {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() {
    registerFallbackValue(Uri.parse('https://api'));
  });

  test('vmToggleLikes adds like when isLiked is false', () async {
    final mockUser = MockUser(uid: 'test-uid');
    final mockAuth = MockFirebaseAuth(mockUser: mockUser, signedIn: true);
    final mockClient = MockClient();

    when(
      () => mockClient.patch(any(), headers: any(named: 'headers')),
    ).thenAnswer(
      (_) async =>
          http.Response('{"message": "Successfully removed like"}', 201),
    );

    final rec = Record(
      record_id: "test-record-id",
      itemName: "newRecord",
      date: DateTime(2026, 6, 27),
      cost: 50,
      isFavourited: false,
      isVisible: false,
    );

    await vmToggleLikes(rec, false, auth: mockAuth, client: mockClient);

    verify(
      () => mockClient.patch(any(), headers: any(named: 'headers')),
    ).called(1);
  });

    test('vmToggleLikes removes like when isLiked is true', () async {
    final mockUser = MockUser(uid: 'test-uid');
    final mockAuth = MockFirebaseAuth(mockUser: mockUser, signedIn: true);
    final mockClient = MockClient();

    when(
      () => mockClient.patch(any(), headers: any(named: 'headers')),
    ).thenAnswer(
      (_) async =>
          http.Response('{"message": "Successfully removed like"}', 201),
    );

    final rec = Record(
      record_id: "test-record-id",
      itemName: "newRecord",
      date: DateTime(2026, 6, 27),
      cost: 50,
      isFavourited: false,
      isVisible: false,
    );

    await vmToggleLikes(rec, true, auth: mockAuth, client: mockClient);

    verify(
      () => mockClient.patch(any(), headers: any(named: 'headers')),
    ).called(1);
  });
}
