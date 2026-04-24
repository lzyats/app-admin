import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:myapp/config/app_config.dart';
import 'package:myapp/config/app_localizations.dart';
import 'package:myapp/pages/main/main_middle.dart';
import 'package:myapp/res/app_theme.dart';
import 'package:myapp/routers/app_router.dart';
import 'package:myapp/tools/locale_tool.dart';

class GoApiApp extends StatefulWidget {
  const GoApiApp({super.key});

  @override
  /// 创建应用根组件的状态对象。
  State<GoApiApp> createState() => _GoApiAppState();
}

class _GoApiAppState extends State<GoApiApp> {
  Locale? _locale;

  @override
  /// 初始化应用时加载已保存的语言配置。
  void initState() {
    super.initState();
    _restoreLocale();
  }

  /// 从本地缓存恢复用户上次选择的语言。
  Future<void> _restoreLocale() async {
    final Locale? saved = await LocaleTool.loadLocale();
    if (!mounted) {
      return;
    }
    setState(() {
      _locale = saved;
    });
  }

  /// 更新应用语言并触发界面重建。
  void updateLocale(Locale? locale) {
    unawaited(LocaleTool.saveLocale(locale));
    setState(() {
      _locale = locale;
    });
  }

  @override
  /// 构建应用入口 MaterialApp。
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
