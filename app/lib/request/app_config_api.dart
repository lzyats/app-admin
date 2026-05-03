import 'dart:convert';

import 'package:myapp/request/http_client.dart';
import 'package:myapp/request/ruoyi_endpoints.dart';

class AppBootstrapConfigData {
  const AppBootstrapConfigData({
    required this.values,
    required this.multiLanguageEnabled,
    required this.registerEnabled,
    required this.inviteCodeEnabled,
    required this.inviteRewardRule,
    required this.usdRate,
    required this.realNameHandheldRequired,
    required this.investCurrencyMode,
    required this.supportRmbToUsd,
    required this.yebaoRedeemAfter24h,
    required this.signRewardType,
    required this.signRewardAmount,
  });

  final Map<String, dynamic> values;
  final bool multiLanguageEnabled;
  final bool registerEnabled;
  final bool inviteCodeEnabled;
  final String inviteRewardRule;
  final double usdRate;
  final bool realNameHandheldRequired;
  final int investCurrencyMode;
  final bool supportRmbToUsd;
  final bool yebaoRedeemAfter24h;
  final String signRewardType;
  final double signRewardAmount;

  @Deprecated('Use supportRmbToUsd')
  bool get supportRmbToUsdExchange => supportRmbToUsd;

  bool get signRewardIsPoint => signRewardType.toUpperCase() != 'MONEY';

  List<InviteRewardRule> get inviteRewardRules {
    final dynamic decoded = _decodeInviteRule(inviteRewardRule);
    if (decoded is! List) {
      return <InviteRewardRule>[];
    }
    final List<InviteRewardRule> rules = <InviteRewardRule>[];
    for (final dynamic item in decoded) {
      if (item is Map<String, dynamic>) {
        rules.add(InviteRewardRule.fromJson(item));
      }
    }
    return rules;
  }

  bool getByItem(String item) {
    return _readBoolValue(values[item]);
  }

  double getByItemDouble(String item) {
    switch (item) {
      case AppConfigOptionItem.usdRate:
        return usdRate;
      case AppConfigOptionItem.signRewardAmount:
        return signRewardAmount;
      default:
        return _readDoubleValue(values[item], defaultValue: 7.0);
    }
  }

  int getByItemInt(String item) {
    switch (item) {
      case AppConfigOptionItem.investCurrencyMode:
        return investCurrencyMode;
      default:
        return _readIntValue(values[item], defaultValue: 1);
    }
  }

  String getByItemString(String item) {
    switch (item) {
      case AppConfigOptionItem.signRewardType:
        return signRewardType;
      case AppConfigOptionItem.inviteRewardRule:
        return inviteRewardRule;
      default:
        return _readStringValue(values[item]);
    }
  }

  dynamic getValueByKey(String key) {
    return values[key];
  }

  Map<String, dynamic> toJson() {
    return Map<String, dynamic>.from(values);
  }

  static AppBootstrapConfigData fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> values = <String, dynamic>{...json};
    values.remove('app.download.url');
    values.remove('app.upgrade.config');
    values.remove('app.sign.continuousRewardRule');
    values.remove('appDownloadUrl');
    values.remove('appUpgradeConfig');
    values.remove('signContinuousRewardRule');
    final bool multiLanguageEnabled = _readBool(json, <String>[
      AppConfigOptionItem.multiLanguageEnabled,
      'multiLanguageEnabled',
    ], true);
    final bool registerEnabled = _readBool(json, <String>[
      AppConfigOptionItem.registerEnabled,
      'registerEnabled',
    ], true);
    final bool inviteCodeEnabled = _readBool(json, <String>[
      AppConfigOptionItem.inviteCodeEnabled,
      'app.feature.inviteCodeEnabled',
      'inviteCodeEnabled',
    ], false);
    final String inviteRewardRule = _readString(json, <String>[
      AppConfigOptionItem.inviteRewardRule,
      'inviteRewardRule',
    ]);
    final double usdRate = _readDouble(json, <String>[
      AppConfigOptionItem.usdRate,
      'usdRate',
    ], 7.0);
    final bool realNameHandheldRequired = _readBool(json, <String>[
      AppConfigOptionItem.realNameHandheldRequired,
      'realNameHandheldRequired',
    ], false);
    final int investCurrencyMode = _readInvestMode(json, <String>[
      AppConfigOptionItem.investCurrencyMode,
      'investCurrencyMode',
    ], 1);
    final bool supportRmbToUsd = _readBool(json, <String>[
      AppConfigOptionItem.supportRmbToUsd,
      'supportRmbToUsd',
      'supportRmbToUsdExchange',
    ], true);
    final bool yebaoRedeemAfter24h = _readBool(json, <String>[
      AppConfigOptionItem.yebaoRedeemAfter24h,
      'yebaoRedeemAfter24h',
    ], true);
    final String signRewardType = _parseSignRewardType(_readString(json, <String>[
      AppConfigOptionItem.signRewardType,
      'signRewardType',
    ]));
    final double signRewardAmount = _readDouble(json, <String>[
      AppConfigOptionItem.signRewardAmount,
      'signRewardAmount',
    ], 1.0);

