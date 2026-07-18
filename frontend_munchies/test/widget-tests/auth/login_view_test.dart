import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_munchies/models/user_profile.dart';
import 'package:frontend_munchies/screens/activities/domain/repositories/record_repo.dart';
import 'package:frontend_munchies/screens/authentication/view/login.dart';
import 'package:frontend_munchies/screens/main_screen.dart';
import 'package:frontend_munchies/services/auth/auth_services_repo.dart';
import 'package:frontend_munchies/screens/authentication/view_model/authentication.dart';
import 'package:frontend_munchies/widgets/button.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';

import '../../mocks/mock_navi_observer.dart';
import '../activities/root_screen_test.dart';

//view test
class MockFirebaseAuth extends Mock implements FirebaseAuth {}
class MockAuthService extends Mock implements AuthServicesRepo {}
class MockRecordRepo extends Mock implements RecordRepository {}
class MockUserCredential extends Mock implements UserCredential {}
class MockUser extends Mock implements User {}
void main() {
  late UserProfile mockProfile;
  late Authentication mockAuth;
  late MockFirebaseAuth mockFirebaseAuth;
  late MockAuthService mockAuthService;
  late MockNaviObserver mockNaviObserver;
  late MockRecordRepo mockRecordRepo;
  late MockUserCredential userCredential;
  late MockUser user;

  setUp(() {
    // streamController = StreamController.broadcast();
    // filter = ActivityFilter.all;
    userCredential = MockUserCredential();
    user = MockUser();
    mockProfile = UserProfile(firebase_uid: 'id', emailAddress: 'test@gmail.com', password: 'testing123', firstName: 'mockProfile');
    mockRecordRepo = MockRecordRepo();
    mockNaviObserver = MockNaviObserver();
    mockFirebaseAuth = MockFirebaseAuth();
    mockAuthService = MockAuthService();
    mockAuth = Authentication(firebaseAuth: mockFirebaseAuth, apiServices: mockAuthService);

    //stub get user method in mockusercred
    when(() => userCredential.user).thenReturn(user);
    //stub user method 
    when(() => user.getIdToken()).thenAnswer((_) async => 'idToken');

    //stub fetchUserProfile method
    when(() => mockAuthService.fetchProfileData(any<String>()),).thenAnswer((_) async => mockProfile);
    //stub signInWith.... method
    when(() => mockFirebaseAuth.signInWithEmailAndPassword(email: any<String>(named: 'email'), password: any<String>(named: 'password')))
    .thenAnswer((inv) async {
      return userCredential;
    }
    );
  });

  Widget createLoginPage({List<NavigatorObserver> naviObs = const []}) {
    return Provider<RecordRepository>.value(value: mockRecordRepo, 
    child: MaterialApp(
      navigatorObservers: naviObs,
      home: Scaffold(body: LoginPage(authentication: mockAuth, 
      homepage: Homepage(viewOptions: [
        const Placeholder(),
        const Placeholder(),
        const Placeholder(),
        const Placeholder(),
        const Placeholder(),
      ],
      messaging: MockFirebaseMessaging(),),)),
    ),);
  }

  Future<void> loadLoginPage(WidgetTester tester) async {
    await tester.pumpWidget(createLoginPage(naviObs: [mockNaviObserver]));
    await tester.pumpAndSettle();
  }

  testWidgets('set up', (tester) async {
    await loadLoginPage(tester);
    expect(find.byType(LoginPage), findsOne);
  });
  testWidgets('Key in the correct login values and user is navigated to their activities homepage', (tester) async {
    await loadLoginPage(tester);
    //stub the signIn method
    await tester.enterText(find.byType(TextFormField).first, 'test@gmail.com');
    await tester.pumpAndSettle();

    await tester.tapAt(Offset.zero);
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).last, 'testing123');
    await tester.pumpAndSettle();
    await tester.tapAt(Offset.zero);
    await tester.pumpAndSettle();
    await tester.tap(find.byType(AppButton));
    await tester.pumpAndSettle();

    verify(() => mockFirebaseAuth.signInWithEmailAndPassword(email: 'test@gmail.com', password: 'testing123'),).called(1);
    expect(find.byType(Homepage), findsOne);
    expect(mockNaviObserver.pushed.last.settings.name, '/home');
  });
}