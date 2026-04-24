import 'package:ota_update/ota_update.dart';

class UpgradeExecutor {
  /// 启动 Android OTA 升级下载流程。
  static Future<void> startAndroidOta({
    required String apkUrl,
    required String version,
  }) async {
    final String cleanVersion = version.replaceAll(RegExp(r'[^0-9A-Za-z._-]'), '_');
    final String fileName = 'myapp_upgrade_$cleanVersion.apk';
    OtaUpdate()
        .execute(
          apkUrl,
          destinationFilename: fileName,
        )
        .listen((_) {});
  }
}
