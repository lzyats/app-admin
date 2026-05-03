import 'package:flutter/material.dart';

import 'package:myapp/config/app_localizations.dart';
import 'package:myapp/request/yebao_api.dart';

class YebaoIncomePage extends StatefulWidget {
  const YebaoIncomePage({super.key});

  @override
  State<YebaoIncomePage> createState() => _YebaoIncomePageState();
}

class _YebaoIncomePageState extends State<YebaoIncomePage> {
  late Future<List<YebaoIncomeLogItem>> _future;

  @override
  void initState() {
    super.initState();
    _future = YebaoApi.fetchMyIncomeLogs();
  }

  Future<void> _refresh() async {
    setState(() {
      _future = YebaoApi.fetchMyIncomeLogs();
    });
    await _future;
  }

  String _text(AppLocalizations i18n, String key) {
    return i18n.t(key);
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

  @override
  Widget build(BuildContext context) {
    final AppLocalizations i18n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: const Color(0xFF09072A),
      appBar: AppBar(
        title: Text(_text(i18n, 'yebaoRecentIncome')),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: FutureBuilder<List<YebaoIncomeLogItem>>(
        future: _future,
        builder: (BuildContext context, AsyncSnapshot<List<YebaoIncomeLogItem>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF39E6FF)),
            );
          }
          if (snapshot.hasError) {
            return _buildErrorState(i18n);
          }
          final List<YebaoIncomeLogItem> incomes = snapshot.data ?? <YebaoIncomeLogItem>[];
          return RefreshIndicator(
            color: const Color(0xFF39E6FF),
            onRefresh: _refresh,
            child: incomes.isEmpty
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(24),
                    children: <Widget>[
                      const SizedBox(height: 120),
                      const Icon(Icons.payments_outlined, color: Color(0xFF39E6FF), size: 56),
                      const SizedBox(height: 12),
                      Text(
                        _text(i18n, 'yebaoNoIncomeLogs'),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xFFEAF5FF),
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _text(i18n, 'yebaoIncomePageHint'),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xFF9DB1C9),
                          fontSize: 13,
                          height: 1.5,
                        ),
                      ),
                    ],
                  )
                : ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
                    itemBuilder: (BuildContext context, int index) {
                      final YebaoIncomeLogItem item = incomes[index];
                      return Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xCC101C30),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: const Color(0x334CE3FF)),
                        ),
                        child: Row(
                          children: <Widget>[
                            const Icon(Icons.payments_outlined, color: Color(0xFFE2FF59), size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    item.orderNo.isNotEmpty ? item.orderNo : '--',
                                    style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${item.settleDays} ${_text(i18n, 'yebaoDayUnit')} / ${_dateTime(item.settleTime)}',
                                    style: const TextStyle(color: Color(0xFF9DB1C9), fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '+${_money(item.incomeAmount)}',
                              style: const TextStyle(
                                color: Color(0xFFFFA500),
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    separatorBuilder: (BuildContext context, int index) => const SizedBox(height: 10),
                    itemCount: incomes.length,
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
        const Icon(Icons.payments_outlined, color: Color(0xFF39E6FF), size: 56),
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
}
