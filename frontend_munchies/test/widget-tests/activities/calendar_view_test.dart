import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_munchies/models/record.dart';
import 'package:frontend_munchies/screens/activities/domain/repositories/record_repo.dart';
import 'package:frontend_munchies/screens/activities/view_models/calendar_view_model.dart';
import 'package:frontend_munchies/screens/activities/views/activities_widgets/record_card.dart';
import 'package:frontend_munchies/screens/activities/views/calendar.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

class MockRecordRepo extends Mock implements RecordRepository {}

void main() {
  late MockRecordRepo mockRepo;
  late StreamController<void> streamController;
  late List<Record> mockRecords;
  late List<Record> juneRecords;
  late CalendarViewModel viewModel;

  setUp(() {
    mockRecords = [
        Record(
          record_id: 'id1',
          itemName: 'May test',
          date: DateTime(2026, 5, 1),
          cost: 500,
          isFavourited: false,
          isVisible: false,
        ),
        Record(
          record_id: 'id2',
          itemName: 'June test',
          date: DateTime(2026, 6, 22),
          cost: 500,
          isFavourited: false,
          isVisible: false,
        ),
        Record(
          record_id: 'id3',
          itemName: 'June test 2',
          date: DateTime(2026, 6, 25),
          cost: 500,
          isFavourited: false,
          isVisible: false,
        ),
        Record(
          record_id: 'id4',
          itemName: 'July test',
          date: DateTime(2026, 7, 1),
          cost: 500,
          isFavourited: false,
          isVisible: false,
        ),
      ];
      juneRecords = mockRecords.sublist(1, 3);
    mockRepo = MockRecordRepo();
    streamController = StreamController<void>.broadcast();
    when(
      () => mockRepo.recordStream,
    ).thenAnswer((_) => streamController.stream);
    when(
        () => mockRepo.fetchAllRecords({'monthly': '6,2026'}),
      ).thenAnswer((_) async => juneRecords);
    viewModel = CalendarViewModel(recordRepo: mockRepo);
  });



  Widget createTestCalendar() {
    return Provider<RecordRepository>.value(
      value: mockRepo,
      child: MaterialApp(
        home: ChangeNotifierProvider.value(
          value: viewModel,
          child: Scaffold(body: CalendarView(),)
        ),
        // navigatorObservers: navigatorObs,
      ),
    );
  }

  Future<void> loadCalendar(WidgetTester tester) async {
    await tester.pumpWidget(createTestCalendar());
    await tester.pumpAndSettle();
    await tester.runAsync(() async {
          await Future.delayed(Duration(seconds: 1));
        });
    await tester.pumpAndSettle();
  }

  testWidgets('load calendar', (tester) async {
    await loadCalendar(tester);
    expect(find.byType(TableCalendar), findsOne);
    expect(find.text('Monthly Logs'), findsOne);
    expect(find.byType(RecordCard), findsNWidgets(2));
  });

  testWidgets('check for icons', (tester) async {
    await loadCalendar(tester);
    expect(find.byIcon((Icons.cookie_rounded)), findsNWidgets(2));
  });

  testWidgets('click on icon to show only records of that date', (tester) async {
    await loadCalendar(tester);
    await tester.tap(find.byIcon(Icons.cookie_rounded).first);
    await tester.pumpAndSettle();
    expect(find.byType(RecordCard), findsOne);
  });

  testWidgets('click on refresh icon to show all records again', (tester) async {
    await loadCalendar(tester);
    await tester.tap(find.byIcon(Icons.cookie_rounded).first);
    await tester.pumpAndSettle();
    
    await tester.tap(find.byIcon(Icons.refresh_rounded));
    await tester.pumpAndSettle();

    expect(find.byType(RecordCard), findsNWidgets(2));
  });
}