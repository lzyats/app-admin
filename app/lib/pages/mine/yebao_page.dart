import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:myapp/routers/app_router.dart';
import 'package:myapp/config/app_localizations.dart';
import 'package:myapp/request/yebao_api.dart';
import 'package:myapp/tools/app_bootstrap_tool.dart';

class YebaoPage extends StatefulWidget {
  const YebaoPage({super.key});

  @override
  State<YebaoPage> createState() => _YebaoPageState();
}

class _YebaoPageState extends State<YebaoPage> {
  late Future<YebaoDetail> _future;
  final TextEditingController _sharesController = TextEditingController(text: '1');

  @override
  void initState() {
    super.initState();
    _future = YebaoApi.fetchMyDetail();
    _sharesController.addListener(_onInputChanged);
  }

  @override
  void dispose() {
    _sharesController.removeListener(_onInputChanged);
    _sharesController.dispose();
    super.dispose();
  }

  void _onInputChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _refresh() async {
    setState(() {
      _future = YebaoApi.fetchMyDetail();
    });
    await _future;
  }

  int _sharesValue() {
    return int.tryParse(_sharesController.text.trim()) ?? 0;
  }

  void _changeShares(int delta) {
    final int current = _sharesValue();
    final int nextValue = (current <= 0 ? 1 : current) + delta;
    final int normalized = nextValue < 1 ? 1 : nextValue;
    _sharesController.text = normalized.toString();
    _sharesController.selection = TextSelection.fromPosition(
      TextPosition(offset: _sharesController.text.length),
    );
  }

  double _purchaseAmount(double unitAmount) {
    return _sharesValue() * unitAmount;
  }

  String _money(double value) {
    return value.toStringAsFixed(2);
  }

  String _dateTime(DateTime? dateTime) {
    if (dateTime == null) {
      return '--';
    }
    final DateTime local = dateTime.toLocal();
    String twoDigits(int value) => value.toString().padLeft(2, '0');
    return '${local.year}-${twoDigits(local.month)}-${twoDigits(local.day)} ${twoDigits(local.hour)}:${twoDigits(local.minute)}';
  }

  String _text(AppLocalizations i18n, String key) {
    return i18n.t(key);
  }

