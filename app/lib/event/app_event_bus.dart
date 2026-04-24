import 'dart:async';

class AppEventBus {
  AppEventBus._();

  static final StreamController<String> _controller = StreamController<String>.broadcast();

  /// 对外暴露全局事件流。
  static Stream<String> get stream => _controller.stream;

  /// 发送一个字符串事件到全局事件总线。
  static void emit(String event) {
    _controller.add(event);
  }
}
