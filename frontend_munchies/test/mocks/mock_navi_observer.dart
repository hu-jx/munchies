import 'package:flutter/material.dart';

class MockNaviObserver extends NavigatorObserver {
  List<Route> popped = [];
  List<Route> pushed = [];
  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    debugPrint(previousRoute.toString());
    popped.add(previousRoute ?? route);
    super.didPop(route, previousRoute);
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    debugPrint(route.toString());
    pushed.add(route);
    super.didPush(route, previousRoute);
  }
}