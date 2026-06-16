import 'package:firebase_auth/firebase_auth.dart';
import 'package:frontend_munchies/services/auth/auth_exception.dart';
import 'package:frontend_munchies/services/records/record_services.dart';
import 'package:frontend_munchies/screens/dashboardFeature/view_opt.dart';
import 'package:frontend_munchies/screens/dashboardFeature/dashboardView/date_helpers.dart';

class DashboardViewModel {
  ViewOpt selectedView = ViewOpt.weekly;
  DateTime chosenDate = DateTime.now();
  List summaryData = [];
  List categoryData = [];
  int requestId = 0;

  void changeView(ViewOpt newView) {
    selectedView = newView;
    getData();
  }

  void backButton(DateTime newDate) {
    chosenDate = newDate;
    getData();
  }

  void forwardButton(DateTime newDate) {
    chosenDate = newDate;
    getData();
  }

  Future<void> getData() async {
    final int currentRequest = ++ requestId;

    User? usr = FirebaseAuth.instance.currentUser;
    if (usr == null) throw AuthException('No permission to access.');
    String? idToken = await usr.getIdToken();
    if (idToken == null || idToken.isEmpty) {
      throw AuthException('No permission to access. ');
    }

    Map<String, dynamic> data = await RecordServices.getDashboardData(
      idToken: idToken,
      user_uid: usr.uid,
      startDate: findStart(selectedView, chosenDate),
      endDate: findEnd(selectedView, chosenDate),
      view: selectedView.name,
    );

    if (currentRequest != requestId) return;

    summaryData = List.from(data['summary']);
    categoryData = List.from(data['catData']);
  }
}
