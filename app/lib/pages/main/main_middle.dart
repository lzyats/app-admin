import 'package:flutter/material.dart';

import '../../tools/auth_tool.dart';
import '../auth/login/login_page.dart';
import 'main_page.dart';

class MainMiddle extends StatelessWidget {
  const MainMiddle({
    super.key,
    required this.onLocaleChanged,
    required this.selectedLocale,
  });

  final ValueChanged<Locale?> onLocaleChanged;
  final Locale? selectedLocale;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String?>(
      valueListenable: AuthTool.tokenNotifier,
      builder: (context, _, __) {
        if (AuthTool.isLogin) {
          return MainPage(onLocaleChanged: onLocaleChanged, selectedLocale: selectedLocale);
        }
        return const LoginPage();
      },
    );
  }
}
