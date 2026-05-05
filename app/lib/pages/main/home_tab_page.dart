import 'dart:async';

import 'package:flutter/material.dart';

import 'package:myapp/config/app_images.dart';
import 'package:myapp/pages/product/invest_product_list_page.dart';
import 'package:myapp/pages/product/invest_product_detail_page.dart';
import 'package:myapp/request/invest_product_api.dart';
import 'package:myapp/request/news_api.dart';
import 'package:myapp/routers/app_router.dart';
import 'package:myapp/widgets/app_network_image.dart';

class HomeTabPage extends StatefulWidget {
  const HomeTabPage({super.key});

  @override
  State<HomeTabPage> createState() => _HomeTabPageState();
}

class _HomeTabPageState extends State<HomeTabPage> {
  bool _loading = true;
  List<NewsArticle> _remoteBanners = <NewsArticle>[];
  List<NewsArticle> _remoteAds = <NewsArticle>[];
  List<HomeNotice> _notices = <HomeNotice>[];
  List<HomeLatestNewsItem> _latestNews = <HomeLatestNewsItem>[];
  List<InvestProductItem> _hotProducts = <InvestProductItem>[];
  final PageController _bannerController = PageController();
  final PageController _adController = PageController();
  final PageController _hotController = PageController();
  Timer? _bannerTimer;
  Timer? _adTimer;
  Timer? _noticeTimer;
  Timer? _hotTimer;
  int _bannerPage = 0;
  int _adPage = 0;
  int _noticePage = 0;
  int _hotPage = 0;

  Future<T?> _pushHomeRoute<T extends Object?>(
    String routeName, {
    Map<String, dynamic>? extraArgs,
  }) {
    final Map<String, dynamic> args = <String, dynamic>{
      'showBottomNav': true,
      'showBottomNavIndex': 0,
      ...?extraArgs,
    };
    return Navigator.pushNamed<T>(context, routeName, arguments: args);
  }

  Future<void> _openNewsDetail(HomeLatestNewsItem item) async {
    NewsArticle article = NewsArticle.fromJson(<String, dynamic>{
      'articleId': item.articleId,
      'articleTitle': item.articleTitle,
      'summary': item.summary,
      'coverImage': item.coverImage,
      'articleContent': item.summary,
      'status': '0',
    });
    try {
      article = await NewsApi.fetchArticleDetail(item.articleId);
    } catch (_) {
      // Keep fallback from list payload when detail request fails.
    }
    if (!mounted) {
      return;
    }
    await _pushHomeRoute(
      AppRouter.newsDetail,
      extraArgs: <String, dynamic>{'article': article},
    );
  }

  @override
  void initState() {
    super.initState();
    _loadHomeData();
    _startAutoTickers();
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _adTimer?.cancel();
    _noticeTimer?.cancel();
    _hotTimer?.cancel();
    _bannerController.dispose();
    _adController.dispose();
    _hotController.dispose();
    super.dispose();
  }

  Future<void> _loadHomeData({bool forceRefresh = false}) async {
    if (!mounted) {
      return;
    }
    if (!forceRefresh) {
      final List<HomeLatestNewsItem> cachedNews =
          await NewsApi.getCachedHomeLatestNews();
      final List<InvestProductItem> cachedHotProducts =
          await InvestProductApi.getCachedHomeHotProducts();
      if (mounted && (cachedNews.isNotEmpty || cachedHotProducts.isNotEmpty)) {
        setState(() {
          if (cachedNews.isNotEmpty) {
            _latestNews = cachedNews;
          }
          if (cachedHotProducts.isNotEmpty) {
            _hotProducts = cachedHotProducts;
            _hotPage = 0;
          }
        });
      }
    }
    setState(() {
      _loading = true;
    });
    try {
      final List<dynamic> results = await Future.wait<dynamic>(<Future<dynamic>>[
        NewsApi.fetchHomePayload(),
        NewsApi.fetchHomeLatestNews(forceRefresh: forceRefresh),
        InvestProductApi.fetchHomeHotProducts(forceRefresh: forceRefresh),
      ]);
      final HomeNewsPayload homePayload = results[0] as HomeNewsPayload;
      if (!mounted) {
        return;
      }
      setState(() {
        _remoteBanners = homePayload.banners;
        _remoteAds = homePayload.ads;
        _notices = homePayload.notices;
        _latestNews = (results[1] as List<HomeLatestNewsItem>);
        _hotProducts = (results[2] as List<InvestProductItem>);
        _bannerPage = 0;
        _adPage = 0;
        _noticePage = 0;
        _hotPage = 0;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _remoteBanners = _remoteBanners;
        _remoteAds = _remoteAds;
        _notices = _notices;
        _latestNews = _latestNews;
        _hotProducts = _hotProducts;
      });
    } finally {
      if (!mounted) {
        return;
      }
      setState(() {
        _loading = false;
      });
    }
  }

