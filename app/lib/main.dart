import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:myapp/bootstrap.dart';

/// Flutter 程序入口方法。
Future<void> main() async {
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint('FlutterError: ${details.exception}');
    debugPrint('${details.stack}');
  };

  PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
    debugPrint('PlatformDispatcherError: $error');
    debugPrint('$stack');
    return true;
  };

  await runZonedGuarded(() async {
    await bootstrap();
  }, (Object error, StackTrace stack) {
    debugPrint('ZoneError: $error');
    debugPrint('$stack');
  });
}
