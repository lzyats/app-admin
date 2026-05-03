import 'package:flutter/material.dart';
import 'package:myapp/config/app_localizations.dart';
import 'package:myapp/request/miner_api.dart';

class MinerRewardLogsPage extends StatefulWidget {
  const MinerRewardLogsPage({super.key});

  @override
  State<MinerRewardLogsPage> createState() => _MinerRewardLogsPageState();
}

class _MinerRewardLogsPageState extends State<MinerRewardLogsPage> {
  bool _loading = true;
  List<dynamic> _logs = <dynamic>[];
  Map<String, dynamic> _overview = <String, dynamic>{};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final List<dynamic> logs = await MinerApi.fetchRewardLogs();
      final Map<String, dynamic> overview = await MinerApi.fetchOverview();
      if (!mounted) return;
      setState(() {
        _logs = logs;
        _overview = overview;
      });
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

  Map<String, dynamic>? get _run =>
      (_overview['run'] as Map?)?.cast<String, dynamic>();

  DateTime? _parseDateTime(dynamic v) {
    if (v == null) return null;
    final String s = (v ?? '').toString().trim();
    if (s.isEmpty) return null;
    final String normalized =
        s.contains(' ') && !s.contains('T') ? s.replaceFirst(' ', 'T') : s;
    return DateTime.tryParse(normalized);
  }

  double _estimateProduced(Map<String, dynamic>? run, double cycleWag) {
    if (run == null || cycleWag <= 0) return 0;
    final String status = _str(run['runStatus']).trim();
    if (status != '0') {
      return _num(run['producedWag']);
    }
    final DateTime? start = _parseDateTime(run['startTime']);
    final DateTime? end = _parseDateTime(run['cycleEndTime']);
    if (start == null || end == null) return 0;
    final int totalMs = end.millisecondsSinceEpoch - start.millisecondsSinceEpoch;
    if (totalMs <= 0) return 0;
    final int nowMs = DateTime.now().millisecondsSinceEpoch;
    final int elapsedMs =
        (nowMs - start.millisecondsSinceEpoch).clamp(0, totalMs);
    return cycleWag * (elapsedMs / totalMs);
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations i18n = AppLocalizations.of(context);
    final bool isZh = i18n.locale.languageCode == 'zh';
    return Scaffold(
      appBar: AppBar(
        title: Text(isZh ? '矿机明细' : 'Reward Logs'),
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
                  itemCount: _logs.length + 1,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (BuildContext ctx, int i) {
                    if (i == 0) {
                      return _buildPendingCard(i18n);
                    }
                    final Map<String, dynamic> row =
                        (_logs[i - 1] as Map?)?.cast<String, dynamic>() ??
                            <String, dynamic>{};
                    final String action = _str(row['action']);
                    final double wag = _num(row['wagAmount']);
                    final String time = _str(row['createTime']);
                    return Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF101533),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0x332A78FF)),
                      ),
                      child: Row(
                        children: <Widget>[
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: const Color(0xFF2A78FF).withOpacity(0.18),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.bolt, color: Color(0xFF9CCBFF)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  action.isEmpty ? '-' : action,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  time,
                                  style: const TextStyle(
                                    color: Color(0xFF6C7BA5),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '${wag.toStringAsFixed(2)} WAG',
                            style: const TextStyle(
                              color: Color(0xFF38FFB3),
                              fontWeight: FontWeight.w700,
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

  Widget _buildPendingCard(AppLocalizations i18n) {
    final bool isZh = i18n.locale.languageCode == 'zh';
    final Map<String, dynamic>? run = _run;
    final String status = _str(run?['runStatus']).trim();
    final double cycle = _num(run?['cycleWag']);
    final double produced = _estimateProduced(run, cycle);
    final double pct = cycle <= 0 ? 0 : (produced / cycle).clamp(0, 1);

    final String title = isZh ? '待领取预估收益' : 'Pending (Estimated)';
    final String sub = isZh
        ? '每10分钟更新，仅用于查看；满24小时后才入账并可兑换'
        : 'Updated every 10 minutes. Exchangeable only after 24 hours.';
    final String value = cycle > 0
        ? '${produced.toStringAsFixed(2)} / ${cycle.toStringAsFixed(2)} WAG'
        : '${produced.toStringAsFixed(2)} WAG';

    final bool show = status == '0' || status == '1' || produced > 0;
    if (!show) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF101533),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0x332A78FF)),
        ),
        child: Text(
          isZh ? '暂无运行数据' : 'No running data',
          style: const TextStyle(color: Color(0xFF9DB1C9)),
        ),
      );
    }

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
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              minHeight: 10,
              value: pct,
              backgroundColor: const Color(0xFF0D1230),
              color: const Color(0xFF2A78FF),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF38FFB3),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            sub,
            style: const TextStyle(color: Color(0xFF6C7BA5), fontSize: 12),
          ),
        ],
      ),
    );
  }
}
