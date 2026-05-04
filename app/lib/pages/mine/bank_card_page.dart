import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:myapp/config/app_localizations.dart';
import 'package:myapp/request/auth_api.dart';
import 'package:myapp/request/bank_card_api.dart';
import 'package:myapp/tools/app_bootstrap_tool.dart';
import 'package:myapp/tools/auth_tool.dart';
import 'package:myapp/routers/app_router.dart';
import 'package:myapp/widgets/currency_brand_badge.dart';

class BankCardPage extends StatefulWidget {
  const BankCardPage({super.key});

  @override
  State<BankCardPage> createState() => _BankCardPageState();
}

class _BankCardPageState extends State<BankCardPage> {
  bool _loading = false;
  int _investMode = 1;
  AuthUserProfile? _profile;
  List<BankCardItem> _cards = <BankCardItem>[];

  bool get _isDualMode => _investMode == 2;

  @override
  void initState() {
    super.initState();
    _initPage();
  }

  Future<void> _initPage() async {
    await _loadConfig();
    await _loadProfile();
    await _loadCards();
  }

  Future<void> _loadConfig() async {
    setState(() {
      _investMode = AppBootstrapTool.config.investCurrencyMode;
    });
  }

  Future<void> _loadProfile() async {
    final AuthUserProfile? localProfile = await AuthTool.getUserProfile();
    if (localProfile != null) {
      setState(() {
        _profile = localProfile;
      });
      return;
    }
    try {
      final AuthUserProfile profile = await AuthApi.getInfo();
      await AuthTool.saveUserProfile(profile);
      if (!mounted) {
        return;
      }
      setState(() {
        _profile = profile;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _profile = null;
      });
    }
  }

  Future<void> _loadCards() async {
    final String loadFailedText = AppLocalizations.of(context).t('bankCardLoadFailed');
    setState(() {
      _loading = true;
    });
    try {
      final List<BankCardItem> cards = await BankCardApi.getMyBankCards();
      if (!mounted) {
        return;
      }
      setState(() {
        _cards = cards;
      });
    } catch (_) {
      if (mounted) {
        _showSnackBar(loadFailedText, error: true);
      }
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  int _cardCountByCurrency(String currencyType) {
    return _cards.where((BankCardItem item) => item.currencyType.toUpperCase() == currencyType).length;
  }

  Future<void> _handleAdd(String currencyType) async {
    final AppLocalizations i18n = AppLocalizations.of(context);
    if (currencyType == 'CNY') {
      final int realNameStatus = _profile?.realNameStatus ?? 0;
      if (realNameStatus != 3) {
        _showSnackBar(i18n.t('bankCardNeedRealName'), error: true);
        if (!mounted) {
          return;
        }
        await Navigator.pushNamed(context, AppRouter.realNameAuth);
        await _loadProfile();
        return;
      }
      final String realName = (_profile?.realName ?? '').trim();
      if (realName.isEmpty) {
        _showSnackBar(i18n.t('bankCardNeedRealName'), error: true);
        return;
      }
    }

    if (_cardCountByCurrency(currencyType) >= 2) {
      _showSnackBar(i18n.t('bankCardMaxReached'), error: true);
      return;
    }

    await _showAddDialog(currencyType);
  }

  Future<void> _showAddDialog(String currencyType) async {
    final AppLocalizations i18n = AppLocalizations.of(context);
    final _AddBankCardFormResult? formResult = await showDialog<_AddBankCardFormResult>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return _AddBankCardDialog(
          currencyType: currencyType,
          verifiedRealName: (_profile?.realName ?? '').trim(),
        );
      },
    );

    if (formResult == null) {
      return;
    }
    try {
      await BankCardApi.addBankCard(
        currencyType: currencyType,
        bankName: currencyType == 'CNY' ? formResult.bankName : null,
        accountNo: currencyType == 'CNY' ? formResult.accountNo : null,
        accountName: currencyType == 'CNY' ? formResult.accountName : null,
        walletAddress: currencyType == 'USD' ? formResult.walletAddress : null,
      );
      if (!mounted) {
        return;
      }
      _showSnackBar(i18n.t('bankCardSubmitSuccess'));
      await _loadCards();
    } catch (_) {
      if (!mounted) {
        return;
      }
      _showSnackBar(i18n.t('bankCardSubmitFailed'), error: true);
    }
  }

