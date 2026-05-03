import 'package:flutter/material.dart';

import 'package:myapp/config/app_localizations.dart';
import 'package:myapp/request/news_api.dart';
import 'package:myapp/routers/app_router.dart';
import 'package:myapp/widgets/app_network_image.dart';

class NewsPage extends StatefulWidget {
  const NewsPage({super.key});

  @override
  State<NewsPage> createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  List<NewsCategory> _categories = const <NewsCategory>[];
  String? _selectedCode;
  Future<List<NewsArticle>>? _articlesFuture;
  bool _loadingCategories = true;
  static const String _bootstrapCategoryCode = 'NEWS_INFO';

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories({bool forceRefresh = false}) async {
    try {
      final String bootstrapCode = _selectedCode ?? _bootstrapCategoryCode;
      if (_articlesFuture == null && !forceRefresh) {
        _articlesFuture = NewsApi.fetchArticles(categoryCode: bootstrapCode);
      }
      final List<NewsCategory> categories = await NewsApi.fetchCategories(forceRefresh: forceRefresh);
      if (!mounted) return;
      final List<NewsCategory> resolved = categories.isNotEmpty
          ? categories
          : const <NewsCategory>[
              NewsCategory(categoryId: 1, categoryCode: 'NEWS_INFO', categoryName: '新闻资讯', sortOrder: 1, status: '0'),
              NewsCategory(categoryId: 2, categoryCode: 'COMPANY_INFO', categoryName: '公司信息', sortOrder: 2, status: '0'),
            ];
      setState(() {
        _categories = resolved;
        final String resolvedCode = _selectedCode ?? resolved.first.categoryCode;
        _selectedCode = resolvedCode;
        if (forceRefresh || _articlesFuture == null || resolvedCode != bootstrapCode) {
          _articlesFuture = NewsApi.fetchArticles(
            categoryCode: resolvedCode,
            forceRefresh: forceRefresh,
          );
        }
        _loadingCategories = false;
      });
    } catch (_) {
      if (!mounted) return;
      final List<NewsCategory> fallback = const <NewsCategory>[
        NewsCategory(categoryId: 1, categoryCode: 'NEWS_INFO', categoryName: '新闻资讯', sortOrder: 1, status: '0'),
        NewsCategory(categoryId: 2, categoryCode: 'COMPANY_INFO', categoryName: '公司信息', sortOrder: 2, status: '0'),
      ];
      setState(() {
        _categories = fallback;
        final String resolvedCode = _selectedCode ?? fallback.first.categoryCode;
        _selectedCode = resolvedCode;
        if (forceRefresh || _articlesFuture == null || resolvedCode != _bootstrapCategoryCode) {
          _articlesFuture = NewsApi.fetchArticles(
            categoryCode: resolvedCode,
            forceRefresh: forceRefresh,
          );
        }
        _loadingCategories = false;
      });
    }
  }

  Future<void> _refresh() async {
    await _loadCategories(forceRefresh: true);
  }

  void _selectCategory(String categoryCode) {
    if (_selectedCode == categoryCode) return;
    setState(() {
      _selectedCode = categoryCode;
      _articlesFuture = NewsApi.fetchArticles(categoryCode: categoryCode);
    });
  }

  String _tabTitle(NewsCategory category, AppLocalizations i18n) {
    if (category.categoryCode == 'COMPANY_INFO') {
      return i18n.t('newsAboutUs');
    }
    return i18n.t('newsInfo');
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations i18n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFF0A0828),
      appBar: AppBar(
        title: Text(i18n.t('newsTitle')),
        backgroundColor: const Color(0xFF0A0828),
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: const Color(0xFF39E6FF),
          onRefresh: _refresh,
          child: Column(
            children: <Widget>[
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _categories.map((NewsCategory item) {
                      final bool active = item.categoryCode == _selectedCode;
                      return Padding(
                        padding: const EdgeInsets.only(right: 16),
                        child: GestureDetector(
                          onTap: () => _selectCategory(item.categoryCode),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: active ? const Color(0xFF0F1F4A) : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: active ? const Color(0xFF34A7FF) : Colors.transparent, width: 1.2),
                              boxShadow: active
                                  ? const <BoxShadow>[
                                      BoxShadow(color: Color(0x332B7DFF), blurRadius: 16, offset: Offset(0, 8)),
                                    ]
                                  : null,
                            ),
                            child: Text(
                              _tabTitle(item, i18n),
                              style: TextStyle(
                                color: active ? const Color(0xFF5BC8FF) : const Color(0xFF9DB1C9),
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: _loadingCategories
                    ? const Center(
                        child: CircularProgressIndicator(color: Color(0xFF39E6FF)),
                      )
                    : FutureBuilder<List<NewsArticle>>(
                        future: _articlesFuture,
                        builder: (BuildContext context, AsyncSnapshot<List<NewsArticle>> snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(color: Color(0xFF39E6FF)),
                            );
                          }
                          if (snapshot.hasError || !snapshot.hasData) {
                            return _buildEmptyState(i18n);
                          }
                          final List<NewsArticle> articles = snapshot.data!;
                          if (articles.isEmpty) {
                            return _buildEmptyState(i18n);
                          }
                          return ListView.separated(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
                            itemCount: articles.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 14),
                            itemBuilder: (BuildContext context, int index) {
                              final NewsArticle article = articles[index];
                              final String? coverUrl = article.resolvedCoverUrl();
                              return GestureDetector(
                                onTap: () {
                                  Navigator.pushNamed(
                                    context,
                                    AppRouter.newsDetail,
                                    arguments: {'article': article},
                                  );
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF0F163F),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: const Color(0x2234A7FF)),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(14),
                                    child: Row(
                                      children: <Widget>[
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Text(
                                                article.articleTitle,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  color: Color(0xFFEAF5FF),
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w800,
                                                  height: 1.2,
                                                ),
                                              ),
                                              const SizedBox(height: 10),
                                              Text(
                                                article.summary.isNotEmpty ? article.summary : article.articleContent,
                                                maxLines: 3,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  color: Color(0xFF9DB1C9),
                                                  fontSize: 13,
                                                  height: 1.5,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(14),
                                          child: Container(
                                            width: 132,
                                            height: 92,
                                            color: const Color(0xFF394052),
                                            child: coverUrl == null
                                                ? const Icon(Icons.image_outlined, color: Color(0xFF7D8CA8), size: 36)
                                                : AppNetworkImage(
                                                    src: coverUrl,
                                                    fit: BoxFit.cover,
                                                    errorBuilder: (_, __, ___) => const Icon(
                                                      Icons.image_outlined,
                                                      color: Color(0xFF7D8CA8),
                                                      size: 36,
                                                    ),
                                                  ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(AppLocalizations i18n) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: <Widget>[
        const SizedBox(height: 120),
        const Icon(Icons.feed_outlined, color: Color(0xFF39E6FF), size: 56),
        const SizedBox(height: 12),
        Text(
          i18n.t('newsEmptyTitle'),
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFFEAF5FF),
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
