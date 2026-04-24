import 'package:flutter/material.dart';

import 'app.dart';
import 'tools/notification_tool.dart';

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationTool.init();
  runApp(const GoApiApp());
}
