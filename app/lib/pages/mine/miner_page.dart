import 'dart:math';

import 'package:flutter/material.dart';
import 'package:myapp/config/app_localizations.dart';
import 'package:myapp/request/miner_api.dart';
import 'package:myapp/request/api_client.dart';
import 'package:myapp/request/api_exception.dart';
import 'package:myapp/routers/app_router.dart';

class MinerPage extends StatefulWidget {
  const MinerPage({super.key});

  @override
  State<MinerPage> createState() => _MinerPageState();
}

class _MinerPageState extends State<MinerPage> {
  Map<String, dynamic> _overview = <String, dynamic>{};
  bool _loading = true;
  bool _autoRedirectedToClaim = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
    });
    try {
      final Map<String, dynamic> data = await MinerApi.fetchOverview();
      if (!mounted) return;
      setState(() {
        _overview = data;
      });
      final bool hasCurrentMiner =
          (_overview['currentMiner'] as Map?)?.isNotEmpty == true;
      if (!hasCurrentMiner && !_autoRedirectedToClaim) {
        _autoRedirectedToClaim = true;
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          if (!mounted) return;
          await Navigator.pushNamed(context, AppRouter.minerClaim);
          if (!mounted) return;
          await _load();
        });
      }
    } finally {
      if (!mounted) return;
      setState(() {
        _loading = false;
      });
    }
  }

  double _num(dynamic v) {
    if (v is num) return v.toDouble();
    return double.tryParse('${v ?? 0}') ?? 0;
  }

  String _str(dynamic v) => (v ?? '').toString();

  Map<String, dynamic>? get _currentMiner =>
      (_overview['currentMiner'] as Map?)?.cast<String, dynamic>();

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

  Future<void> _openExchange() async {
    final TextEditingController controller = TextEditingController();
    final AppLocalizations i18n = AppLocalizations.of(context);
    final bool isZh = i18n.locale.languageCode == 'zh';
    final bool? ok = await showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: Text(isZh ? 'WAG兑换' : 'WAG Exchange'),
          content: TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              hintText: isZh ? '请输入WAG数量' : 'Enter WAG amount',
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(isZh ? '取消' : 'Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(isZh ? '确认' : 'Confirm'),
            ),
          ],
        );
      },
    );
    if (ok != true) return;

    final double wagAmount = double.tryParse(controller.text.trim()) ?? 0;
    if (wagAmount <= 0) return;
    final String requestNo = _buildRequestNo();
    try {
      await MinerApi.exchange(requestNo: requestNo, wagAmount: wagAmount);
      await _load();
    } catch (e) {
      if (!mounted) return;
      final String msg = _errorText(e, isZh: isZh);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg)),
      );
    }
  }

  String _buildRequestNo() {
    final int ts = DateTime.now().millisecondsSinceEpoch;
    final int rnd = Random().nextInt(900000) + 100000;
    return 'WAG$ts$rnd';
  }

  Future<void> _collectIfNeeded() async {
    await MinerApi.collect();
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations i18n = AppLocalizations.of(context);
    final bool isZh = i18n.locale.languageCode == 'zh';
    final double wag = _num(_overview['availableWag']);
    final double rate = _num(_overview['wagToUsdRate']);
    final String targetCurrency = _str(_overview['targetCurrency']).isEmpty
        ? 'USD'
        : _str(_overview['targetCurrency']);

    final Map<String, dynamic>? miner = _currentMiner;
    final Map<String, dynamic>? run = _run;
    final bool hasMiner = miner != null && (miner['minerId'] != null);
    final String minerName = _str(miner?['minerName']);
    final double wagPerDay = _num(miner?['wagPerDay']);
    final double totalOutput = _num(miner?['totalOutputWag']);
    final String runStatus = _str(run?['runStatus']);
    final double cycleWag = _num(run?['cycleWag']);
    final double producedWag = _estimateProduced(run, cycleWag);
    final bool waitingCollect = runStatus == '1';
    final String statusText = !hasMiner
        ? (isZh ? '未领取' : 'Not Claimed')
        : (waitingCollect ? (isZh ? '待领取' : 'To Collect') : (isZh ? '运行中' : 'Running'));

    return Scaffold(
      appBar: AppBar(
        title: Text(isZh ? '我的节点' : 'My Node'),
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
        child: RefreshIndicator(
          onRefresh: _load,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: <Widget>[
              _buildTopStats(i18n, wag, rate),
              const SizedBox(height: 14),
              _buildMinerCard(
                i18n: i18n,
                isZh: isZh,
                hasMiner: hasMiner,
                minerName: minerName,
                statusText: statusText,
                coverImage: _str(miner?['coverImage']),
                wagPerDay: wagPerDay,
                totalOutput: totalOutput,
                producedWag: producedWag,
                cycleWag: cycleWag,
                waitingCollect: waitingCollect,
                onCollect: _collectIfNeeded,
              ),
              const SizedBox(height: 14),
              Row(
                children: <Widget>[
                  Expanded(
                    child: _buildQuickAction(
                      label: isZh ? '矿机明细' : 'Reward Logs',
                      icon: Icons.storage_outlined,
                      onTap: () {
                        Navigator.pushNamed(context, AppRouter.minerRewardLogs);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildQuickAction(
                      label: isZh ? '兑换明细' : 'Exchange Logs',
                      icon: Icons.swap_horiz,
                      onTap: () {
                        Navigator.pushNamed(context, AppRouter.minerExchangeLogs);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Row(
                children: <Widget>[
                  Expanded(
                    child: _buildBottomButton(
                      label: isZh ? '更换节点' : 'Change Node',
                      colors: const <Color>[Color(0xFF2BB673), Color(0xFF1D9B6B)],
                      onTap: () async {
                        await Navigator.pushNamed(
                            context, AppRouter.minerClaim);
                        await _load();
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildBottomButton(
                      label: isZh
                          ? 'WAG转换$targetCurrency'
                          : 'WAG to $targetCurrency',
                      colors: const <Color>[Color(0xFF355CFF), Color(0xFF1E3BFF)],
                      onTap: () async {
                        if (!hasMiner) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(isZh ? '请先领取矿机' : 'Please claim a miner first')),
                          );
                          return;
                        }
                        if (wag <= 0) {
                          final String hint = producedWag > 0
                              ? (isZh ? '未满24小时，收益为待领取，暂不可兑换' : 'Not reached 24h yet. Earnings are pending and not exchangeable.')
                              : (isZh ? '暂无可兑换WAG' : 'No WAG available');
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(hint)),
                          );
                          return;
                        }
                        await _openExchange();
                      },
                    ),
                  ),
                ],
              ),
              if (_loading)
                Padding(
                  padding: const EdgeInsets.only(top: 18),
                  child: Center(
                    child: Text(
                      isZh ? '加载中...' : 'Loading...',
                      style: const TextStyle(color: Color(0xFF9DB1C9)),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopStats(AppLocalizations i18n, double wag, double rate) {
    final bool isZh = i18n.locale.languageCode == 'zh';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF101533),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0x332A78FF)),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: _statBlock(
              title: isZh ? '我的WAG数' : 'My WAG',
              value: '${wag.toStringAsFixed(2)} WAG',
            ),
          ),
          Container(width: 1, height: 42, color: const Color(0x331B2A55)),
          Expanded(
            child: _statBlock(
              title: isZh ? 'WAG兑换率' : 'WAG Rate',
              value: rate.toStringAsFixed(6),
              alignRight: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statBlock({
    required String title,
    required String value,
    bool alignRight = false,
  }) {
    return Column(
      crossAxisAlignment:
          alignRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          title,
          style: const TextStyle(color: Color(0xFF6C7BA5), fontSize: 12),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildMinerCard({
    required AppLocalizations i18n,
    required bool isZh,
    required bool hasMiner,
    required String minerName,
    required String statusText,
    required String coverImage,
    required double wagPerDay,
    required double totalOutput,
    required double producedWag,
    required double cycleWag,
    required bool waitingCollect,
    required Future<void> Function() onCollect,
  }) {
    final String? imageUrl =
        coverImage.isEmpty ? null : ApiClient.instance.resolveImageUrl(coverImage);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1230),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0x332A78FF)),
      ),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  minerName.isEmpty ? (isZh ? '未领取节点' : 'No Node') : minerName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF2A78FF).withOpacity(0.25),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF2A78FF)),
                ),
                child: Text(
                  statusText,
                  style: const TextStyle(
                    color: Color(0xFF9CCBFF),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildMinerSquareImage(imageUrl),
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  '${isZh ? '日产出' : 'Daily'}: ${wagPerDay.toStringAsFixed(2)}WAG',
                  style: const TextStyle(color: Color(0xFF9DB1C9)),
                ),
              ),
              Expanded(
                child: Text(
                  '${isZh ? '累计产出' : 'Total'}: ${totalOutput.toStringAsFixed(2)}WAG',
                  textAlign: TextAlign.end,
                  style: const TextStyle(color: Color(0xFF9DB1C9)),
                ),
              ),
            ],
          ),
          if (hasMiner && !waitingCollect && producedWag > 0) ...<Widget>[
            const SizedBox(height: 10),
            Text(
              cycleWag > 0
                  ? '${isZh ? '待领取收益' : 'Pending'}: ${producedWag.toStringAsFixed(4)} / ${cycleWag.toStringAsFixed(4)} WAG'
                  : '${isZh ? '待领取收益' : 'Pending'}: ${producedWag.toStringAsFixed(4)} WAG',
              style: const TextStyle(color: Color(0xFF6C7BA5), fontSize: 12),
            ),
          ],
          if (waitingCollect) ...<Widget>[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF38FFB3),
                  foregroundColor: const Color(0xFF08121F),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: onCollect,
                child: Text(isZh ? '领取收益' : 'Collect'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _errorText(Object e, {required bool isZh}) {
    if (e is ApiException) {
      final String raw = e.userMessage.trim();
      if (raw.isNotEmpty) {
        final String firstLine = raw.split('\n').first.trim();
        if (firstLine.isNotEmpty) return firstLine;
      }
      return isZh ? '请求失败' : 'Request failed';
    }
    final String s = e.toString().trim();
    return s.isEmpty ? (isZh ? '请求失败' : 'Request failed') : s;
  }

  Widget _buildMinerSquareImage(String? imageUrl) {
    const double size = 140;
    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: size,
          height: size,
          color: const Color(0xFF0A0E26),
          child: imageUrl == null
              ? _minerSquarePlaceholder(size)
              : Image.network(
                  imageUrl,
                  width: size,
                  height: size,
                  fit: BoxFit.cover,
                  alignment: Alignment.center,
                  errorBuilder: (_, __, ___) => _minerSquarePlaceholder(size),
                ),
        ),
      ),
    );
  }

  Widget _minerSquarePlaceholder(double size) {
    return SizedBox(
      height: size,
      width: size,
      child: const Center(
        child: Icon(Icons.memory, color: Color(0xFF2A78FF), size: 52),
      ),
    );
  }

  Widget _buildQuickAction({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF101533),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0x332A78FF)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(icon, color: const Color(0xFF9DB1C9)),
            const SizedBox(width: 10),
            Text(label, style: const TextStyle(color: Color(0xFF9DB1C9))),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomButton({
    required String label,
    required List<Color> colors,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      height: 48,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            gradient: LinearGradient(colors: colors),
          ),
          child: Center(
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
