import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_munchies/models/category_item.dart';
import 'package:frontend_munchies/screens/activities/domain/repositories/record_repo.dart';
import 'package:frontend_munchies/screens/loggingFeature/view_models/logging_view_model.dart';
import 'package:frontend_munchies/screens/loggingFeature/views/logging_widgets/fields/categories.dart';
import 'package:frontend_munchies/screens/loggingFeature/views/logging_widgets/fields/cost.dart';
import 'package:frontend_munchies/screens/loggingFeature/views/logging_widgets/fields/date.dart';
import 'package:frontend_munchies/screens/loggingFeature/views/logging_widgets/fields/details.dart';
import 'package:frontend_munchies/screens/loggingFeature/views/logging_widgets/fields/item_name.dart';
import 'package:frontend_munchies/screens/loggingFeature/views/logging_widgets/fields/visibility_toggle.dart';
import 'package:frontend_munchies/screens/loggingFeature/views/logging_widgets/image_widgets.dart/image_selection_button.dart';
import 'package:frontend_munchies/screens/loggingFeature/views/tracking.dart';
import 'package:frontend_munchies/widgets/button.dart';
import 'package:frontend_munchies/widgets/errorMessage.dart';
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';
import 'package:mocktail/mocktail.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:provider/provider.dart';
import 'package:frontend_munchies/models/record.dart';

import '../../mocks/mock_navi_observer.dart';

class MockRecordRepo extends Mock implements RecordRepository {}

class MockRoute extends Mock implements Route {}

class MockImagePicker extends Mock
    with MockPlatformInterfaceMixin
    implements ImagePickerPlatform {}


MockImagePicker setUpMockPicker() {
  final MockImagePicker mock = MockImagePicker();
  return mock;
}

