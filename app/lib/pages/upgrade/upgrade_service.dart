import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:myapp/config/app_config.dart';
import 'package:myapp/pages/upgrade/upgrade_model.dart';
import 'package:myapp/request/upgrade_api.dart';
import 'package:myapp/tools/upgrade_executor.dart';

class UpgradeService {
  const UpgradeService._();

  static bool _checkedOnce = false;

  /// 拉取并计算当前平台是否需要升级。
  static Future<UpgradeCheckResult> checkUpgrade() async {
    final UpgradeConfig config = await UpgradeApi.fetchUpgradeConfig();
    final String localVersion = await _readLocalVersion();

    final TargetPlatform platform = defaultTargetPlatform;
    if (kIsWeb) {
      return UpgradeCheckResult(
        config: config,
        localVersion: localVersion,
        latestVersion: '',
        needUpgrade: false,
        canUpgradeAction: config.iosInstallUrl.isNotEmpty || config.androidApkUrl.isNotEmpty,
        platformType: 'web',
      );
    }

    if (platform == TargetPlatform.android) {
      final String latestVersion = config.androidVersion;
      final bool needUpgrade =
          latestVersion.isNotEmpty && _compareVersion(latestVersion, localVersion) > 0;
      return UpgradeCheckResult(
        config: config,
        localVersion: localVersion,
        latestVersion: latestVersion,
        needUpgrade: needUpgrade,
        canUpgradeAction: config.androidApkUrl.isNotEmpty,
        platformType: 'android',
      );
    }

    if (platform == TargetPlatform.iOS) {
      final String latestVersion = config.iosVersion.isNotEmpty ? config.iosVersion : config.androidVersion;
      final bool needUpgrade = latestVersion.isNotEmpty && _compareVersion(latestVersion, localVersion) > 0;
      return UpgradeCheckResult(
        config: config,
        localVersion: localVersion,
        latestVersion: latestVersion,
        needUpgrade: needUpgrade,
        canUpgradeAction: config.iosInstallUrl.isNotEmpty,
        platformType: 'ios',
      );
    }

    return UpgradeCheckResult(
      config: config,
      localVersion: localVersion,
      latestVersion: '',
      needUpgrade: false,
      canUpgradeAction: false,
      platformType: 'other',
    );
  }

  /// 根据平台执行升级动作（安卓 OTA，iOS 外链跳转）。
  static Future<void> executeUpgrade(UpgradeCheckResult result) async {
    if (result.platformType == 'android') {
      await UpgradeExecutor.startAndroidOta(
        apkUrl: result.config.androidApkUrl,
        version: result.latestVersion,
      );
      return;
    }

    final String jumpUrl = result.config.iosInstallUrl.isNotEmpty
        ? result.config.iosInstallUrl
        : result.config.androidApkUrl;
    if (jumpUrl.isEmpty) {
      return;
    }
    final Uri uri = Uri.parse(jumpUrl);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  /// 仅在应用生命周期内执行一次升级检查。
  static Future<UpgradeCheckResult?> checkOnce() async {
    if (_checkedOnce) {
      return null;
    }
    _checkedOnce = true;
    return checkUpgrade();
  }

  /// 比较两个版本号大小：a>b 返回 1，a<b 返回 -1，相等返回 0。
  static int _compareVersion(String a, String b) {
    final List<int> left = _splitVersion(a);
    final List<int> right = _splitVersion(b);
    final int len = left.length > right.length ? left.length : right.length;
    for (int i = 0; i < len; i++) {
      final int lv = i < left.length ? left[i] : 0;
      final int rv = i < right.length ? right[i] : 0;
      if (lv != rv) {
        return lv > rv ? 1 : -1;
      }
    }
    return 0;
  }

  /// 将版本号字符串拆分为整型数组用于比较。
  static List<int> _splitVersion(String version) {
    if (version.trim().isEmpty) {
      return <int>[0];
    }
    return version
        .split('.')
        .map((String part) => int.tryParse(part.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0)
        .toList();
  }

  /// 获取本地应用版本号，失败时回退配置版本。
  static Future<String> _readLocalVersion() async {
    try {
      final PackageInfo info = await PackageInfo.fromPlatform();
      if (info.version.trim().isNotEmpty) {
        return info.version.trim();
      }
    } catch (_) {}
    return AppConfig.appVersion;
  }
}
