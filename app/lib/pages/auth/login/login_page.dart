import 'package:flutter/material.dart';

import '../../../config/app_localizations.dart';
import '../../../tools/auth_tool.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final i18n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(i18n.t('loginTitle'))),
      body: Center(
        child: ElevatedButton(
          onPressed: () => AuthTool.login('demo-token'),
          child: Text(i18n.t('loginMock')),
        ),
      ),
    );
  }
}
