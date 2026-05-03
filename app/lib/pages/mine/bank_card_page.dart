import 'package:flutter/material.dart';

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
  bool _submitting = false;
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
        _showSnackBar(AppLocalizations.of(context).t('bankCardLoadFailed'), error: true);
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
    if (currencyType == 'CNY') {
      final int realNameStatus = _profile?.realNameStatus ?? 0;
      if (realNameStatus != 3) {
        _showSnackBar(AppLocalizations.of(context).t('bankCardNeedRealName'), error: true);
        if (!mounted) {
          return;
        }
        await Navigator.pushNamed(context, AppRouter.realNameAuth);
        await _loadProfile();
        return;
      }
    }

    if (_cardCountByCurrency(currencyType) >= 2) {
      _showSnackBar(AppLocalizations.of(context).t('bankCardMaxReached'), error: true);
      return;
    }

    await _showAddDialog(currencyType);
  }

  Future<void> _showAddDialog(String currencyType) async {
    final TextEditingController bankNameController = TextEditingController();
    final TextEditingController accountNoController = TextEditingController();
    final TextEditingController accountNameController = TextEditingController();
    final TextEditingController walletAddressController = TextEditingController();
    bool submitting = false;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (BuildContext context, void Function(void Function()) setDialogState) {
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
                                currencyType: currencyType,
                                size: 42,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    currencyType == 'USD'
                                        ? AppLocalizations.of(context).t('bankCardAddUsdTitle')
                                        : AppLocalizations.of(context).t('bankCardAddRmbTitle'),
                                    style: const TextStyle(
                                      color: Color(0xFFEAF5FF),
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    currencyType == 'USD'
                                        ? AppLocalizations.of(context).t('bankCardWalletAddressHint')
                                        : AppLocalizations.of(context).t('bankCardBankNameHint'),
                                    style: const TextStyle(
                                      color: Color(0xFF9DB1C9),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            GestureDetector(
                              onTap: submitting ? null : () => Navigator.of(dialogContext).pop(),
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
                              if (currencyType == 'CNY') ...<Widget>[
                                _buildDialogField(
                                  context,
                                  controller: bankNameController,
                                  label: AppLocalizations.of(context).t('bankCardBankName'),
                                  hint: AppLocalizations.of(context).t('bankCardBankNameHint'),
                                ),
                                _buildDialogField(
                                  context,
                                  controller: accountNoController,
                                  label: AppLocalizations.of(context).t('bankCardAccountNo'),
                                  hint: AppLocalizations.of(context).t('bankCardAccountNoHint'),
                                ),
                                _buildDialogField(
                                  context,
                                  controller: accountNameController,
                                  label: AppLocalizations.of(context).t('bankCardAccountName'),
                                  hint: AppLocalizations.of(context).t('bankCardAccountNameHint'),
                                ),
                              ] else ...<Widget>[
                                _buildDialogField(
                                  context,
                                  controller: walletAddressController,
                                  label: AppLocalizations.of(context).t('bankCardWalletAddress'),
                                  hint: AppLocalizations.of(context).t('bankCardWalletAddressHint'),
                                  minLines: 3,
                                  maxLines: 4,
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: TextButton(
                                onPressed: submitting ? null : () => Navigator.of(dialogContext).pop(),
                                style: TextButton.styleFrom(
                                  foregroundColor: const Color(0xFF9DB1C9),
                                  backgroundColor: Colors.white.withOpacity(0.04),
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: Text(AppLocalizations.of(context).t('cancel')),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: submitting
                                    ? null
                                    : () async {
                                        bool keepDialogOpen = true;
                                        final String bankName = bankNameController.text.trim();
                                        final String accountNo = accountNoController.text.trim();
                                        final String accountName = accountNameController.text.trim();
                                        final String walletAddress = walletAddressController.text.trim();
                                        if (currencyType == 'CNY') {
                                          if (bankName.isEmpty || accountNo.isEmpty || accountName.isEmpty) {
                                            _showSnackBar(AppLocalizations.of(context).t('bankCardFillRequired'), error: true);
                                            return;
                                          }
                                        } else if (walletAddress.isEmpty) {
                                          _showSnackBar(AppLocalizations.of(context).t('bankCardFillRequired'), error: true);
                                          return;
                                        }

                                        setDialogState(() {
                                          submitting = true;
                                        });
                                        try {
                                          await BankCardApi.addBankCard(
                                            currencyType: currencyType,
                                            bankName: currencyType == 'CNY' ? bankName : null,
                                            accountNo: currencyType == 'CNY' ? accountNo : null,
                                            accountName: currencyType == 'CNY' ? accountName : null,
                                            walletAddress: currencyType == 'USD' ? walletAddress : null,
                                          );
                                          if (!mounted) {
                                            return;
                                          }
                                          Navigator.of(dialogContext).pop();
                                          keepDialogOpen = false;
                                          _showSnackBar(AppLocalizations.of(context).t('bankCardSubmitSuccess'));
                                          await _loadCards();
                                        } catch (_) {
                                          _showSnackBar(AppLocalizations.of(context).t('bankCardSubmitFailed'), error: true);
                                        } finally {
                                          if (mounted && keepDialogOpen) {
                                            setDialogState(() {
                                              submitting = false;
                                            });
                                          }
                                        }
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF39E6FF),
                                  foregroundColor: const Color(0xFF0A1220),
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: submitting
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF0A1220)),
                                      )
                                    : Text(AppLocalizations.of(context).t('bankCardSubmit')),
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
          },
        );
      },
    );

    bankNameController.dispose();
    accountNoController.dispose();
    accountNameController.dispose();
    walletAddressController.dispose();
  }

  Widget _buildDialogField(
    BuildContext context, {
    required TextEditingController controller,
    required String label,
    required String hint,
    int minLines = 1,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: controller,
        minLines: minLines,
        maxLines: maxLines,
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

  Future<void> _handleDelete(BankCardItem item) async {
    final bool confirmed = await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
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
                              AppLocalizations.of(context).t('bankCardDelete'),
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
                        AppLocalizations.of(context).t('bankCardDeleteConfirm'),
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
                            child: TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              style: TextButton.styleFrom(
                                foregroundColor: const Color(0xFF9DB1C9),
                                backgroundColor: Colors.white.withOpacity(0.04),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: Text(AppLocalizations.of(context).t('cancel')),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFF6B6B),
                                foregroundColor: const Color(0xFFFFFFFF),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: Text(AppLocalizations.of(context).t('delete')),
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
      _showSnackBar(AppLocalizations.of(context).t('bankCardDeleteSuccess'));
      await _loadCards();
    } catch (_) {
      _showSnackBar(AppLocalizations.of(context).t('bankCardDeleteFailed'), error: true);
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
    return '${text.substring(0, 4)}${'*' * (text.length - 8)}${text.substring(text.length - 4)}';
  }

  void _showSnackBar(String text, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        backgroundColor: error ? const Color(0xFFFF6B6B) : const Color(0xFF38FFB3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations i18n = AppLocalizations.of(context)!;
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
