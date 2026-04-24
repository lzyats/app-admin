import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppLocalizations {
  AppLocalizations(this.locale, this._data);

  final Locale locale;
  final Map<String, String> _data;

  static const supportedLocales = <Locale>[
    Locale('zh', 'CN'),
    Locale('en', 'US'),
  ];

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  static AppLocalizations of(BuildContext context) {
    final AppLocalizations? result = Localizations.of<AppLocalizations>(context, AppLocalizations);
    assert(result != null, 'No AppLocalizations found in context.');
    return result!;
  }

  String t(String key) => _data[key] ?? key;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return AppLocalizations.supportedLocales.any((item) => item.languageCode == locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    final String path = locale.languageCode == 'zh' ? 'assets/i18n/zh-CN.json' : 'assets/i18n/en-US.json';
    final String raw = await rootBundle.loadString(path);
    final Map<String, dynamic> decoded = json.decode(raw) as Map<String, dynamic>;
    final Map<String, String> data = decoded.map((k, v) => MapEntry(k, v.toString()));
    return AppLocalizations(locale, data);
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) => false;
}
