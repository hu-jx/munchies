import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:frontend_munchies/screens/recommendationFeature/view_model/rec_view_model.dart';
import 'package:mocktail/mocktail.dart';
import 'package:http/http.dart' as http;

class MockClient extends Mock implements http.Client {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() {
    registerFallbackValue(Uri.parse('https://api'));
    registerFallbackValue('');
  });

  test('getRec returns data on success', () async {
    final mockUser = MockUser(uid: 'test-uid');
    final mockAuth = MockFirebaseAuth(mockUser: mockUser, signedIn: true);
    final mockClient = MockClient();
    final mockResponse = """
  {
    "tastePreference": "We noticed that you prefer sweet and creamy treats.",
      "recommendations": [
        { "name": "Greek Yogurt", "flavours": "creamy, tangy", "benefit": "High protein" },
        { "name": "Dark Chocolate", "flavours": "rich, bittersweet", "benefit": "Antioxidants" },
        { "name": "Frozen Banana", "flavours": "sweet, creamy, cold", "benefit": "Natural sugars" }
      ]
  }
""";

    when(
      () => mockClient.get(any(), headers: any(named: 'headers')),
    ).thenAnswer((_) async => http.Response(mockResponse, 200));

    final result = await getRec(auth: mockAuth, client: mockClient);

    expect(result, isNotNull);
    expect(result["tastePreference"], "We noticed that you prefer sweet and creamy treats.");
    expect(result["recommendations"].length, 3);
  });

  test('getRec returns error if server error occurs', () async {
    final mockUser = MockUser(uid: 'test-uid');
    final mockAuth = MockFirebaseAuth(mockUser: mockUser, signedIn: true);
    final mockClient = MockClient();

    when(
      () => mockClient.get(any(), headers: any(named: 'headers')),
    ).thenAnswer((_) async => http.Response('{"message": "Server error"}', 500));

    final result = await getRec(auth: mockAuth, client: mockClient);

    expect(result, { 'error': true });
  });

  test('getRec returns error if server error occurs', () async {
    final mockUser = MockUser(uid: 'test-uid');
    final mockAuth = MockFirebaseAuth(mockUser: mockUser, signedIn: true);
    final mockClient = MockClient();

    when(
      () => mockClient.get(any(), headers: any(named: 'headers')),
    ).thenAnswer((_) async => http.Response('{ "message" : "Not enough data, or Gemini API error occured" }', 200));

    final result = await getRec(auth: mockAuth, client: mockClient);

    expect(result.containsKey('message'), true);
  });
}
