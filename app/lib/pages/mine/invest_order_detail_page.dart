import 'package:flutter/material.dart';
import 'package:myapp/config/app_images.dart';
import 'package:myapp/config/app_localizations.dart';
import 'package:myapp/request/invest_order_api.dart';
import 'package:myapp/widgets/countdown_text.dart';

class InvestOrderDetailPage extends StatefulWidget {
  const InvestOrderDetailPage({
    super.key,
    required this.orderId,
    this.fallbackItem,
  });

  final int orderId;
  final InvestOrderListItem? fallbackItem;

  @override
  State<InvestOrderDetailPage> createState() => _InvestOrderDetailPageState();
}

class _InvestOrderDetailPageState extends State<InvestOrderDetailPage> {
  late Future<InvestOrderDetailData> _future;

  @override
  void initState() {
    super.initState();
    _future = InvestOrderApi.fetchOrderDetail(widget.orderId);
  }

  Future<void> _refresh() async {
    setState(() {
      _future = InvestOrderApi.fetchOrderDetail(widget.orderId);
    });
    await _future;
  }

  String _money(double value) => value.toStringAsFixed(2);

  String _time(DateTime? time) {
    if (time == null) return '--';
    final DateTime local = time.toLocal();
    String d(int v) => v.toString().padLeft(2, '0');
    return '${local.year}-${d(local.month)}-${d(local.day)} ${d(local.hour)}:${d(local.minute)}';
  }

  String _currencyUnit(String currency) => currency.toUpperCase() == 'USD' ? 'U' : '楼';