    values[AppConfigOptionItem.multiLanguageEnabled] = multiLanguageEnabled;
    values['multiLanguageEnabled'] = multiLanguageEnabled;
    values[AppConfigOptionItem.registerEnabled] = registerEnabled;
    values['registerEnabled'] = registerEnabled;
    values[AppConfigOptionItem.inviteCodeEnabled] = inviteCodeEnabled;
    values['app.feature.inviteCodeEnabled'] = inviteCodeEnabled;
    values['inviteCodeEnabled'] = inviteCodeEnabled;
    values[AppConfigOptionItem.inviteRewardRule] = inviteRewardRule;
    values['inviteRewardRule'] = inviteRewardRule;
    values[AppConfigOptionItem.usdRate] = usdRate;
    values['usdRate'] = usdRate;
    values[AppConfigOptionItem.realNameHandheldRequired] = realNameHandheldRequired;
    values['realNameHandheldRequired'] = realNameHandheldRequired;
    values[AppConfigOptionItem.investCurrencyMode] = investCurrencyMode;
    values['investCurrencyMode'] = investCurrencyMode;
    values[AppConfigOptionItem.supportRmbToUsd] = supportRmbToUsd;
    values['supportRmbToUsd'] = supportRmbToUsd;
    values[AppConfigOptionItem.yebaoRedeemAfter24h] = yebaoRedeemAfter24h;
    values['yebaoRedeemAfter24h'] = yebaoRedeemAfter24h;
    final bool captchaEnabled = _readBool(json, <String>[
      AppConfigOptionItem.captchaEnabled,
      'captchaEnabled',
    ], true);
    values[AppConfigOptionItem.captchaEnabled] = captchaEnabled;
    values['captchaEnabled'] = captchaEnabled;
    values[AppConfigOptionItem.signRewardType] = signRewardType;
    values['signRewardType'] = signRewardType;
    values[AppConfigOptionItem.signRewardAmount] = signRewardAmount;
    values['signRewardAmount'] = signRewardAmount;