  Widget _buildDialogActionButton({
    required String label,
    required Color textColor,
    required Color backgroundColor,
    required Color borderColor,
    required VoidCallback onTap,
    bool enabled = true,
    bool loading = false,
    Color loadingColor = const Color(0xFFEAF5FF),
  }) {
    return Opacity(
      opacity: enabled ? 1 : 0.6,
      child: IgnorePointer(
        ignoring: !enabled,
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor),
            ),
            child: loading
                ? SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: loadingColor),
                  )
                : Text(
                    label,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleDelete(BankCardItem item) async {
    final AppLocalizations i18n = AppLocalizations.of(context);
    final bool confirmed = await showDialog<bool>(
          context: context,
          builder: (BuildContext dialogContext) {
            return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: <Color>[Color(0xFF132238), Color(0xFF0C1525)],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0x334CE3FF)),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: Colors.black.withOpacity(0.35),
                      blurRadius: 28,
                      offset: const Offset(0, 14),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: const Color(0x22FF6B6B),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(Icons.delete_outline, color: Color(0xFFFF6B6B)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              i18n.t('bankCardDelete'),
                              style: const TextStyle(
                                color: Color(0xFFEAF5FF),
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        i18n.t('bankCardDeleteConfirm'),
                        style: const TextStyle(
                          color: Color(0xFF9DB1C9),
                          fontSize: 13,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 18),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: _buildDialogActionButton(
                              label: i18n.t('cancel'),
                              textColor: const Color(0xFF9DB1C9),
                              backgroundColor: Colors.white.withOpacity(0.04),
                              borderColor: Colors.white.withOpacity(0.08),
                              onTap: () => Navigator.of(dialogContext).pop(false),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildDialogActionButton(
                              label: i18n.t('delete'),
                              textColor: const Color(0xFFFFFFFF),
                              backgroundColor: const Color(0xFFFF6B6B),
                              borderColor: const Color(0x88FF6B6B),
                              onTap: () => Navigator.of(dialogContext).pop(true),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ) ??
        false;
    if (!confirmed) {
      return;
    }
    try {
      await BankCardApi.deleteBankCard(item.bankCardId);
      if (!mounted) {
        return;
      }
      _showSnackBar(i18n.t('bankCardDeleteSuccess'));
      await _loadCards();
    } catch (_) {
      if (!mounted) {
        return;
      }
      _showSnackBar(i18n.t('bankCardDeleteFailed'), error: true);
    }
  }

  String _maskTail(String value) {
    final String text = value.trim();
    if (text.isEmpty) {
      return '';
    }
    if (text.length <= 4) {
      return text;
    }
    return '${'*' * (text.length - 4)}${text.substring(text.length - 4)}';
  }

  String _maskCenter(String value) {
    final String text = value.trim();
    if (text.isEmpty) {
      return '';
    }
    if (text.length <= 8) {
      return text;
    }
    // 钱包地址脱敏固定中间 9 个 *，避免按真实长度展示掩码位数。
    return '${text.substring(0, 4)}*********${text.substring(text.length - 4)}';
  }

  void _showSnackBar(String text, {bool error = false}) {
    if (!mounted) {
      return;
    }
    final ScaffoldMessengerState? messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) {
      return;
    }
    messenger.showSnackBar(
      SnackBar(
        content: Text(text),
        backgroundColor: error ? const Color(0xFFFF6B6B) : const Color(0xFF38FFB3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations i18n = AppLocalizations.of(context);
    final int total = _cards.length;

    return Scaffold(
      backgroundColor: const Color(0xFF07111F),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(i18n.t('bankCardTitle')),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Stack(
        children: <Widget>[
          const Positioned(
            top: -80,
            right: -76,
            child: _GlowBlob(
              size: 220,
              colors: <Color>[Color(0x2239E6FF), Color(0x00000000)],
            ),
          ),
          const Positioned(
            top: 160,
            left: -92,
            child: _GlowBlob(
              size: 180,
              colors: <Color>[Color(0x1A38FFB3), Color(0x00000000)],
            ),
          ),
          SafeArea(
            child: RefreshIndicator(
              color: const Color(0xFF39E6FF),
              onRefresh: _initPage,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _buildHeroCard(i18n, total),
                    const SizedBox(height: 16),
                    _buildSectionTitle(
                      title: i18n.t('bankCardTitle'),
                      subtitle: '',
                    ),
                    const SizedBox(height: 12),
                    if (_loading)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Center(
                          child: CircularProgressIndicator(color: Color(0xFF39E6FF)),
                        ),
                      )
                    else if (_cards.isEmpty)
                      _buildEmptyState(i18n)
                    else
                      Column(
                        children: _cards.map(_buildCardItem).toList(),
                      ),
                    const SizedBox(height: 16),
                    _buildSectionTitle(
                      title: i18n.t('bankCardAddRmb'),
                      subtitle: '',
                    ),
                    const SizedBox(height: 12),
                    if (_isDualMode)
                      Row(
                        children: <Widget>[
                          Expanded(
                          child: _buildAddButton(
                              label: i18n.t('bankCardAddRmb'),
                              currencyType: 'CNY',
                              accent: const Color(0xFF39E6FF),
                              hint: i18n.t('bankCardBankNameHint'),
                              onTap: () => _handleAdd('CNY'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildAddButton(
                              label: i18n.t('bankCardAddUsd'),
                              currencyType: 'USD',
                              accent: const Color(0xFFFFA500),
                              hint: i18n.t('bankCardWalletAddressHint'),
                              onTap: () => _handleAdd('USD'),
                            ),
                          ),
                        ],
                      )
                    else
                    _buildAddButton(
                      label: i18n.t('bankCardAddRmb'),
                      currencyType: 'CNY',
                      accent: const Color(0xFF39E6FF),
                      hint: i18n.t('bankCardBankNameHint'),
                      onTap: () => _handleAdd('CNY'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroCard(AppLocalizations i18n, int total) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[Color(0xFF18253B), Color(0xFF0E1728)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0x334CE3FF)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withOpacity(0.22),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: <Widget>[
          Positioned(
            right: -6,
            top: -4,
            child: Icon(
              Icons.account_balance_wallet_outlined,
              size: 96,
              color: const Color(0xFF39E6FF).withOpacity(0.08),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: <Widget>[
                  _buildHeroChip(
                    icon: Icons.credit_card_outlined,
                    text: i18n.t('bankCardCount').replaceAll('{count}', '$total'),
                    color: const Color(0xFF39E6FF),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                i18n.t('bankCardTitle'),
                style: const TextStyle(
                  color: Color(0xFFEAF5FF),
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  height: 1.05,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                i18n.t('bankCardCount').replaceAll('{count}', '$total'),
                style: const TextStyle(
                  color: Color(0xFF9DB1C9),
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle({
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: <Widget>[
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            color: const Color(0xFF39E6FF),
            borderRadius: BorderRadius.circular(99),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFFEAF5FF),
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (subtitle.isNotEmpty) ...<Widget>[
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xFF9DB1C9),
                    fontSize: 12,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(AppLocalizations i18n) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 42, horizontal: 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[Color(0xFF101C30), Color(0xFF0D1728)],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0x334CE3FF)),
      ),
      child: Column(
        children: <Widget>[
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              color: const Color(0x2239E6FF),
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Icon(Icons.credit_card_off_outlined, color: Color(0xFF39E6FF), size: 34),
          ),
          const SizedBox(height: 14),
          Text(
            i18n.t('bankCardNoData'),
            style: const TextStyle(
              color: Color(0xFFEAF5FF),
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
        ],
      ),
    );
  }

  Widget _buildHeroChip({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.24)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardItem(BankCardItem item) {
    final bool isUsd = item.currencyType.toUpperCase() == 'USD';
    final Color accent = isUsd ? const Color(0xFFFFA500) : const Color(0xFF39E6FF);
    final List<Color> colors = isUsd
        ? <Color>[const Color(0xFF0C3D7B), const Color(0xFF0A1A31)]
        : <Color>[const Color(0xFF14384A), const Color(0xFF0E1A2B)];
    final String title = isUsd
        ? AppLocalizations.of(context).t('bankCardUsdLabel')
        : AppLocalizations.of(context).t('bankCardRmbLabel');
    final String displayValue = isUsd
        ? _maskCenter(item.walletAddress ?? '')
        : _maskTail(item.accountNo ?? '');

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: accent.withOpacity(0.24)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withOpacity(0.22),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  CurrencyBrandBadge(
                    currencyType: item.currencyType,
                    size: 50,
                    useUnionPayForCny: true,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          title,
                          style: const TextStyle(
                            color: Color(0xFFEAF5FF),
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.userName.isEmpty ? '-' : item.userName,
                          style: const TextStyle(
                            color: Color(0xFF9DB1C9),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _handleDelete(item),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.04),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withOpacity(0.08)),
                      ),
                      child: const Icon(Icons.delete_outline, color: Color(0xFF9DB1C9), size: 18),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Text(
                displayValue.isEmpty ? '-' : displayValue,
                style: TextStyle(
                  color: accent,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: isUsd
                    ? <Widget>[
                        _buildCardChip(
                          title: AppLocalizations.of(context).t('bankCardWalletAddress'),
                          value: _maskCenter(item.walletAddress ?? '-'),
                          color: accent,
                        ),
                      ]
                    : <Widget>[
                        _buildCardChip(
                          title: AppLocalizations.of(context).t('bankCardBankName'),
                          value: item.bankName ?? '-',
                          color: accent,
                        ),
                        _buildCardChip(
                          title: AppLocalizations.of(context).t('bankCardAccountName'),
                          value: item.accountName ?? '-',
                          color: accent,
                        ),
                      ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCardChip({
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.16)),
      ),
      child: RichText(
        text: TextSpan(
          children: <TextSpan>[
            TextSpan(
              text: '$title: ',
              style: const TextStyle(
                color: Color(0xFF9DB1C9),
                fontSize: 12,
              ),
            ),
            TextSpan(
              text: value,
              style: const TextStyle(
                color: Color(0xFFEAF5FF),
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddButton({
    required String label,
    required String currencyType,
    required Color accent,
    required String hint,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 98,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[Color(0xFF101C30), Color(0xFF0D1728)],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: accent.withOpacity(0.18)),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withOpacity(0.14),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Stack(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              child: Row(
                children: <Widget>[
                  CurrencyBrandBadge(
                    currencyType: currencyType,
                    size: 46,
                    useUnionPayForCny: true,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          label,
                          style: const TextStyle(
                            color: Color(0xFFEAF5FF),
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          hint,
                          style: const TextStyle(
                            color: Color(0xFF9DB1C9),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.add_circle_outline, color: accent, size: 22),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryInfo {
  _SummaryInfo({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;
}

class _AddBankCardFormResult {
  const _AddBankCardFormResult({
    this.bankName,
    this.accountNo,
    this.accountName,
    this.walletAddress,
  });

  final String? bankName;
  final String? accountNo;
  final String? accountName;
  final String? walletAddress;
}

class _AddBankCardDialog extends StatefulWidget {
  const _AddBankCardDialog({
    required this.currencyType,
    required this.verifiedRealName,
  });

  final String currencyType;
  final String verifiedRealName;

  @override
  State<_AddBankCardDialog> createState() => _AddBankCardDialogState();
}

class _AddBankCardDialogState extends State<_AddBankCardDialog> {
  final TextEditingController _bankNameController = TextEditingController();
  final TextEditingController _accountNoController = TextEditingController();
  final TextEditingController _accountNameController = TextEditingController();
  final TextEditingController _walletAddressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _accountNameController.text = widget.verifiedRealName;
  }

  @override
  void dispose() {
    _bankNameController.dispose();
    _accountNoController.dispose();
    _accountNameController.dispose();
    _walletAddressController.dispose();
    super.dispose();
  }

  void _submit() {
    final AppLocalizations i18n = AppLocalizations.of(context);
    final String bankName = _bankNameController.text.trim();
    final String accountNo = _accountNoController.text.trim();
    final String accountName = widget.verifiedRealName.trim();
    final String walletAddress = _walletAddressController.text.trim();
    if (widget.currencyType == 'CNY') {
      if (bankName.isEmpty || accountNo.isEmpty || accountName.isEmpty) {
        _showSnackBar(i18n.t('bankCardFillRequired'), error: true);
        return;
      }
      Navigator.of(context).pop(
        _AddBankCardFormResult(
          bankName: bankName,
          accountNo: accountNo,
          accountName: accountName,
        ),
      );
      return;
    }
    if (walletAddress.isEmpty) {
      _showSnackBar(i18n.t('bankCardFillRequired'), error: true);
      return;
    }
    if (walletAddress.length > 34) {
      _showSnackBar(i18n.t('bankCardWalletAddressTooLong'), error: true);
      return;
    }
    Navigator.of(context).pop(_AddBankCardFormResult(walletAddress: walletAddress));
  }

  void _showSnackBar(String text, {bool error = false}) {
    final ScaffoldMessengerState? messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) {
      return;
    }
    messenger.showSnackBar(
      SnackBar(
        content: Text(text),
        backgroundColor: error ? const Color(0xFFFF6B6B) : const Color(0xFF38FFB3),
      ),
    );
  }

  Widget _buildDialogField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int minLines = 1,
    int maxLines = 1,
    bool readOnly = false,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: controller,
        minLines: minLines,
        maxLines: maxLines,
        readOnly: readOnly,
        inputFormatters: inputFormatters,
        style: const TextStyle(color: Color(0xFFEAF5FF)),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          filled: true,
          fillColor: const Color(0xFF0B1525),
          labelStyle: const TextStyle(color: Color(0xFF9DB1C9)),
          hintStyle: const TextStyle(color: Color(0xFF60748E)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0x334CE3FF)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFF39E6FF)),
          ),
        ),
      ),
    );
  }

  Widget _buildDialogActionButton({
    required String label,
    required Color textColor,
    required Color backgroundColor,
    required Color borderColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: textColor,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations i18n = AppLocalizations.of(context);
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[Color(0xFF132238), Color(0xFF0C1525)],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0x334CE3FF)),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withOpacity(0.35),
              blurRadius: 28,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: const Color(0x2239E6FF),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: CurrencyBrandBadge(
                        currencyType: widget.currencyType,
                        size: 42,
                        useUnionPayForCny: true,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            widget.currencyType == 'USD'
                                ? i18n.t('bankCardAddUsdTitle')
                                : i18n.t('bankCardAddRmbTitle'),
                            style: const TextStyle(
                              color: Color(0xFFEAF5FF),
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.currencyType == 'USD'
                                ? i18n.t('bankCardWalletAddressHint')
                                : i18n.t('bankCardBankNameHint'),
                            style: const TextStyle(
                              color: Color(0xFF9DB1C9),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.04),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white.withOpacity(0.08)),
                        ),
                        child: const Icon(Icons.close, color: Color(0xFF9DB1C9), size: 18),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF101C30),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0x334CE3FF)),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      if (widget.currencyType == 'CNY') ...<Widget>[
                        _buildDialogField(
                          controller: _bankNameController,
                          label: i18n.t('bankCardBankName'),
                          hint: i18n.t('bankCardBankNameHint'),
                        ),
                        _buildDialogField(
                          controller: _accountNoController,
                          label: i18n.t('bankCardAccountNo'),
                          hint: i18n.t('bankCardAccountNoHint'),
                        ),
                        _buildDialogField(
                          controller: _accountNameController,
                          label: i18n.t('bankCardAccountName'),
                          hint: i18n.t('bankCardAccountNameHint'),
                          readOnly: true,
                        ),
                      ] else ...<Widget>[
                        _buildDialogField(
                          controller: _walletAddressController,
                          label: i18n.t('bankCardWalletAddress'),
                          hint: i18n.t('bankCardWalletAddressHint'),
                          minLines: 3,
                          maxLines: 4,
                          inputFormatters: <TextInputFormatter>[
                            LengthLimitingTextInputFormatter(34),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: _buildDialogActionButton(
                        label: i18n.t('cancel'),
                        textColor: const Color(0xFF9DB1C9),
                        backgroundColor: Colors.white.withOpacity(0.04),
                        borderColor: Colors.white.withOpacity(0.08),
                        onTap: () => Navigator.of(context).pop(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildDialogActionButton(
                        label: i18n.t('bankCardSubmit'),
                        textColor: const Color(0xFF0A1220),
                        backgroundColor: const Color(0xFF39E6FF),
                        borderColor: const Color(0x8839E6FF),
                        onTap: _submit,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GlowBlob extends StatelessWidget {
  const _GlowBlob({
    required this.size,
    required this.colors,
  });

  final double size;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: colors),
      ),
    );
  }
}
