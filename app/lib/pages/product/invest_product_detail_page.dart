import 'package:flutter/material.dart';
import 'package:myapp/config/app_images.dart';
import 'package:myapp/request/api_client.dart';
import 'package:myapp/request/invest_product_api.dart';
import 'package:myapp/routers/app_router.dart';
import 'package:myapp/widgets/app_network_image.dart';

class InvestProductDetailPage extends StatefulWidget {
  const InvestProductDetailPage({
    super.key,
    required this.productId,
  });

  final int productId;

  @override
  State<InvestProductDetailPage> createState() => _InvestProductDetailPageState();
}

class _InvestProductDetailPageState extends State<InvestProductDetailPage> {
  late Future<InvestProductItem> _future;
  int _tabIndex = 0;

  @override
  void initState() {
    super.initState();
    _future = InvestProductApi.fetchProductDetail(widget.productId);
  }

  Future<void> _refresh() async {
    setState(() {
      _future = InvestProductApi.fetchProductDetail(widget.productId);
    });
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF080A2D),
      appBar: AppBar(
        title: const Text('产品详情'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: FutureBuilder<InvestProductItem>(
        future: _future,
        builder: (BuildContext context, AsyncSnapshot<InvestProductItem> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF39E6FF)));
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return Center(
              child: FilledButton(
                onPressed: _refresh,
                child: const Text('重试'),
              ),
            );
          }
          final InvestProductItem item = snapshot.data!;
          return RefreshIndicator(
            onRefresh: _refresh,
            color: const Color(0xFF39E6FF),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 16),
              children: <Widget>[
                _buildTopCard(item),
                const SizedBox(height: 12),
                _buildTabs(),
                const SizedBox(height: 8),
                if (_tabIndex == 0) _buildDetailTab(item) else _buildIncomeTab(item),
                const SizedBox(height: 16),
                _buildBottomButton(item),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTopCard(InvestProductItem item) {
    final String progress = '${item.progressPercent.toStringAsFixed(3)}%';
    final double remainingAmount = _calcRemainingAmount(item);
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[Color(0xFF171C59), Color(0xFF171444)],
        ),
        border: Border.all(color: const Color(0x224CE3FF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  item.productName,
                  style: const TextStyle(color: Colors.white, fontSize: 40 / 2, fontWeight: FontWeight.w700),
                ),
              ),
              if (item.coverImage.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: AppNetworkImage(
                    src: ApiClient.instance.resolveImageUrl(item.coverImage) ?? item.coverImage,
                    width: 44,
                    height: 44,
                    fit: BoxFit.cover,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: <Widget>[
              Expanded(
                child: _buildBigData('${item.singleRate.toStringAsFixed(2)}%', '单购利率'),
              ),
                const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _buildInlineMetric('投资周期', '${item.cycleDays}天'),
                    const SizedBox(height: 8),
                    _buildInlineMetric('剩余金额', _fmt(remainingAmount)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              if (item.riskTag.isNotEmpty) _chip(item.riskTag),
              _chip('${_fmt(item.minInvestAmount)}元起投'),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              const Text('进度:', style: TextStyle(color: Color(0xFF8C94BC), fontSize: 16)),
              const SizedBox(width: 8),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: (item.progressPercent.clamp(0, 100)) / 100,
                    minHeight: 10,
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF38DFFF)),
                    backgroundColor: const Color(0xFF2B315E),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(progress, style: const TextStyle(color: Color(0xFF8C94BC), fontSize: 16)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBigData(String value, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFF35DAFF),
            fontSize: 40 / 2,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(color: Color(0xFF7E89B5), fontSize: 14)),
      ],
    );
  }

