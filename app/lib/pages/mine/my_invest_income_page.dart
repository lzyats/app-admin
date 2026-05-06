import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:myapp/config/app_images.dart';
import 'package:myapp/config/app_localizations.dart';
import 'package:myapp/request/invest_order_api.dart';

class MyInvestIncomePage extends StatefulWidget {
  const MyInvestIncomePage({super.key});

  @override
  State<MyInvestIncomePage> createState() => _MyInvestIncomePageState();
}

class _MyInvestIncomePageState extends State<MyInvestIncomePage> {
  late Future<InvestIncomeData> _future;
  AppLocalizations get i18n => AppLocalizations.of(context)!;

  @override
  void initState() {
    super.initState();
    _future = InvestOrderApi.fetchIncomeData();
  }

  Future<void> _refresh() async {
    setState(() {
      _future = InvestOrderApi.fetchIncomeData();
    });
    await _future;
  }

  String _money(double value) => value.toStringAsFixed(2);

  String _time(DateTime? t) {
    if (t == null) return '--';
    final DateTime local = t.toLocal();
    String d(int v) => v.toString().padLeft(2, '0');
    return '${d(local.month)}-${d(local.day)} ${d(local.hour)}:${d(local.minute)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0E2A),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          i18n.t('myIncomeDetailTitle'),
          style: TextStyle(color: Color(0xFFEAF4FF), fontWeight: FontWeight.w700, fontSize: 20),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Stack(
        children: <Widget>[
          _buildPageBackground(),
          SafeArea(
            child: FutureBuilder<InvestIncomeData>(
              future: _future,
              builder: (_, AsyncSnapshot<InvestIncomeData> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Color(0xFF39E6FF)));
                }
                if (snapshot.hasError || !snapshot.hasData) {
                  return Center(
                    child: TextButton(onPressed: _refresh, child: Text(i18n.t('loadFailedRetryTap'))),
                  );
                }
                final InvestIncomeData data = snapshot.data!;
                return RefreshIndicator(
                  onRefresh: _refresh,
                  color: const Color(0xFF39E6FF),
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
                    children: <Widget>[
                      _buildSummary(data),
                      const SizedBox(height: 10),
                      const _IncomeHint(),
                      const SizedBox(height: 18),
                      Row(
                        children: <Widget>[
                          const Icon(Icons.account_balance_wallet_outlined, color: Color(0xFFA7A5C4), size: 16),
                          const SizedBox(width: 8),
                          Text(
                            i18n.t('financeList'),
                            style: const TextStyle(color: Color(0xFFA7A5C4), fontSize: 15, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (data.logs.isEmpty)
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 48),
                          child: Center(
                            child: Text(i18n.t('myIncomeEmpty'), style: const TextStyle(color: Color(0xFF9DB1C9))),
                          ),
                        )
                      else
                        ...data.logs
                            .where((InvestIncomeLogItem item) => item.planType.toUpperCase() == 'INTEREST')
                            .map(_buildLogItem),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageBackground() {
    return Stack(
      children: <Widget>[
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[
                Color(0xFF0A1220),
                Color(0xFF0D1B2A),
                Color(0xFF14233A),
              ],
            ),
          ),
        ),
        Positioned(
          top: -120,
          right: -80,
          child: _blurBall(size: 240, color: const Color(0x5539E6FF)),
        ),
        Positioned(
          bottom: -100,
          left: -90,
          child: _blurBall(size: 260, color: const Color(0x5538FFB3)),
        ),
      ],
    );
  }

  Widget _blurBall({required double size, required Color color}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: color,
            blurRadius: size * 0.5,
            spreadRadius: size * 0.1,
          ),
        ],
      ),
    );
  }

