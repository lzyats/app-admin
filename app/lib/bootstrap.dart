import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:myapp/app.dart';
import 'package:myapp/request/auth_api.dart';
import 'package:myapp/tools/app_bootstrap_tool.dart';
import 'package:myapp/tools/auth_tool.dart';
import 'package:myapp/tools/local_proxy_manager.dart';
import 'package:myapp/tools/notification_tool.dart';

/// 应用启动引导：先显示界面，再在后台完成初始化。
Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const GoApiApp());

  // 先让首屏出来，再静默初始化，避免冷启动白屏。
  unawaited(_initRuntime());
}

/// 后台初始化登录态、配置、本地代理和通知能力。
Future<void> _initRuntime() async {
  try {
    await AuthTool.init();
  } catch (e, s) {
    debugPrint('AuthTool.init error: $e');
    debugPrint('$s');
  }

  if (AuthTool.isLogin) {
    unawaited(_refreshUserProfileOnStartup());
  }

  try {
    await AppBootstrapTool.init();
  } catch (e, s) {
    debugPrint('AppBootstrapTool.init error: $e');
    debugPrint('$s');
  }

  try {
    await NotificationTool.init();
  } catch (e, s) {
    debugPrint('NotificationTool.init error: $e');
    debugPrint('$s');
  }

  if (!kIsWeb) {
    try {
      await LocalProxyManager.instance.startHttpProxy();
    } catch (e, s) {
      debugPrint('LocalProxyManager.startHttpProxy error: $e');
      debugPrint('$s');
    }
  }
}

Future<void> _refreshUserProfileOnStartup() async {
  try {
    await AuthApi.getInfo(forceRefresh: true);
  } catch (e, s) {
    debugPrint('AuthApi.getInfo(forceRefresh: true) error: $e');
    debugPrint('$s');
  }
}
