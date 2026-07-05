import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_munchies/screens/activities/domain/repositories/record_repo.dart';
import 'package:frontend_munchies/screens/loggingFeature/repository/scan_repository.dart';
import 'package:frontend_munchies/screens/loggingFeature/view_models/scan_view_model.dart';
import 'package:frontend_munchies/screens/loggingFeature/views/logging_widgets/fields/item_name.dart';
import 'package:frontend_munchies/screens/loggingFeature/views/logging_widgets/image_widgets.dart/image_selection_button.dart';
import 'package:frontend_munchies/screens/loggingFeature/views/logging_widgets/logging_form.dart';
import 'package:frontend_munchies/screens/loggingFeature/views/scan_picture.dart';
import 'package:frontend_munchies/widgets/button.dart';
import 'package:frontend_munchies/widgets/errorMessage.dart';
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';
import 'package:mocktail/mocktail.dart';
import 'package:frontend_munchies/models/record.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:provider/provider.dart';

class MockRecordRepo extends Mock implements RecordRepository {}

class MockScanRepo extends Mock implements ScanRepository {}

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
  late MockScanRepo mockRepo;
  late ScanViewModel vm;
  GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  setUp(() {
    mockRepo = MockScanRepo();
    vm = ScanViewModel(scanRepo: mockRepo);
    mockPicker = setUpMockPicker();
    ImagePickerPlatform.instance = mockPicker;
  });

  setUpAll(() {
    registerFallbackValue(ImageSource.gallery);
    registerFallbackValue(const ImagePickerOptions());
    registerFallbackValue(
      Record(
        itemName: 'toSave',
        date: DateTime.now(),
        cost: 500,
        isFavourited: false,
        isVisible: false,
      ),
    );
  });

  Widget createScanWidget() {
    return MultiProvider(
      providers: [
        Provider<RecordRepository>(create: (_) => MockRecordRepo()),
        ChangeNotifierProvider<ScanViewModel>(create: (_) => vm),
      ],
      child: MaterialApp(
        navigatorKey: navigatorKey,
        initialRoute: '/',
        routes: {
          '/': (_) => const Placeholder(),
          '/scan': (_) => const ScanPicture(),
        },
      ),
    );
  }

  Future<void> loadScanWidget(WidgetTester tester) async {
    await tester.pumpWidget(createScanWidget());
    navigatorKey.currentState!.pushNamed('/scan');
    await tester.pumpAndSettle();
  }

  Future<void> pickImage(WidgetTester tester) async {
    await tester.tap(find.byType(ImageSelectionButton));
        await tester.pumpAndSettle();

        expect(find.byType(BottomSheet), findsOne);

        await tester.tap(find.widgetWithText(TextButton, 'Pick from gallery'));
        await tester.pumpAndSettle();

        await tester.tapAt(Offset.zero);
        await tester.pumpAndSettle();
  }

  Future<void> submitImage(WidgetTester tester) async {
    await tester.scrollUntilVisible(
          find.byType(AppButton),
          100.0,
          scrollable: find.byType(Scrollable).last,
        );
        await tester.pumpAndSettle();

        await tester.tap(find.byType(AppButton));
        await tester.pump();
  }

  group('Scan on valid uploads', () {

    setUp(() {
      when(
          () => mockPicker.getImageFromSource(
            source: any(named: 'source'),
            options: any(named: 'options'),
          ),
        ).thenAnswer((_) async {
          return Future(() => XFile('test/assets/sample1.png'));
        });
    });

    testWidgets('Successful set-up of scanning page', (tester) async {
      await loadScanWidget(tester);
      expect(find.byType(ImageSelectionButton), findsOne);
      expect(find.byType(MaterialBanner), findsNWidgets(2));
    });

    testWidgets(
      'On successful scan, user is brought to a logging form that has the item name derived from the AI scan method',
      (tester) async {
        when(() => mockRepo.scanPicture(any<String>())).thenAnswer((_) async {
          await Future.delayed(Duration(seconds: 1));
          return 'scanned picture';
        });
        await loadScanWidget(tester);

        //pick an image
        await pickImage(tester);

        verify(
          () => mockPicker.getImageFromSource(
            source: any(named: 'source'),
            options: any(named: 'options'),
          ),
        ).called(1);

        expect(find.byType(ImageSelectionButton), findsOne);
        expect(find.byType(Image), findsOne);
        tester.widget<Image>(find.byType(Image));

        //submit imagr
        await submitImage(tester);
        
        //expect loading screen
        expect(find.byType(CircularProgressIndicator), findsOne);
        await tester.binding.handlePopRoute();
        await tester.pump();
        expect(find.byType(CircularProgressIndicator), findsOne);

        await tester.pumpAndSettle();

        //check logging form details are keyed in correctly
        expect(find.byType(LoggingForm), findsOne);
        expect(find.widgetWithText(ItemName, 'scanned picture'), findsOne);
      },
    );

    testWidgets(
    'Unsuccessful item name return shows a dismissible dialog',
    (tester) async {
      when(() => mockRepo.scanPicture(any<String>())).thenAnswer((_) async {
          await Future.delayed(Duration(seconds: 1));
          return 'No food detected';
        });

      await loadScanWidget(tester);
      await pickImage(tester);
      await submitImage(tester);
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOne);
      expect(find.text('No food was detected in the image.\n Either try again or record manually'), findsOne);
      
      await tester.tapAt(Offset.zero);
      await tester.pumpAndSettle();
      expect(find.text('No food was detected in the image.\n Either try again or record manually'), findsNothing);
      expect(find.byType(AlertDialog), findsNothing);
    },
  );

  testWidgets(
    'Failure on server side pops loading screen and shows error message',
    (tester) async {
      when(() => mockRepo.scanPicture(any<String>())).thenAnswer((_) async {
          await Future.delayed(Duration(seconds: 1));
          throw Exception('Scan Picture exception');
        });

      await loadScanWidget(tester);
      await pickImage(tester);
      await submitImage(tester);
      expect(find.byType(CircularProgressIndicator), findsOne);

      await tester.pumpAndSettle();

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.byType(ModalBarrier), findsOne);
      expect(find.widgetWithText(ShowErrorMessage,'Exception: Scan Picture exception'), findsOne);
    },
  );
  });

  testWidgets(
    'Any file type errors such as incompatibility or empty files trigger error message',
    (tester) async {
      when(
          () => mockPicker.getImageFromSource(
            source: any(named: 'source'),
            options: any(named: 'options'),
          ),
        ).thenAnswer((_) async {
          return Future(() => XFile('test/assets/sample1.heic'));
        });

      when(() => mockRepo.scanPicture(any<String>())).thenAnswer((_) async {
          await Future.delayed(Duration(seconds: 1));
          return 'scanned picture';
        });
      await loadScanWidget(tester);

      //check functional error message text when an incompatible file is returned
      await pickImage(tester);
      await submitImage(tester);
      await tester.pumpAndSettle();

      expect(find.text('Exception: File is unsupported or corrupted.'), findsOne);
    },
  );
}