void main() {
  late MockImagePicker mockPicker;
  late MockRecordRepo mockRepo;
  late LoggingViewModel vm;
  late MockNaviObserver mno;
  GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  setUp(() {
    mockRepo = MockRecordRepo();
    mockPicker = setUpMockPicker();
    mno = MockNaviObserver();
    ImagePickerPlatform.instance = mockPicker;
    vm = LoggingViewModel(recordChanger: mockRepo);
  });

  setUpAll(() {
    registerFallbackValue(
      Record(
        itemName: 'toSave',
        date: DateTime.now(),
        cost: 500,
        isFavourited: false,
        isVisible: false,
      ),
    );

    registerFallbackValue(MockRoute());
  });

  Widget createTestWidget({
    List<NavigatorObserver> navigatorObservers = const [],
  }) {
    return ChangeNotifierProvider(
      create: (_) => vm,
      child: MaterialApp(
        navigatorKey: navigatorKey,
        initialRoute: '/home',
        routes: {
          '/home': (_) => const Placeholder(),
          '/track': (_) => const TrackingPage(),
        },
        navigatorObservers: navigatorObservers,
      ),
    );
  }

  Future<void> setUpLogging(WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget(navigatorObservers: [mno]));
    navigatorKey.currentState!.pushNamed('/track');
    await tester.pumpAndSettle();
  }

  testWidgets('Logging form builds without crashing', (tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => LoggingViewModel(recordChanger: mockRepo),
        child: const MaterialApp(home: TrackingPage()),
      ),
    );
    expect(find.byType(TrackingPage), findsOneWidget);
    expect(find.byType(ItemName), findsOneWidget);
    expect(find.byType(DateField), findsOneWidget);
    expect(find.byType(CostField), findsOneWidget);
    expect(find.byType(DetailsField), findsOneWidget);
    expect(find.byType(CategoryMenu), findsOneWidget);
    expect(find.byType(ImageSelectionButton), findsOneWidget);
    expect(find.byType(VisibilityToggle), findsOneWidget);
    expect(find.text('Save'), findsOne);
    expect(find.byIcon(Icons.favorite_border_rounded), findsOne);
  });

  group('Fields are functional when keying in', () {
    testWidgets(
      'TextFormFields are functional and updates the viewModel state. Re-editing updates state.',
      (tester) async {
        await setUpLogging(tester);
        await tester.enterText(find.byType(ItemName), 'mock record');
        await tester.pump();

        expect(find.text('mock record'), findsOne);
        expect(vm.itemName, 'mock record');
      },
    );

    testWidgets(
      'Tapping on date field shows date picker for users to choose dates, and text entering does not work',
      (tester) async {
        await setUpLogging(tester);
        await tester.enterText(find.byType(DateField), 'Wrong');
        await tester.pump();
        expect(find.widgetWithText(DateField, ''), findsOne);

        //expect error message if date field is left empty
        FocusManager.instance.primaryFocus?.unfocus();
        await tester.pumpAndSettle();
        expect(find.text('Field cannot be empty'), findsOne);

        await tester.tap(find.byType(DateField));
        await tester.pumpAndSettle();

        expect(find.byType(DatePickerDialog), findsOne);
      },
    );

    testWidgets(
      'Cost field shows validator error message once an invalid value is typed in',
      (tester) async {
        await setUpLogging(tester);

        await tester.enterText(find.byType(CostField), 'invalid');
        await tester.pump();

        //FIXME: if wrong value, it should not be saved to the VM
        // debugPrint(vm.cost);

        FocusManager.instance.primaryFocus?.unfocus();
        await tester.pumpAndSettle();
        expect(find.text('Invalid value for cost.'), findsOne);
      },
    );
    setUpAll(() {
      registerFallbackValue(ImageSource.gallery);
      registerFallbackValue(const ImagePickerOptions());
    });

    testWidgets(
      'ImageSelectionButton allows for taps to open gallery options.'
      'Reclicking and reselecting image changes display image and the viewModel saved file',
      (tester) async {
        int counter = 0;
        when(
          () => mockPicker.getImageFromSource(
            source: any(named: 'source'),
            options: any(named: 'options'),
          ),
        ).thenAnswer((_) async {
          counter++;
          if (counter == 1) {
            return Future(() => XFile('../../assets/sample1.png'));
          } else {
            return Future(() => XFile('../../assets/sample2.png'));
          }
        });
        await setUpLogging(tester);

        await tester.tap(find.byType(ImageSelectionButton));
        await tester.pumpAndSettle();

        expect(find.byType(BottomSheet), findsOne);

        await tester.tap(find.text('Pick from gallery'));
        await tester.pumpAndSettle();

        final firstImage =
            tester.widget<Image>(find.byType(Image)).image as FileImage;

        //'change' the image
        await tester.tap(find.text('Pick from gallery'));
        await tester.pumpAndSettle();

        final finalImage =
            tester.widget<Image>(find.byType(Image)).image as FileImage;

        expect(identical(firstImage.file, finalImage.file), false);
        expect(finalImage.file.path, '../../assets/sample2.png');
      },
    );
  });

  testWidgets(
    'CategoryMenu does not allow for typing. Menu opens when clicked',
    (tester) async {
      await setUpLogging(tester);

      await tester.enterText(find.byType(CategoryMenu), 'test');
      await tester.pump();
      expect(find.widgetWithText(CategoryMenu, ''), findsOne);

      await tester.tap(find.byType(CategoryMenu));
      await tester.pumpAndSettle();

      expect(find.byType(DropdownMenu<CategoryItem>), findsOne);
    },
  );

  testWidgets(
    'VisibilityToggle does not allow for typing.'
    'BottomModalSheet opens when clicked, and closes when an option is selected or when it is dismissed'
    'On dismissed, the last chosen (or default) visibility option is saved',
    (tester) async {
      await setUpLogging(tester);

      //default value is private. Check that VM's value corresponds
      await tester.enterText(find.byType(VisibilityToggle), 'test');
      await tester.pump();
      expect(find.widgetWithText(VisibilityToggle, 'Private'), findsOne);
      expect(vm.isVisible, false);

      await tester.scrollUntilVisible(
        find.byType(VisibilityToggle),
        200.0,
        scrollable: find.byType(Scrollable).last,
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(VisibilityToggle));
      await tester.pumpAndSettle();
      expect(find.byType(BottomSheet), findsOne);

      await tester.tapAt(Offset.zero);
      await tester.pumpAndSettle();
      expect(find.widgetWithText(VisibilityToggle, 'Private'), findsOne);

      await tester.tap(find.byType(VisibilityToggle));
      await tester.pumpAndSettle();
      await tester.tap(
        find.widgetWithText(
          TextButton,
          "Public. The record will \nshow up on your friends' feeds.",
        ),
      );
      await tester.pump();
      await tester.tapAt(Offset.zero);
      await tester.pumpAndSettle();
      expect(find.widgetWithText(VisibilityToggle, 'Public'), findsOne);
      expect(find.byType(BottomSheet), findsNothing);

      //expect that vm updates accordingly
      expect(vm.isVisible, true);
    },
  );

  group('Save actions with a valid form', () {
    Future<void> createValidForm(WidgetTester tester) async {
      await setUpLogging(tester);

      await tester.enterText(find.byType(ItemName), 'MockRecord');
      await tester.pump();
      //item name expectation
      expect(find.widgetWithText(ItemName, 'MockRecord'), findsOne);

      await tester.tap(find.byType(DateField));
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      expect(
        find.widgetWithText(
          DateField,
          DateTime.now().toIso8601String().split('T')[0],
        ),
        findsOne,
      );

      await tester.enterText(find.byType(CostField), '3');
      await tester.pumpAndSettle();
      expect(find.widgetWithText(CostField, '3'), findsOne);

      await tester.tapAt(Offset.zero);
      await tester.pumpAndSettle();
    }

    Future<void> pressSubmit(WidgetTester tester) async {
      await tester.scrollUntilVisible(
        find.text('Save'),
        100.0,
        scrollable: find.byType(Scrollable).last,
      );
      await tester.pumpAndSettle();
      await tester.tap(
        find.widgetWithText(AppButton, 'Save'),
        warnIfMissed: true,
      );
      await tester.pump();
    }

    testWidgets(
      'On a valid form, a loading page appears and then navigation happens. Loading page cannot be dismissed by back-press',
      (tester) async {
        //stub successful save repo method
        when(() => mockRepo.saveRecord(any())).thenAnswer((_) async {
          await Future.delayed(Duration(seconds: 1));
        });
        //a valid form is created when all required fields are filled.
        await createValidForm(tester);
        await pressSubmit(tester);

        //expect that the loading screen cannot be dismissed by any means by user.
        //this is a preventive measure for unexpected saving or updating behaviour.
        expect(find.byType(CircularProgressIndicator), findsOne);

        await tester.binding.handlePopRoute();
        await tester.pump();
        expect(find.byType(CircularProgressIndicator), findsOne);

        await tester.tapAt(Offset.zero);
        expect(find.byType(CircularProgressIndicator), findsOne);

        await tester.pumpAndSettle();
        expect(find.byType(CircularProgressIndicator), findsNothing);

        //expect that the home is the last popped route
        expect(mno.popped[mno.popped.length - 1].settings.name, '/home');
      },
    );
    testWidgets(
      'If server-side errors or errors down the pipeline occurs, the loading page is popped'
      'and error message shows in the previous record form',
      (tester) async {
        when(() => mockRepo.saveRecord(any())).thenAnswer((_) async {
          await Future.delayed(Duration(seconds: 1));
          throw Exception('Test Exception');
        });

        //create a valid form before testing
        await createValidForm(tester);
        await pressSubmit(tester);

        //check that the loading screen occurred.
        expect(find.byType(CircularProgressIndicator), findsOne);

        //check that user returns to the previous tracking page.
        await tester.pumpAndSettle();

        //expect loading screen to be popped
        expect(find.byType(CircularProgressIndicator), findsNothing);

        //expect there to be the error message widget
        expect(find.byType(ShowErrorMessage), findsOne);
        expect(find.text('Exception: Test Exception'), findsOne);
      },
    );
    testWidgets(
      'On an invalid form or exceptions caught before HTTP call is made, an error message shows',
      (tester) async {
        when(() => mockRepo.saveRecord(any())).thenAnswer((_) async {
          await Future.delayed(Duration(seconds: 1));
        });
        await tester.pumpWidget(createTestWidget(navigatorObservers: []));
        navigatorKey.currentState!.pushNamed('/track');
        await tester.pumpAndSettle();

        //press submit on an empty form
        await pressSubmit(tester);
        await tester.pump();

        await tester.scrollUntilVisible(
          find.byType(ItemName),
          100.0,
          scrollable: find.byType(Scrollable).last,
        );
        await tester.pumpAndSettle();

        expect(find.text('Field cannot be empty'), findsNWidgets(3));
      },
    );

    testWidgets(
      'The save button cannot be spam-clicked (i.e. clicked more than once before loading page apepars)',
      (tester) async {
        WidgetController.hitTestWarningShouldBeFatal = true;
        when(() => mockRepo.saveRecord(any())).thenAnswer((_) async {
          await Future.delayed(Duration(seconds: 1));
        });
        await createValidForm(tester);
        await pressSubmit(tester);

        expect(find.byType(CircularProgressIndicator), findsOne);
        //try tapping submit again
        expect(() async {
          await tester.tap(find.text('Save'), warnIfMissed: true);
        }, throwsA(isA<FlutterError>()));

        await tester.pumpAndSettle();
        WidgetController.hitTestWarningShouldBeFatal = false;
      },
    );
  });
}
