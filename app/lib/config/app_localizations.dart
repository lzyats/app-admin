import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppLocalizations {
  AppLocalizations(this.locale, this._data);

  final Locale locale;
  final Map<String, String> _data;

  static const List<Locale> supportedLocales = <Locale>[
    Locale('zh', 'CN'),
    Locale('en', 'US'),
  ];

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// 从当前上下文获取本地化实例。
  static AppLocalizations of(BuildContext context) {
    final AppLocalizations? result =
        Localizations.of<AppLocalizations>(context, AppLocalizations);
    assert(result != null, 'No AppLocalizations found in context.');
    return result!;
  }

  /// 通过键名读取文案，不存在时回退为键名本身。
  String t(String key) {
    final String? value = _data[key];
    if (value != null && value.isNotEmpty) {
      return value;
    }
    return key;
  }
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  /// 判断当前语言是否在支持列表中。
  bool isSupported(Locale locale) {
    return AppLocalizations.supportedLocales
        .any((Locale item) => item.languageCode == locale.languageCode);
  }

  @override
  /// 根据语言加载对应的 JSON 语言包。
  Future<AppLocalizations> load(Locale locale) async {
    print('Loading locale: $locale');
    final String path = locale.languageCode == 'zh'
        ? 'assets/i18n/zh-CN.json'
        : 'assets/i18n/en-US.json';
    print('Loading translation file: $path');
    // 确保使用UTF-8编码加载文件
    final ByteData data = await rootBundle.load(path);
    final String raw = utf8.decode(data.buffer.asUint8List());
    print('Loaded translation file, length: ${raw.length}');
    final Map<String, dynamic> decoded = json.decode(raw) as Map<String, dynamic>;
    print('Decoded translation data, keys: ${decoded.keys.length}');
    print('Has securityQuestionSaveButton: ${decoded.containsKey('securityQuestionSaveButton')}');
    if (decoded.containsKey('securityQuestionSaveButton')) {
      print('securityQuestionSaveButton value: ${decoded['securityQuestionSaveButton']}');
    }
    final Map<String, String> translationData = 
        decoded.map((String k, dynamic v) => MapEntry(k, v.toString()));
    return AppLocalizations(locale, translationData);
  }

  @override
  /// 本地化代理无需动态重载。
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) {
    return false;
  }
}