  @override
  Widget build(BuildContext context) {
    final AppLocalizations i18n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: const Color(0xFF0B0E2A),
      appBar: AppBar(
        title: const Text('订单详情', style: TextStyle(color: Color(0xFFEAF4FF), fontWeight: FontWeight.w700)),
        centerTitle: true,
        backgroundColor: const Color(0xFF0B0E2A),
        elevation: 0,
      ),
      body: Stack(
        children: <Widget>[
          _buildBackground(),
          SafeArea(
            child: FutureBuilder<InvestOrderDetailData>(
              future: _future,
              builder: (_, AsyncSnapshot<InvestOrderDetailData> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return _loadingView();
                }
                if (snapshot.hasError || !snapshot.hasData) {
                  return Center(
                    child: TextButton(
                      onPressed: _refresh,
                      child: const Text('加载失败，点击重试', style: TextStyle(color: Colors.white)),
                    ),
                  );
                }

                final InvestOrderDetailData data = snapshot.data!;
                final InvestOrderListItem order = data.order;
                final bool couponActive = data.hasCoupon;
                final bool isEnded = order.status == '1' || (order.endTime != null && DateTime.now().isAfter(order.endTime!));
                final bool isRedeemed = order.status == '2';
                final String statusText = isRedeemed
                    ? i18n.t('redeemed')
                    : (isEnded ? i18n.t('ended') : i18n.t('running'));
                final Color statusColor = isRedeemed
                    ? const Color(0xFF8A7DFF)
                    : (isEnded ? const Color(0xFFFF6B6B) : const Color(0xFF37DFFF));
                final String unit = _currencyUnit(order.currency);

                return RefreshIndicator(
                  onRefresh: _refresh,
                  color: const Color(0xFF39E6FF),
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                    children: <Widget>[
                      _section(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                Image.asset(
                                  AppImages.currencyBrand(order.currency, usePurpleVariant: true),
                                  width: 22,
                                  height: 22,
                                  fit: BoxFit.contain,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    order.productName.isEmpty ? '--' : order.productName,
                                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: statusColor.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: statusColor.withOpacity(0.5)),
                                  ),
                                  child: Text(statusText, style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.w700)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            _bigValueRow('投资本金', '${_money(order.investAmount)} $unit'),
                            if (couponActive) ...<Widget>[
                              const SizedBox(height: 10),
                              _bigValueRow('优惠抵扣', '${_money(order.couponDiscountAmount)} $unit', valueColor: const Color(0xFFFFA257)),
                              const SizedBox(height: 10),
                              _bigValueRow('实付金额', '${_money(order.payAmount)} $unit', valueColor: const Color(0xFF38FFB3)),
                            ],
                            const SizedBox(height: 10),
                            _bigValueRow('预计收益', '${_money(order.expectedIncome)} $unit', valueColor: const Color(0xFFFF6A4A)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      _section(
                        title: '券后口径',
                        child: Column(
                          children: <Widget>[
                            _kv('优惠券', couponActive ? _couponName(order) : '--'),
                            _kv('优惠类型', order.couponType.isEmpty ? '--' : order.couponType),
                            _kv('抵扣金额', '${_money(order.couponDiscountAmount)} $unit'),
                            _kv('实付金额', '${_money(order.payAmount)} $unit'),
                            _kv('返本金额', '${_money(order.payAmount)} $unit'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      _section(
                        title: '订单信息',
                        child: Column(
                          children: <Widget>[
                            _kv('订单编号', order.orderNo.isEmpty ? '--' : order.orderNo),
                            _kv('产品编号', '${order.productId}'),
                            _kv('投资金额', '${_money(order.investAmount)} $unit'),
                            _kv('收益率', '${order.effectiveRate.toStringAsFixed(3)}%'),
                            _kv('周期天数', '${order.cycleDays}天'),
                            _kv('创建时间', _time(order.createTime)),
                            _kv('结束时间', _time(order.endTime)),
                          ],
                        ),
                      ),
                      if (order.groupMode) ...<Widget>[
                        const SizedBox(height: 12),
                        _section(
                          title: '拼团信息',
                          child: Column(
                            children: <Widget>[
                              _kv('拼团状态', _groupStatusText(i18n, order.groupStatus)),
                              _kv('拼团编号', order.groupNo.isEmpty ? '--' : order.groupNo),
                              _kv('拼团截止', _time(order.groupDeadlineTime)),
                              if (order.groupMode && order.groupStatus == '0')
                                Row(
                                  children: <Widget>[
                                    const SizedBox(
                                      width: 90,
                                      child: Text('剩余时间', style: TextStyle(color: Color(0xFF717EA8), fontSize: 14)),
                                    ),
                                    Expanded(
                                      child: Align(
                                        alignment: Alignment.centerRight,
                                        child: order.groupCountdownSeconds > 0
                                            ? CountdownText(
                                                key: ValueKey<String>('detail_${order.orderNo}_${order.groupNo}'),
                                                initialSeconds: order.groupCountdownSeconds,
                                                finishedText: i18n.t('groupStatusUpdating'),
                                                textStyle: const TextStyle(
                                                  color: Color(0xFFFFA500),
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              )
                                            : Text(
                                                i18n.t('groupStatusUpdating'),
                                                style: const TextStyle(
                                                  color: Color(0xFFFFA500),
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),
                      _section(
                        title: '计划明细',
                        child: data.plans.isEmpty
                            ? const Padding(
                                padding: EdgeInsets.symmetric(vertical: 24),
                                child: Center(
                                  child: Text('暂无计划', style: TextStyle(color: Color(0xFF9DB1C9))),
                                ),
                              )
                            : Column(
                                children: data.plans.map((InvestOrderPlanItem plan) {
                                  final bool settled = plan.status == '1';
                                  final bool cancelled = plan.status == '2';
                                  final Color badgeColor = settled
                                      ? const Color(0xFF36D399)
                                      : (cancelled ? const Color(0xFF8892B5) : const Color(0xFFFFD166));
                                  final String badgeText = settled
                                      ? '已结算'
                                      : (cancelled ? '已取消' : '待结算');
                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 10),
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: const Color(0x141F2C49),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: const Color(0x2A4CE3FF)),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Row(
                                          children: <Widget>[
                                            Text(
                                              '${plan.planType} · 第${plan.stageNo}期',
                                              style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700),
                                            ),
                                            const Spacer(),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                              decoration: BoxDecoration(
                                                color: badgeColor.withOpacity(0.18),
                                                borderRadius: BorderRadius.circular(20),
                                                border: Border.all(color: badgeColor.withOpacity(0.45)),
                                              ),
                                              child: Text(badgeText, style: TextStyle(color: badgeColor, fontSize: 11, fontWeight: FontWeight.w700)),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        _kv('计划金额', '${_money(plan.planAmount)} $unit'),
                                        _kv('计划收益率', '${plan.planRate.toStringAsFixed(3)}%'),
                                        _kv('计划时间', _time(plan.planTime)),
                                        _kv('执行时间', _time(plan.execTime)),
                                        if (plan.remark.trim().isNotEmpty) _kv('备注', plan.remark.trim()),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                      ),
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

  Widget _loadingView() {
    return const Center(child: CircularProgressIndicator(color: Color(0xFF39E6FF)));
  }

  Widget _buildBackground() {
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

  Widget _section({String? title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      decoration: BoxDecoration(
        color: const Color(0xCC101C30),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x334CE3FF)),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (title != null) ...<Widget>[
            Text(title, style: const TextStyle(color: Color(0xFF9DB1C9), fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
          ],
          child,
        ],
      ),
    );
  }

  Widget _bigValueRow(String label, String value, {Color valueColor = const Color(0xFFEAF4FF)}) {
    return Row(
      children: <Widget>[
        Text(label, style: const TextStyle(color: Color(0xFF7B86A8), fontSize: 13, fontWeight: FontWeight.w500)),
        const Spacer(),
        Text(value, style: TextStyle(color: valueColor, fontSize: 20, fontWeight: FontWeight.w800)),
      ],
    );
  }

  Widget _kv(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: <Widget>[
          SizedBox(
            width: 90,
            child: Text(label, style: const TextStyle(color: Color(0xFF717EA8), fontSize: 14)),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(color: Color(0xFFEDEDFB), fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  String _couponName(InvestOrderListItem order) {
    final String name = order.couponName.trim();
    if (name.isNotEmpty) {
      return name;
    }
    if (order.userCouponId > 0) {
      return '已使用优惠券';
    }
    return '--';
  }

  String _groupStatusText(AppLocalizations i18n, String status) {
    switch (status) {
      case '0':
        return i18n.t('grouping');
      case '1':
        return i18n.t('groupSuccess');
      case '2':
        return i18n.t('groupFailedRefunded');
      default:
        return i18n.t('normalOrder');
    }
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
}
