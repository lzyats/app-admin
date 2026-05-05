import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:myapp/config/app_localizations.dart';
import 'package:myapp/request/invest_order_api.dart';
import 'package:myapp/widgets/countdown_text.dart';

class MyGroupPage extends StatefulWidget {
  const MyGroupPage({super.key});

  @override
  State<MyGroupPage> createState() => _MyGroupPageState();
}

class _MyGroupPageState extends State<MyGroupPage> {
  bool _loading = true;
  String _error = '';
  List<InvestOrderListItem> _groups = const <InvestOrderListItem>[];
  AppLocalizations get i18n => AppLocalizations.of(context)!;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = '';
    });
    try {
      final InvestOrderListData data = await InvestOrderApi.fetchOrderList(tab: 'total');
      final List<InvestOrderListItem> rows = data.list
          .where((InvestOrderListItem e) => e.groupMode || e.groupNo.trim().isNotEmpty)
          .toList()
        ..sort((InvestOrderListItem a, InvestOrderListItem b) {
          final DateTime at = a.createTime ?? DateTime.fromMillisecondsSinceEpoch(0);
          final DateTime bt = b.createTime ?? DateTime.fromMillisecondsSinceEpoch(0);
          return bt.compareTo(at);
        });
      setState(() {
        _groups = rows;
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1220),
      appBar: AppBar(
        title: Text(i18n.t('myGroupTitle')),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF39E6FF)),
      );
    }
    if (_error.isNotEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: <Widget>[
          const SizedBox(height: 120),
          Center(
            child: Text(_error, style: const TextStyle(color: Color(0xFFE9F3FF))),
          ),
          const SizedBox(height: 14),
          Center(
            child: FilledButton(onPressed: _load, child: Text(i18n.t('signRetry'))),
          ),
        ],
      );
    }
    if (_groups.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: <Widget>[
          SizedBox(height: 120),
          Center(
            child: Text(i18n.t('myGroupEmpty'), style: const TextStyle(color: Color(0xFF9DB1C9), fontSize: 16)),
          ),
        ],
      );
    }
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 16),
      children: <Widget>[
        _buildSummaryCard(),
        const SizedBox(height: 10),
        ..._groups.map(_buildGroupCard),
      ],
    );
  }

  Widget _buildSummaryCard() {
    final int running = _groups.where((InvestOrderListItem e) => e.groupStatus == '0').length;
    final int success = _groups.where((InvestOrderListItem e) => e.groupStatus == '1').length;
    final int failed = _groups.where((InvestOrderListItem e) => e.groupStatus == '2').length;
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      decoration: BoxDecoration(
        color: const Color(0xCC101C30),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x334CE3FF)),
      ),
      child: Row(
        children: <Widget>[
          _summaryCell(i18n.t('myGroupTotal'), _groups.length.toString()),
          _summaryCell(i18n.t('grouping'), running.toString()),
          _summaryCell(i18n.t('groupSuccess'), success.toString()),
          _summaryCell(i18n.t('failed'), failed.toString()),
        ],
      ),
    );
  }

  Widget _summaryCell(String label, String value) {
    return Expanded(
      child: Column(
        children: <Widget>[
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF39E6FF),
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: Color(0xFF9DB1C9), fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildGroupCard(InvestOrderListItem item) {
    final String groupNo = item.groupNo.trim();
    final String groupStatusLabel = _groupStatusLabel(item.groupStatus);
    final Color groupStatusColor = _groupStatusColor(item.groupStatus);
    final String createTime = item.createTime == null ? '--' : _fmtDateTime(item.createTime!);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      decoration: BoxDecoration(
        color: const Color(0xCC101C30),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0x334CE3FF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  item.productName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: groupStatusColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: groupStatusColor.withOpacity(0.6)),
                ),
                child: Text(
                  groupStatusLabel,
                  style: TextStyle(color: groupStatusColor, fontSize: 12, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text('${i18n.t('groupNo')}：${groupNo.isEmpty ? '--' : groupNo}',
              style: const TextStyle(color: Color(0xFFE9F3FF), fontSize: 13)),
          const SizedBox(height: 4),
          Text('${i18n.t('purchaseAmount')}：${item.investAmount.toStringAsFixed(2)} ${item.currency}',
              style: const TextStyle(color: Color(0xFF9DB1C9), fontSize: 13)),
          const SizedBox(height: 4),
          Text('${i18n.t('orderTime')}：$createTime', style: const TextStyle(color: Color(0xFF9DB1C9), fontSize: 13)),
          if (item.groupStatus == '0') ...<Widget>[
            const SizedBox(height: 4),
            if (item.groupCountdownSeconds > 0)
              CountdownText(
                key: ValueKey<String>('${item.orderNo}_${item.groupNo}'),
                initialSeconds: item.groupCountdownSeconds,
                prefix: '${i18n.t('groupRemainingTime')}：',
                finishedText: i18n.t('groupStatusUpdating'),
                textStyle: const TextStyle(color: Color(0xFFFFA500), fontSize: 13),
              )
            else
              Text(
                i18n.t('groupStatusUpdating'),
                style: TextStyle(color: Color(0xFFFFA500), fontSize: 13),
              ),
          ],
          const SizedBox(height: 10),
          Row(
            children: <Widget>[
              Expanded(
                child: OutlinedButton(
                  onPressed: groupNo.isEmpty ? null : () => _copyGroupNo(groupNo),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF2E8FFF)),
                    foregroundColor: const Color(0xFF39E6FF),
                  ),
                  child: Text(i18n.t('copyGroupNo')),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: groupNo.isEmpty ? null : () => _copyShareText(item),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1F3CF5),
                    foregroundColor: const Color(0xFF39E6FF),
                  ),
                  child: Text(i18n.t('copyShareCopy')),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _copyGroupNo(String groupNo) async {
    await Clipboard.setData(ClipboardData(text: groupNo));
    _toast('${i18n.t('groupNoCopied')}：$groupNo', success: true);
  }

  Future<void> _copyShareText(InvestOrderListItem item) async {
    final String groupNo = item.groupNo.trim();
    final String text = i18n
        .t('groupShareTemplate')
        .replaceAll('{productName}', item.productName)
        .replaceAll('{groupNo}', groupNo);
    await Clipboard.setData(ClipboardData(text: text));
    _toast(i18n.t('groupShareCopied'), success: true);
  }

  void _toast(String text, {bool success = false}) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        backgroundColor: success ? const Color(0xFF38FFB3) : const Color(0xFFFFA500),
      ),
    );
  }

  String _groupStatusLabel(String status) {
    switch (status) {
      case '0':
        return i18n.t('grouping');
      case '1':
        return i18n.t('groupSuccess');
      case '2':
        return i18n.t('failed');
      default:
        return i18n.t('unknown');
    }
  }

  Color _groupStatusColor(String status) {
    switch (status) {
      case '0':
        return const Color(0xFFFFA500);
      case '1':
        return const Color(0xFF38FFB3);
      case '2':
        return const Color(0xFFFF6B6B);
      default:
        return const Color(0xFF9DB1C9);
    }
  }

  String _fmtDateTime(DateTime dt) {
    final DateTime t = dt.toLocal();
    return '${t.year}-${t.month.toString().padLeft(2, '0')}-${t.day.toString().padLeft(2, '0')} '
        '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
  }
}
