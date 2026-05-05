import 'package:flutter/material.dart';
import 'package:myapp/config/app_images.dart';
import 'package:myapp/request/invest_order_api.dart';
import 'package:myapp/routers/app_router.dart';
import 'package:myapp/widgets/countdown_text.dart';

class MyInvestOrdersPage extends StatefulWidget {
  const MyInvestOrdersPage({super.key});

  @override
  State<MyInvestOrdersPage> createState() => _MyInvestOrdersPageState();
}

class _MyInvestOrdersPageState extends State<MyInvestOrdersPage> {
  static const List<String> _tabs = <String>['total', 'running', 'ended'];
  int _tabIndex = 0;
  late Future<InvestOrderListData> _future;

  @override
  void initState() {
    super.initState();
    _future = InvestOrderApi.fetchOrderList(tab: _tabs[_tabIndex]);
  }

  Future<void> _refresh() async {
    setState(() {
      _future = InvestOrderApi.fetchOrderList(tab: _tabs[_tabIndex]);
    });
    await _future;
  }

  String _tabText(int index, InvestOrderListData data) {
    switch (index) {
      case 1:
        return '进行中(${data.runningCount})';
      case 2:
        return '已结束(${data.endedCount})';
      default:
        return '总订单(${data.totalCount})';
    }
  }

  String _fmtMoney(double value) => value.toStringAsFixed(2);

  String _fmtTime(DateTime? time) {
    if (time == null) return '--';
    final DateTime local = time.toLocal();
    String d(int v) => v.toString().padLeft(2, '0');
    return '${local.year}-${d(local.month)}-${d(local.day)} ${d(local.hour)}:${d(local.minute)}';
  }

  String _currencyUnit(String currency) => currency == 'USD' ? 'U' : '¥';

  String _currencyText(String currency) => currency == 'USD' ? 'USDT' : 'CNY';

  _OrderTheme _themeFor(String currency) {
    return const _OrderTheme(
      cardColors: <Color>[Color(0xCC101C30), Color(0xCC0E182A)],
      borderColor: Color(0x334CE3FF),
      statusColor: Color(0xFF39E6FF),
      valueColor: Color(0xFF9DB1C9),
    );
  }