  Future<void> _submitPurchase() async {
    final AppLocalizations i18n = AppLocalizations.of(context)!;
    final int shares = _sharesValue();
    if (shares <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_text(i18n, 'yebaoPurchaseSharesInvalid'))),
      );
      return;
    }

    try {
      await YebaoApi.purchase(
        shares: shares,
      );
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_text(i18n, 'yebaoPurchaseSuccess'))),
      );
      await _refresh();
    } catch (error) {
      if (!mounted) {
        return;
      }
      final String message = error
          .toString()
          .replaceFirst('Exception: ', '')
          .replaceFirst('ServiceException: ', '');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: const Color(0xFFFF6B6B),
        ),
      );
    }
  }

  Future<void> _submitRedeem(YebaoOrderItem item) async {
    final AppLocalizations i18n = AppLocalizations.of(context)!;
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(_text(i18n, 'yebaoRedeemConfirm')),
          content: Text(item.orderNo.isNotEmpty ? item.orderNo : _text(i18n, 'yebaoRedeemConfirm')),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(_text(i18n, 'cancel')),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(_text(i18n, 'commonConfirm')),
            ),
          ],
        );
      },
    );
    if (confirmed != true) {
      return;
    }

    try {
      await YebaoApi.redeem(orderId: item.orderId);
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_text(i18n, 'yebaoRedeemSuccess'))),
      );
      await _refresh();
    } catch (error) {
      if (!mounted) {
        return;
      }
      final String message = error
          .toString()
          .replaceFirst('Exception: ', '')
          .replaceFirst('ServiceException: ', '');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: const Color(0xFFFF6B6B),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations i18n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: const Color(0xFF09072A),
      appBar: AppBar(
        title: Text(_text(i18n, 'mineBalanceTreasure')),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: FutureBuilder<YebaoDetail>(
        future: _future,
        builder: (BuildContext context, AsyncSnapshot<YebaoDetail> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF39E6FF)),
            );
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return _buildErrorState(i18n);
          }

          final YebaoDetail detail = snapshot.data!;
          final YebaoConfig config = detail.config ??
              const YebaoConfig(
                configId: 0,
                configName: 'Balance Treasure',
                annualRate: 0,
                unitAmount: 100,
                status: '0',
              );
          final double purchaseAmount = _purchaseAmount(config.unitAmount);

          return RefreshIndicator(
            color: const Color(0xFF39E6FF),
            onRefresh: _refresh,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _buildHeroCard(i18n, config, detail),
                  const SizedBox(height: 14),
                  _buildPurchaseCard(i18n, config, purchaseAmount),
                  const SizedBox(height: 14),
                  _buildQuickActions(i18n),
                  if (AppBootstrapTool.config.yebaoRedeemAfter24h) ...<Widget>[
                    const SizedBox(height: 14),
                    _buildRedeemNotice(i18n),
                  ],
                  const SizedBox(height: 14),
                  _buildRuleCard(i18n),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildErrorState(AppLocalizations i18n) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: <Widget>[
        const SizedBox(height: 140),
        const Icon(Icons.savings_outlined, color: Color(0xFF39E6FF), size: 56),
        const SizedBox(height: 12),
        Text(
          _text(i18n, 'yebaoLoadFailed'),
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFFEAF5FF),
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          _text(i18n, 'yebaoLoadFailedHint'),
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFF9DB1C9),
            fontSize: 13,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 18),
        FilledButton(
          onPressed: _refresh,
          child: Text(_text(i18n, 'assetsRetry')),
        ),
      ],
    );
  }

  Widget _buildHeroCard(AppLocalizations i18n, YebaoConfig config, YebaoDetail detail) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[Color(0xFF212E66), Color(0xFF0F1735)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0x334CE3FF)),
        boxShadow: const <BoxShadow>[
          BoxShadow(color: Color(0x55000000), blurRadius: 20, offset: Offset(0, 10)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  config.configName.isNotEmpty ? config.configName : _text(i18n, 'mineBalanceTreasure'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              _buildRateChip(config.annualRate),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: <Widget>[
              Expanded(
                child: _buildSummaryTile(
                  _text(i18n, 'yebaoTotalPrincipal'),
                  _money(detail.totalPrincipal),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildSummaryTile(
                  _text(i18n, 'yebaoTotalIncome'),
                  _money(detail.totalIncome),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: <Widget>[
              Expanded(
                child: _buildSummaryTile(
                  _text(i18n, 'yebaoTodayIncome'),
                  _money(detail.todayIncome),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildSummaryTile(
                  _text(i18n, 'yebaoOrderCount'),
                  '${detail.orderCount}',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '${_text(i18n, 'yebaoUnitAmount')} ${_money(config.unitAmount)} / ${_text(i18n, 'mineBalanceTreasure')}',
            style: const TextStyle(color: Color(0xFFB9C8DE), fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildRateChip(double annualRate) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: <Color>[Color(0xFFA14CFF), Color(0xFF4094FF)],
        ),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '${annualRate.toStringAsFixed(2)}%',
        style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w800),
      ),
    );
  }

  Widget _buildSummaryTile(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0x331B2A44),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x224CE3FF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            label,
            style: const TextStyle(color: Color(0xFF9DB1C9), fontSize: 12),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPurchaseCard(AppLocalizations i18n, YebaoConfig config, double purchaseAmount) {
    final bool enabled = config.status == '0';
    final int shares = _sharesValue();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xCC101C30),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0x334CE3FF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            _text(i18n, 'yebaoBuyNow'),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              _buildStepperButton(
                icon: Icons.remove_rounded,
                onTap: () => _changeShares(-1),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildSharesInput(i18n, shares, config.unitAmount),
              ),
              const SizedBox(width: 10),
              _buildStepperButton(
                icon: Icons.add_rounded,
                onTap: () => _changeShares(1),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0x331B2A44),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0x224CE3FF)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  '${_text(i18n, 'yebaoPurchaseAmount')}: ${_money(purchaseAmount)}',
                  style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_text(i18n, 'yebaoUnitAmount')}: ${_money(config.unitAmount)}',
                  style: const TextStyle(color: Color(0xFF9DB1C9), fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: enabled ? _submitPurchase : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: enabled ? const Color(0xFF39E6FF) : const Color(0x664CE3FF),
                foregroundColor: const Color(0xFF09111D),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
              ),
              child: Text(
                enabled ? _text(i18n, 'yebaoPurchaseButton') : _text(i18n, 'yebaoPurchaseDisabled'),
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepperButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: const Color(0xFF1B2A44),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0x334CE3FF)),
        ),
        child: Icon(icon, color: const Color(0xFF39E6FF), size: 22),
      ),
    );
  }

  Widget _buildSharesPreview(AppLocalizations i18n, int shares, double unitAmount) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: const Color(0x331B2A44),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x224CE3FF)),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              '$shares ${_text(i18n, 'yebaoShareUnit')}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Text(
            '${_money(_purchaseAmount(unitAmount))}',
            style: const TextStyle(
              color: Color(0xFF39E6FF),
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSharesInput(AppLocalizations i18n, int shares, double unitAmount) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: const Color(0x331B2A44),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x224CE3FF)),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: TextField(
              controller: _sharesController,
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly,
              ],
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
              decoration: const InputDecoration(
                isDense: true,
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                hintText: '',
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            _text(i18n, 'yebaoShareUnit'),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          Text(
            _money(_purchaseAmount(unitAmount)),
            style: const TextStyle(
              color: Color(0xFF39E6FF),
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(AppLocalizations i18n) {
    return Row(
      children: <Widget>[
        Expanded(
          child: _buildActionButton(
            text: _text(i18n, 'yebaoRecentOrders'),
            onTap: () {
              Navigator.of(context).pushNamed(AppRouter.balanceTreasureOrders);
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionButton(
            text: _text(i18n, 'yebaoRecentIncome'),
            onTap: () {
              Navigator.of(context).pushNamed(AppRouter.balanceTreasureIncomes);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required String text,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      height: 46,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1B2A44),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
          elevation: 0,
        ),
        child: Text(
          text,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
        ),
      ),
    );
  }

  Widget _buildRedeemNotice(AppLocalizations i18n) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0x331B2A44),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0x33FFB74D)),
      ),
      child: Row(
        children: <Widget>[
          const Icon(Icons.schedule_rounded, color: Color(0xFFFFB74D), size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _text(i18n, 'yebaoRedeem24hNotice'),
              style: const TextStyle(
                color: Color(0xFFFFD9A6),
                fontSize: 12,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRuleCard(AppLocalizations i18n) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xCC101C30),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0x334CE3FF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            _text(i18n, 'yebaoSettlementRule'),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          _buildRuleLine(_text(i18n, 'yebaoSettlementRuleLine1')),
          const SizedBox(height: 8),
          _buildRuleLine(_text(i18n, 'yebaoSettlementRuleLine2')),
          const SizedBox(height: 8),
          _buildRuleLine(_text(i18n, 'yebaoSettlementRuleLine3')),
        ],
      ),
    );
  }

  Widget _buildRuleLine(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          margin: const EdgeInsets.only(top: 6),
          width: 8,
          height: 8,
          decoration: const BoxDecoration(
            color: Color(0xFF39E6FF),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Color(0xFFB9C8DE),
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

}