  void _startAutoTickers() {
    _bannerTimer?.cancel();
    _bannerTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted || _remoteBanners.length <= 1 || !_bannerController.hasClients) {
        return;
      }
      _bannerPage = (_bannerPage + 1) % _remoteBanners.length;
      _bannerController.animateToPage(
        _bannerPage,
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOut,
      );
    });

    _adTimer?.cancel();
    _adTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted || _remoteAds.length <= 1 || !_adController.hasClients) {
        return;
      }
      _adPage = (_adPage + 1) % _remoteAds.length;
      _adController.animateToPage(
        _adPage,
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOut,
      );
    });

    _noticeTimer?.cancel();
    _noticeTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted || _notices.length <= 1) {
        return;
      }
      setState(() {
        _noticePage = (_noticePage + 1) % _notices.length;
      });
    });

    _hotTimer?.cancel();
    _hotTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted || _hotProducts.length <= 1 || !_hotController.hasClients) {
        return;
      }
      _hotPage = (_hotPage + 1) % _hotProducts.length;
      _hotController.animateToPage(
        _hotPage,
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: Stack(
        children: <Widget>[
          Positioned(
            top: -110,
            right: -80,
            child: _blurBall(
              size: 250,
              color: const Color(0x5539E6FF),
            ),
          ),
          Positioned(
            bottom: -150,
            left: -90,
            child: _blurBall(
              size: 320,
              color: const Color(0x5538FFB3),
            ),
          ),
          Positioned(
            top: 260,
            left: 130,
            child: _blurBall(
              size: 180,
              color: const Color(0x3324C6FF),
            ),
          ),
          SafeArea(
            child: RefreshIndicator(
              onRefresh: () => _loadHomeData(forceRefresh: true),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(14, 8, 14, 18),
                children: <Widget>[
                  _buildHeader(),
                  const SizedBox(height: 10),
                  _buildTopActions(),
                  const SizedBox(height: 12),
                  _buildHeroCard(),
                  const SizedBox(height: 12),
                  _buildFeatureGrid(),
                  const SizedBox(height: 12),
                  _buildBannerSection(),
                  const SizedBox(height: 10),
                  _buildNoticeRow(),
                  const SizedBox(height: 10),
                  _buildHotProductsSection(),
                  const SizedBox(height: 14),
                  _buildNewsSection(),
                  if (_loading) ...<Widget>[
                    const SizedBox(height: 14),
                    const Center(
                      child: SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
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

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      decoration: _panelDecoration(),
      child: Row(
        children: <Widget>[
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(17),
              border: Border.all(color: const Color(0x66FFFFFF)),
            ),
            clipBehavior: Clip.antiAlias,
            child: Image.asset(AppImages.homeLogo, fit: BoxFit.cover),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: SizedBox(
              height: 30,
              child: Image.asset(
                AppImages.homeLogo1,
                fit: BoxFit.contain,
                alignment: Alignment.centerLeft,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopActions() {
    final List<_HomeActionItem> items = <_HomeActionItem>[
      _HomeActionItem(
        '充值',
        Icons.savings_outlined,
        const Color(0xFF39E6FF),
        () {
        _pushHomeRoute(AppRouter.recharge);
      },
      ),
      _HomeActionItem(
        '提现',
        Icons.account_balance_wallet_outlined,
        const Color(0xFF38FFB3),
        () {
        _pushHomeRoute(AppRouter.withdraw);
      },
      ),
      _HomeActionItem('领矿', Icons.memory_rounded, const Color(0xFFFFA500), () {
        _pushHomeRoute(AppRouter.miner);
      }),
      _HomeActionItem('推广', Icons.groups_outlined, const Color(0xFF39E6FF), () {
        _pushHomeRoute(AppRouter.myTeam);
      }),
      _HomeActionItem(
        '邀请',
        Icons.person_add_alt_1_outlined,
        const Color(0xFF38FFB3),
        () {
        _pushHomeRoute(AppRouter.inviteFriend);
      },
      ),
    ];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: _panelDecoration(),
      child: Row(
        children: items
            .map(
              (_HomeActionItem item) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: _buildActionButton(item),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildActionButton(_HomeActionItem item) {
    return InkWell(
      onTap: item.onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 78,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _buildGlowCircleIcon(item),
            const SizedBox(height: 8),
            Text(
              item.label,
              style: const TextStyle(
                color: Color(0xFF9DB1C9),
                fontSize: 11,
                height: 1.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroCard() {
    final List<_BannerSource> sources = _resolveBannerSources();
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
      decoration: _panelDecoration(
        colors: const <Color>[Color(0xCC101C30), Color(0xCC0E1A2D)],
      ),
      child: AspectRatio(
        aspectRatio: 1161 / 473,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: PageView.builder(
            controller: _bannerController,
            itemCount: sources.length,
            onPageChanged: (int index) {
              _bannerPage = index;
            },
            itemBuilder: (_, int index) {
              final _BannerSource item = sources[index];
              return InkWell(
                onTap: item.onTap,
                child: item.isAsset
                    ? Image.asset(
                        item.value,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      )
                    : AppNetworkImage(
                        src: item.value,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Image.asset(
                          AppImages.homeBanner1,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureGrid() {
    final List<_HomeActionItem> items = <_HomeActionItem>[
      _HomeActionItem(
        '每日签到',
        Icons.event_available_outlined,
        const Color(0xFFE2FF59),
        () {
        _pushHomeRoute(AppRouter.signIn);
      },
      ),
      _HomeActionItem(
        '会员等级',
        Icons.workspace_premium_outlined,
        const Color(0xFFE2FF59),
        () {
        _pushHomeRoute(AppRouter.memberCenter);
      },
      ),
      _HomeActionItem(
        '实名认证',
        Icons.verified_user_outlined,
        const Color(0xFFE2FF59),
        () {
        _pushHomeRoute(AppRouter.realNameAuth);
      },
      ),
      _HomeActionItem('我的团队', Icons.groups_outlined, const Color(0xFF39E6FF), () {
        _pushHomeRoute(AppRouter.myTeam);
      }),
      _HomeActionItem(
        '我的矿机',
        Icons.precision_manufacturing_outlined,
        const Color(0xFFFFA500),
        () {
        _pushHomeRoute(AppRouter.miner);
      },
      ),
      _HomeActionItem(
        '幸运魔方',
        Icons.view_in_ar_outlined,
        const Color(0xFF9DB1C9),
        () {},
      ),
      _HomeActionItem('口令红包', Icons.redeem_outlined, const Color(0xFF39E6FF), () {}),
      _HomeActionItem(
        '余额宝',
        Icons.savings_rounded,
        const Color(0xFFFFA500),
        () {
        _pushHomeRoute(AppRouter.balanceTreasure);
      },
      ),
      _HomeActionItem(
        '我的资产',
        Icons.account_balance_wallet_rounded,
        const Color(0xFFFFA500),
        () {
        _pushHomeRoute(AppRouter.assets);
      },
      ),
      _HomeActionItem('算力奖池', Icons.pool_outlined, const Color(0xFF38FFB3), () {}),
    ];
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
      decoration: _panelDecoration(),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: items.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 5,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 0.74,
        ),
        itemBuilder: (BuildContext context, int index) {
          return _buildFeatureItem(items[index]);
        },
      ),
    );
  }

  Widget _buildFeatureItem(_HomeActionItem item) {
    return InkWell(
      onTap: item.onTap,
      borderRadius: BorderRadius.circular(12),
      child: Column(
        children: <Widget>[
          _buildGlowCircleIcon(item),
          const SizedBox(height: 6),
          Text(
            item.label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF9DB1C9),
              fontSize: 11,
              height: 1.0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlowCircleIcon(_HomeActionItem item) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: <Color>[
            item.iconColor.withOpacity(0.35),
            item.iconColor.withOpacity(0.10),
          ],
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: item.iconColor.withOpacity(0.25),
            blurRadius: 12,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Icon(
        item.icon,
        size: 24,
        color: item.iconColor,
      ),
    );
  }

  Widget _buildBannerSection() {
    final List<_BannerSource> sources = _resolveAdSources();
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
      decoration: _panelDecoration(),
      child: SizedBox(
        height: 104,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: PageView.builder(
            controller: _adController,
            itemCount: sources.length,
            onPageChanged: (int index) {
              _adPage = index;
            },
            itemBuilder: (_, int index) {
              final _BannerSource item = sources[index];
              return InkWell(
                onTap: item.onTap,
                child: item.isAsset
                    ? Image.asset(
                        item.value,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      )
                    : AppNetworkImage(
                        src: item.value,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Image.asset(
                          AppImages.homeBanner2,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
              );
            },
          ),
        ),
      ),
    );
  }

  List<_BannerSource> _resolveBannerSources() {
    if (_remoteBanners.isNotEmpty) {
      return _remoteBanners
          .where((NewsArticle item) => item.resolvedCoverUrl() != null && item.resolvedCoverUrl()!.isNotEmpty)
          .map(_bannerFromArticle)
          .toList();
    }
    return <_BannerSource>[_BannerSource.asset(AppImages.homeBanner1)];
  }

  List<_BannerSource> _resolveAdSources() {
    if (_remoteAds.isNotEmpty) {
      return _remoteAds
          .where((NewsArticle item) => item.resolvedCoverUrl() != null && item.resolvedCoverUrl()!.isNotEmpty)
          .map(_bannerFromArticle)
          .toList();
    }
    return <_BannerSource>[_BannerSource.asset(AppImages.homeBanner2)];
  }

  _BannerSource _bannerFromArticle(NewsArticle article) {
    final String cover = article.resolvedCoverUrl() ?? '';
    final String link = article.summary.trim();
    return _BannerSource.network(
      cover,
      onTap: link.isNotEmpty ? () => _openLink(link) : null,
    );
  }

  void _openLink(String value) {
    final String v = value.trim();
    if (v.isEmpty) {
      return;
    }
    if (v.startsWith('app://')) {
      final Uri uri = Uri.tryParse(v) ?? Uri();
      if (uri.host == 'product' && (uri.path == '/group' || uri.path == '/group-zone')) {
        Navigator.push(
          context,
          MaterialPageRoute<void>(
            builder: (_) => const InvestProductListPage(
              initialTag: '拼团',
              showBottomNav: true,
            ),
          ),
        );
        return;
      }
      if (uri.host == 'product' && uri.path == '/detail') {
        final int productId = int.tryParse(uri.queryParameters['productId'] ?? '') ?? 0;
        if (productId > 0) {
          Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder: (_) => InvestProductDetailPage(productId: productId),
            ),
          );
        }
        return;
      }
    }
    if (v.startsWith('http://') || v.startsWith('https://')) {
      Navigator.pushNamed(
        context,
        AppRouter.newsDetail,
        arguments: NewsArticle(
          articleId: 0,
          categoryId: 0,
          categoryCode: '',
          categoryName: '',
          articleTitle: '广告详情',
          summary: '',
          coverImage: '',
          articleContent: '<p><a href="$v">$v</a></p>',
          sortOrder: 0,
          topFlag: '0',
          status: '0',
        ),
      );
    }
  }

  Widget _buildNoticeRow() {
    final List<String> noticeTexts = _notices.isNotEmpty
        ? _notices
            .map((HomeNotice item) => item.noticeTitle.trim().isNotEmpty ? item.noticeTitle.trim() : item.noticeContent.trim())
            .where((String text) => text.isNotEmpty)
            .toList()
        : <String>['系统通知：欢迎使用'];
    final String notice = noticeTexts[_noticePage % noticeTexts.length];
    return Container(
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: _panelDecoration(
        colors: const <Color>[Color(0xCC101C30), Color(0xCC0E1A2D)],
      ),
      child: Row(
        children: <Widget>[
          const Icon(Icons.bolt_rounded, color: Color(0xFFEBF2FF), size: 17),
          const SizedBox(width: 6),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 260),
              transitionBuilder: (Widget child, Animation<double> animation) {
                final Animation<Offset> offset = Tween<Offset>(
                  begin: const Offset(0, 0.6),
                  end: Offset.zero,
                ).animate(animation);
                return SlideTransition(position: offset, child: child);
              },
              child: Text(
                notice,
                key: ValueKey<String>(notice),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Color(0xFFD5E8FF), fontSize: 15),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHotProductsSection() {
    final List<InvestProductItem> rows = _hotProducts;
    if (rows.isEmpty) {
      return Container(
        decoration: _panelDecoration(
          colors: const <Color>[Color(0xCC101C30), Color(0xCC0E1A2D)],
        ),
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
        child: const Text(
          '暂无推荐产品',
          style: TextStyle(color: Color(0xFFE9F3FF), fontSize: 16),
        ),
      );
    }
    return SizedBox(
      height: 186,
      child: PageView.builder(
        controller: _hotController,
        itemCount: rows.length,
        onPageChanged: (int index) {
          _hotPage = index;
        },
        itemBuilder: (_, int index) => _buildHotProductCard(rows[index]),
      ),
    );
  }

  Widget _buildHotProductCard(InvestProductItem item) {
    final double progress = (item.progressPercent.clamp(0, 100)) / 100;
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute<void>(
            builder: (_) => InvestProductDetailPage(
              productId: item.productId,
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(14),
      child: Container(
        decoration: _panelDecoration(
          colors: const <Color>[Color(0xCC101C30), Color(0xCC0E1A2D)],
        ),
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
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
                    style: const TextStyle(
                      color: Color(0xFFEAF4FF),
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0x331F3E66),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0x334CE3FF)),
                  ),
                  child: const Text(
                    '购买',
                    style: TextStyle(
                      color: Color(0xFF8DD3FF),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: <Widget>[
                Expanded(
                  child: _statCell(
                    value: '${item.singleRate.toStringAsFixed(3)} %',
                    label: '单购利率',
                  ),
                ),
                Container(
                  width: 1,
                  height: 48,
                  color: const Color(0x446B8BD5),
                ),
                Expanded(
                  child: _statCell(
                    value: '${item.cycleDays} 天',
                    label: '${item.minInvestAmount.toStringAsFixed(0)}元起投',
                    alignEnd: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: <Widget>[
                Image.asset(
                  AppImages.currencyBrand(item.currency),
                  width: 16,
                  height: 16,
                  fit: BoxFit.contain,
                ),
                const SizedBox(width: 6),
                Text(
                  '${item.currency} 剩余 ${item.remainingAmount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Color(0xFF9DB1C9),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: <Widget>[
                const Text(
                  '进度',
                  style: TextStyle(color: Color(0xFF9DB1C9), fontSize: 12),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 8,
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF39E6FF)),
                      backgroundColor: const Color(0xFF2E3468),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${item.progressPercent.toStringAsFixed(2)}%',
                  style: const TextStyle(color: Color(0xFF9DB1C9), fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _statCell({
    required String value,
    required String label,
    bool alignEnd = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        crossAxisAlignment:
            alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF39E6FF),
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(color: Color(0xFF9DB1C9), fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildNewsSection() {
    final List<HomeLatestNewsItem> rows =
        _latestNews.length > 4 ? _latestNews.sublist(0, 4) : _latestNews;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text(
          '最新资讯',
          style: TextStyle(
            color: Color(0xFFF1F7FF),
            fontSize: 19,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: rows.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 1.18,
          ),
          itemBuilder: (_, int index) => _buildNewsCard(rows[index]),
        ),
      ],
    );
  }

  Widget _buildNewsCard(HomeLatestNewsItem item) {
    final String? cover = item.resolvedCoverUrl();
    final String summary = item.summary.trim().isEmpty ? '暂无摘要' : item.summary.trim();
    return InkWell(
      onTap: () => _openNewsDetail(item),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
        decoration: _panelDecoration(
          colors: const <Color>[Color(0xCC101C30), Color(0xCC0E1A2D)],
          radius: 10,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: cover == null || cover.isEmpty
                      ? Container(
                          width: 60,
                          height: 52,
                          color: const Color(0xFF223A94),
                          child: const Icon(
                            Icons.image_outlined,
                            color: Color(0xFF9DD6FF),
                            size: 22,
                          ),
                        )
                      : AppNetworkImage(
                          src: cover,
                          width: 60,
                          height: 52,
                          fit: BoxFit.cover,
                        ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    item.articleTitle,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFFCEDFFF),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              summary,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF9DB1C9),
                fontSize: 12,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  BoxDecoration _panelDecoration({
    List<Color> colors = const <Color>[Color(0xCC101C30), Color(0xCC0E1A2D)],
    double radius = 14,
  }) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(radius),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: colors,
      ),
      border: Border.all(color: const Color(0x335B83D8)),
      backgroundBlendMode: BlendMode.srcOver,
      boxShadow: const <BoxShadow>[
        BoxShadow(
          color: Color(0x66000000),
          blurRadius: 22,
          offset: Offset(0, 8),
        ),
      ],
    );
  }
}

class _HomeActionItem {
  const _HomeActionItem(this.label, this.icon, this.iconColor, this.onTap);

  final String label;
  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;
}

class _BannerSource {
  const _BannerSource._({
    required this.value,
    required this.isAsset,
    this.onTap,
  });

  factory _BannerSource.asset(String path, {VoidCallback? onTap}) {
    return _BannerSource._(value: path, isAsset: true, onTap: onTap);
  }

  factory _BannerSource.network(String url, {VoidCallback? onTap}) {
    return _BannerSource._(value: url, isAsset: false, onTap: onTap);
  }

  final String value;
  final bool isAsset;
  final VoidCallback? onTap;
}