    return AppBootstrapConfigData(
      values: values,
      multiLanguageEnabled: multiLanguageEnabled,
      registerEnabled: registerEnabled,
      inviteCodeEnabled: inviteCodeEnabled,
      inviteRewardRule: inviteRewardRule,
      usdRate: usdRate,
      realNameHandheldRequired: realNameHandheldRequired,
      investCurrencyMode: investCurrencyMode,
      supportRmbToUsd: supportRmbToUsd,
      yebaoRedeemAfter24h: yebaoRedeemAfter24h,
      signRewardType: signRewardType,
      signRewardAmount: signRewardAmount,
    );
  }

  static String _parseSignRewardType(dynamic value) {
    final String parsed = _parseString(value).toUpperCase();
    if (parsed == 'MONEY') {
      return 'MONEY';
    }
    return 'POINT';
  }

  static String _parseString(dynamic value, {String defaultValue = ''}) {
    if (value == null) return defaultValue;
    if (value is String) {
      return value;
    }
    return value.toString();
  }

  static bool _readBoolValue(dynamic value, {bool defaultValue = false}) {
    if (value == null) {
      return defaultValue;
    }
    final String parsed = _parseString(value).trim().toLowerCase();
    if (parsed.isEmpty) {
      return defaultValue;
    }
    return parsed == '1' ||
        parsed == 'true' ||
        parsed == 'y' ||
        parsed == 'yes' ||
        parsed == 'on';
  }

  static double _readDoubleValue(dynamic value, {double defaultValue = 0}) {
    if (value == null) {
      return defaultValue;
    }
    if (value is double) {
      return value;
    }
    if (value is int) {
      return value.toDouble();
    }
    if (value is String) {
      final double? parsed = double.tryParse(value);
      if (parsed != null) {
        return parsed;
      }
    }
    return defaultValue;
  }

  static int _readIntValue(dynamic value, {int defaultValue = 0}) {
    if (value == null) {
      return defaultValue;
    }
    if (value is int) {
      return value;
    }
    if (value is double) {
      return value.toInt();
    }
    if (value is String) {
      final int? parsed = int.tryParse(value);
      if (parsed != null) {
        return parsed;
      }
    }
    return defaultValue;
  }

  static String _readStringValue(dynamic value, {String defaultValue = ''}) {
    final String parsed = _parseString(value, defaultValue: defaultValue).trim();
    return parsed.isEmpty ? defaultValue : parsed;
  }

  static bool _readBool(
    Map<String, dynamic> json,
    List<String> keys,
    bool defaultValue,
  ) {
    for (final String key in keys) {
      final dynamic value = json[key];
      if (value == null) {
        continue;
      }
      final String parsed = _parseString(value).trim().toLowerCase();
      if (parsed.isEmpty) {
        continue;
      }
      return parsed == '1' ||
          parsed == 'true' ||
          parsed == 'y' ||
          parsed == 'yes' ||
          parsed == 'on';
    }
    return defaultValue;
  }

  static double _readDouble(
    Map<String, dynamic> json,
    List<String> keys,
    double defaultValue,
  ) {
    for (final String key in keys) {
      final dynamic value = json[key];
      if (value == null) {
        continue;
      }
      if (value is double) {
        return value;
      }
      if (value is int) {
        return value.toDouble();
      }
      if (value is String) {
        final double? parsed = double.tryParse(value);
        if (parsed != null) {
          return parsed;
        }
      }
    }
    return defaultValue;
  }

  static int _readInt(
    Map<String, dynamic> json,
    List<String> keys,
    int defaultValue,
  ) {
    for (final String key in keys) {
      final dynamic value = json[key];
      if (value == null) {
        continue;
      }
      if (value is int) {
        return value;
      }
      if (value is double) {
        return value.toInt();
      }
      if (value is String) {
        final int? parsed = int.tryParse(value);
        if (parsed != null) {
          return parsed;
        }
      }
    }
    return defaultValue;
  }

  static int _readInvestMode(
    Map<String, dynamic> json,
    List<String> keys,
    int defaultValue,
  ) {
    final int parsed = _readInt(json, keys, defaultValue);
    return parsed == 2 ? 2 : 1;
  }

  static String _readString(
    Map<String, dynamic> json,
    List<String> keys, {
    String defaultValue = '',
  }) {
    for (final String key in keys) {
      final dynamic value = json[key];
      final String parsed = _parseString(value, defaultValue: '').trim();
      if (parsed.isNotEmpty) {
        return parsed;
      }
    }
    return defaultValue;
  }

  static dynamic _decodeInviteRule(String raw) {
    if (raw.trim().isEmpty) {
      return const <dynamic>[];
    }
    try {
      return jsonDecode(raw);
    } catch (_) {
      return const <dynamic>[];
    }
  }

  static const AppBootstrapConfigData defaults = AppBootstrapConfigData(
    values: <String, dynamic>{
      AppConfigOptionItem.multiLanguageEnabled: true,
      AppConfigOptionItem.registerEnabled: true,
      AppConfigOptionItem.inviteCodeEnabled: false,
      AppConfigOptionItem.inviteRewardRule: '[]',
      AppConfigOptionItem.usdRate: 7.0,
      AppConfigOptionItem.realNameHandheldRequired: false,
      AppConfigOptionItem.investCurrencyMode: 1,
      AppConfigOptionItem.supportRmbToUsd: true,
      AppConfigOptionItem.yebaoRedeemAfter24h: true,
      AppConfigOptionItem.captchaEnabled: true,
      AppConfigOptionItem.signRewardType: 'POINT',
      AppConfigOptionItem.signRewardAmount: 1.0,
    },
    multiLanguageEnabled: true,
    registerEnabled: true,
    inviteCodeEnabled: false,
    usdRate: 7.0,
    realNameHandheldRequired: false,
    investCurrencyMode: 1,
    supportRmbToUsd: true,
    yebaoRedeemAfter24h: true,
    signRewardType: 'POINT',
    signRewardAmount: 1.0,
    inviteRewardRule: '[]',
  );
}

