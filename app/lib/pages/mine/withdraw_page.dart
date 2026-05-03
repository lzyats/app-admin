import 'package:flutter/material.dart';
import 'dart:math';

import 'package:myapp/config/app_localizations.dart';
import 'package:myapp/request/auth_api.dart';
import 'package:myapp/request/bank_card_api.dart';
import 'package:myapp/request/withdraw_api.dart';
import 'package:myapp/routers/app_router.dart';
import 'package:myapp/tools/app_bootstrap_tool.dart';
import 'package:myapp/tools/auth_tool.dart';
import 'package:myapp/widgets/currency_brand_badge.dart';

class WithdrawPage extends StatefulWidget {
  const WithdrawPage({super.key});

  @override
  State<WithdrawPage> createState() => _WithdrawPageState();
}

class _WithdrawPageState extends State<WithdrawPage> {
  final TextEditingController _amountController = TextEditingController();
  final Random _random = Random();

  bool _submitting = false;
  int _investMode = 1;
  AuthUserProfile? _profile;
  List<WithdrawWalletItem> _wallets = <WithdrawWalletItem>[];
  List<BankCardItem> _bankCards = <BankCardItem>[];
  String _selectedCurrencyType = 'CNY';
  String _selectedWithdrawMethod = 'BANK';
  int? _selectedBankCardId;
  late String _requestNo;

  bool get _isDualMode => _investMode == 2;

