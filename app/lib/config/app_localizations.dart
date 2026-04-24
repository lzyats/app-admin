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

  /// 从当前上下文获取本地化实例。
  static AppLocalizations of(BuildContext context) {
    final AppLocalizations? result = Localizations.of<AppLocalizations>(context, AppLocalizations);
    assert(result != null, 'No AppLocalizations found in context.');
    return result!;
  }

  /// 通过键名读取本地化文案，不存在时回退为键名本身。
  String t(String key) {
    final String? value = _data[key];
    if (value != null && value.isNotEmpty) {
      return value;
    }
    final bool zh = locale.languageCode == 'zh';
    return (_fallback[zh ? 'zh' : 'en']?[key]) ?? key;
  }

  /// 认证场景兜底文案，防止资源未刷新时直接显示 key。
  static const Map<String, Map<String, String>> _fallback = <String, Map<String, String>>{
    'zh': <String, String>{
      'authLoginTitle': '账号登录',
      'authLoginSubTitle': '安全连接已就绪，请输入账号信息继续。',
      'authUsername': '用户名',
      'authUsernameHint': '请输入用户名',
      'authPassword': '密码',
      'authPasswordHint': '请输入密码（5-20位）',
      'authCaptcha': '验证码',
      'authCaptchaHint': '请输入验证码',
      'authRefreshCaptcha': '刷新验证码',
      'authChooseLine': '线路选择',
      'authLoginAction': '立即登录',
      'authSubmitting': '提交中...',
      'authGoRegister': '注册账号',
      'authGoForgotPassword': '忘记密码',
      'authRegisterTitle': '创建账号',
      'authRegisterSubTitle': '注册新账号后即可开始使用系统。',
      'authRegisterAction': '完成注册',
      'authConfirmPassword': '确认密码',
      'authConfirmPasswordHint': '请再次输入密码',
      'authBackToLogin': '返回登录',
    },
    'en': <String, String>{
      'authLoginTitle': 'Account Login',
      'authLoginSubTitle': 'Secure channel is ready. Enter your credentials to continue.',
      'authUsername': 'Username',
      'authUsernameHint': 'Enter your username',
      'authPassword': 'Password',
      'authPasswordHint': 'Enter password (5-20 chars)',
      'authCaptcha': 'Captcha',
      'authCaptchaHint': 'Enter captcha',
      'authRefreshCaptcha': 'Refresh captcha',
      'authChooseLine': 'Select line',
      'authLoginAction': 'Login now',
      'authSubmitting': 'Submitting...',
      'authGoRegister': 'Create account',
      'authGoForgotPassword': 'Forgot password',
      'authRegisterTitle': 'Create Account',
      'authRegisterSubTitle': 'Register a new account to start using the system.',
      'authRegisterAction': 'Complete registration',
      'authConfirmPassword': 'Confirm password',
      'authConfirmPasswordHint': 'Enter the password again',
      'authBackToLogin': 'Back to login',
    },
  };
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  /// 判断当前语言是否在支持列表中。
  bool isSupported(Locale locale) {
    return AppLocalizations.supportedLocales.any((item) => item.languageCode == locale.languageCode);
  }

  @override
  /// 根据语言加载对应的 JSON 语言包。
  Future<AppLocalizations> load(Locale locale) async {
    final String path = locale.languageCode == 'zh' ? 'assets/i18n/zh-CN.json' : 'assets/i18n/en-US.json';
    final String raw = await rootBundle.loadString(path);
    final Map<String, dynamic> decoded = json.decode(raw) as Map<String, dynamic>;
    final Map<String, String> data = decoded.map((k, v) => MapEntry(k, v.toString()));
    return AppLocalizations(locale, data);
  }

  @override
  /// 本地化代理无需动态重载。
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) => false;
}