  Widget _buildSummary(InvestIncomeData data) {
    final InvestIncomeCurrencySummary cny = _summaryFor(data, 'CNY');
    final InvestIncomeCurrencySummary usd = _summaryFor(data, 'USD');
    final double cnyReceived = cny.receivedInterest;
    final double cnyPending = cny.pendingInterest;
    final double usdReceived = usd.receivedInterest;
    final double usdPending = usd.pendingInterest;
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 18, 22, 18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            Color(0xCC101C30),
            Color(0xCC0E182A),
          ],
        ),
        border: Border.all(color: const Color(0x334CE3FF)),
        borderRadius: BorderRadius.circular(18),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x66000000),
            blurRadius: 22,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: _statCell(
                  label: i18n.t('receivedInterestCny'),
                  value: _money(cnyReceived),
                ),
              ),
              Expanded(
                child: _statCell(
                  label: i18n.t('pendingInterestCny'),
                  value: _money(cnyPending),
                  alignEnd: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: <Widget>[
              Expanded(
                child: _statCell(
                  label: i18n.t('receivedInterestUsdt'),
                  value: _money(usdReceived),
                ),
              ),
              Expanded(
                child: _statCell(
                  label: i18n.t('pendingInterestUsdt'),
                  value: _money(usdPending),
                  alignEnd: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  InvestIncomeCurrencySummary _summaryFor(InvestIncomeData data, String currency) {
    for (final InvestIncomeCurrencySummary item in data.summaryByCurrency) {
      if (item.currency.toUpperCase() == currency.toUpperCase()) {
        return item;
      }
    }
    return InvestIncomeCurrencySummary(
      currency: currency.toUpperCase(),
      receivedInterest: 0,
      pendingInterest: 0,
      receivedPrincipal: 0,
      pendingPrincipal: 0,
    );
  }

  Widget _statCell({required String label, required String value, bool alignEnd = false}) {
    final CrossAxisAlignment align = alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    return Column(
      crossAxisAlignment: align,
      children: <Widget>[
        Text(label, style: const TextStyle(color: Color(0xFFA7A5C4), fontSize: 13, fontWeight: FontWeight.w500)),
        const SizedBox(height: 10),
        Text(
          value,
          style: const TextStyle(color: Color(0xFFEDEDFB), fontSize: 22, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }

  String _currencyUnit(String currency) {
    final String c = currency.trim().toUpperCase();
    if (c == 'USD') {
      return 'USDT';
    }
    return 'CNY';
  }

  Widget _buildLogItem(InvestIncomeLogItem item) {
    final bool isSettled = item.status == '1';
    final bool isCancelled = item.status == '2';
    final bool notDueYet = !isSettled &&
        !isCancelled &&
        item.planTime != null &&
        DateTime.now().isBefore(item.planTime!.toLocal());
    final String symbol = isSettled ? '+' : '';
    final String currency = _currencyUnit(item.currency);
    final _IncomeLogTheme theme = _logTheme(item.currency);
    final Color amountColor = isSettled ? const Color(0xFFFF6A4A) : const Color(0xFF9DB1C9);
    final String statusText = isSettled
        ? i18n.t('incomeReceived')
        : (isCancelled ? i18n.t('incomeCancelled') : (notDueYet ? i18n.t('incomeNotReceived') : i18n.t('incomePending')));
    final Color statusColor = isSettled
        ? const Color(0xFF36D399)
        : (isCancelled ? const Color(0xFF8892B5) : const Color(0xFFFFD166));
    final IconData statusIcon = isSettled
        ? Icons.check_circle_outline
        : (isCancelled ? Icons.cancel_outlined : Icons.schedule_outlined);
    final String timeLabel = isSettled ? i18n.t('incomeReceivedTime') : i18n.t('incomeExpectedTime');
    final DateTime? showTime = isSettled ? (item.execTime ?? item.planTime) : item.planTime;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: theme.cardColors,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.borderColor),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 14,
            offset: Offset(0, 8),
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
                  Expanded(
                    child: Text(
                      item.productName.isEmpty ? i18n.t('incomeRecord') : item.productName,
                      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0x221E2B56),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0x3353668F)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Icon(statusIcon, size: 13, color: statusColor),
                        const SizedBox(width: 4),
                        Text(
                          statusText,
                          style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              RichText(
                text: TextSpan(
                  style: TextStyle(color: amountColor, fontSize: 18, fontWeight: FontWeight.w700),
                  children: <TextSpan>[
                    TextSpan(text: '$symbol${_money(item.planAmount)}'),
                    const TextSpan(text: '  '),
                    TextSpan(text: currency),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              if (_hasCouponInfo(item)) ...<Widget>[
                _smallKv('券后口径', _couponDisplayText(item), valueColor: const Color(0xFF37DFFF)),
                const SizedBox(height: 4),
              ],
              Text(
                i18n.t('orderNo'),
                style: TextStyle(color: Color(0xFF95A0C0), fontSize: 12, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 4),
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      item.orderNo.isEmpty ? '--' : item.orderNo,
                      style: const TextStyle(color: Color(0xFFB6C2DF), fontSize: 12, fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 6),
                  InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: item.orderNo.isEmpty
                        ? null
                        : () async {
                            await Clipboard.setData(ClipboardData(text: item.orderNo));
                            if (!mounted) {
                              return;
                            }
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(i18n.t('orderNoCopied')),
                                duration: Duration(milliseconds: 1200),
                                backgroundColor: Color(0xFF38FFB3),
                              ),
                            );
                          },
                    child: const Padding(
                      padding: EdgeInsets.all(2),
                      child: Icon(Icons.copy_rounded, size: 15, color: Color(0xFF8EA3C7)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                '$timeLabel: ${_time(showTime)}',
                style: const TextStyle(color: Color(0xFF7B86A8), fontSize: 13, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Image.asset(
              AppImages.currencyBrand(item.currency, usePurpleVariant: true),
              width: 18,
              height: 18,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }

  bool _hasCouponInfo(InvestIncomeLogItem item) {
    return item.userCouponId > 0 ||
        item.couponDiscountAmount > 0 ||
        item.couponName.trim().isNotEmpty ||
        (item.payAmount > 0 && (item.payAmount - item.planAmount).abs() > 0.000001);
  }

  String _couponDisplayText(InvestIncomeLogItem item) {
    final String name = item.couponName.trim().isNotEmpty ? item.couponName.trim() : '已使用优惠券';
    final String discount = item.couponDiscountAmount > 0 ? _money(item.couponDiscountAmount) : '--';
    final String payAmount = item.payAmount > 0 ? _money(item.payAmount) : '--';
    return '$name / 抵扣 $discount / 实付 $payAmount';
  }

  Widget _smallKv(String k, String v, {Color valueColor = const Color(0xFF7B86AA)}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(
          width: 68,
          child: Text(k, style: const TextStyle(color: Color(0xFF717EA8), fontSize: 12)),
        ),
        Expanded(
          child: Text(
            v,
            textAlign: TextAlign.right,
            style: TextStyle(color: valueColor, fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  _IncomeLogTheme _logTheme(String currency) {
    return const _IncomeLogTheme(
      cardColors: <Color>[Color(0xCC101C30), Color(0xCC0E182A)],
      borderColor: Color(0x334CE3FF),
    );
  }
}

class _IncomeLogTheme {
  const _IncomeLogTheme({
    required this.cardColors,
    required this.borderColor,
  });

  final List<Color> cardColors;
  final Color borderColor;
}

class _IncomeHint extends StatelessWidget {
  const _IncomeHint();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0x1A39E6FF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0x3339E6FF)),
      ),
      child: const Text(
        '提示：当前收益记录的返本口径已按优惠后实付金额计算，和订单页保持一致。',
        style: TextStyle(color: Color(0xFF9DB1C9), fontSize: 12, height: 1.35),
      ),
    );
  }
}
