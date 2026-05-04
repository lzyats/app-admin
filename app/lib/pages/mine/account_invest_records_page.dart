import 'package:flutter/material.dart';
import 'package:myapp/config/app_images.dart';
import 'package:myapp/request/invest_order_api.dart';

class AccountInvestRecordsPage extends StatefulWidget {
  const AccountInvestRecordsPage({super.key});

  @override
  State<AccountInvestRecordsPage> createState() => _AccountInvestRecordsPageState();
}

class _AccountInvestRecordsPageState extends State<AccountInvestRecordsPage> {
  late Future<List<InvestWalletLogItem>> _future;

  @override
  void initState() {
    super.initState();
    _future = InvestOrderApi.fetchWalletInvestLogs();
  }

  Future<void> _refresh() async {
    setState(() {
      _future = InvestOrderApi.fetchWalletInvestLogs();
    });
    await _future;
  }

  String _time(DateTime? t) {
    if (t == null) return '--';
    final DateTime local = t.toLocal();
    String d(int v) => v.toString().padLeft(2, '0');
    return '${local.year}-${d(local.month)}-${d(local.day)} ${d(local.hour)}:${d(local.minute)}';
  }

  String _typeText(String type) {
    switch (type.toLowerCase()) {
      case 'redeem':
        return '赎回';
      case 'profit':
        return '收益';
      default:
        return '投资';
    }
  }

  bool _isPositiveFlow(String type) {
    final String t = type.toLowerCase();
    return t == 'redeem' || t == 'profit';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1220),
      appBar: AppBar(
        title: const Text('投资记录'),
        backgroundColor: const Color(0xFF0A1220),
        elevation: 0,
      ),
      body: FutureBuilder<List<InvestWalletLogItem>>(
        future: _future,
        builder: (_, AsyncSnapshot<List<InvestWalletLogItem>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF39E6FF)));
          }
          if (snapshot.hasError) {
            return Center(
              child: TextButton(onPressed: _refresh, child: const Text('加载失败，点击重试')),
            );
          }
          final List<InvestWalletLogItem> rows = snapshot.data ?? <InvestWalletLogItem>[];
          return RefreshIndicator(
            onRefresh: _refresh,
            child: rows.isEmpty
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: const <Widget>[
                      SizedBox(height: 120),
                      Center(child: Text('暂无记录', style: TextStyle(color: Color(0xFF9DB1C9)))),
                    ],
                  )
                : ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    itemCount: rows.length,
                    itemBuilder: (_, int i) {
                      final InvestWalletLogItem item = rows[i];
                      final bool positive = _isPositiveFlow(item.type);
                      final Color amountColor = positive ? const Color(0xFF38FFB3) : const Color(0xFFFF6B6B);
                      final String amount = '${positive ? '+' : '-'}${item.amount.toStringAsFixed(2)} ${item.currencyType}';
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xCC101C30),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0x334CE3FF)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                Expanded(
                                  child: Text(
                                    _typeText(item.type),
                                    style: const TextStyle(
                                      color: Color(0xFFE9F3FF),
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    Image.asset(
                                      AppImages.currencyBrand(item.currencyType),
                                      width: 16,
                                      height: 16,
                                      fit: BoxFit.contain,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      amount,
                                      style: TextStyle(
                                        color: amountColor,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text('订单号: ${item.orderNo.isEmpty ? '--' : item.orderNo}',
                                style: const TextStyle(color: Color(0xFF9DB1C9), fontSize: 12)),
                            const SizedBox(height: 4),
                            Text('时间: ${_time(item.createTime)}',
                                style: const TextStyle(color: Color(0xFF9DB1C9), fontSize: 12)),
                            if (item.remark.trim().isNotEmpty) ...<Widget>[
                              const SizedBox(height: 4),
                              Text('备注: ${item.remark.trim()}',
                                  style: const TextStyle(color: Color(0xFF9DB1C9), fontSize: 12)),
                            ],
                          ],
                        ),
                      );
                    },
                  ),
          );
        },
      ),
    );
  }
}
