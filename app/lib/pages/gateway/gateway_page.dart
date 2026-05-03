import 'package:flutter/material.dart';
import 'package:myapp/config/app_localizations.dart';

class GatewayPage extends StatelessWidget {
  const GatewayPage({super.key});

  @override
  /// 构建网关页面。
  Widget build(BuildContext context) {
    final i18n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(i18n.t('gatewayTitle'))),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(i18n.t('gatewayDesc')),
      ),
    );
  }
}
