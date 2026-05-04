import 'package:flutter/material.dart';
import 'package:myapp/config/app_images.dart';
import 'package:myapp/request/invest_product_api.dart';
import 'package:myapp/routers/app_router.dart';

class InvestProductListPage extends StatefulWidget {
  const InvestProductListPage({super.key});

  @override
  State<InvestProductListPage> createState() => _InvestProductListPageState();
}

class _InvestProductListPageState extends State<InvestProductListPage> {
  late Future<InvestProductCatalog> _future;
  final TextEditingController _searchController = TextEditingController();
  List<String> _tagGroups = const <String>['全部'];
  String _selectedTag = '全部';

  @override
  void initState() {
    super.initState();
    _future = InvestProductApi.fetchCatalog();
    _loadCachedTagGroups();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _refresh() async {
    setState(() {
      _future = InvestProductApi.fetchCatalog(forceRefresh: true);
    });
    await _future;
  }

  Future<void> _loadCachedTagGroups() async {
    final List<String> cached = await InvestProductApi.getCachedTagGroups();
    if (!mounted) {
      return;
    }
    setState(() {
      _tagGroups = _normalizeTagGroups(cached);
      if (!_tagGroups.contains(_selectedTag)) {
        _selectedTag = '全部';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF080A2D),
      body: SafeArea(
        child: FutureBuilder<InvestProductCatalog>(
          future: _future,
          builder: (BuildContext context, AsyncSnapshot<InvestProductCatalog> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: Color(0xFF39E6FF)));
            }
            if (snapshot.hasError) {
              return _buildErrorState();
            }
            final InvestProductCatalog catalog =
                snapshot.data ?? const InvestProductCatalog(products: <InvestProductItem>[], tagGroups: <String>['全部']);
            final List<String> currentTags = _normalizeTagGroups(
              <String>[
                ...catalog.tagGroups,
                ..._collectTagsFromProducts(catalog.products),
              ],
            );
            if (_isNeedSyncTags(currentTags)) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!mounted) {
                  return;
                }
                setState(() {
                  _tagGroups = currentTags;
                  if (!_tagGroups.contains(_selectedTag)) {
                    _selectedTag = '全部';
                  }
                });
              });
            }
            final List<InvestProductItem> all = catalog.products;
            final List<InvestProductItem> visible = _filterProducts(all);
            return RefreshIndicator(
              onRefresh: _refresh,
              color: const Color(0xFF39E6FF),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 16),
                children: <Widget>[
                  _buildSearchBox(),
                  const SizedBox(height: 10),
                  _buildCategoryTabs(),
                  const SizedBox(height: 12),
                  if (visible.isEmpty) _buildEmptyState(),
                  ...visible.map(_buildProductCard),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: <Widget>[
        const SizedBox(height: 140),
        const Icon(Icons.cloud_off_outlined, color: Color(0xFFFF6B6B), size: 56),
        const SizedBox(height: 10),
        Center(
          child: FilledButton(
            onPressed: _refresh,
            child: const Text('重试'),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBox() {
    return Container(
      height: 46,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF111743),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0x2A4CE3FF)),
      ),
      child: Row(
        children: <Widget>[
          const Icon(Icons.search, color: Color(0xFF8290BC), size: 22),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white, fontSize: 15),
              decoration: const InputDecoration(
                hintText: '搜索',
                hintStyle: TextStyle(color: Color(0xFF6877A9)),
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTabs() {
    return SizedBox(
      height: 38,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: _tagGroups.map((String tag) {
          final bool selected = _selectedTag == tag;
          return GestureDetector(
            onTap: () => setState(() => _selectedTag = tag),
            child: Container(
              margin: const EdgeInsets.only(right: 14),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: selected ? const Color(0xFF0F1E66) : Colors.transparent,
                border: Border.all(
                  color: selected ? const Color(0xFF39E6FF) : Colors.transparent,
                ),
                boxShadow: selected
                    ? const <BoxShadow>[
                        BoxShadow(color: Color(0x6639E6FF), blurRadius: 8, offset: Offset(0, 2)),
                      ]
                    : null,
              ),
              child: Text(
                tag,
                style: TextStyle(
                  color: selected ? const Color(0xFF39E6FF) : const Color(0xFF8C99C9),
                  fontSize: 17,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildProductCard(InvestProductItem item) {
    final String progressText = '${item.progressPercent.toStringAsFixed(3)}%';
    final _CardThemeStyle cardTheme = _resolveCardTheme(item);
    final Color singleRateColor = const Color(0xFFFF7A8A);
    final Color groupRateColor = const Color(0xFF35DAFF);
    return GestureDetector(
      onTap: () => _openDetail(item),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.fromLTRB(12, 14, 12, 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: cardTheme.gradientColors,
          ),
          border: Border.all(color: cardTheme.borderColor),
        ),
        child: Column(
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        item.productName.isEmpty ? '未命名产品' : item.productName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: _buildTagBadges(item),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    _buildCurrencyBadge(item.currency, cardTheme.accentColor),
                    const SizedBox(height: 6),
                    _buildInvestButton(item, compact: true, borderColor: cardTheme.accentColor, textColor: cardTheme.accentColor),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: <Widget>[
                Expanded(
                  child: _buildRateBlock(
                    '${item.singleRate.toStringAsFixed(3)}%',
                    '单购利率',
                    singleRateColor,
                  ),
                ),
                if (item.groupEnabled)
                  Expanded(
                    child: _buildRateBlock(
                      '${item.groupRate.toStringAsFixed(3)}%',
                      '拼团利率',
                      groupRateColor,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: <Widget>[
                Expanded(child: _buildMiniStat('起投投资', item.currency, _fmt(item.minInvestAmount))),
                Expanded(child: _buildMiniStat('最高投资', item.currency, _fmt(item.maxInvestAmount))),
                if (item.redPacketPerUnit > 0)
                  Expanded(child: _buildMiniStat('红包金额', item.currency, _fmt(item.redPacketPerUnit))),
              ],
            ),
            const SizedBox(height: 9),
            Row(
              children: <Widget>[
                const Text('进度:', style: TextStyle(color: Color(0xFF8D95BB), fontSize: 33 / 2)),
                const SizedBox(width: 8),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: (item.progressPercent.clamp(0, 100)) / 100,
                      minHeight: 10,
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF39E6FF)),
                      backgroundColor: const Color(0xFF2E3468),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  progressText,
                  style: const TextStyle(color: Color(0xFF8D95BB), fontSize: 28 / 2),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildTagBadges(InvestProductItem item) {
    final List<String> badges = <String>[];
    badges.add(item.interestModeLabel);
    if (item.riskTag.isNotEmpty) {
      badges.add(item.riskTag);
    }
    badges.add('${item.cycleDays}天');
    return badges.take(3).map((String text) {
      final Color bg = text.contains('风险')
          ? const Color(0xFFFF5A5A)
          : text.endsWith('天')
              ? const Color(0xFF2FC84A)
              : const Color(0xFFFF4D4F);
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          text,
          style: const TextStyle(color: Colors.white, fontSize: 14 / 2 * 1.7, fontWeight: FontWeight.w700),
        ),
      );
    }).toList();
  }

  Widget _buildCurrencyBadge(String currency, Color accentColor) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Image.asset(
          AppImages.currencyBrand(currency, usePurpleVariant: true),
          width: 22,
          height: 22,
          fit: BoxFit.contain,
        ),
        const SizedBox(width: 6),
        Text(
          currency.isEmpty ? '--' : currency,
          style: TextStyle(
            color: accentColor,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _currencyValue(String currency, String value) {
    return Row(
      children: <Widget>[
        Image.asset(
          AppImages.currencyBrand(currency),
          width: 16,
          height: 16,
          fit: BoxFit.contain,
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            '$value ${currency.isEmpty ? "--" : currency}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Color(0xFF909AC3), fontSize: 17),
          ),
        ),
      ],
    );
  }

  Widget _buildMiniStat(String label, String currency, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(label, style: const TextStyle(color: Color(0xFF7A84B1), fontSize: 15)),
        const SizedBox(height: 2),
        _currencyValue(currency, value),
      ],
    );
  }

  Widget _buildRateBlock(String value, String label, Color valueColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          value,
          style: TextStyle(color: valueColor, fontSize: 45 / 2, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(color: Color(0xFF7E89B4), fontSize: 16)),
      ],
    );
  }

  Widget _buildInvestButton(
    InvestProductItem item, {
    bool compact = false,
    Color borderColor = const Color(0xFF2E8FFF),
    Color textColor = const Color(0xFF4AA2FF),
  }) {
    return InkWell(
      onTap: () => _openDetail(item),
      borderRadius: BorderRadius.circular(999),
      child: Container(
        width: compact ? 66 : 78,
        height: compact ? 34 : 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: borderColor),
        ),
        child: Text(
          '投资',
          style: TextStyle(
            color: textColor,
            fontSize: compact ? 16 : 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      margin: const EdgeInsets.only(top: 80),
      alignment: Alignment.center,
      child: const Text(
        '暂无产品',
        style: TextStyle(color: Color(0xFF8D98C7), fontSize: 16),
      ),
    );
  }

  void _openDetail(InvestProductItem item) {
    Navigator.pushNamed(
      context,
      AppRouter.investProductDetail,
      arguments: <String, dynamic>{'productId': item.productId},
    );
  }

  List<InvestProductItem> _filterProducts(List<InvestProductItem> source) {
    final String keyword = _searchController.text.trim();
    return source.where((InvestProductItem item) {
      if (keyword.isNotEmpty) {
        final String text = '${item.productName} ${item.currency} ${item.tagNames.join(' ')}'.toLowerCase();
        if (!text.contains(keyword.toLowerCase())) {
          return false;
        }
      }
      return _matchTagGroup(item);
    }).toList();
  }

  bool _matchTagGroup(InvestProductItem item) {
    if (_selectedTag == '全部') {
      return true;
    }
    return item.tagNames.any((String e) => e.trim() == _selectedTag);
  }

  String _fmt(double value) {
    if (value % 1 == 0) {
      return value.toStringAsFixed(0);
    }
    return value.toStringAsFixed(3);
  }

  bool _isNeedSyncTags(List<String> current) {
    if (current.length != _tagGroups.length) {
      return true;
    }
    for (int i = 0; i < current.length; i++) {
      if (current[i] != _tagGroups[i]) {
        return true;
      }
    }
    return false;
  }

  List<String> _normalizeTagGroups(List<String> raw) {
    final List<String> tags = <String>['全部'];
    for (final String e in raw) {
      final String text = e.trim();
      if (text.isNotEmpty && text != '全部' && !tags.contains(text)) {
        tags.add(text);
      }
    }
    return tags;
  }

  List<String> _collectTagsFromProducts(List<InvestProductItem> products) {
    final List<String> tags = <String>[];
    for (final InvestProductItem item in products) {
      for (final String tag in item.tagNames) {
        final String text = tag.trim();
        if (text.isNotEmpty && !tags.contains(text)) {
          tags.add(text);
        }
      }
    }
    return tags;
  }

  _CardThemeStyle _resolveCardTheme(InvestProductItem item) {
    final String key = item.cardTheme.trim().toLowerCase();
    if (key == 'purple') {
      return const _CardThemeStyle(
        gradientColors: <Color>[Color(0xFF2A185C), Color(0xFF1E144A)],
        borderColor: Color(0x226E5AFF),
        accentColor: Color(0xFF8A7DFF),
      );
    }
    if (key == 'green') {
      return const _CardThemeStyle(
        gradientColors: <Color>[Color(0xFF13434C), Color(0xFF122F45)],
        borderColor: Color(0x2256D8B6),
        accentColor: Color(0xFF56D8B6),
      );
    }
    if (key == 'red') {
      return const _CardThemeStyle(
        gradientColors: <Color>[Color(0xFF4A1C3D), Color(0xFF28163D)],
        borderColor: Color(0x22FF7A8A),
        accentColor: Color(0xFFFF7A8A),
      );
    }
    if (key == 'blue') {
      return const _CardThemeStyle(
        gradientColors: <Color>[Color(0xFF161B56), Color(0xFF171444)],
        borderColor: Color(0x224CE3FF),
        accentColor: Color(0xFF39E6FF),
      );
    }
    final String currency = item.currency.trim().toUpperCase();
    if (currency == 'USD') {
      return const _CardThemeStyle(
        gradientColors: <Color>[Color(0xFF2A185C), Color(0xFF1E144A)],
        borderColor: Color(0x226E5AFF),
        accentColor: Color(0xFF8A7DFF),
      );
    }
    return const _CardThemeStyle(
      gradientColors: <Color>[Color(0xFF161B56), Color(0xFF171444)],
      borderColor: Color(0x224CE3FF),
      accentColor: Color(0xFF39E6FF),
    );
  }
}

extension on InvestProductItem {
  String get interestModeLabel {
    return '每日返息';
  }
}

class _CardThemeStyle {
  const _CardThemeStyle({
    required this.gradientColors,
    required this.borderColor,
    required this.accentColor,
  });

  final List<Color> gradientColors;
  final Color borderColor;
  final Color accentColor;
}