class SignRewardRule {
  const SignRewardRule({
    required this.day,
    required this.amount,
  });

  final int day;
  final double amount;

  factory SignRewardRule.fromJson(Map<String, dynamic> json) {
    return SignRewardRule(
      day: int.tryParse('${json['day'] ?? json['days'] ?? 0}') ?? 0,
      amount: double.tryParse('${json['amount'] ?? json['reward'] ?? 0}') ?? 0,
    );
  }
}

class InviteRewardRule {
  const InviteRewardRule({
    required this.level,
    required this.percent,
    required this.amount,
  });

  final int level;
  final double percent;
  final double amount;

  factory InviteRewardRule.fromJson(Map<String, dynamic> json) {
    return InviteRewardRule(
      level: int.tryParse('${json['level'] ?? json['day'] ?? json['tier'] ?? 0}') ?? 0,
      percent: double.tryParse('${json['percent'] ?? json['ratio'] ?? 0}') ?? 0,
      amount: double.tryParse('${json['amount'] ?? json['reward'] ?? 0}') ?? 0,
    );
  }
}

class AppConfigApi {
  AppConfigApi._();

  static Future<AppBootstrapConfigData> bootstrap({
    List<String>? items,
  }) async {
    final Map<String, dynamic>? query = (items == null || items.isEmpty)
        ? null
        : <String, dynamic>{'items': items.join(',')};
    final res = await HttpClient.get(
      RuoYiEndpoints.appBootstrapConfig,
      query: query,
      encrypt: true,
      retry: true,
    );
    final dynamic raw = res.data;
    if (raw is Map) {
      final Map<String, dynamic> json = <String, dynamic>{};
      raw.forEach((dynamic key, dynamic value) {
        json[key.toString()] = value;
      });
      return AppBootstrapConfigData.fromJson(json);
    }
    return AppBootstrapConfigData.defaults;
  }

  static Future<List<AppConfigOptionItemMeta>> options() async {
    final res = await HttpClient.get(
      RuoYiEndpoints.appConfigOptions,
      encrypt: true,
      retry: true,
    );
    final dynamic raw = res.data;
    if (raw is! List) {
      return AppConfigOptionItemMeta.defaults;
    }
    final Map<String, AppConfigOptionItemMeta> remoteByItem = <String, AppConfigOptionItemMeta>{};
    for (final dynamic item in raw) {
      if (item is Map) {
        final Map<String, dynamic> json = <String, dynamic>{};
        item.forEach((dynamic key, dynamic value) {
          json[key.toString()] = value;
        });
        final AppConfigOptionItemMeta meta = AppConfigOptionItemMeta.fromJson(json);
        if (meta.item.trim().isNotEmpty) {
          remoteByItem[meta.item] = meta;
        }
      }
    }
    if (remoteByItem.isEmpty) {
      return AppConfigOptionItemMeta.defaults;
    }
    final List<AppConfigOptionItemMeta> merged = <AppConfigOptionItemMeta>[];
    final Set<String> added = <String>{};
    for (final AppConfigOptionItemMeta fallback in AppConfigOptionItemMeta.defaults) {
      final AppConfigOptionItemMeta? remote = remoteByItem[fallback.item];
      merged.add(remote ?? fallback);
      added.add(fallback.item);
    }
    for (final AppConfigOptionItemMeta remote in remoteByItem.values) {
      if (!added.contains(remote.item)) {
        merged.add(remote);
      }
    }
    return merged;
  }
}

class AppConfigOptionItem {
  const AppConfigOptionItem._();

  static const String multiLanguageEnabled = 'app.feature.multiLanguage';
  static const String registerEnabled = 'sys.account.registerUser';
  static const String captchaEnabled = 'sys.account.captchaEnabled';
  static const String inviteCodeEnabled = 'app.feature.inviteCodeEnabled';
  static const String inviteRewardRule = 'app.invite.rewardRule';
  static const String realNameHandheldRequired = 'app.feature.realNameHandheldRequired';
  static const String usdRate = 'app.currency.usdRate';
  static const String investCurrencyMode = 'app.currency.investMode';
  static const String supportRmbToUsd = 'app.currency.supportRmbToUsd';
  static const String yebaoRedeemAfter24h = 'app.yebao.redeemAfter24h';
  static const String signRewardType = 'app.sign.rewardType';
  static const String signRewardAmount = 'app.sign.rewardAmount';

