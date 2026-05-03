import 'package:flutter/material.dart';
import 'package:myapp/config/app_localizations.dart';
import 'package:myapp/request/miner_api.dart';

class MinerExchangeLogsPage extends StatefulWidget {
  const MinerExchangeLogsPage({super.key});

  @override
  State<MinerExchangeLogsPage> createState() => _MinerExchangeLogsPageState();
}

class _MinerExchangeLogsPageState extends State<MinerExchangeLogsPage> {
  bool _loading = true;
  List<dynamic> _logs = <dynamic>[];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final List<dynamic> logs = await MinerApi.fetchExchangeLogs();
      if (!mounted) return;
      setState(() => _logs = logs);
    } finally {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  String _str(dynamic v) => (v ?? '').toString();

  double _num(dynamic v) {
    if (v is num) return v.toDouble();
    return double.tryParse('${v ?? 0}') ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations i18n = AppLocalizations.of(context);
    final bool isZh = i18n.locale.languageCode == 'zh';
    return Scaffold(
      appBar: AppBar(
        title: Text(isZh ? '兑换明细' : 'Exchange Logs'),
        backgroundColor: const Color(0xFF070A1E),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[Color(0xFF05071B), Color(0xFF020311)],
          ),
        ),
        child: _loading
            ? Center(
                child: Text(
                  isZh ? '加载中...' : 'Loading...',
                  style: const TextStyle(color: Color(0xFF9DB1C9)),
                ),
              )
            : RefreshIndicator(
                onRefresh: _load,
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _logs.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (BuildContext ctx, int i) {
                    final Map<String, dynamic> row =
                        (_logs[i] as Map?)?.cast<String, dynamic>() ??
                            <String, dynamic>{};
                    final String requestNo = _str(row['requestNo']);
                    final double wag = _num(row['wagAmount']);
                    final double target = _num(row['targetAmount']);
                    final String currency = _str(row['targetCurrency']);
                    final String status = _str(row['status']);
                    final String time = _str(row['createTime']);
                    return Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF101533),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0x332A78FF)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Expanded(
                                child: Text(
                                  requestNo.isEmpty ? '-' : requestNo,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: status == '0'
                                      ? const Color(0xFF38FFB3).withOpacity(0.18)
                                      : const Color(0xFFFF6B6B).withOpacity(0.18),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  status == '0'
                                      ? (isZh ? '成功' : 'Success')
                                      : (isZh ? '失败' : 'Failed'),
                                  style: TextStyle(
                                    color: status == '0'
                                        ? const Color(0xFF38FFB3)
                                        : const Color(0xFFFF6B6B),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: <Widget>[
                              Expanded(
                                child: Text(
                                  '${wag.toStringAsFixed(2)} WAG',
                                  style: const TextStyle(
                                    color: Color(0xFF9DB1C9),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Text(
                                '${target.toStringAsFixed(2)} $currency',
                                style: const TextStyle(
                                  color: Color(0xFF39E6FF),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            time,
                            style: const TextStyle(
                              color: Color(0xFF6C7BA5),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
      ),
    );
  }
}
