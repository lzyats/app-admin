import 'package:flutter/material.dart';

import 'package:myapp/app.dart';
import 'package:myapp/tools/auth_tool.dart';
import 'package:myapp/tools/notification_tool.dart';

/// 应用启动引导：初始化依赖并运行主组件。
Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AuthTool.init();
  await NotificationTool.init();
  runApp(const GoApiApp());
}
