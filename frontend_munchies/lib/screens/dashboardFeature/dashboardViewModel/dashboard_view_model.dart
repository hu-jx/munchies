import 'package:firebase_auth/firebase_auth.dart';
import 'package:frontend_munchies/services/records/record_services.dart';
import 'package:frontend_munchies/screens/dashboardFeature/view_opt.dart';
import 'package:frontend_munchies/screens/dashboardFeature/dashboardViewModel/date_helpers.dart';
import 'package:frontend_munchies/utils/auth_helper.dart';
import 'package:http/http.dart' as http;

class DashboardViewModel {
  final FirebaseAuth _auth;
  final http.Client? _client;

  ViewOpt selectedView = ViewOpt.weekly;
  DateTime chosenDate = DateTime.now();
  List summaryData = [];
  List categoryData = [];
  int requestId = 0;

  bool _useTestData = false;

  DashboardViewModel({
    FirebaseAuth? auth,
    http.Client? client,
    List? testSummaryData,
    List? testCategoryData,
  }) : _auth = auth ?? FirebaseAuth.instance,
       _client = client,
       _useTestData = testCategoryData != null {
    // if test data provided, populate immediately
    if (testSummaryData != null) summaryData = testSummaryData;
    if (testCategoryData != null) categoryData = testCategoryData;
  }

  void changeView(ViewOpt newView) {
    selectedView = newView;
    //getData();
  }

  void backButton(DateTime newDate) {
    chosenDate = newDate;
    // getData();
  }

  void forwardButton(DateTime newDate) {
    chosenDate = newDate;
    // getData();
  }

  /*
  Future<void> changeView(ViewOpt newView) async {
    selectedView = newView;
    getData();
  }

  Future<void> backButton(DateTime newDate) async {
    chosenDate = newDate;
    await getData();
  }

  Future<void> forwardButton(DateTime newDate) async {
    chosenDate = newDate;
    await getData();
  }
  */

  Future<void> getData() async {
    if (_useTestData) { return; }
    
    final int currentRequest = ++requestId;

    final firebaseInfo = await userIdToken(_auth);
    final idToken = firebaseInfo.idToken;
    final usr = firebaseInfo.usr;

    Map<String, dynamic> dbData = await RecordServices.getDashboardData(
      idToken: idToken,
      user_uid: usr.uid,
      startDate: findStart(selectedView, chosenDate),
      endDate: findEnd(selectedView, chosenDate),
      view: selectedView.name,
      client: _client,
    );

    if (currentRequest != requestId) return;

    summaryData = List.from(dbData['summary']);
    categoryData = List.from(dbData['catData']);
  }
}
