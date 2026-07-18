import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_munchies/models/filters.dart';
import 'package:frontend_munchies/screens/activities/domain/repositories/record_repo.dart';
import 'package:frontend_munchies/screens/loggingFeature/views/logging_widgets/logging_form.dart';
import 'package:frontend_munchies/screens/main_screen.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:frontend_munchies/models/record.dart';
import '../../mocks/mock_navi_observer.dart';

class MockRecordRepo extends Mock implements RecordRepository {}
class MockMessage extends Mock implements FirebaseMessaging {}

void main() {
  late List<Record> records;
  late MockRecordRepo mockRepo;
  late MockNaviObserver mockObserver;
  late StreamController<void> streamController;
  late ActivityFilter filter;

  setUp(() {
    records = [
      Record(
        record_id: 'id',
        itemName: 'Test',
        date: DateTime.now(),
        cost: 500,
        isFavourited: false,
        isVisible: false,
      ),
    ];
    mockRepo = MockRecordRepo();
    mockObserver = MockNaviObserver();
    streamController = StreamController<void>.broadcast();
    filter = ActivityFilter.all;
     when(
      () => mockRepo.recordStream,
    ).thenAnswer((_) => streamController.stream);
    when(() => mockRepo.fetchAllRecords(filter.query)).thenAnswer((_) async {
      return Future.delayed(Durations.medium4, () => records);
    });    
  });

  Widget createHomepage({
    List<NavigatorObserver> navigatorObs = const [],
  }) {
    return Provider<RecordRepository>(
      create: (_) => mockRepo,
      child: MaterialApp(
        home: Homepage(viewOptions: [
          const Placeholder(),
          const Placeholder(),
          const Placeholder(),
          const Placeholder(),
          const Placeholder()
        ],),
        navigatorObservers: navigatorObs,
      ),
    );
  }

  Future<void> loadHomePage(WidgetTester tester) async {
    await tester.pumpWidget(createHomepage(navigatorObs: [mockObserver]));
    await tester.pumpAndSettle();
  }

  testWidgets('pressing plus icon opens menu and pressing manual record opens logging page', (tester) async {
    await loadHomePage(tester);
    
    await tester.tap(find.byIcon(Icons.add_circle_rounded));
    await tester.pumpAndSettle();

    //check that options show up 
    expect(find.byType(TextButton), findsNWidgets(3));
    expect(find.text('Manual Record'), findsOne);

    await tester.tap(find.text('Manual Record'));
    await tester.pumpAndSettle();

    expect(find.byType(LoggingForm), findsOne);
  });
}