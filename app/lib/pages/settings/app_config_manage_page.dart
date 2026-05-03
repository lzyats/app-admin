import 'package:flutter/material.dart';
import 'package:myapp/config/app_localizations.dart';
import 'package:myapp/request/app_config_api.dart';

class AppConfigManagePage extends StatefulWidget {
  const AppConfigManagePage({super.key});

  @override
  State<AppConfigManagePage> createState() => _AppConfigManagePageState();
}

class _AppConfigManagePageState extends State<AppConfigManagePage> {
  bool _loading = true;
  List<AppConfigOptionItemMeta> _options = <AppConfigOptionItemMeta>[];

  @override
  void initState() {
    super.initState();
    _loadOptions();
  }

  Future<void> _loadOptions() async {
    try {
      final List<AppConfigOptionItemMeta> options = await AppConfigApi.options();
      if (!mounted) {
        return;
      }
      setState(() {
        _options = options;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _options = AppConfigOptionItemMeta.defaults;
        _loading = false;
      });
    }
  }

  Future<void> _refreshConfig() async {
    setState(() {
      _loading = true;
    });
    try {
      await _loadOptions();
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations i18n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(i18n.t('appConfigManageTitle')),
        actions: <Widget>[
          IconButton(
            onPressed: _loading ? null : _refreshConfig,
            icon: const Icon(Icons.refresh),
            tooltip: i18n.t('appConfigManageRefresh'),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: <Widget>[
                _buildHintCard(i18n),
                const SizedBox(height: 12),
                ..._options.map((AppConfigOptionItemMeta option) {
                  final dynamic value = option.defaultValue;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Expanded(
                                  child: Text(
                                    _optionDisplayName(i18n, option),
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                _valueChip(_formatValue(value)),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              option.configKey,
                              style: const TextStyle(
                                color: Color(0xFF90A4B8),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
    );
  }

  Widget _buildHintCard(AppLocalizations i18n) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              i18n.t('appConfigCurrentValues'),
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              i18n.t('appConfigManageHint'),
              style: const TextStyle(
                color: Color(0xFF9FB3CB),
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _valueChip(String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF3FF),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        value,
        style: const TextStyle(
          color: Color(0xFF3558D5),
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _formatValue(dynamic value) {
    if (value == null) {
      return '--';
    }
    if (value is bool) {
      return value ? 'ON' : 'OFF';
    }
    if (value is num) {
      return value.toString();
    }
    final String text = value.toString().trim();
    if (text.isEmpty) {
      return '--';
    }
    if ((text.startsWith('{') || text.startsWith('[')) && text.length > 32) {
      return '${text.substring(0, 32)}...';
    }
    if (text.length > 48) {
      return '${text.substring(0, 48)}...';
    }
    return text;
  }

  String _optionDisplayName(AppLocalizations i18n, AppConfigOptionItemMeta option) {
    if (option.name.trim().isNotEmpty) {
      return option.name;
    }
    switch (option.item) {
      case AppConfigOptionItem.multiLanguageEnabled:
        return i18n.t('appConfigItemMultiLanguage');
      case AppConfigOptionItem.registerEnabled:
        return i18n.t('appConfigItemRegister');
      case AppConfigOptionItem.captchaEnabled:
        return i18n.t('appConfigItemCaptchaEnabled');
      case AppConfigOptionItem.inviteCodeEnabled:
        return i18n.t('appConfigItemInviteCode');
      case AppConfigOptionItem.inviteRewardRule:
        return i18n.t('appConfigItemInviteRewardRule');
      case AppConfigOptionItem.usdRate:
        return i18n.t('appConfigItemUsdRate');
      case AppConfigOptionItem.realNameHandheldRequired:
        return i18n.t('appConfigItemRealNameHandheld');
      case AppConfigOptionItem.investCurrencyMode:
        return i18n.t('appConfigItemInvestCurrencyMode');
      case AppConfigOptionItem.supportRmbToUsd:
        return i18n.t('appConfigItemSupportRmbToUsd');
      case AppConfigOptionItem.yebaoRedeemAfter24h:
        return i18n.t('appConfigItemYebaoRedeemAfter24h');
      case AppConfigOptionItem.signRewardType:
        return i18n.t('appConfigItemSignRewardType');
      case AppConfigOptionItem.signRewardAmount:
        return i18n.t('appConfigItemSignRewardAmount');
      default:
        return option.configKey;
    }
  }
}
