import 'package:flutter/material.dart';
import 'package:myapp/config/app_localizations.dart';
import 'package:myapp/pages/auth/login/login_page.dart';
import 'package:myapp/pages/main/main_page.dart';
import 'package:myapp/pages/upgrade/upgrade_model.dart';
import 'package:myapp/pages/upgrade/upgrade_service.dart';
import 'package:myapp/tools/auth_tool.dart';
import 'package:flutter/foundation.dart';

class MainMiddle extends StatefulWidget {
  const MainMiddle({
    super.key,
    required this.onLocaleChanged,
    required this.selectedLocale,
  });

  final ValueChanged<Locale?> onLocaleChanged;
  final Locale? selectedLocale;

  @override
  /// 创建主中间层状态对象。
  State<MainMiddle> createState() => _MainMiddleState();
}

class _MainMiddleState extends State<MainMiddle> {
  @override
  /// 页面初始化后触发一次升级检查。
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _runUpgradeCheck();
    });
  }

  /// 执行启动时升级检测与升级弹窗逻辑。
  Future<void> _runUpgradeCheck() async {
    try {
      final UpgradeCheckResult? result = await UpgradeService.checkOnce();
      if (!mounted || result == null) {
        return;
      }
      if (!result.needUpgrade) {
        return;
      }

      final i18n = AppLocalizations.of(context);
      final bool forceUpgrade = result.config.forceUpgrade;
      await showDialog<void>(
        context: context,
        barrierDismissible: !forceUpgrade,
        builder: (BuildContext context) {
          return WillPopScope(
            onWillPop: () async => !forceUpgrade,
            child: AlertDialog(
              title: Text(i18n.t('upgradeDialogTitle')),
              content: Text(
                '${i18n.t('upgradeLocalVersion')}: ${result.localVersion}\n'
                '${i18n.t('upgradeLatestVersion')}: ${result.latestVersion}\n'
                '${result.config.releaseNote.isNotEmpty ? result.config.releaseNote : i18n.t('upgradeFound')}',
              ),
              actions: [
                if (!forceUpgrade)
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(i18n.t('upgradeLaterButton')),
                  ),
                FilledButton(
                  onPressed: () async {
                    try {
                      await UpgradeService.executeUpgrade(result);
                    } catch (e, s) {
                      debugPrint('upgrade execute error: $e');
                      debugPrint('$s');
                    }
                    if (!context.mounted) {
                      return;
                    }
                    Navigator.of(context).pop();
                  },
                  child: Text(i18n.t('upgradeNowButton')),
                ),
              ],
            ),
          );
        },
      );
    } catch (e, s) {
      debugPrint('upgrade check error: $e');
      debugPrint('$s');
    }
  }

  @override
  /// 根据登录态展示主页面或登录页面。
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String?>(
      valueListenable: AuthTool.tokenNotifier,
      builder: (context, _, __) {
        if (AuthTool.isLogin) {
          return MainPage(onLocaleChanged: widget.onLocaleChanged, selectedLocale: widget.selectedLocale);
        }
        return LoginPage(onLocaleChanged: widget.onLocaleChanged, selectedLocale: widget.selectedLocale);
      },
    );
  }
}
