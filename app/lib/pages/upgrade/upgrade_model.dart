class UpgradeConfig {
  /// 创建升级配置数据对象。
  UpgradeConfig({
    required this.configKey,
    required this.appUrl,
    required this.androidVersion,
    required this.androidApkUrl,
    required this.iosVersion,
    required this.iosInstallUrl,
    required this.forceUpgrade,
    required this.releaseNote,
  });

  final String configKey;
  final String appUrl;
  final String androidVersion;
  final String androidApkUrl;
  final String iosVersion;
  final String iosInstallUrl;
  final bool forceUpgrade;
  final String releaseNote;

  bool get hasAppUrl => appUrl.isNotEmpty;
  bool get hasAndroidUpgradeSource => androidVersion.isNotEmpty && androidApkUrl.isNotEmpty;
  bool get hasIosUpgradeSource => iosInstallUrl.isNotEmpty;

  /// 从接口 JSON 数据构建升级配置对象。
  factory UpgradeConfig.fromJson(Map<String, dynamic> json) {
    return UpgradeConfig(
      configKey: (json['configKey'] ?? '').toString(),
      appUrl: (json['appUrl'] ?? '').toString(),
      androidVersion: (json['androidVersion'] ?? '').toString(),
      androidApkUrl: (json['androidApkUrl'] ?? '').toString(),
      iosVersion: (json['iosVersion'] ?? '').toString(),
      iosInstallUrl: (json['iosInstallUrl'] ?? '').toString(),
      forceUpgrade: (json['forceUpgrade'] is bool)
          ? json['forceUpgrade'] as bool
          : (json['forceUpgrade'] ?? '').toString().toLowerCase() == 'true',
      releaseNote: (json['releaseNote'] ?? '').toString(),
    );
  }
}

class UpgradeCheckResult {
  /// 创建升级检查结果对象。
  UpgradeCheckResult({
    required this.config,
    required this.localVersion,
    required this.latestVersion,
    required this.needUpgrade,
    required this.canUpgradeAction,
    required this.platformType,
  });

  final UpgradeConfig config;
  final String localVersion;
  final String latestVersion;
  final bool needUpgrade;
  final bool canUpgradeAction;
  final String platformType;
}
