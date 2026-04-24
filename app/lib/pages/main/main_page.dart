import 'package:flutter/material.dart';
import 'package:myapp/config/app_localizations.dart';
import 'package:myapp/routers/app_router.dart';
import 'package:myapp/tools/auth_tool.dart';

class MainPage extends StatelessWidget {
  const MainPage({
    super.key,
    required this.onLocaleChanged,
    required this.selectedLocale,
  });

  final ValueChanged<Locale?> onLocaleChanged;
  final Locale? selectedLocale;

  @override
  /// 构建主功能导航页面。
  Widget build(BuildContext context) {
    final i18n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(i18n.t('homeTitle')),
        actions: [
          IconButton(
            onPressed: AuthTool.logout,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              title: Text(i18n.t('upgradeTitle')),
              onTap: () => Navigator.pushNamed(context, AppRouter.upgrade),
            ),
          ),
          Card(
            child: ListTile(
              title: Text(i18n.t('lineTitle')),
              onTap: () => Navigator.pushNamed(context, AppRouter.line),
            ),
          ),
          Card(
            child: ListTile(
              title: Text(i18n.t('gatewayTitle')),
              onTap: () => Navigator.pushNamed(context, AppRouter.gateway),
            ),
          ),
          const SizedBox(height: 24),
          DropdownButtonFormField<String>(
            value: selectedLocale == null ? 'system' : '${selectedLocale!.languageCode}_${selectedLocale!.countryCode}',
            items: [
              DropdownMenuItem(value: 'system', child: Text(i18n.t('followSystem'))),
              DropdownMenuItem(value: 'zh_CN', child: Text(i18n.t('zhCN'))),
              DropdownMenuItem(value: 'en_US', child: Text(i18n.t('enUS'))),
            ],
            onChanged: (value) {
              switch (value) {
                case 'zh_CN':
                  onLocaleChanged(const Locale('zh', 'CN'));
                  break;
                case 'en_US':
                  onLocaleChanged(const Locale('en', 'US'));
                  break;
                default:
                  onLocaleChanged(null);
              }
            },
          ),
        ],
      ),
    );
  }
}
