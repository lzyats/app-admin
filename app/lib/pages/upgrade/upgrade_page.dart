import 'package:flutter/material.dart';

import '../../config/app_localizations.dart';

class UpgradePage extends StatelessWidget {
  const UpgradePage({super.key});

  @override
  Widget build(BuildContext context) {
    final i18n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(i18n.t('upgradeTitle'))),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(i18n.t('upgradeDesc')),
      ),
    );
  }
}
