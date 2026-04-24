import 'dart:async';

class AppEventBus {
  AppEventBus._();

  static final StreamController<String> _controller = StreamController<String>.broadcast();

  static Stream<String> get stream => _controller.stream;

  static void emit(String event) {
    _controller.add(event);
  }
}
