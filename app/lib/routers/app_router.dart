import 'package:flutter/material.dart';

import 'package:myapp/pages/auth/forgot/forgot_page.dart';
import 'package:myapp/pages/auth/register/register_page.dart';
import 'package:myapp/pages/gateway/gateway_page.dart';
import 'package:myapp/pages/line/line_page.dart';
import 'package:myapp/pages/upgrade/upgrade_page.dart';

class AppRouter {
  const AppRouter._();

  static const String upgrade = '/upgrade';
  static const String line = '/line';
  static const String gateway = '/gateway';
  static const String register = '/auth/register';
  static const String forgotPassword = '/auth/forgot';

  /// 根据路由名称构建对应页面。
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case upgrade:
        return MaterialPageRoute(builder: (_) => const UpgradePage());
      case line:
        return MaterialPageRoute(builder: (_) => const LinePage());
      case gateway:
        return MaterialPageRoute(builder: (_) => const GatewayPage());
      case register:
        return MaterialPageRoute(builder: (_) => const RegisterPage());
      case forgotPassword:
        return MaterialPageRoute(builder: (_) => const ForgotPage());
      default:
        return null;
    }
  }
}
