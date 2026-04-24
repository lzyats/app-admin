import 'package:flutter/material.dart';

import '../../config/app_localizations.dart';

class LinePage extends StatelessWidget {
  const LinePage({super.key});

  @override
  Widget build(BuildContext context) {
    final i18n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(i18n.t('lineTitle'))),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(i18n.t('lineDesc')),
      ),
    );
  }
}