  bool _isEnded(InvestOrderListItem item) {
    if (item.status == '1') {
      return true;
    }
    if (item.endTime == null) {
      return false;
    }
    return DateTime.now().isAfter(item.endTime!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0E2A),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          '我的投资',
          style: TextStyle(color: Color(0xFFEAF4FF), fontWeight: FontWeight.w700, fontSize: 20),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: TextButton(
              onPressed: () => Navigator.pushNamed(context, AppRouter.myInvestIncomes),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFFEAF4FF),
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
              child: const Text(
                '收益明细',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: <Widget>[
          _buildPageBackground(),
          SafeArea(
            child: FutureBuilder<InvestOrderListData>(
              future: _future,
              builder: (BuildContext context, AsyncSnapshot<InvestOrderListData> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Color(0xFF39E6FF)));
                }
                if (snapshot.hasError || !snapshot.hasData) {
                  return Center(
                    child: TextButton(
                      onPressed: _refresh,
                      child: const Text('加载失败，点击重试', style: TextStyle(color: Colors.white)),
                    ),
                  );
                }
                final InvestOrderListData data = snapshot.data!;
                final List<InvestOrderListItem> rows = data.list;
                return Column(
                  children: <Widget>[
                    const SizedBox(height: 4),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: _buildOverviewCard(data),
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: _buildTabs(data),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: _refresh,
                        color: const Color(0xFF39E6FF),
                        child: rows.isEmpty
                            ? ListView(
                                physics: const AlwaysScrollableScrollPhysics(),
                                padding: const EdgeInsets.fromLTRB(14, 10, 14, 18),
                                children: const <Widget>[
                                  SizedBox(height: 160),
                                  Center(
                                    child: Text('暂无投资订单', style: TextStyle(color: Color(0xFF9DB1C9))),
                                  ),
                                ],
                              )
                            : ListView.builder(
                                physics: const AlwaysScrollableScrollPhysics(),
                                padding: const EdgeInsets.fromLTRB(14, 8, 14, 18),
                                itemCount: rows.length,
                                itemBuilder: (_, int index) => _buildItem(rows[index]),
                              ),
                      ),
                    ),
                  ],
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

  Widget _buildOverviewCard(InvestOrderListData data) {
    final int total = data.totalCount;
    final int running = data.runningCount;
    final int ended = data.endedCount;
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: const Color(0xCC101C30),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x334CE3FF)),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x66000000),
            blurRadius: 22,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          Expanded(child: _overviewCell('总订单', '$total')),
          _divider(),
          Expanded(child: _overviewCell('进行中', '$running')),
          _divider(),
          Expanded(child: _overviewCell('已结束', '$ended')),
        ],
      ),
    );
  }

  Widget _overviewCell(String label, String value) {
    return Column(
      children: <Widget>[
        Text(
          label,
          style: const TextStyle(color: Color(0xFF9DB1C9), fontSize: 12, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(color: Color(0xFFEAF4FF), fontSize: 20, fontWeight: FontWeight.w800),
        ),
      ],
    );
  }

  Widget _divider() {
    return Container(
      width: 1,
      height: 30,
      color: const Color(0x336B7D9F),
    );
  }

  Widget _buildTabs(InvestOrderListData data) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: const Color(0xCC101C30),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0x334CE3FF)),
      ),
      child: Row(
        children: List<Widget>.generate(_tabs.length, (int index) {
          final bool active = index == _tabIndex;
          return Expanded(
            child: InkWell(
              onTap: () {
                if (_tabIndex == index) return;
                setState(() {
                  _tabIndex = index;
                  _future = InvestOrderApi.fetchOrderList(tab: _tabs[_tabIndex]);
                });
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    _tabText(index, data),
                    style: TextStyle(
                      color: active ? const Color(0xFFEFF4FF) : const Color(0xFF7B8AB2),
                      fontSize: 15,
                      fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 6),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    height: 3,
                    width: active ? 54 : 0,
                    decoration: BoxDecoration(
                      color: const Color(0xFF37DFFF),
                      boxShadow: active
                          ? const <BoxShadow>[
                              BoxShadow(
                                color: Color(0x8037DFFF),
                                blurRadius: 8,
                                spreadRadius: 1,
                              ),
                            ]
                          : null,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildItem(InvestOrderListItem item) {
    final _OrderStatusView statusView = _statusView(item);
    final String unit = _currencyUnit(item.currency);
    final _OrderTheme theme = _themeFor(item.currency);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: theme.cardColors,
        ),
        border: Border.all(color: theme.borderColor, width: 1),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Image.asset(
                AppImages.currencyBrand(item.currency, usePurpleVariant: true),
                width: 20,
                height: 20,
                fit: BoxFit.contain,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  item.productName.isEmpty ? '--' : item.productName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: statusView.bgColor.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: statusView.bgColor.withOpacity(0.55)),
                ),
                child: Text(
                  statusView.text,
                  style: TextStyle(color: statusView.bgColor, fontSize: 12, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _kv('单购利率', '${_fmtMoney(item.investAmount)} $unit'),
          _kv('预期收益', '${_fmtMoney(item.expectedIncome)} $unit'),
          _kv('投资期限', '${item.cycleDays}天'),
          _kv('投资利率', '${item.effectiveRate.toStringAsFixed(3)}%', valueColor: theme.valueColor),
          if (item.groupMode)
            _kv('拼团状态', _groupStatusText(item), valueFontSize: 16),
          if (item.groupMode && item.groupNo.isNotEmpty)
            _kv('拼团团号', item.groupNo, valueColor: const Color(0xFF9DB1C9), valueFontSize: 14),
          if (item.groupMode && item.groupStatus == '0')
            _kvWidget(
              '待成团时间',
              item.groupCountdownSeconds > 0
                  ? CountdownText(
                      key: ValueKey<String>('order_${item.orderNo}_${item.groupNo}'),
                      initialSeconds: item.groupCountdownSeconds,
                      finishedText: '状态更新中，请下拉刷新',
                      textStyle: const TextStyle(
                        color: Color(0xFFFFA500),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    )
                  : const Text(
                      '状态更新中，请下拉刷新',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        color: Color(0xFFFFA500),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          const SizedBox(height: 8),
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  '订单号 ${item.orderNo.isEmpty ? '--' : item.orderNo}',
                  style: const TextStyle(color: Color(0xFF7482AD), fontSize: 12, fontWeight: FontWeight.w500),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _fmtTime(item.createTime),
                style: const TextStyle(color: Color(0xFF7482AD), fontSize: 12, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Image.asset(
                AppImages.currencyBrand(item.currency, usePurpleVariant: true),
                width: 16,
                height: 16,
                fit: BoxFit.contain,
              ),
              const SizedBox(width: 6),
              Text(
                _currencyText(item.currency),
                style: const TextStyle(color: Color(0xFF8EA4C7), fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ],
      ),
    );
  }

  _OrderStatusView _statusView(InvestOrderListItem item) {
    final String status = item.status.trim();
    if (status == '2') {
      return const _OrderStatusView(
        text: '已赎回',
        bgColor: Color(0x668A7DFF),
      );
    }
    if (status == '1') {
      return const _OrderStatusView(
        text: '已结束',
        bgColor: Color(0x66FF6B6B),
      );
    }
    if (_isEnded(item)) {
      return const _OrderStatusView(
        text: '已结束',
        bgColor: Color(0x66FF6B6B),
      );
    }
    if (item.groupMode && item.groupStatus == '0') {
      return _OrderStatusView(
        text: '拼团中',
        bgColor: themeForStatus(item),
      );
    }
    return _OrderStatusView(
      text: '进行中',
      bgColor: themeForStatus(item),
    );
  }

  Color themeForStatus(InvestOrderListItem item) {
    return _themeFor(item.currency).statusColor;
  }

  Widget _kv(
    String k,
    String v, {
    Color valueColor = const Color(0xFF7B86AA),
    double valueFontSize = 17,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: <Widget>[
          SizedBox(
            width: 90,
            child: Text(k, style: const TextStyle(color: Color(0xFF717EA8), fontSize: 15)),
          ),
          Expanded(
            child: Text(
              v,
              textAlign: TextAlign.right,
              style: TextStyle(color: valueColor, fontSize: valueFontSize, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _kvWidget(String k, Widget valueWidget) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 90,
            child: Text(k, style: const TextStyle(color: Color(0xFF717EA8), fontSize: 15)),
          ),
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: valueWidget,
            ),
          ),
        ],
      ),
    );
  }

  String _groupStatusText(InvestOrderListItem item) {
    switch (item.groupStatus) {
      case '0':
        return '拼团中';
      case '1':
        return '已成团';
      case '2':
        return '拼团失败已退款';
      default:
        return '普通订单';
    }
  }
}

class _OrderTheme {
  const _OrderTheme({
    required this.cardColors,
    required this.borderColor,
    required this.statusColor,
    required this.valueColor,
  });

  final List<Color> cardColors;
  final Color borderColor;
  final Color statusColor;
  final Color valueColor;
}

class _OrderStatusView {
  const _OrderStatusView({
    required this.text,
    required this.bgColor,
  });

  final String text;
  final Color bgColor;
}
