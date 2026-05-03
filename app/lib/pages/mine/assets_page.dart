import 'package:flutter/material.dart';

import 'package:myapp/config/app_images.dart';
import 'package:myapp/config/app_localizations.dart';
import 'package:myapp/request/withdraw_api.dart';
import 'package:myapp/routers/app_router.dart';
import 'package:myapp/tools/app_bootstrap_tool.dart';

class AssetsPage extends StatefulWidget {
  const AssetsPage({super.key});

  @override
  State<AssetsPage> createState() => _AssetsPageState();
}

class _AssetsPageState extends State<AssetsPage> {
  bool _loading = true;
  bool _loadFailed = false;
  bool _dualMode = false;
  String _selectedCurrencyType = 'CNY';
  List<WithdrawWalletItem> _wallets = <WithdrawWalletItem>[];

  AppLocalizations get i18n => AppLocalizations.of(context);

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final int investMode = AppBootstrapTool.config.investCurrencyMode;
      if (mounted) {
        setState(() {
          _dualMode = investMode == 2;
          _loadFailed = false;
        });
      }
      final List<WithdrawWalletItem> wallets = await WithdrawApi.getWallets();
      if (!mounted) {
        return;
      }
      final String initialCurrency = _resolveInitialCurrency(wallets, investMode == 2);
      setState(() {
        _dualMode = investMode == 2;
        _wallets = wallets;
        _selectedCurrencyType = initialCurrency;
        _loading = false;
        _loadFailed = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _loading = false;
        _loadFailed = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(i18n.t('assetsLoadFailed')),
          backgroundColor: const Color(0xFFFF6B6B),
        ),
      );
    }
  }

  Widget _buildLoadingBlock({
    required double width,
    required double height,
    double radius = 16,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFF13233A),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }

  Widget _buildLoadingState() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (_dualMode)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                _buildLoadingBlock(width: 86, height: 38, radius: 999),
                const SizedBox(width: 28),
                _buildLoadingBlock(width: 86, height: 38, radius: 999),
              ],
            )
          else
            Center(
              child: _buildLoadingBlock(width: 110, height: 38, radius: 999),
            ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[Color(0xFF231338), Color(0xFF161225)],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0x334CE3FF)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    _buildLoadingBlock(width: 142, height: 18, radius: 999),
                    const Spacer(),
                    _buildLoadingBlock(width: 74, height: 24, radius: 999),
                  ],
                ),
                const SizedBox(height: 16),
                _buildLoadingBlock(width: 148, height: 34, radius: 14),
                const SizedBox(height: 12),
                Container(height: 1, color: Colors.white.withOpacity(0.08)),
                const SizedBox(height: 12),
                Row(
                  children: <Widget>[
                    Expanded(child: _buildLoadingBlock(width: double.infinity, height: 44, radius: 14)),
                    const SizedBox(width: 10),
                    Expanded(child: _buildLoadingBlock(width: double.infinity, height: 44, radius: 14)),
                    const SizedBox(width: 10),
                    Expanded(child: _buildLoadingBlock(width: double.infinity, height: 44, radius: 14)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _buildLoadingBlock(width: double.infinity, height: 58, radius: 18),
          const SizedBox(height: 10),
          _buildLoadingBlock(width: double.infinity, height: 58, radius: 18),
          if (_dualMode) ...<Widget>[
            const SizedBox(height: 10),
            _buildLoadingBlock(width: double.infinity, height: 58, radius: 18),
          ],
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF101C30),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0x334CE3FF)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _buildLoadingBlock(width: 126, height: 18, radius: 999),
                const SizedBox(height: 12),
                _buildLoadingBlock(width: 220, height: 14, radius: 999),
                const SizedBox(height: 8),
                _buildLoadingBlock(width: 170, height: 14, radius: 999),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _resolveInitialCurrency(List<WithdrawWalletItem> wallets, bool dualMode) {
    if (wallets.isEmpty) {
      return 'CNY';
    }
    if (!dualMode) {
      return wallets.any((WithdrawWalletItem item) => item.currencyType.toUpperCase() == 'CNY')
          ? 'CNY'
          : wallets.first.currencyType.toUpperCase();
    }
    if (wallets.any((WithdrawWalletItem item) => item.currencyType.toUpperCase() == 'CNY')) {
      return 'CNY';
    }
    if (wallets.any((WithdrawWalletItem item) => item.currencyType.toUpperCase() == 'USD')) {
      return 'USD';
    }
    return wallets.first.currencyType.toUpperCase();
  }

  WithdrawWalletItem? _walletByType(String currencyType) {
    for (final WithdrawWalletItem item in _wallets) {
      if (item.currencyType.toUpperCase() == currencyType.toUpperCase()) {
        return item;
      }
    }
    return null;
  }

  WithdrawWalletItem? get _selectedWallet => _walletByType(_selectedCurrencyType);

  String _currencyLabel(String currencyType) {
    return currencyType.toUpperCase() == 'USD' ? i18n.t('assetsUsd') : i18n.t('assetsRmb');
  }

  String _heroIcon(String currencyType) {
    return AppImages.currencyBrand(currencyType, usePurpleVariant: true);
  }

  double _totalAssets(WithdrawWalletItem wallet) {
    return wallet.totalInvest +
        wallet.availableBalance +
        wallet.frozenAmount +
        wallet.pendingAmount +
        wallet.profitAmount;
  }

  String _formatAmount(double value) {
    return value.toStringAsFixed(2);
  }

  void _openDetailSheet(WithdrawWalletItem wallet) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFF0C1525),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
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
                        i18n.t('assetsDetail'),
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
                        child: const Icon(
                          Icons.close,
                          color: Color(0xFF9DB1C9),
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _detailRow(i18n.t('assetsTotalAssets'), _formatAmount(_totalAssets(wallet))),
                _detailRow(i18n.t('assetsInvestable'), _formatAmount(wallet.totalInvest)),
                _detailRow(i18n.t('assetsAvailable'), _formatAmount(wallet.availableBalance)),
                _detailRow(i18n.t('assetsFrozen'), _formatAmount(wallet.frozenAmount)),
                _detailRow(i18n.t('assetsProfit'), _formatAmount(wallet.profitAmount)),
                const SizedBox(height: 8),
                _detailRow(i18n.t('assetsRechargeCount'), _formatAmount(wallet.totalRecharge)),
                _detailRow(i18n.t('assetsWithdrawCount'), _formatAmount(wallet.totalWithdraw)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF9DB1C9),
                fontSize: 13,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFFEAF5FF),
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  void _openRecharge() {
    Navigator.pushNamed(context, AppRouter.recharge);
  }

  void _openWithdraw() {
    Navigator.pushNamed(context, AppRouter.withdraw);
  }

  void _openExchange(String currencyType) {
    Navigator.pushNamed(
      context,
      AppRouter.exchange,
      arguments: <String, dynamic>{
        'fromCurrency': currencyType.toUpperCase(),
      },
    );
  }

  Widget _buildCurrencyTab(String currencyType, bool selected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCurrencyType = currencyType;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? const Color(0x1A39E6FF) : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? const Color(0xFF39E6FF) : Colors.transparent,
          ),
        ),
        child: Text(
          _currencyLabel(currencyType),
          style: TextStyle(
            color: selected ? const Color(0xFF39E6FF) : const Color(0xFF9DB1C9),
            fontSize: 16,
            fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildHeroCard(WithdrawWalletItem wallet) {
    final bool isUsd = wallet.currencyType.toUpperCase() == 'USD';
    final Color accent = isUsd ? const Color(0xFF39E6FF) : const Color(0xFFB14CFF);
    final List<Color> cardColors = isUsd
        ? <Color>[const Color(0xFF1A1538), const Color(0xFF121A36)]
        : <Color>[const Color(0xFF231338), const Color(0xFF161225)];
    final String imagePath = _heroIcon(wallet.currencyType);
    final String title = '${_currencyLabel(wallet.currencyType)}${i18n.t('assetsTotalAssets')}';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: cardColors,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: accent.withOpacity(0.28)),
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
            right: -18,
            top: -10,
            child: Container(
              width: 126,
              height: 126,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: accent.withOpacity(0.06),
                border: Border.all(color: accent.withOpacity(0.08), width: 8),
              ),
              child: Center(
                child: Image.asset(
                  imagePath,
                  width: 64,
                  height: 64,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Text(
                    title,
                    style: const TextStyle(
                      color: Color(0xFFEAF5FF),
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => _openDetailSheet(wallet),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: <Color>[accent.withOpacity(0.85), const Color(0xFF2D7BFF)],
                        ),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        i18n.t('assetsDetail'),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                _formatAmount(_totalAssets(wallet)),
                style: TextStyle(
                  color: accent,
                  fontSize: 34,
                  fontWeight: FontWeight.w800,
                  height: 1.0,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                height: 1,
                color: Colors.white.withOpacity(0.08),
              ),
              const SizedBox(height: 12),
              Row(
                children: <Widget>[
                  Expanded(
                    child: _buildMetric(
                      title: i18n.t('assetsFrozen'),
                      value: _formatAmount(wallet.frozenAmount),
                    ),
                  ),
                  Expanded(
                    child: _buildMetric(
                      title: i18n.t('assetsAvailable'),
                      value: _formatAmount(wallet.availableBalance),
                    ),
                  ),
                  Expanded(
                    child: _buildMetric(
                      title: i18n.t('assetsPending'),
                      value: _formatAmount(wallet.pendingAmount),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetric({required String title, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF9DB1C9),
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFFEAF5FF),
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required String label,
    required VoidCallback onTap,
    required Color accent,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 58,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[accent.withOpacity(0.20), const Color(0xFF0E1728)],
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: accent.withOpacity(0.28)),
          ),
          child: Center(
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholderCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF101C30),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0x334CE3FF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0x1A39E6FF),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.account_balance_wallet_outlined,
                  color: Color(0xFF39E6FF),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  i18n.t('assetsSummaryTitle'),
                  style: const TextStyle(
                    color: Color(0xFFEAF5FF),
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            i18n.t('assetsNoWallets'),
            style: const TextStyle(
              color: Color(0xFF9DB1C9),
              fontSize: 14,
            ),
          ),
          Text(
            i18n.t('assetsNoWalletsHint'),
            style: const TextStyle(
              color: Color(0xFF9DB1C9),
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF101C30),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0x334CE3FF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0x1AFF6B6B),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.cloud_off_outlined,
                  color: Color(0xFFFF6B6B),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  i18n.t('assetsLoadFailed'),
                  style: const TextStyle(
                    color: Color(0xFFEAF5FF),
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            i18n.t('assetsLoadFailedHint'),
            style: const TextStyle(
              color: Color(0xFF9DB1C9),
              fontSize: 13,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: _loadData,
            child: Container(
              height: 46,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: <Color>[Color(0xFF39E6FF), Color(0xFF2D7BFF)],
                ),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Center(
                child: Text(
                  i18n.t('assetsRetry'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageBody() {
    final WithdrawWalletItem? wallet = _selectedWallet;
    final bool showExchange = _dualMode;
    final bool showErrorState = _loadFailed && _wallets.isEmpty;

    return RefreshIndicator(
      color: const Color(0xFF39E6FF),
      onRefresh: _loadData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            if (_dualMode)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  _buildCurrencyTab('CNY', _selectedCurrencyType == 'CNY'),
                  const SizedBox(width: 28),
                  _buildCurrencyTab('USD', _selectedCurrencyType == 'USD'),
                ],
              )
            else
              Center(
                child: _buildCurrencyTab('CNY', true),
              ),
          const SizedBox(height: 12),
          if (showErrorState)
            _buildErrorCard()
          else if (wallet == null)
            _buildPlaceholderCard()
          else
            _buildHeroCard(wallet),
            const SizedBox(height: 14),
            Row(
              children: <Widget>[
                _buildActionButton(
                  label: i18n.t('assetsRecharge'),
                  onTap: _openRecharge,
                  accent: const Color(0xFF39E6FF),
                ),
                const SizedBox(width: 10),
                _buildActionButton(
                  label: i18n.t('assetsWithdraw'),
                  onTap: _openWithdraw,
                  accent: const Color(0xFF38FFB3),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (showExchange) ...<Widget>[
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: GestureDetector(
                  onTap: () => _openExchange(_selectedCurrencyType),
                  child: Container(
                    height: 58,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: <Color>[Color(0xFFB14CFF), Color(0xFF2D7BFF)],
                      ),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Center(
                      child: Text(
                        i18n.t('assetsExchange'),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations i18n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFF07111F),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(i18n.t('assetsTitle')),
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
            top: 140,
            left: -90,
            child: _GlowBlob(
              size: 180,
              colors: <Color>[Color(0x1A38FFB3), Color(0x00000000)],
            ),
          ),
          SafeArea(
            child: _loading
                ? _buildLoadingState()
                : _buildPageBody(),
          ),
        ],
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
