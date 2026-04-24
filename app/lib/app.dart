import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'config/app_config.dart';
import 'config/app_localizations.dart';
import 'pages/main/main_middle.dart';
import 'res/app_theme.dart';
import 'routers/app_router.dart';

class GoApiApp extends StatefulWidget {
  const GoApiApp({super.key});

  @override
  State<GoApiApp> createState() => _GoApiAppState();
}

class _GoApiAppState extends State<GoApiApp> {
  Locale? _locale;

  void updateLocale(Locale? locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConfig.appName,
      locale: _locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: AppTheme.light,
      onGenerateRoute: AppRouter.onGenerateRoute,
      home: MainMiddle(onLocaleChanged: updateLocale, selectedLocale: _locale),
    );
  }
}
