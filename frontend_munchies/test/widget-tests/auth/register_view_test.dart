import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_munchies/models/user_profile.dart';
import 'package:frontend_munchies/screens/activities/domain/repositories/record_repo.dart';
import 'package:frontend_munchies/screens/authentication/view/register.dart';
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

  setUpAll(() {
    mockProfile = UserProfile(firebase_uid: 'id', emailAddress: 'new@gmail.com', password: 'password', firstName: 'mock');
    registerFallbackValue(mockProfile);
  });

  setUp(() {
    // streamController = StreamController.broadcast();
    // filter = ActivityFilter.all;
    userCredential = MockUserCredential();
    user = MockUser();
    mockRecordRepo = MockRecordRepo();
    mockNaviObserver = MockNaviObserver();
    mockFirebaseAuth = MockFirebaseAuth();
    mockAuthService = MockAuthService();
    mockAuth = Authentication(firebaseAuth: mockFirebaseAuth, apiServices: mockAuthService);

    //stub get user method in mockusercred
    when(() => userCredential.user).thenReturn(user);
    //stub user method 
    when(() => user.getIdToken()).thenAnswer((_) async => 'idToken');
    when(() => user.uid).thenReturn('uid');

    //stub fetchUserProfile method
    when(() => mockAuthService.createProfile(any<String>(), any<UserProfile>())).thenAnswer((inv) async {
      debugPrint('${inv.positionalArguments}');
      return Future(() => null); 
    });
    //stub signInWith.... method
    when(() => mockFirebaseAuth.createUserWithEmailAndPassword(email: any<String>(named: 'email'), password: any<String>(named: 'password')))
    .thenAnswer((inv) async {
      return userCredential;
    }
    );
  });

  Widget createRegisterPage({List<NavigatorObserver> naviObs = const []}) {
    return Provider<RecordRepository>.value(value: mockRecordRepo, 
    child: MaterialApp(
      navigatorObservers: naviObs,
      home: Scaffold(body: RegisterPage(authentication: mockAuth, 
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

  Future<void> loadRegisterPage(WidgetTester tester) async {
    await tester.pumpWidget(createRegisterPage(naviObs: [mockNaviObserver]));
    await tester.pumpAndSettle();
  }

  Future<void> keyInValue(Finder finder, String text, WidgetTester tester) async {
    await tester.enterText(finder, text);
    await tester.pumpAndSettle();
    await tester.tapAt(Offset.zero);
    await tester.pumpAndSettle();
  }

  testWidgets('set up', (tester) async {
    await loadRegisterPage(tester);
    expect(find.byType(RegisterPage), findsOne);
  });
  testWidgets('Key in the correct login values and user is navigated to their activities homepage', (tester) async {
    await loadRegisterPage(tester);
    //stub the signIn method
    await keyInValue(find.widgetWithText(TextFormField, 'Email Address'), 'new@gmail.com', tester);
    await keyInValue(find.widgetWithText(TextFormField, 'Confirm Email Address'), 'new@gmail.com', tester);
    await keyInValue(find.widgetWithText(TextFormField, 'First Name'), 'mock', tester);
    await keyInValue(find.widgetWithText(TextFormField, 'Password'), 'password', tester);
    await keyInValue(find.widgetWithText(TextFormField, 'Confirm Password'), 'password', tester);

    //scroll until visible 
    await tester.scrollUntilVisible(find.byType(AppButton), 200.0, scrollable: find.byType(Scrollable).last);
    expect(find.text('Sign up now!'), findsOne);
    await tester.tap(find.text('Sign up now!'));
    await tester.pumpAndSettle();

    verify(() => mockFirebaseAuth.createUserWithEmailAndPassword(email: 'new@gmail.com', password: 'password'),).called(1);
    verify(() => mockAuthService.createProfile(any(), any())).called(1);
    expect(find.byType(Homepage), findsOne);
    expect(mockNaviObserver.pushed.last.settings.name, '/home');
  });

  testWidgets('Key in wrong values and trigger validator', (tester) async {
    await loadRegisterPage(tester);

    await tester.scrollUntilVisible(find.byType(AppButton), 200.0, scrollable: find.byType(Scrollable).last);
    expect(find.text('Sign up now!'), findsOne);
    await tester.tap(find.text('Sign up now!'));
    await tester.pumpAndSettle();

    expect(find.text('Field cannot be empty.'), findsNWidgets(5));
  });
}