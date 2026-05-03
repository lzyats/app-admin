import 'package:flutter/material.dart';

import 'package:myapp/config/app_localizations.dart';
import 'package:myapp/pages/upgrade/upgrade_model.dart';
import 'package:myapp/pages/upgrade/upgrade_service.dart';
import 'package:myapp/routers/app_router.dart';

class SoftwareSettingsPage extends StatelessWidget {
  const SoftwareSettingsPage({
    super.key,
    this.onLocaleChanged,
    this.selectedLocale,
  });

  final Function(Locale)? onLocaleChanged;
  final Locale? selectedLocale;

  @override
  Widget build(BuildContext context) {
    final i18n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFF0A1220),
      appBar: AppBar(
        title: Text(i18n.t('mineSoftwareSettingNav')),
        backgroundColor: const Color(0xFF0A1220),
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[
              Color(0xFF0A1220),
              Color(0xFF0D1B2A),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xCC101C30),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0x334CE3FF)),
                boxShadow: const <BoxShadow>[
                  BoxShadow(
                    color: Color(0x66000000),
                    blurRadius: 28,
                    offset: Offset(0, 14),
                  ),
                ],
              ),
              child: Column(
                children: <Widget>[
                  _buildMenuItem(
                    icon: Icons.lan_outlined,
                    iconColor: const Color(0xFF39E6FF),
                    label: i18n.t('mineLineSetting'),
                    onTap: () {
                      Navigator.pushNamed(context, AppRouter.line);
                    },
                  ),
                  _buildDivider(),
                  _buildMenuItem(
                    icon: Icons.system_update_outlined,
                    iconColor: const Color(0xFF38FFB3),
                    label: i18n.t('mineCheckUpgrade'),
                    onTap: () {
                      _checkUpgrade(context);
                    },
                  ),
                  _buildDivider(),
                  _buildMenuItem(
                    icon: Icons.language_outlined,
                    iconColor: const Color(0xFFE9F3FF),
                    label: i18n.locale.languageCode == 'en' ? 'Language Settings' : '语言设置',
                    onTap: () {
                      _showLanguageSelection(context);
                    },
                  ),
                  _buildDivider(),
                  _buildMenuItem(
                    icon: Icons.notifications_outlined,
                    iconColor: const Color(0xFFE2FF59),
                    label: i18n.t('mineEarningsReminder'),
                    onTap: () {
                      _showComingSoon(context);
                    },
                    isLast: true,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required Color iconColor,
    required String label,
    required VoidCallback onTap,
    bool isLast = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: isLast
          ? const BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            )
          : BorderRadius.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: <Widget>[
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 22,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: Color(0xFFE9F3FF),
                  fontSize: 15,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: Color(0xFF9DB1C9),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      margin: const EdgeInsets.only(left: 76),
      height: 1,
      color: const Color(0x334CE3FF),
    );
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('功能开发中'),
        backgroundColor: Color(0xFFFFA500),
      ),
    );
  }

  Future<void> _checkUpgrade(BuildContext context) async {
    final AppLocalizations i18n = AppLocalizations.of(context);
    try {
      final UpgradeCheckResult result = await UpgradeService.checkUpgrade();
      if (!context.mounted) {
        return;
      }

      if (!result.needUpgrade) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(i18n.t('upgradeLatest'))),
        );
        return;
      }

      final bool forceUpgrade = result.config.forceUpgrade;
      await showDialog<void>(
        context: context,
        barrierDismissible: !forceUpgrade,
        builder: (BuildContext dialogContext) {
          return PopScope(
            canPop: !forceUpgrade,
            child: AlertDialog(
              title: Text(i18n.t('upgradeDialogTitle')),
              content: Text(
                '${i18n.t('upgradeLocalVersion')}: ${result.localVersion}\n'
                '${i18n.t('upgradeLatestVersion')}: ${result.latestVersion}\n'
                '${result.config.releaseNote.isNotEmpty ? result.config.releaseNote : i18n.t('upgradeFound')}',
              ),
              actions: <Widget>[
                if (!forceUpgrade)
                  TextButton(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    child: Text(i18n.t('upgradeLaterButton')),
                  ),
                FilledButton(
                  onPressed: () async {
                    try {
                      await UpgradeService.executeUpgrade(result);
                    } catch (_) {}
                    if (dialogContext.mounted) {
                      Navigator.of(dialogContext).pop();
                    }
                  },
                  child: Text(i18n.t('upgradeNowButton')),
                ),
              ],
            ),
          );
        },
      );
    } catch (_) {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(i18n.t('upgradeCheckFailed'))),
      );
    }
  }

  void _showLanguageSelection(BuildContext context) {
    final i18n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A2332),
        title: Text(i18n.t('language'), style: const TextStyle(color: Color(0xFFE9F3FF))),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              title: Text(i18n.t('zhCN'), style: const TextStyle(color: Color(0xFFE9F3FF))),
              onTap: () {
                Navigator.pop(context);
                if (onLocaleChanged != null) {
                  onLocaleChanged!(const Locale('zh', 'CN'));
                }
              },
            ),
            ListTile(
              title: Text(i18n.t('enUS'), style: const TextStyle(color: Color(0xFFE9F3FF))),
              onTap: () {
                Navigator.pop(context);
                if (onLocaleChanged != null) {
                  onLocaleChanged!(const Locale('en', 'US'));
                }
              },
            ),
          ],
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消', style: TextStyle(color: Color(0xFF9DB1C9))),
          ),
        ],
      ),
    );
  }
}