  @override
  void initState() {
    super.initState();
    _requestNo = _generateRequestNo();
    _loadPageData();
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _loadPageData() async {
    setState(() {
      _investMode = AppBootstrapTool.config.investCurrencyMode;
    });
    try {
      final AuthUserProfile? profile = await _loadProfile();
      final List<WithdrawWalletItem> wallets = await WithdrawApi.getWallets();
      final List<BankCardItem> bankCards = await BankCardApi.getMyBankCards();
      if (!mounted) {
        return;
      }
      setState(() {
        _profile = profile;
        _wallets = wallets;
        _bankCards = bankCards;
      });
      _syncSelection();
    } catch (_) {
      if (mounted) {
        _showSnackBar(AppLocalizations.of(context).t('withdrawLoadFailed'), error: true);
      }
    }
  }

  Future<AuthUserProfile?> _loadProfile() async {
    final AuthUserProfile? cachedProfile = await AuthTool.getUserProfile();
    if (cachedProfile != null && cachedProfile.userId > 0) {
      return cachedProfile;
    }
    final AuthUserProfile profile = await AuthApi.getInfo();
    await AuthTool.saveUserProfile(profile);
    return profile;
  }

  void _syncSelection() {
    if (_isDualMode) {
      _selectedCurrencyType = _selectedCurrencyType == 'USD' ? 'USD' : 'CNY';
      _selectedWithdrawMethod = _selectedCurrencyType == 'USD' ? 'USDT' : 'BANK';
    } else {
      _selectedCurrencyType = 'CNY';
      _selectedWithdrawMethod = 'BANK';
    }
    _selectedBankCardId = _availableCardsForSelectedMethod().isNotEmpty
        ? _availableCardsForSelectedMethod().first.bankCardId
        : null;
  }

  List<BankCardItem> _availableCardsForSelectedMethod() {
    return _bankCards
        .where((BankCardItem item) => item.currencyType.toUpperCase() == _selectedCurrencyType)
        .toList();
  }

  WithdrawWalletItem? _walletByCurrency(String currencyType) {
    for (final WithdrawWalletItem wallet in _wallets) {
      if (wallet.currencyType.toUpperCase() == currencyType.toUpperCase()) {
        return wallet;
      }
    }
    return null;
  }

  double _availableBalance(String currencyType) {
    return _walletByCurrency(currencyType)?.availableBalance ?? 0;
  }

  BankCardItem? _selectedCard() {
    final List<BankCardItem> cards = _availableCardsForSelectedMethod();
    if (cards.isEmpty) {
      return null;
    }
    if (_selectedBankCardId != null) {
      for (final BankCardItem item in cards) {
        if (item.bankCardId == _selectedBankCardId) {
          return item;
        }
      }
    }
    return cards.first;
  }

  Future<void> _pickMethod(String currencyType, String withdrawMethod) async {
    setState(() {
      _selectedCurrencyType = currencyType;
      _selectedWithdrawMethod = withdrawMethod;
      _selectedBankCardId = _availableCardsForCurrency(currencyType).isNotEmpty
          ? _availableCardsForCurrency(currencyType).first.bankCardId
          : null;
    });
  }

  List<BankCardItem> _availableCardsForCurrency(String currencyType) {
    return _bankCards.where((BankCardItem item) => item.currencyType.toUpperCase() == currencyType.toUpperCase()).toList();
  }

  Future<void> _showAccountPicker() async {
    final List<BankCardItem> cards = _availableCardsForSelectedMethod();
    if (cards.isEmpty) {
      _showNeedCardPrompt();
      return;
    }
    final int? selectedId = await showModalBottomSheet<int>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return _AccountPickerSheet(
          currencyType: _selectedCurrencyType,
          cards: cards,
          selectedId: _selectedBankCardId,
        );
      },
    );
    if (selectedId != null && mounted) {
      setState(() {
        _selectedBankCardId = selectedId;
      });
    }
  }

  void _showNeedCardPrompt() {
    final AppLocalizations i18n = AppLocalizations.of(context);
    if (_selectedCurrencyType == 'CNY' && (_profile?.realNameStatus ?? 0) != 3) {
      _showSnackBar(i18n.t('withdrawNeedRealName'), error: true);
      Navigator.pushNamed(context, AppRouter.realNameAuth).then((_) => _loadPageData());
      return;
    }
    _showSnackBar(i18n.t('withdrawNeedAccount'), error: true);
    Navigator.pushNamed(context, AppRouter.bankCard).then((_) => _loadPageData());
  }

  Future<void> _submit() async {
    final AppLocalizations i18n = AppLocalizations.of(context);
    final double? amount = double.tryParse(_amountController.text.trim());
    if (amount == null || amount <= 0) {
      _showSnackBar(i18n.t('withdrawNeedAmount'), error: true);
      return;
    }

    final BankCardItem? card = _selectedCard();
    if (card == null) {
      _showNeedCardPrompt();
      return;
    }
    if (_selectedCurrencyType == 'CNY' && (_profile?.realNameStatus ?? 0) != 3) {
      _showSnackBar(i18n.t('withdrawNeedRealName'), error: true);
      Navigator.pushNamed(context, AppRouter.realNameAuth).then((_) => _loadPageData());
      return;
    }

    final double currentBalance = _availableBalance(_selectedCurrencyType);
    if (amount > currentBalance) {
      _showSnackBar(i18n.t('withdrawBalanceNotEnough'), error: true);
      return;
    }

    setState(() {
      _submitting = true;
    });
    try {
      await WithdrawApi.submitWithdraw(
        amount: amount,
        currencyType: _selectedCurrencyType,
        withdrawMethod: _selectedWithdrawMethod,
        bankCardId: card.bankCardId,
        requestNo: _requestNo,
      );
      if (!mounted) {
        return;
      }
      _showSnackBar(i18n.t('withdrawSubmitSuccess'));
      _amountController.clear();
      _requestNo = _generateRequestNo();
      await _loadPageData();
    } catch (_) {
      if (mounted) {
        _showSnackBar(i18n.t('withdrawSubmitFailed'), error: true);
      }
    } finally {
      if (mounted) {
        setState(() {
          _submitting = false;
        });
      }
    }
  }

  void _showSnackBar(String text, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        backgroundColor: error ? const Color(0xFFFF6B6B) : const Color(0xFF38FFB3),
      ),
    );
  }

  String _currencyLabel(String currencyType) {
    return currencyType.toUpperCase() == 'USD'
        ? 'USDT'
        : AppLocalizations.of(context).t('assetsRmb');
  }

  String _maskTail(String value) {
    final String text = value.trim();
    if (text.isEmpty) {
      return "-";
    }
    if (text.length <= 4) {
      return text;
    }
    return "*" * (text.length - 4) + text.substring(text.length - 4);
  }

  String _accountLabel(BankCardItem item) {
    if (item.currencyType.toUpperCase() == 'USD') {
      return _maskTail(item.walletAddress ?? '');
    }
    return '${item.bankName ?? '-'} / ${_maskTail(item.accountNo ?? '')} / ${item.accountName ?? '-'}';
  }

  String _generateRequestNo() {
    final int ts = DateTime.now().microsecondsSinceEpoch;
    final int suffix = _random.nextInt(900000) + 100000;
    return 'W$ts$suffix';
  }
  @override
  Widget build(BuildContext context) {
    final AppLocalizations i18n = AppLocalizations.of(context);
    final List<_WithdrawMethodOption> methods = _isDualMode
        ? <_WithdrawMethodOption>[
            _WithdrawMethodOption(
              currencyType: 'CNY',
              withdrawMethod: 'BANK',
              title: i18n.t('withdrawMethodBank'),
              icon: Icons.account_balance,
              color: const Color(0xFF39E6FF),
            ),
            _WithdrawMethodOption(
              currencyType: 'USD',
              withdrawMethod: 'USDT',
              title: i18n.t('withdrawMethodUsd'),
              icon: Icons.currency_exchange,
              color: const Color(0xFFFFA500),
            ),
          ]
        : <_WithdrawMethodOption>[
            _WithdrawMethodOption(
              currencyType: 'CNY',
              withdrawMethod: 'BANK',
              title: i18n.t('withdrawMethodBank'),
              icon: Icons.account_balance,
              color: const Color(0xFF39E6FF),
            ),
          ];

    return Scaffold(
      backgroundColor: const Color(0xFF07111F),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(i18n.t('mineWithdraw')),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Stack(
        children: <Widget>[
          const Positioned(
            top: -80,
            right: -70,
            child: _GlowBlob(
              size: 210,
              colors: <Color>[Color(0x2239E6FF), Color(0x00000000)],
            ),
          ),
          const Positioned(
            top: 160,
            left: -90,
            child: _GlowBlob(
              size: 180,
              colors: <Color>[Color(0x1A38FFB3), Color(0x00000000)],
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _buildHeroCard(i18n),
                  const SizedBox(height: 18),
                  Text(
                    i18n.t('withdrawMethodTitle'),
                    style: const TextStyle(
                      color: Color(0xFFEAF5FF),
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Column(
                    children: methods.map((_WithdrawMethodOption option) {
                      final bool selected = _selectedCurrencyType == option.currencyType &&
                          _selectedWithdrawMethod == option.withdrawMethod;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: GestureDetector(
                          onTap: () => _pickMethod(option.currencyType, option.withdrawMethod),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: selected
                                  ? const LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: <Color>[Color(0xFF1D3558), Color(0xFF13253D)],
                                    )
                                  : const LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: <Color>[Color(0xFF101C30), Color(0xFF0D1728)],
                                    ),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: selected ? const Color(0xFF39E6FF) : const Color(0x334CE3FF),
                                width: selected ? 1.5 : 1,
                              ),
                              boxShadow: <BoxShadow>[
                                BoxShadow(
                                  color: Colors.black.withOpacity(selected ? 0.18 : 0.12),
                                  blurRadius: selected ? 18 : 12,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Row(
                              children: <Widget>[
                                CurrencyBrandBadge(
                                  currencyType: option.currencyType,
                                  size: 54,
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        option.title,
                                        style: TextStyle(
                                          color: selected ? const Color(0xFF39E6FF) : const Color(0xFFEAF5FF),
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        _currencyLabel(option.currencyType),
                                        style: const TextStyle(
                                          color: Color(0xFF9DB1C9),
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  selected ? Icons.check_circle : Icons.radio_button_unchecked,
                                  color: selected ? const Color(0xFF39E6FF) : const Color(0xFF9DB1C9),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 6),
                  _buildAmountCard(i18n),
                  const SizedBox(height: 18),
                  _buildAccountCard(i18n),
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0x2210263B),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0x334CE3FF)),
                    ),
                    child: Text(
                      i18n.t('withdrawNote'),
                      style: const TextStyle(
                        color: Color(0xFF9DB1C9),
                        fontSize: 13,
                        height: 1.6,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Container(
                    width: double.infinity,
                    height: 54,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: <Color>[Color(0xFF39E6FF), Color(0xFF38FFB3)],
                      ),
                      borderRadius: BorderRadius.circular(27),
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                          color: const Color(0xFF39E6FF).withOpacity(0.22),
                          blurRadius: 18,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: _submitting ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor: const Color(0xFF0A1220),
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(27),
                        ),
                      ),
                      child: _submitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Color(0xFF0A1220),
                              ),
                            )
                          : Text(
                              i18n.t('withdrawSubmit'),
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroCard(AppLocalizations i18n) {
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
            right: -12,
            top: -8,
            child: Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0x2239E6FF),
                border: Border.all(color: const Color(0x2239E6FF)),
              ),
            ),
          ),
          Positioned(
            right: 18,
            top: 18,
            child: Icon(
              Icons.payments_outlined,
              size: 56,
              color: const Color(0xFF39E6FF).withOpacity(0.12),
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
                    icon: Icons.account_balance_wallet_outlined,
                    text: i18n.t('withdrawAmountTitle'),
                    color: const Color(0xFF39E6FF),
                  ),
                  _buildHeroChip(
                    icon: Icons.credit_card_outlined,
                    text: i18n.t('withdrawMethodTitle'),
                    color: const Color(0xFF38FFB3),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                i18n.t('mineWithdraw'),
                style: const TextStyle(
                  color: Color(0xFFEAF5FF),
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  height: 1.05,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                i18n.t('withdrawHeroHint'),
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

  Widget _buildAmountCard(AppLocalizations i18n) {
    final double currentBalance = _availableBalance(_selectedCurrencyType);
    final double usdBalance = _availableBalance('USD');
    final double cnyBalance = _availableBalance('CNY');
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[Color(0xFF111D31), Color(0xFF0E1726)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0x334CE3FF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  i18n.t('withdrawAmountTitle'),
                  style: const TextStyle(
                    color: Color(0xFFEAF5FF),
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              TextButton(
                onPressed: currentBalance <= 0
                    ? null
                    : () {
                        setState(() {
                          _amountController.text = currentBalance.toStringAsFixed(2);
                        });
                      },
                child: Text(
                  i18n.t('withdrawAll'),
                  style: const TextStyle(color: Color(0xFF9DB1C9)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: const TextStyle(color: Color(0xFFEAF5FF), fontSize: 30, fontWeight: FontWeight.w800),
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: i18n.t('withdrawAmountPlaceholder'),
              hintStyle: const TextStyle(color: Color(0xFF60748E), fontSize: 18),
              suffixText: _currencyLabel(_selectedCurrencyType),
              suffixStyle: const TextStyle(color: Color(0xFF9DB1C9), fontSize: 14),
            ),
          ),
          const SizedBox(height: 10),
          Container(height: 1, color: const Color(0x334CE3FF)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: <Widget>[
              _BalanceChip(
                label: '${i18n.t('withdrawAvailableBalance')} ${_currencyLabel('CNY')}',
                value: cnyBalance.toStringAsFixed(2),
                selected: _selectedCurrencyType == 'CNY',
              ),
              if (_isDualMode)
                _BalanceChip(
                  label: '${_currencyLabel('USD')} ${i18n.t('withdrawAvailableBalance')}',
                  value: usdBalance.toStringAsFixed(2),
                  selected: _selectedCurrencyType == 'USD',
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAccountCard(AppLocalizations i18n) {
    final BankCardItem? card = _selectedCard();
    final bool needsRealName = _selectedCurrencyType == 'CNY' && (_profile?.realNameStatus ?? 0) != 3;
    final bool noCard = card == null;

    return GestureDetector(
      onTap: _showAccountPicker,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[Color(0xFF111D31), Color(0xFF0E1726)],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0x334CE3FF)),
        ),
        child: Row(
          children: <Widget>[
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: const Color(0x2239E6FF),
                borderRadius: BorderRadius.circular(16),
              ),
              child: CurrencyBrandBadge(
                currencyType: _selectedCurrencyType,
                size: 52,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    i18n.t('withdrawAccountTitle'),
                    style: const TextStyle(
                      color: Color(0xFFEAF5FF),
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    needsRealName
                        ? i18n.t('withdrawNeedRealName')
                        : noCard
                            ? i18n.t('withdrawNoAccount')
                            : _accountLabel(card),
                    style: const TextStyle(
                      color: Color(0xFF9DB1C9),
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF9DB1C9)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroChip({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.28)),
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
}

class _WithdrawMethodOption {
  const _WithdrawMethodOption({
    required this.currencyType,
    required this.withdrawMethod,
    required this.title,
    required this.icon,
    required this.color,
  });

  final String currencyType;
  final String withdrawMethod;
  final String title;
  final IconData icon;
  final Color color;
}

class _BalanceChip extends StatelessWidget {
  const _BalanceChip({
    required this.label,
    required this.value,
    required this.selected,
  });

  final String label;
  final String value;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: selected ? const Color(0x2239E6FF) : const Color(0x1410263B),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: selected ? const Color(0xFF39E6FF) : const Color(0x334CE3FF),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF9DB1C9),
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: selected ? const Color(0xFF39E6FF) : const Color(0xFFEAF5FF),
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _AccountPickerSheet extends StatelessWidget {
  const _AccountPickerSheet({
    required this.currencyType,
    required this.cards,
    required this.selectedId,
  });

  final String currencyType;
  final List<BankCardItem> cards;
  final int? selectedId;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations i18n = AppLocalizations.of(context);
    return Container(
      decoration: const BoxDecoration(
        color: Colors.transparent,
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[Color(0xFF132238), Color(0xFF0C1525)],
          ),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          border: Border(top: BorderSide(color: Color(0x334CE3FF))),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      i18n.t('withdrawAccountTitle'),
                      style: const TextStyle(
                        color: Color(0xFFEAF5FF),
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
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
              const SizedBox(height: 14),
              ...cards.map(
                (BankCardItem card) {
                  final bool selected = selectedId == card.bankCardId;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).pop(card.bankCardId),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          gradient: selected
                              ? const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: <Color>[Color(0xFF1D3558), Color(0xFF13253D)],
                                )
                              : const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: <Color>[Color(0xFF101C30), Color(0xFF0D1728)],
                                ),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: selected ? const Color(0xFF39E6FF) : const Color(0x334CE3FF),
                            width: selected ? 1.5 : 1,
                          ),
                        ),
                        child: Row(
                          children: <Widget>[
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: const Color(0x2239E6FF),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: CurrencyBrandBadge(
                                currencyType: currencyType,
                                size: 44,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    currencyType == 'USD'
                                        ? i18n.t('withdrawMethodUsd')
                                        : (card.bankName?.isNotEmpty == true ? card.bankName! : i18n.t('withdrawMethodBank')),
                                    style: const TextStyle(
                                      color: Color(0xFFEAF5FF),
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    currencyType == 'USD'
                                        ? (card.walletAddress ?? '-')
                                        : '${card.accountNo ?? '-'} / ${card.accountName ?? '-'}',
                                    style: const TextStyle(
                                      color: Color(0xFF9DB1C9),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              selected ? Icons.check_circle : Icons.radio_button_unchecked,
                              color: selected ? const Color(0xFF39E6FF) : const Color(0xFF9DB1C9),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
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