  Widget _buildInlineMetric(String label, String value) {
    return Row(
      children: <Widget>[
        Text(
          label,
          style: const TextStyle(color: Color(0xFF7E89B5), fontSize: 14),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF35DAFF),
              fontSize: 34 / 2,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _chip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFFF5A5A),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700),
      ),
    );
  }

  Widget _buildTabs() {
    return Row(
      children: <Widget>[
        Expanded(child: _tabButton('产品详情', 0)),
        const SizedBox(width: 12),
        Expanded(child: _tabButton('收益计算', 1)),
      ],
    );
  }

  Widget _tabButton(String text, int index) {
    final bool selected = _tabIndex == index;
    return InkWell(
      onTap: () => setState(() => _tabIndex = index),
      child: Container(
        height: 48,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: selected ? const Color(0xFF2E8FFF) : Colors.transparent),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: selected ? const Color(0xFF35DAFF) : const Color(0xFF8B96C3),
            fontSize: 36 / 2,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildDetailTab(InvestProductItem item) {
    final bool shareMode = item.investMode != 'AMOUNT';
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
      decoration: BoxDecoration(
        color: const Color(0xFF141B52),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0x224CE3FF)),
      ),
      child: Column(
        children: <Widget>[
          _kv('项目名', item.productName),
          _kv('项目进度', '${item.progressPercent.toStringAsFixed(4)}%'),
          if (shareMode) ...<Widget>[
            _kv('总份数', '${item.totalShares}'),
            _kv('已投份数', '${item.soldShares}'),
            _kv('剩余份数', '${item.remainingShares}'),
            _kv('单份金额', _fmt(item.minInvestAmount)),
          ] else ...<Widget>[
            _kv('总金额', _fmt(item.totalAmount)),
            _kv('已投金额', _fmt(item.soldAmount)),
          ],
          _kv('剩余金额', _fmt(_calcRemainingAmount(item))),
          _kv('成长值', '${item.growthPerUnit.toStringAsFixed(0)}'),
          _kv('限购等级', item.limitLevel <= 0 ? '无' : 'VIP.${item.limitLevel}'),
          _kv('单购利率', '${item.singleRate.toStringAsFixed(2)}%'),
          _kv('限投次数', item.limitTimes <= 0 ? '不限' : '限投${item.limitTimes}次'),
          _kv('产品有效期', _buildValidPeriodText(item)),
          if (item.galleryImages.isNotEmpty) ...<Widget>[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: Text('产品组图', style: _labelStyle),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 90,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: item.galleryImages.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (BuildContext context, int index) {
                  final String src = ApiClient.instance.resolveImageUrl(item.galleryImages[index]) ?? item.galleryImages[index];
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: AppNetworkImage(src: src, width: 120, height: 90, fit: BoxFit.cover),
                  );
                },
              ),
            ),
          ],
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerLeft,
            child: Text('产品介绍', style: _labelStyle),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0x1EFFFFFF),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              _stripHtml(item.productContent),
              style: const TextStyle(color: Color(0xFF9AA6D0), fontSize: 15, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIncomeTab(InvestProductItem item) {
    final double principal = item.minInvestAmount <= 0 ? 1000 : item.minInvestAmount;
    final double income = principal * item.singleRate / 100 * item.cycleDays;
    final List<String> tradeRules = _buildTradeRules(item, principal, income);
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      decoration: BoxDecoration(
        color: const Color(0xFF141B52),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0x224CE3FF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            '交易规则',
            style: TextStyle(color: Colors.white, fontSize: 38 / 2, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 14),
          _ruleTimeline(),
          const SizedBox(height: 12),
          ...tradeRules.map((String ruleText) {
            return Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0x1AFFFFFF),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                ruleText,
                style: const TextStyle(color: Color(0xFF8D99C7), fontSize: 16),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _ruleTimeline() {
    const TextStyle captionStyle = TextStyle(color: Color(0xFF707EAF), fontSize: 12);
    const TextStyle valueStyle = TextStyle(color: Color(0xFF8A97C4), fontSize: 14);
    return Column(
      children: <Widget>[
        Row(
          children: const <Widget>[
            Icon(Icons.circle, size: 10, color: Color(0xFF35DAFF)),
            SizedBox(width: 8),
            Expanded(child: Divider(color: Color(0xFF33406E), thickness: 1)),
            SizedBox(width: 8),
            Icon(Icons.circle, size: 10, color: Color(0xFF35DAFF)),
            SizedBox(width: 8),
            Expanded(child: Divider(color: Color(0xFF33406E), thickness: 1)),
            SizedBox(width: 8),
            Icon(Icons.circle, size: 10, color: Color(0xFF35DAFF)),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: const <Widget>[
            Expanded(child: Column(children: <Widget>[Text('申购提交', style: captionStyle, maxLines: 1, softWrap: false, overflow: TextOverflow.ellipsis), Text('今日', style: valueStyle, maxLines: 1, softWrap: false, overflow: TextOverflow.ellipsis)])),
            Expanded(child: Column(children: <Widget>[Text('每日返利', style: captionStyle, maxLines: 1, softWrap: false, overflow: TextOverflow.ellipsis), Text('24小时后', style: valueStyle, maxLines: 1, softWrap: false, overflow: TextOverflow.ellipsis)])),
            Expanded(child: Column(children: <Widget>[Text('申请提现', style: captionStyle, maxLines: 1, softWrap: false, overflow: TextOverflow.ellipsis), Text('24小时内到账', style: valueStyle, maxLines: 1, softWrap: false, overflow: TextOverflow.ellipsis)])),
          ],
        ),
      ],
    );
  }

  double _calcRemainingAmount(InvestProductItem item) {
    if (item.investMode == 'AMOUNT') {
      return item.remainingAmount > 0 ? item.remainingAmount : 0;
    }
    final int remain = item.totalShares > 0 ? (item.totalShares - item.soldShares) : item.remainingShares;
    final int safeRemain = remain < 0 ? 0 : remain;
    return safeRemain * item.minInvestAmount;
  }

  Widget _buildBottomButton(InvestProductItem item) {
    return SizedBox(
      height: 56,
      child: ElevatedButton(
        onPressed: () {
          final String? reason = _resolveOrderBlockedReason(item);
          if (reason != null && reason.isNotEmpty) {
            _showToast(reason);
            return;
          }
          Navigator.pushNamed(
            context,
            item.groupEnabled ? AppRouter.investGroupPurchase : AppRouter.investPurchase,
            arguments: <String, dynamic>{'productId': item.productId},
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1F3CF5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset(
              AppImages.currencyBrand(item.currency, usePurpleVariant: true),
              width: 20,
              height: 20,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 6),
            Text(
              '${item.currency}下单',
              style: const TextStyle(color: Color(0xFF35DAFF), fontSize: 38 / 2, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }

  Widget _kv(String k, String v) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: <Widget>[
          Expanded(child: Text(k, style: _labelStyle)),
          Expanded(
            child: Text(
              v,
              textAlign: TextAlign.right,
              style: const TextStyle(color: Color(0xFF8E9AC6), fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  String _fmt(double value) {
    if (value % 1 == 0) {
      return value.toStringAsFixed(0);
    }
    return value.toStringAsFixed(2);
  }

  String _stripHtml(String raw) {
    if (raw.trim().isEmpty) {
      return '暂无介绍';
    }
    return raw
        .replaceAll(RegExp(r'<[^>]*>'), ' ')
        .replaceAll('&nbsp;', ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  List<String> _buildTradeRules(InvestProductItem item, double principal, double income) {
    final List<String> configured = item.tradeRuleContent
        .split(RegExp(r'\r?\n'))
        .map((String e) => e.trim())
        .where((String e) => e.isNotEmpty)
        .toList();
    if (configured.isNotEmpty) {
      return configured.take(8).toList();
    }
    final String fallback = '1. ${item.currency}收益：${_fmt(principal)}*${item.singleRate.toStringAsFixed(2)}%*${item.cycleDays}=${_fmt(income)} ${item.currency}';
    return List<String>.filled(4, fallback);
  }

  String _buildValidPeriodText(InvestProductItem item) {
    final String start = _normalizeDateText(item.startTime);
    final String end = _normalizeDateText(item.endTime);
    if (start.isEmpty && end.isEmpty) {
      return '长期有效';
    }
    if (start.isNotEmpty && end.isNotEmpty) {
      return '$start ~ $end';
    }
    if (start.isNotEmpty) {
      return '$start 起';
    }
    return '截至 $end';
  }

  String _normalizeDateText(String raw) {
    final String value = raw.trim();
    if (value.isEmpty) {
      return '';
    }
    return value.length >= 19 ? value.substring(0, 19) : value;
  }

  String? _resolveOrderBlockedReason(InvestProductItem item) {
    if (!item.canOrder) {
      return item.orderDisabledReason.isEmpty ? '当前产品暂不可下单' : item.orderDisabledReason;
    }
    final DateTime now = DateTime.now();
    final DateTime? startTime = _parseDateTime(item.startTime);
    if (startTime != null && now.isBefore(startTime)) {
      return '产品未开始';
    }
    final DateTime? endTime = _parseDateTime(item.endTime);
    if (endTime != null && now.isAfter(endTime)) {
      return '产品已过有效期';
    }
    if (item.progressPercent >= 100) {
      return '产品进度已100%，暂不可下单';
    }
    final double remainAmount = _calcRemainingAmount(item);
    if (remainAmount <= 0) {
      return '该产品已满额，暂不可下单';
    }
    if (item.limitTimes > 0 && item.userInvestCount >= item.limitTimes) {
      return item.limitTimes == 1 ? '该产品不可复购，您已订购过' : '该产品最多可认购${item.limitTimes}次，已达上限';
    }
    return null;
  }

  DateTime? _parseDateTime(String text) {
    final String raw = text.trim();
    if (raw.isEmpty) {
      return null;
    }
    final String normalized = raw.contains(' ') ? raw.replaceFirst(' ', 'T') : raw;
    return DateTime.tryParse(normalized);
  }

  void _showToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}

const TextStyle _labelStyle = TextStyle(color: Color(0xFF707EAF), fontSize: 16);
