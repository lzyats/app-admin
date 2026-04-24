import 'package:flutter/material.dart';

import '../pages/gateway/gateway_page.dart';
import '../pages/line/line_page.dart';
import '../pages/upgrade/upgrade_page.dart';

class AppRouter {
  const AppRouter._();

  static const String upgrade = '/upgrade';
  static const String line = '/line';
  static const String gateway = '/gateway';

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case upgrade:
        return MaterialPageRoute(builder: (_) => const UpgradePage());
      case line:
        return MaterialPageRoute(builder: (_) => const LinePage());
      case gateway:
        return MaterialPageRoute(builder: (_) => const GatewayPage());
      default:
        return null;
    }
  }
}
