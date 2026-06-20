import 'dart:async';
import 'package:async/async.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_debouncer/flutter_debouncer.dart';
import 'package:frontend_munchies/screens/activities/domain/view_models/record_handler.dart';
import 'package:frontend_munchies/screens/activities/data/repositories/record_changer.dart';
import 'package:frontend_munchies/models/record.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarViewModel extends ChangeNotifier implements RecordHandler {
  final RecordRepoImpl recordRepo;
  late StreamSubscription _subscription;

  CalendarViewModel({required this.recordRepo}) {

    _subscription = recordRepo.recordStream.listen((rec) {
      getMonthlyRecords(DateTime.now());
    });
    getMonthlyRecords(DateTime.now());
  }
  bool _isDisposed = false;
  bool _isLoading = false;
  String? _errorMessage;
  List<Record> _records = [];
  List<DateTime> _datesWithRecord = [];
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  CancelableOperation<List<Record>>? fetchOperation;
  final Debouncer debouncer = Debouncer();

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  // List<Record> get recordDetails => _records;
  List<DateTime> get datesWithRecord => _datesWithRecord;
  DateTime get focusedDay => _focusedDay;
  DateTime? get selectedDay => _selectedDay;
  List<Record> get recordDetails {
    if (selectedDay == null) return _records;
    return _records.where((r) => isSameDay(r.date, selectedDay)).toList();
  }

  @override
  void onLoading() {
    _isLoading = true;
    notifyListeners();
  }

  @override
  void offLoading() {
    _isLoading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
    _isDisposed = true;
    _subscription.cancel();
  }

  @override
  void notifyListeners() {
    if (!_isDisposed) {
      super.notifyListeners();
    }
  }

  Future<void> setSelectedDay(DateTime? selectedDay) async {
    _selectedDay = selectedDay;
    if (selectedDay == null) {
      getMonthlyRecords(focusedDay);
    }
    notifyListeners();
  }

  void onDaySelected(DateTime focusedDay, DateTime? selectedDay) {
    _selectedDay = selectedDay;
    // _focusedDay = focusedDay;
    notifyListeners();
  }

  void getMonthlyRecords(DateTime date) async {
    _focusedDay = date;
    debugPrint("FOCUSED DAY AT START IS $_focusedDay");
    String month = date.month.toString();
    String year = date.year.toString();
    String query = '$month,$year';
    onLoading();
    fetchOperation = CancelableOperation<List<Record>>.fromFuture(
      recordRepo.fetchAllRecords({'monthly': query}),
      onCancel: () => debugPrint('Operation cancelled.'),
    );
    fetchOperation!.value.then((data) {
      List<DateTime> dates = data.map((rec) => rec.date).toSet().toList();
      _selectedDay = null;
      _records = data;
      _datesWithRecord = dates;
      notifyListeners();
      offLoading();
    });
    debugPrint("FOCUSED DAY AT END IS $_focusedDay");
  }

  void onPageChanged(DateTime focusedDay) async {
    await fetchOperation?.cancel();
    debouncer.debounce(
      duration: Duration(seconds: 1), 
      onDebounce: ()
        {_selectedDay = null;
        _focusedDay = focusedDay;
         getMonthlyRecords(focusedDay);}
    );
  }

  @override
  Future<void> onDeletePressed(String recordId) async {
    onLoading();
    await recordRepo.deleteRec(recordId);
    getMonthlyRecords(_focusedDay);
    offLoading();
  }
}

