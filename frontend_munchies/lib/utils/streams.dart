import 'dart:async';

final friendsUpdatedController = StreamController<void>.broadcast();
final friendsUpdatedStream = friendsUpdatedController.stream;