import 'dart:async';

import 'package:flutter/material.dart';

import 'package:myapp/config/app_localizations.dart';
import 'package:myapp/request/auth_api.dart';
import 'package:myapp/request/card_package_api.dart';

class CardPackagePage extends StatefulWidget {
  const CardPackagePage({
    super.key,
    this.initialSection = CardPackageSection.coupon,
  });

  final CardPackageSection initialSection;

  @override
  State<CardPackagePage> createState() => _CardPackagePageState();
}

class _CardPackagePageState extends State<CardPackagePage> {
  bool _loading = true;
  String _error = '';
  late CardPackageSection _initialSection;
  List<CardPackageItem> _couponCards = <CardPackageItem>[];
  List<CardPackageItem> _trialCards = <CardPackageItem>[];
  Timer? _countdownTimer;

  AppLocalizations get i18n => AppLocalizations.of(context)!;

  @override
  void initState() {
    super.initState();
    _initialSection = widget.initialSection;
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {});
      }
    });
    _load();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = '';
    });
    try {
      final List<CardPackageItem> couponCards = await CardPackageApi.fetchCoupons();
      final List<CardPackageItem> trialCards = await CardPackageApi.fetchTrials();
      if (!mounted) {
        return;
      }
      setState(() {
        _couponCards = couponCards;
        _trialCards = trialCards;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }
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
    return DefaultTabController(
      length: 2,
      initialIndex: _initialSection.index,
      child: Scaffold(
        backgroundColor: const Color(0xFF0A1220),
        appBar: AppBar(
          title: Text(i18n.t('mineCardPackage')),
          centerTitle: true,
          backgroundColor: const Color(0xFF0A1220),
          elevation: 0,
          bottom: TabBar(
            indicatorColor: const Color(0xFF39E6FF),
            labelColor: const Color(0xFF39E6FF),
            unselectedLabelColor: const Color(0xFF9DB1C9),
            tabs: <Tab>[
              Tab(text: i18n.t('cardPackageTabCoupon')),
              Tab(text: i18n.t('cardPackageTabTrial')),
            ],
          ),
        ),
        body: RefreshIndicator(
          onRefresh: _load,
          child: _buildBody(),
        ),
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
        padding: const EdgeInsets.all(20),
        children: <Widget>[
          const SizedBox(height: 100),
          Center(
            child: Text(
              _error,
              style: const TextStyle(color: Color(0xFFE9F3FF)),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: FilledButton(
              onPressed: _load,
              child: Text(i18n.t('assetsRetry')),
            ),
          ),
        ],
      );
    }

    return TabBarView(
      children: <Widget>[
        _buildTab(
          section: CardPackageSection.coupon,
          cards: _couponCards,
        ),
        _buildTab(
          section: CardPackageSection.trial,
          cards: _trialCards,
        ),
      ],
    );
  }

  Widget _buildTab({
    required CardPackageSection section,
    required List<CardPackageItem> cards,
  }) {
    final bool isCoupon = section == CardPackageSection.coupon;
    final Color accent = isCoupon ? const Color(0xFF39E6FF) : const Color(0xFF38FFB3);
    final Color accentSoft = isCoupon ? const Color(0xFF1F3CF5) : const Color(0xFF2B8A68);
    final String title = isCoupon ? i18n.t('cardPackageCouponTitle') : i18n.t('cardPackageTrialTitle');
    final String desc = isCoupon ? i18n.t('cardPackageCouponDesc') : i18n.t('cardPackageTrialDesc');
    final CardPackageItem? activeTrial = isCoupon ? null : _currentUsingTrial();

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      children: <Widget>[
        _buildSummaryCard(
          accent: accent,
          title: title,
          desc: desc,
          count: cards.length,
          chips: isCoupon
              ? <String>[
                  i18n.t('cardPackageCouponChip1'),
                  i18n.t('cardPackageCouponChip2'),
                  i18n.t('cardPackageCouponChip3'),
                ]
              : <String>[
                  i18n.t('cardPackageTrialChip1'),
                  i18n.t('cardPackageTrialChip2'),
                  i18n.t('cardPackageTrialChip3'),
                ],
        ),
        const SizedBox(height: 12),
        _buildUsageHint(),
        if (activeTrial != null) ...<Widget>[
          const SizedBox(height: 12),
          _buildActiveTrialBanner(activeTrial),
        ],
        const SizedBox(height: 14),
        if (cards.isEmpty)
          _buildEmptyState(section)
        else
          ...cards.map((CardPackageItem item) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildCardItem(
                  item,
                  accent: accent,
                  accentSoft: accentSoft,
                  section: section,
                ),
              )),
      ],
    );
  }

  Widget _buildUsageHint() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xCC101C30),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x334CE3FF)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Icon(
            Icons.info_outline,
            size: 18,
            color: Color(0xFF39E6FF),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              i18n.t('cardPackageDataHint'),
              style: const TextStyle(
                color: Color(0xFFE9F3FF),
                fontSize: 12,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard({
    required Color accent,
    required String title,
    required String desc,
    required int count,
    required List<String> chips,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            accent.withOpacity(0.22),
            const Color(0xCC101C30),
            const Color(0xCC101C30),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accent.withOpacity(0.45)),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x66000000),
            blurRadius: 24,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: accent.withOpacity(0.16),
                ),
                child: Icon(
                  Icons.card_giftcard_outlined,
                  color: accent,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      desc,
                      style: const TextStyle(
                        color: Color(0xFF9DB1C9),
                        fontSize: 13,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: accent.withOpacity(0.16),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: accent.withOpacity(0.35)),
                ),
                child: Text(
                  '${_localizedText("共", "Total ")}$count',
                  style: TextStyle(
                    color: accent,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: chips
                .map(
                  (String chip) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: accent.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: accent.withOpacity(0.35)),
                    ),
                    child: Text(
                      chip,
                      style: TextStyle(
                        color: accent,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(CardPackageSection section) {
    final bool isCoupon = section == CardPackageSection.coupon;
    final String text = isCoupon ? i18n.t('cardPackageCouponEmpty') : i18n.t('cardPackageTrialEmpty');
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 64, horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xCC101C30),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0x334CE3FF)),
      ),
      child: Column(
        children: <Widget>[
          const Icon(Icons.inbox_outlined, size: 44, color: Color(0xFF9DB1C9)),
          const SizedBox(height: 12),
          Text(
            text,
            style: const TextStyle(
              color: Color(0xFF9DB1C9),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: _load,
            child: Text(i18n.t('assetsRetry')),
          ),
        ],
      ),
    );
  }

  Widget _buildCardItem(
    CardPackageItem item, {
    required Color accent,
    required Color accentSoft,
    required CardPackageSection section,
  }) {
    final DateTime now = DateTime.now();
    final bool ended = item.userStatus.trim() == '2';
    final bool activeExpired = item.isUsing && item.endTime != null && item.endTime!.isBefore(now);
    final bool templateNotStartedYet = item.templateStartTime != null && item.templateStartTime!.isAfter(now);
    final bool templateExpired = item.templateEndTime != null && item.templateEndTime!.isBefore(now);
    final bool expired = !ended && (activeExpired || templateExpired);
    final bool usableWindow = !expired && !templateNotStartedYet && item.canStart;
    final bool isTrial = section == CardPackageSection.trial;
    final String statusText = ended
        ? _localizedText('已结束', 'Ended')
        : item.isUsing && !activeExpired
        ? _localizedText('使用中', 'In use')
        : expired
            ? i18n.t('cardPackageStatusExpired')
            : templateNotStartedYet
                ? _localizedText('未到启用时间', 'Not yet available')
                : _localizedText('待启用', 'Ready');
    final Color statusColor = ended
        ? const Color(0xFFFF6B6B)
        : item.isUsing && !activeExpired
          ? const Color(0xFF39E6FF)
          : expired
            ? const Color(0xFFFF6B6B)
            : const Color(0xFF38FFB3);
    final String typeText = _cardTypeText(item.cardType, item.trialLevel);
    final List<String> infoLines = _cardInfoLines(item);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xCC101C30),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: accent.withOpacity(0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  item.cardName.isEmpty ? typeText : item.cardName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: statusColor.withOpacity(0.45)),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            typeText,
            style: TextStyle(
              color: accent,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          ...infoLines.map(
            (String line) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('•', style: TextStyle(color: accentSoft, fontSize: 14)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      line,
                      style: const TextStyle(
                        color: Color(0xFFE9F3FF),
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (item.isUsing && !activeExpired && !ended) ...<Widget>[
            const SizedBox(height: 10),
            Text(
              '${_localizedText("剩余", "Remaining")}: ${_formatRemaining(item)}',
              style: const TextStyle(
                color: Color(0xFF39E6FF),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          if (!ended && !item.isUsing && item.templateStartTime != null && item.templateEndTime != null) ...<Widget>[
            const SizedBox(height: 6),
            Text(
              '${_localizedText("卡片有效期", "Template window")}: ${_formatRange(item.templateStartTime, item.templateEndTime)}',
              style: const TextStyle(
                color: Color(0xFF9DB1C9),
                fontSize: 12,
                height: 1.4,
              ),
            ),
          ],
          if ((item.remark ?? '').trim().isNotEmpty) ...<Widget>[
            const SizedBox(height: 6),
            Text(
              '${i18n.t('cardPackageRemark')}: ${item.remark!.trim()}',
              style: const TextStyle(
                color: Color(0xFF9DB1C9),
                fontSize: 12,
                height: 1.4,
              ),
            ),
          ],
          if (isTrial && !ended && !item.isUsing && usableWindow) ...<Widget>[
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: accent,
                  foregroundColor: const Color(0xFF08101A),
                ),
                onPressed: () => _startTrialCard(item),
                child: Text(_localizedText('启动', 'Start')),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActiveTrialBanner(CardPackageItem item) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xCC101C30),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x5539E6FF)),
      ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Icon(Icons.timer_outlined, size: 18, color: Color(0xFF39E6FF)),
              const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  '${_localizedText("正在使用", "In use")}: ${item.cardName.isEmpty ? _cardTypeText(item.cardType, item.trialLevel) : item.cardName}',
                  style: const TextStyle(
                    color: Color(0xFFE9F3FF),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_localizedText("剩余", "Remaining")}: ${_formatRemaining(item)}',
                  style: const TextStyle(
                    color: Color(0xFF9DB1C9),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          OutlinedButton(
            onPressed: () => _confirmEndTrialCard(item),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFFF6B6B),
              side: const BorderSide(color: Color(0x55FF6B6B)),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            ),
            child: Text(_localizedText('结束使用', 'End')),
          ),
        ],
      ),
    );
  }

  String _cardTypeText(String cardType, int? trialLevel) {
    final String normalized = cardType.trim().toUpperCase();
    switch (normalized) {
      case 'EXPERIENCE':
        return i18n.t('cardPackageTypeExperience');
      case 'CASH':
        return i18n.t('cardPackageTypeCash');
      case 'FULL_REDUCTION':
        return i18n.t('cardPackageTypeReduction');
      case 'RATE_BOOST':
        return i18n.t('cardPackageTypeRateBoost');
      default:
        if (trialLevel != null && trialLevel > 0) {
          return '${i18n.t('cardPackageTypeTrial')} V$trialLevel';
        }
        return i18n.t('cardPackageTypeUnknown');
    }
  }

  List<String> _cardInfoLines(CardPackageItem item) {
    final List<String> lines = <String>[];
    final String templateRangeText = _formatRange(item.templateStartTime, item.templateEndTime);
    if (templateRangeText.isNotEmpty) {
      lines.add('${_localizedText("卡片有效期", "Template window")}: $templateRangeText');
    } else {
      lines.add('${_localizedText("卡片有效期", "Template window")}: ${_localizedText("长期有效", "Long-term valid")}');
    }
    final String rangeText = _formatRange(item.startTime, item.endTime);
    if (rangeText.isNotEmpty) {
      lines.add('${_localizedText("启动后有效期", "Active window")}: $rangeText');
    }
    if (item.minAmount != null && item.minAmount! > 0) {
      lines.add('${i18n.t('cardPackageMinAmount')}: ${item.minAmount!.toStringAsFixed(2)}');
    }
    if (item.discountAmount != null && item.discountAmount! > 0) {
      lines.add('${i18n.t('cardPackageDiscountAmount')}: ${item.discountAmount!.toStringAsFixed(2)}');
    }
    if (item.bonusRate != null && item.bonusRate! > 0) {
      lines.add('${i18n.t('cardPackageBonusRate')}: ${item.bonusRate!.toStringAsFixed(4)}%');
    }
    if (item.experiencePrincipal != null && item.experiencePrincipal! > 0) {
      lines.add('${i18n.t('cardPackageExperiencePrincipal')}: ${item.experiencePrincipal!.toStringAsFixed(2)}');
    }
    if (item.minExperienceUnits != null || item.maxExperienceUnits != null) {
      lines.add(
        '${i18n.t('cardPackageExperienceRange')}: '
        '${item.minExperienceUnits ?? 0} - ${item.maxExperienceUnits ?? 0}',
      );
    }
    if (item.validDays != null && item.validDays! > 0) {
      lines.add('${i18n.t('cardPackageValidDays')}: ${item.validDays}');
    }
    if ((item.grantType).trim().isNotEmpty) {
      lines.add('${i18n.t('cardPackageGrantType')}: ${item.grantType}');
    }
    if (item.originalLevel != null || item.currentLevel != null) {
      lines.add(
        '${_localizedText("等级", "Level")}: ${item.originalLevel ?? 0} -> ${item.currentLevel ?? 0}',
      );
    }
    return lines;
  }

  Future<void> _startTrialCard(CardPackageItem item) async {
    try {
      final CardPackageItem updated = await CardPackageApi.startTrialCard(item.userTrialId);
      if (!mounted) {
        return;
      }
      await AuthApi.getInfo(forceRefresh: true);
      await _load();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${_localizedText("已启动", "Started")}: ${updated.cardName.isEmpty ? item.cardName : updated.cardName}',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
        ),
      );
    }
  }

  Future<void> _confirmEndTrialCard(CardPackageItem item) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Container(
            width: 360,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF101C30),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0x55FF6B6B)),
              boxShadow: const <BoxShadow>[
                BoxShadow(
                  color: Color(0x88000000),
                  blurRadius: 24,
                  offset: Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        _localizedText('确认结束使用', 'Confirm end'),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(dialogContext).pop(false),
                      icon: const Icon(Icons.close, color: Color(0xFF9DB1C9)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  _localizedText(
                    '结束后将恢复当前用户等级，是否确认结束这张体验卡？',
                    'Ending will restore your original level. Continue?',
                  ),
                  style: const TextStyle(
                    color: Color(0xFF9DB1C9),
                    fontSize: 13,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xCC0A1220),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0x334CE3FF)),
                  ),
                  child: Text(
                    item.cardName.isEmpty ? _cardTypeText(item.cardType, item.trialLevel) : item.cardName,
                    style: const TextStyle(
                      color: Color(0xFFE9F3FF),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.of(dialogContext).pop(false),
                        child: Text(_localizedText('取消', 'Cancel')),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFFFF6B6B),
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () => Navigator.of(dialogContext).pop(true),
                        child: Text(_localizedText('确认结束', 'End now')),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
    if (confirmed == true) {
      await _endTrialCard(item);
    }
  }

  Future<void> _endTrialCard(CardPackageItem item) async {
    try {
      final CardPackageItem updated = await CardPackageApi.endTrialCard(item.userTrialId);
      if (!mounted) {
        return;
      }
      await AuthApi.getInfo();
      await _load();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${_localizedText("已结束使用", "Ended")}: ${updated.cardName.isEmpty ? item.cardName : updated.cardName}',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
        ),
      );
    }
  }

  CardPackageItem? _currentUsingTrial() {
    for (final CardPackageItem item in _trialCards) {
      final DateTime now = DateTime.now();
      final bool ended = item.userStatus.trim() == '2';
      final bool activeExpired = item.endTime != null && item.endTime!.isBefore(now);
      if (!ended && item.isUsing && !activeExpired) {
        return item;
      }
    }
    return null;
  }

  String _formatRange(DateTime? start, DateTime? end) {
    if (start == null && end == null) {
      return '';
    }
    final String startText = start == null ? '--' : _formatDate(start);
    final String endText = end == null ? '--' : _formatDate(end);
    return '$startText ~ $endText';
  }

  String _formatDate(DateTime dt) {
    final DateTime t = dt.toLocal();
    return '${t.year}-${t.month.toString().padLeft(2, '0')}-${t.day.toString().padLeft(2, '0')}';
  }

  String _formatRemaining(CardPackageItem item) {
    final DateTime? end = item.endTime;
    final int seconds = end == null ? item.remainingSeconds : end.difference(DateTime.now()).inSeconds;
    return _formatSeconds(seconds);
  }

  String _formatSeconds(int seconds) {
    final int safe = seconds < 0 ? 0 : seconds;
    final int days = safe ~/ 86400;
    final int hours = (safe % 86400) ~/ 3600;
    final int minutes = (safe % 3600) ~/ 60;
    final int secs = safe % 60;
    if (days > 0) {
      return '$days${_localizedText("天", "d")} ${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    }
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  String _localizedText(String zh, String en) {
    return i18n.locale.languageCode == 'zh' ? zh : en;
  }
}

enum CardPackageSection {
  coupon,
  trial,
}