  @Deprecated('Use supportRmbToUsd')
  static const String supportRmbToUsdExchange = supportRmbToUsd;

  static const List<String> required = <String>[
    captchaEnabled,
    inviteRewardRule,
    yebaoRedeemAfter24h,
    signRewardType,
    signRewardAmount,
  ];

  static const List<String> all = <String>[
    multiLanguageEnabled,
    registerEnabled,
    captchaEnabled,
    inviteCodeEnabled,
    inviteRewardRule,
    realNameHandheldRequired,
    usdRate,
    investCurrencyMode,
    supportRmbToUsd,
    yebaoRedeemAfter24h,
    signRewardType,
    signRewardAmount,
  ];
}

class AppConfigOptionItemMeta {
  const AppConfigOptionItemMeta({
    required this.item,
    required this.configKey,
    required this.name,
    required this.defaultValue,
  });

  final String item;
  final String configKey;
  final String name;
  final dynamic defaultValue;

  static AppConfigOptionItemMeta fromJson(Map<String, dynamic> json) {
    return AppConfigOptionItemMeta(
      item: (json['item'] ?? '').toString(),
      configKey: (json['configKey'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      defaultValue: json['defaultValue'],
    );
  }

  static const List<AppConfigOptionItemMeta> defaults = <AppConfigOptionItemMeta>[
    AppConfigOptionItemMeta(
      item: AppConfigOptionItem.multiLanguageEnabled,
      configKey: 'app.feature.multiLanguage',
      name: 'Multi-language',
      defaultValue: true,
    ),
    AppConfigOptionItemMeta(
      item: AppConfigOptionItem.registerEnabled,
      configKey: 'sys.account.registerUser',
      name: 'Open Registration',
      defaultValue: true,
    ),
    AppConfigOptionItemMeta(
      item: AppConfigOptionItem.captchaEnabled,
      configKey: 'sys.account.captchaEnabled',
      name: 'Captcha Enabled',
      defaultValue: true,
    ),
    AppConfigOptionItemMeta(
      item: AppConfigOptionItem.inviteCodeEnabled,
      configKey: 'app.feature.inviteCodeEnabled',
      name: 'Invite Code Registration',
      defaultValue: false,
    ),
    AppConfigOptionItemMeta(
      item: AppConfigOptionItem.inviteRewardRule,
      configKey: 'app.invite.rewardRule',
      name: 'Invite reward rule',
      defaultValue: '[]',
    ),
    AppConfigOptionItemMeta(
      item: AppConfigOptionItem.usdRate,
      configKey: 'app.currency.usdRate',
      name: 'USD Exchange Rate',
      defaultValue: 7.0,
    ),
    AppConfigOptionItemMeta(
      item: AppConfigOptionItem.realNameHandheldRequired,
      configKey: 'app.feature.realNameHandheldRequired',
      name: 'Handheld ID Required',
      defaultValue: false,
    ),
    AppConfigOptionItemMeta(
      item: AppConfigOptionItem.investCurrencyMode,
      configKey: 'app.currency.investMode',
      name: 'Investment Currency Mode',
      defaultValue: 1,
    ),
    AppConfigOptionItemMeta(
      item: AppConfigOptionItem.supportRmbToUsd,
      configKey: 'app.currency.supportRmbToUsd',
      name: 'Support CNY to USD',
      defaultValue: true,
    ),
    AppConfigOptionItemMeta(
      item: AppConfigOptionItem.yebaoRedeemAfter24h,
      configKey: 'app.yebao.redeemAfter24h',
      name: 'Yebao redeem after 24h',
      defaultValue: true,
    ),
    AppConfigOptionItemMeta(
      item: AppConfigOptionItem.signRewardType,
      configKey: 'app.sign.rewardType',
      name: 'Sign reward type',
      defaultValue: 'POINT',
    ),
    AppConfigOptionItemMeta(
      item: AppConfigOptionItem.signRewardAmount,
      configKey: 'app.sign.rewardAmount',
      name: 'Sign reward amount',
      defaultValue: 1.0,
    ),
  ];
}
