import 'package:flutter/material.dart';
import 'package:myapp/config/app_localizations.dart';
import 'package:myapp/pages/upgrade/upgrade_controller.dart';

class UpgradePage extends StatefulWidget {
  const UpgradePage({super.key});

  @override
  /// 创建升级页面状态对象。
  State<UpgradePage> createState() => _UpgradePageState();
}

class _UpgradePageState extends State<UpgradePage> {
  late final UpgradeController _controller;

  @override
  /// 初始化升级控制器并立即检查更新。
  void initState() {
    super.initState();
    _controller = UpgradeController();
    _controller.check();
  }

  @override
  /// 释放升级控制器资源。
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  /// 构建升级页面。
  Widget build(BuildContext context) {
    final i18n = AppLocalizations.of(context);
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        final result = _controller.result;
        return Scaffold(
          appBar: AppBar(title: Text(i18n.t('upgradeTitle'))),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(i18n.t('upgradeDesc')),
                const SizedBox(height: 12),
                if (result != null) ...[
                  Text('${i18n.t('upgradeLocalVersion')}: ${result.localVersion}'),
                  Text('${i18n.t('upgradeLatestVersion')}: ${result.latestVersion.isEmpty ? '--' : result.latestVersion}'),
                  Text('${i18n.t('upgradePlatform')}: ${result.platformType}'),
                  const SizedBox(height: 8),
                  Text(i18n.t(_controller.messageKey)),
                  const SizedBox(height: 8),
                  if (result.config.releaseNote.isNotEmpty)
                    Text('${i18n.t('upgradeReleaseNote')}: ${result.config.releaseNote}'),
                ] else ...[
                  Text(i18n.t(_controller.messageKey)),
                ],
                const Spacer(),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _controller.loading ? null : _controller.check,
                        child: Text(_controller.loading ? i18n.t('upgradeChecking') : i18n.t('upgradeCheckButton')),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: _controller.upgrading ? null : _controller.doUpgrade,
                        child: Text(_controller.upgrading ? i18n.t('upgradeStarting') : i18n.t('upgradeNowButton')),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
