import 'package:flutter/material.dart';

class MockNaviObserver extends NavigatorObserver {
  List<Route> popped = [];
  List<Route> pushed = [];
  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    popped.add(previousRoute ?? route);
    super.didPop(route, previousRoute);
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    pushed.add(route);
    super.didPush(route, previousRoute);
  }
}