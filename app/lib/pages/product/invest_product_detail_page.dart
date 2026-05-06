import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:myapp/config/app_images.dart';
import 'package:myapp/config/app_localizations.dart';
import 'package:myapp/pages/main/main_page.dart';
import 'package:myapp/request/app_config_api.dart';
import 'package:myapp/request/api_client.dart';
import 'package:myapp/request/auth_api.dart';
import 'package:myapp/request/invest_product_api.dart';
import 'package:myapp/routers/app_router.dart';
import 'package:myapp/tools/app_bootstrap_tool.dart';
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

  AppLocalizations get i18n => AppLocalizations.of(context)!;

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
      backgroundColor: const Color(0xFF0A1220),
      appBar: AppBar(
        title: Text(i18n.t('productDetailTitle')),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
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
            right: -90,
            child: _blurBall(size: 260, color: const Color(0x5539E6FF)),
          ),
          Positioned(
            bottom: -140,
            left: -90,
            child: _blurBall(size: 300, color: const Color(0x5538FFB3)),
          ),
          FutureBuilder<InvestProductItem>(
            future: _future,
            builder: (BuildContext context, AsyncSnapshot<InvestProductItem> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF39E6FF)));
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return Center(
              child: FilledButton(
                onPressed: _refresh,
                child: Text(i18n.t('signRetry')),
              ),
            );
          }
          final InvestProductItem item = snapshot.data!;
          return RefreshIndicator(
            onRefresh: _refresh,
            color: const Color(0xFF39E6FF),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(14, 4, 14, 16),
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
        ],
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF0A1220),
        border: Border(
          top: BorderSide(
            color: Color(0x33FFFFFF),
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              _buildNavItem(0, Icons.home_rounded, i18n.t('tabHome')),
              _buildNavItem(1, Icons.calendar_view_month_rounded, i18n.t('tabProduct')),
              _buildNavItem(2, Icons.memory_rounded, i18n.t('tabMiner')),
              _buildNavItem(3, Icons.person_rounded, i18n.t('tabMine')),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    const int currentIndex = 1;
    final bool isSelected = index == currentIndex;
    const Color activeColor = Color(0xFF39E6FF);
    const Color inactiveColor = Color(0xFF9DB1C9);
    return GestureDetector(
      onTap: () => _openMainTab(index),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              icon,
              size: 24,
              color: isSelected ? activeColor : inactiveColor,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: isSelected ? activeColor : inactiveColor,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openMainTab(int index) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(
        builder: (_) => MainPage(initialIndex: index),
      ),
      (Route<dynamic> route) => false,
    );
  }

  Widget _buildTopCard(InvestProductItem item) {
    final String progress = '${item.progressPercent.toStringAsFixed(3)}%';
    final double remainingAmount = _calcRemainingAmount(item);
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      decoration: _panelDecoration(radius: 16),
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
                child: _buildRatePanel(item),
              ),
                const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _buildInlineMetric(i18n.t('productPeriod'), '${item.cycleDays}${i18n.t('signDayUnit')}'),
                    const SizedBox(height: 8),
                    _buildInlineMetric(i18n.t('productRemainingAmount'), _fmt(remainingAmount)),
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
              _yieldModeText(item),
              if (item.riskTag.isNotEmpty) _chip(item.riskTag),
              _chip(i18n.t('homeMinInvestLabel').replaceAll('{amount}', _fmt(item.minInvestAmount))),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              Text('${i18n.t('productProgress')}:', style: const TextStyle(color: Color(0xFF8C94BC), fontSize: 16)),
              const SizedBox(width: 8),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: (item.progressPercent.clamp(0, 100)) / 100,
                    minHeight: 10,
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF38DFFF)),
                    backgroundColor: const Color(0x331E2A44),
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

  Widget _buildRatePanel(InvestProductItem item) {
    if (!item.groupEnabled) {
      return _buildBigData(_displayRateText(item), _displayRateLabel(item));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _buildBigData(_displayRateText(item), _displayRateLabel(item)),
        const SizedBox(height: 6),
        Row(
          children: <Widget>[
            Text(
              i18n.t('productSingleRate'),
              style: const TextStyle(color: Color(0xFF7E89B5), fontSize: 13),
            ),
            const SizedBox(width: 6),
            Text(
              '${item.singleRate.toStringAsFixed(2)}%',
              style: const TextStyle(
                color: Color(0xFF35DAFF),
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _chip(String text) {
    final bool isRisk = text.contains('风险') || text.toLowerCase().contains('risk');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: isRisk ? const Color(0xCCFF3B30) : const Color(0x4039E6FF),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0x334CE3FF)),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Color(0xFFE9F3FF), fontSize: 13, fontWeight: FontWeight.w700),
      ),
    );
  }

  Widget  _yieldModeText(InvestProductItem item) {
    final String mode = item.interestMode.trim().toUpperCase();
    final String text;
    switch (mode) {
      case 'DAILY':
        text = '每日返息';
        break;
      case 'STAGED':
        text = '分段返息';
        break;
      default:
        text = '到期返息';
        break;
    }
    return Text(
      text,
      style: const TextStyle(
        color: Color(0xFFE9F3FF),
        fontSize: 13,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _buildTabs() {
    return Row(
      children: <Widget>[
        Expanded(child: _tabButton(i18n.t('productDetailTab'), 0)),
        const SizedBox(width: 2),
        Expanded(child: _tabButton(i18n.t('productIncomeCalcTab'), 1)),
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
          color: selected ? const Color(0x331F3E66) : Colors.transparent,
          border: Border.all(color: selected ? const Color(0xFF39E6FF) : const Color(0x334CE3FF)),
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
      decoration: _panelDecoration(),
      child: Column(
        children: <Widget>[
          _kv(i18n.t('productProjectName'), item.productName),
          _kv(i18n.t('productProjectProgress'), '${item.progressPercent.toStringAsFixed(4)}%'),
          if (shareMode) ...<Widget>[
            _kv(i18n.t('productTotalShares'), '${item.totalShares}'),
            _kv(i18n.t('productSoldShares'), '${item.soldShares}'),
            _kv(i18n.t('productRemainingShares'), '${item.remainingShares}'),
            _kv(i18n.t('productUnitAmount'), _fmt(item.minInvestAmount)),
          ] else ...<Widget>[
            _kv(i18n.t('productTotalAmount'), _fmt(item.totalAmount)),
            _kv(i18n.t('productSoldAmount'), _fmt(item.soldAmount)),
          ],
          _kv(i18n.t('productRemainingAmount'), _fmt(_calcRemainingAmount(item))),
          _kv(i18n.t('productGrowthValue'), '${item.growthPerUnit.toStringAsFixed(0)}'),
          _kv(i18n.t('productLimitLevel'), item.limitLevel <= 0 ? i18n.t('notSet') : 'VIP.${item.limitLevel}'),
          _kv(_displayRateLabel(item), _displayRateText(item)),
          if (item.groupEnabled) _kv(i18n.t('productSingleRate'), '${item.singleRate.toStringAsFixed(2)}%'),
          _kv(i18n.t('productLimitTimes'), item.limitTimes <= 0 ? i18n.t('productUnlimited') : i18n.t('productLimitTimesValue').replaceAll('{times}', '${item.limitTimes}')),
          if (_hasValidPeriod(item)) _buildValidPeriodBlock(item),
          if (item.galleryImages.isNotEmpty) ...<Widget>[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(i18n.t('productGallery'), style: _labelStyle),
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
            child: Text(i18n.t('productIntro'), style: _labelStyle),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0x14FFFFFF),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0x224CE3FF)),
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
    final double income = principal * _displayRateValue(item) / 100 * item.cycleDays;
    final List<String> tradeRules = _buildTradeRules(item, principal, income);
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      decoration: _panelDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            i18n.t('productTradeRulesTitle'),
            style: TextStyle(color: Colors.white, fontSize: 38 / 2, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 14),
          _buildYieldCalcCard(item, principal, income),
          const SizedBox(height: 12),
          _ruleTimeline(),
          const SizedBox(height: 12),
          ...tradeRules.map((String ruleText) {
            return Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0x14FFFFFF),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0x224CE3FF)),
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

  Widget _buildYieldCalcCard(InvestProductItem item, double principal, double income) {
    final List<_YieldStageNode> stages = _parseStageConfig(item.stageConfigJson);
    final String interestSummary = _describeYieldMode(
      label: '返息',
      mode: item.interestMode,
      stageCount: item.interestStageCount,
    );
    final String principalSummary = _describeYieldMode(
      label: '返本',
      mode: item.principalMode,
      stageCount: item.principalStageCount,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0x14FFFFFF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0x224CE3FF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            '收益计算说明',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          _buildModeInfoRow('返息方式', interestSummary),
          const SizedBox(height: 6),
          _buildModeInfoRow('返本方式', principalSummary),
          const SizedBox(height: 6),
          _buildYieldInfoRow('周期天数', '${item.cycleDays}天'),
          const SizedBox(height: 6),
          _buildYieldInfoRow('收益参考', _buildYieldFormulaText(item, principal, income)),
          const SizedBox(height: 10),
          Text(
            '分段配置',
            style: const TextStyle(
              color: Color(0xFF39E6FF),
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          if (stages.isEmpty)
            const Text(
              '当前产品未配置分段 JSON，收益将按上面的方式字段计算。',
              style: TextStyle(color: Color(0xFF8D99C7), fontSize: 14, height: 1.5),
            )
          else ...<Widget>[
            Text(
              'JSON 会按 stageNo 排序；type=INTEREST 时作用于返息，type=PRINCIPAL 时作用于返本，type 为空时视为通用配置。',
              style: const TextStyle(color: Color(0xFF8D99C7), fontSize: 13, height: 1.5),
            ),
            const SizedBox(height: 10),
            ..._buildStageSections(stages),
          ],
        ],
      ),
    );
  }

  Widget _buildYieldInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(
          width: 82,
          child: Text(
            label,
            style: const TextStyle(color: Color(0xFF707EAF), fontSize: 13),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(color: Color(0xFFE8F1FF), fontSize: 14, height: 1.4),
          ),
        ),
      ],
    );
  }

  Widget _buildModeInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(
          width: 82,
          child: Text(
            label,
            style: const TextStyle(color: Color(0xFF707EAF), fontSize: 13),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(color: Color(0xFFE9F3FF), fontSize: 14, fontWeight: FontWeight.w600, height: 1.4),
          ),
        ),
      ],
    );
  }

  String _buildYieldFormulaText(InvestProductItem item, double principal, double income) {
    final String rateText = _displayRateText(item);
    final String rateLabel = _displayRateLabel(item);
    return '参考公式：${_fmt(principal)} × $rateLabel $rateText × ${item.cycleDays}天 ≈ ${_fmt(income)}';
  }

  String _describeYieldMode({
    required String label,
    required String mode,
    required int stageCount,
  }) {
    final String normalized = mode.trim().toUpperCase();
    if (normalized == 'DAILY') {
      return '$label按每日返息/返本计算';
    }
    if (normalized == 'STAGED') {
      if (stageCount > 0) {
        return '$label按分段返息/返本计算（$stageCount 段）';
      }
      return '$label按分段返息/返本计算';
    }
    return '$label按到期返息/返本计算';
  }

  List<Widget> _buildStageSections(List<_YieldStageNode> stages) {
    final Map<String, List<_YieldStageNode>> grouped = <String, List<_YieldStageNode>>{};
    for (final _YieldStageNode stage in stages) {
      grouped.putIfAbsent(stage.typeKey, () => <_YieldStageNode>[]).add(stage);
    }
    final List<String> order = <String>['GENERAL', 'INTEREST', 'PRINCIPAL'];
    final List<Widget> widgets = <Widget>[];
    for (final String key in order) {
      final List<_YieldStageNode>? items = grouped[key];
      if (items == null || items.isEmpty) {
        continue;
      }
      items.sort((a, b) => a.stageNo.compareTo(b.stageNo));
      widgets.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Text(
            _stageGroupLabel(key),
            style: const TextStyle(color: Color(0xFFB2C2F0), fontSize: 13, fontWeight: FontWeight.w700),
          ),
        ),
      );
      for (final _YieldStageNode stage in items) {
        widgets.add(_buildStageItem(stage));
        widgets.add(const SizedBox(height: 8));
      }
      if (widgets.isNotEmpty) {
        widgets.removeLast();
        widgets.add(const SizedBox(height: 10));
      }
    }
    if (widgets.isNotEmpty) {
      widgets.removeLast();
    }
    return widgets;
  }

  String _stageGroupLabel(String key) {
    switch (key) {
      case 'INTEREST':
        return '返息分段';
      case 'PRINCIPAL':
        return '返本分段';
      default:
        return '通用分段';
    }
  }

  Widget _buildStageItem(_YieldStageNode stage) {
    final String stageLabel = stage.typeKey == 'GENERAL'
        ? '第${stage.stageNo}段'
        : '${_stageGroupLabel(stage.typeKey)} 第${stage.stageNo}段';
    final List<String> details = <String>[
      if (stage.day > 0) '第${stage.day}天',
      if (stage.ratio > 0) '${_formatPercent(stage.ratio)}%',
      if (stage.remark.isNotEmpty) stage.remark,
    ];
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0x141F3E66),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0x224CE3FF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            stageLabel,
            style: const TextStyle(color: Color(0xFFE8F1FF), fontSize: 14, fontWeight: FontWeight.w700),
          ),
          if (details.isNotEmpty) ...<Widget>[
            const SizedBox(height: 6),
            Text(
              details.join('  |  '),
              style: const TextStyle(color: Color(0xFF8D99C7), fontSize: 13, height: 1.4),
            ),
          ],
        ],
      ),
    );
  }

  String _formatPercent(double value) {
    final double percent = value > 1 ? value : value * 100;
    if (percent % 1 == 0) {
      return percent.toStringAsFixed(0);
    }
    return percent.toStringAsFixed(2).replaceFirst(RegExp(r'\.?0+$'), '');
  }

  List<_YieldStageNode> _parseStageConfig(String raw) {
    String content = raw.trim();
    if (content.isEmpty) {
      return const <_YieldStageNode>[];
    }
    try {
      dynamic decoded = jsonDecode(content);
      if (decoded is String) {
        final String nested = decoded.trim();
        if (nested.isEmpty) {
          return const <_YieldStageNode>[];
        }
        decoded = jsonDecode(nested);
      }
      if (decoded is Map && decoded['data'] != null) {
        decoded = decoded['data'];
      }
      if (decoded is Map && decoded['rows'] != null) {
        decoded = decoded['rows'];
      }
      if (decoded is! List) {
        return const <_YieldStageNode>[];
      }
      final List<_YieldStageNode> nodes = <_YieldStageNode>[];
      for (final dynamic entry in decoded) {
        if (entry is! Map) {
          continue;
        }
        final Map<String, dynamic> map = Map<String, dynamic>.from(entry as Map);
        nodes.add(
          _YieldStageNode(
            typeKey: _normalizeStageType(_safeString(map['type'] ?? map['planType'])),
            stageNo: _safeInt(map['stageNo']),
            day: _safeInt(map['day']) > 0 ? _safeInt(map['day']) : _safeInt(map['dayOffset']),
            ratio: _safeDouble(map['ratio']) > 0
                ? _safeDouble(map['ratio'])
                : (_safeDouble(map['percent']) > 0 ? _safeDouble(map['percent']) : _safeDouble(map['rate'])),
            remark: _safeString(map['remark']),
          ),
        );
      }
      nodes.sort((a, b) {
        final int typeCompare = _stageTypeSortIndex(a.typeKey).compareTo(_stageTypeSortIndex(b.typeKey));
        if (typeCompare != 0) {
          return typeCompare;
        }
        return a.stageNo.compareTo(b.stageNo);
      });
      return nodes;
    } catch (_) {
      return const <_YieldStageNode>[];
    }
  }

  String _normalizeStageType(String raw) {
    final String value = raw.trim().toUpperCase();
    if (value == 'INTEREST' || value == 'PRINCIPAL') {
      return value;
    }
    return 'GENERAL';
  }

  int _stageTypeSortIndex(String typeKey) {
    switch (typeKey) {
      case 'GENERAL':
        return 0;
      case 'INTEREST':
        return 1;
      case 'PRINCIPAL':
        return 2;
      default:
        return 3;
    }
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
          children: <Widget>[
            Expanded(child: Column(children: <Widget>[Text(i18n.t('productTimelineSubmit'), style: captionStyle, maxLines: 1, softWrap: false, overflow: TextOverflow.ellipsis), Text(i18n.t('productTimelineToday'), style: valueStyle, maxLines: 1, softWrap: false, overflow: TextOverflow.ellipsis)])),
            Expanded(child: Column(children: <Widget>[Text(i18n.t('productTimelineDailyRebate'), style: captionStyle, maxLines: 1, softWrap: false, overflow: TextOverflow.ellipsis), Text(i18n.t('productTimelineAfter24h'), style: valueStyle, maxLines: 1, softWrap: false, overflow: TextOverflow.ellipsis)])),
            Expanded(child: Column(children: <Widget>[Text(i18n.t('productTimelineWithdraw'), style: captionStyle, maxLines: 1, softWrap: false, overflow: TextOverflow.ellipsis), Text(i18n.t('productTimelineArrive24h'), style: valueStyle, maxLines: 1, softWrap: false, overflow: TextOverflow.ellipsis)])),
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
    final bool realGroupEnabled =
        AppBootstrapTool.config.getByItem(AppConfigOptionItem.realGroupEnabled);
    final bool useGroupPurchase = item.groupEnabled && realGroupEnabled;
    return SizedBox(
      height: 56,
      child: ElevatedButton(
        onPressed: () async {
          final String? reason = await _resolveOrderBlockedReason(item);
          if (reason != null && reason.isNotEmpty) {
            _showToast(reason);
            return;
          }
          Navigator.pushNamed(
            context,
            useGroupPurchase ? AppRouter.investGroupPurchase : AppRouter.investPurchase,
            arguments: <String, dynamic>{'productId': item.productId},
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
          elevation: 0,
          padding: EdgeInsets.zero,
        ),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            gradient: const LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: <Color>[Color(0xFF39F3FF), Color(0xFF2DFFD6)],
            ),
            boxShadow: const <BoxShadow>[
              BoxShadow(
                color: Color(0x5539E6FF),
                blurRadius: 14,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Center(
            child: Text(
              '${item.currency}下单',
              style: const TextStyle(
                color: Color(0xFF031B2E),
                fontSize: 21,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
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
      return i18n.t('productNoIntro');
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
    final String fallback = i18n
        .t('productTradeRuleFormula')
        .replaceAll('{currency}', item.currency)
        .replaceAll('{principal}', _fmt(principal))
        .replaceAll('{rate}', _displayRateText(item))
        .replaceAll('{days}', '${item.cycleDays}')
        .replaceAll('{income}', _fmt(income));
    return List<String>.filled(4, fallback);
  }

  double _displayRateValue(InvestProductItem item) {
    return item.groupEnabled ? item.groupRate : item.singleRate;
  }

  String _displayRateText(InvestProductItem item) {
    return '${_displayRateValue(item).toStringAsFixed(2)}%';
  }

  String _displayRateLabel(InvestProductItem item) {
    return item.groupEnabled ? i18n.t('productGroupRate') : i18n.t('productSingleRate');
  }

  String _normalizeDateText(String raw) {
    final String value = raw.trim();
    if (value.isEmpty) {
      return '';
    }
    return value.length >= 19 ? value.substring(0, 19) : value;
  }

  bool _hasValidPeriod(InvestProductItem item) {
    return _normalizeDateText(item.startTime).isNotEmpty ||
        _normalizeDateText(item.endTime).isNotEmpty;
  }

  Widget _buildValidPeriodBlock(InvestProductItem item) {
    final String start = _normalizeDateText(item.startTime);
    final String end = _normalizeDateText(item.endTime);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(child: Text(i18n.t('productValidPeriod'), style: _labelStyle)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                if (start.isNotEmpty)
                  Text(
                    '${i18n.t('productOpenTime')}  $start',
                    textAlign: TextAlign.right,
                    style: const TextStyle(color: Color(0xFF8E9AC6), fontSize: 16),
                  ),
                if (start.isNotEmpty && end.isNotEmpty) const SizedBox(height: 6),
                if (end.isNotEmpty)
                  Text(
                    '${i18n.t('productEndTime')}  $end',
                    textAlign: TextAlign.right,
                    style: const TextStyle(color: Color(0xFF8E9AC6), fontSize: 16),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<String?> _resolveOrderBlockedReason(InvestProductItem item) async {
    if (!item.canOrder) {
      return item.orderDisabledReason.isEmpty ? i18n.t('productOrderDisabled') : item.orderDisabledReason;
    }
    final DateTime now = DateTime.now();
    final DateTime? startTime = _parseDateTime(item.startTime);
    if (startTime != null && now.isBefore(startTime)) {
      return i18n.t('productNotStarted');
    }
    final DateTime? endTime = _parseDateTime(item.endTime);
    if (endTime != null && now.isAfter(endTime)) {
      return i18n.t('productExpired');
    }
    if (item.progressPercent >= 100) {
      return i18n.t('productProgressFull');
    }
    final double remainAmount = _calcRemainingAmount(item);
    if (remainAmount <= 0) {
      return i18n.t('productSoldOut');
    }
    if (item.limitTimes > 0 && item.userInvestCount >= item.limitTimes) {
      return item.limitTimes == 1
          ? i18n.t('productNoRepurchase')
          : i18n.t('productLimitReached').replaceAll('{times}', '${item.limitTimes}');
    }
    if (item.limitLevel > 0) {
      try {
        final AuthUserProfile profile = await AuthApi.getInfo();
        final int userLevel = (profile.userLevel ?? 0) > 0 ? (profile.userLevel ?? 0) : (profile.level ?? 0);
        if (userLevel < item.limitLevel) {
          return i18n
              .t('productLevelNotEnough')
              .replaceAll('{required}', 'VIP.${item.limitLevel}')
              .replaceAll('{current}', 'VIP.$userLevel');
        }
      } catch (_) {
        return i18n.t('productLevelCheckFailed');
      }
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFFFA500),
      ),
    );
  }

  BoxDecoration _panelDecoration({double radius = 14}) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(radius),
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: <Color>[Color(0xF2101C30), Color(0xF20E1A2D)],
      ),
      border: Border.all(color: const Color(0x334CE3FF)),
      boxShadow: const <BoxShadow>[
        BoxShadow(
          color: Color(0x66000000),
          blurRadius: 22,
          offset: Offset(0, 8),
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
            blurRadius: size * 0.55,
            spreadRadius: size * 0.08,
          ),
        ],
      ),
    );
  }
}

class _YieldStageNode {
  const _YieldStageNode({
    required this.typeKey,
    required this.stageNo,
    required this.day,
    required this.ratio,
    required this.remark,
  });

  final String typeKey;
  final int stageNo;
  final int day;
  final double ratio;
  final String remark;
}

String _safeString(dynamic value) => (value ?? '').toString().trim();

int _safeInt(dynamic value) {
  if (value is int) {
    return value;
  }
  return int.tryParse('${value ?? 0}') ?? 0;
}

double _safeDouble(dynamic value) {
  if (value is num) {
    return value.toDouble();
  }
  return double.tryParse('${value ?? 0}') ?? 0;
}

const TextStyle _labelStyle = TextStyle(color: Color(0xFF707EAF), fontSize: 16);
