import 'package:awesome_notifications/awesome_notifications.dart';

class NotificationTool {
  static Future<void> init() async {
    await AwesomeNotifications().initialize(
      null,
      [
        NotificationChannel(
          channelKey: 'default_channel',
          channelName: '\u9ed8\u8ba4\u901a\u77e5',
          channelDescription: '\u5e94\u7528\u9ed8\u8ba4\u901a\u77e5\u901a\u9053',
          importance: NotificationImportance.High,
        ),
      ],
      debug: true,
    );
  }
}
