import 'dart:async';
import 'dart:convert';

import 'package:myapp/request/api_client.dart';
import 'package:myapp/request/api_response.dart';
import 'package:myapp/request/ruoyi_endpoints.dart';
import 'package:shared_preferences/shared_preferences.dart';

int _toInt(dynamic value) {
  if (value is int) {
    return value;
  }
  return int.tryParse('${value ?? 0}') ?? 0;
}

class NewsCategory {
  const NewsCategory({
    required this.categoryId,
    required this.categoryCode,
    required this.categoryName,
    required this.sortOrder,
    required this.status,
  });

  final int categoryId;
  final String categoryCode;
  final String categoryName;
  final int sortOrder;
  final String status;

  factory NewsCategory.fromJson(Map<String, dynamic> json) {
    return NewsCategory(
      categoryId: _toInt(json['categoryId'] ?? json['category_id']),
      categoryCode: (json['categoryCode'] ?? json['category_code'] ?? '').toString(),
      categoryName: (json['categoryName'] ?? json['category_name'] ?? '').toString(),
      sortOrder: _toInt(json['sortOrder'] ?? json['sort_order']),
      status: (json['status'] ?? '').toString(),
    );
  }
}

class NewsArticle {
  const NewsArticle({
    required this.articleId,
    required this.categoryId,
    required this.categoryCode,
    required this.categoryName,
    required this.articleTitle,
    required this.summary,
    required this.coverImage,
    required this.articleContent,
    required this.sortOrder,
    required this.topFlag,
    required this.status,
  });

  final int articleId;
  final int categoryId;
  final String categoryCode;
  final String categoryName;
  final String articleTitle;
  final String summary;
  final String coverImage;
  final String articleContent;
  final int sortOrder;
  final String topFlag;
  final String status;

  factory NewsArticle.fromJson(Map<String, dynamic> json) {
    return NewsArticle(
      articleId: _toInt(json['articleId'] ?? json['article_id']),
      categoryId: _toInt(json['categoryId'] ?? json['category_id']),
      categoryCode: (json['categoryCode'] ?? json['category_code'] ?? '').toString(),
      categoryName: (json['categoryName'] ?? json['category_name'] ?? '').toString(),
      articleTitle: (json['articleTitle'] ?? json['article_title'] ?? '').toString(),
      summary: (json['summary'] ?? '').toString(),
      coverImage: (json['coverImage'] ?? json['cover_image'] ?? '').toString(),
      articleContent: (json['articleContent'] ?? json['article_content'] ?? '').toString(),
      sortOrder: _toInt(json['sortOrder'] ?? json['sort_order']),
      topFlag: (json['topFlag'] ?? json['top_flag'] ?? '0').toString(),
      status: (json['status'] ?? '').toString(),
    );
  }

  String? resolvedCoverUrl() {
    return ApiClient.instance.resolveImageUrl(coverImage);
  }
}

class NewsApi {
  const NewsApi._();

  static const Duration _cacheMaxAge = Duration(minutes: 10);
  static const String _categoriesCacheKey = 'news.cache.categories.v1';
  static const String _categoriesUpdatedAtKey = 'news.cache.categories.updatedAt.v1';
  static const String _articlesCachePrefix = 'news.cache.articles.v1.';
  static const String _articlesUpdatedAtPrefix = 'news.cache.articles.updatedAt.v1.';

  static Future<List<NewsCategory>> fetchCategories({bool forceRefresh = false}) async {
    if (!forceRefresh) {
      final List<NewsCategory>? cached = await _readCategoryCache(allowStale: true);
      if (cached != null) {
        final bool fresh = await _readCategoryCache() != null;
        if (!fresh) {
          unawaited(_refreshCategoriesInBackground());
        }
        return cached;
      }
    }

    try {
      final List<NewsCategory> categories = await _fetchCategoriesRemote();
      await _saveCategoryCache(categories);
      return categories;
    } catch (_) {
      final List<NewsCategory>? cached = await _readCategoryCache(allowStale: true);
      return cached ?? <NewsCategory>[];
    }
  }

  static Future<List<NewsArticle>> fetchArticles({
    String? categoryCode,
    bool forceRefresh = false,
  }) async {
    final String safeCategoryCode = (categoryCode ?? '').trim().isEmpty ? 'NEWS_INFO' : categoryCode!.trim();
    if (!forceRefresh) {
      final List<NewsArticle>? cached = await _readArticlesCache(safeCategoryCode, allowStale: true);
      if (cached != null) {
        final bool fresh = await _readArticlesCache(safeCategoryCode) != null;
        if (!fresh) {
          unawaited(_refreshArticlesInBackground(safeCategoryCode));
        }
        return cached;
      }
    }

    final Map<String, dynamic> query = <String, dynamic>{
      'status': '0',
      if (safeCategoryCode.isNotEmpty) 'categoryCode': safeCategoryCode,
    };
    try {
      final List<NewsArticle> articles = await _fetchArticlesRemote(query);
      await _saveArticlesCache(safeCategoryCode, articles);
      return articles;
    } catch (_) {
      final List<NewsArticle>? cached = await _readArticlesCache(
        safeCategoryCode,
        allowStale: true,
      );
      return cached ?? <NewsArticle>[];
    }
  }

  static Future<NewsArticle> fetchArticleDetail(int articleId) async {
    final ApiResponse<dynamic> response = await ApiClient.instance.get(RuoYiEndpoints.newsDetail(articleId));
    final dynamic raw = response.data;
    final dynamic payload = raw is Map<String, dynamic>
        ? (raw['data'] ?? raw['rows'] ?? raw['list'])
        : response.raw['data'] ?? response.raw['rows'] ?? response.raw['list'];
    final Map<String, dynamic> data = payload is Map
        ? Map<String, dynamic>.from(payload as Map)
        : <String, dynamic>{};
    return NewsArticle.fromJson(data);
  }

  static Future<List<NewsCategory>> _fetchCategoriesRemote() async {
    final ApiResponse<dynamic> response = await ApiClient.instance.get(RuoYiEndpoints.newsCategories);
    final dynamic raw = response.data;
    final dynamic payload = raw is List
        ? raw
        : raw is Map<String, dynamic>
            ? (raw['data'] ?? raw['rows'] ?? raw['list'])
            : response.raw['data'] ?? response.raw['rows'] ?? response.raw['list'];
    final List<dynamic> rows = payload is List ? payload : <dynamic>[];
    return rows
        .whereType<Map>()
        .map((dynamic item) => NewsCategory.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList();
  }

  static Future<void> _refreshCategoriesInBackground() async {
    try {
      final List<NewsCategory> categories = await _fetchCategoriesRemote();
      await _saveCategoryCache(categories);
    } catch (_) {}
  }

  static Future<List<NewsArticle>> _fetchArticlesRemote(Map<String, dynamic> query) async {
    final ApiResponse<dynamic> response = await ApiClient.instance.get(RuoYiEndpoints.newsList, query: query);
    final dynamic raw = response.data;
    final dynamic payload = raw is List
        ? raw
        : raw is Map<String, dynamic>
            ? (raw['data'] ?? raw['rows'] ?? raw['list'])
            : response.raw['data'] ?? response.raw['rows'] ?? response.raw['list'];
    final List<dynamic> rows = payload is List ? payload : <dynamic>[];
    return rows
        .whereType<Map>()
        .map((dynamic item) => NewsArticle.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList();
  }

  static Future<void> _refreshArticlesInBackground(String categoryCode) async {
    try {
      final Map<String, dynamic> query = <String, dynamic>{
        'status': '0',
        if (categoryCode.isNotEmpty) 'categoryCode': categoryCode,
      };
      final List<NewsArticle> articles = await _fetchArticlesRemote(query);
      await _saveArticlesCache(categoryCode, articles);
    } catch (_) {}
  }

  static Future<List<NewsCategory>?> _readCategoryCache({bool allowStale = false}) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String raw = (prefs.getString(_categoriesCacheKey) ?? '').trim();
    if (raw.isEmpty) {
      return null;
    }
    final int? updatedAt = prefs.getInt(_categoriesUpdatedAtKey);
    if (!allowStale && !_isCacheFresh(updatedAt)) {
      return null;
    }
    return _decodeCategories(raw);
  }

  static Future<void> _saveCategoryCache(List<NewsCategory> categories) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _categoriesCacheKey,
      jsonEncode(categories.map((NewsCategory item) => item.toJson()).toList()),
    );
    await prefs.setInt(_categoriesUpdatedAtKey, DateTime.now().millisecondsSinceEpoch);
  }

  static Future<List<NewsArticle>?> _readArticlesCache(
    String categoryCode, {
    bool allowStale = false,
  }) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String raw = (prefs.getString(_articlesCacheKey(categoryCode)) ?? '').trim();
    if (raw.isEmpty) {
      return null;
    }
    final int? updatedAt = prefs.getInt(_articlesUpdatedAtKey(categoryCode));
    if (!allowStale && !_isCacheFresh(updatedAt)) {
      return null;
    }
    return _decodeArticles(raw);
  }

  static Future<void> _saveArticlesCache(String categoryCode, List<NewsArticle> articles) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _articlesCacheKey(categoryCode),
      jsonEncode(articles.map((NewsArticle item) => item.toJson()).toList()),
    );
    await prefs.setInt(_articlesUpdatedAtKey(categoryCode), DateTime.now().millisecondsSinceEpoch);
  }

  static bool _isCacheFresh(int? updatedAt) {
    if (updatedAt == null) {
      return true;
    }
    final int ageMs = DateTime.now().millisecondsSinceEpoch - updatedAt;
    return ageMs >= 0 && ageMs <= _cacheMaxAge.inMilliseconds;
  }

  static String _articlesCacheKey(String categoryCode) {
    return '$_articlesCachePrefix$categoryCode';
  }

  static String _articlesUpdatedAtKey(String categoryCode) {
    return '$_articlesUpdatedAtPrefix$categoryCode';
  }

  static List<NewsCategory> _decodeCategories(String raw) {
    try {
      final dynamic decoded = jsonDecode(raw);
      if (decoded is! List) {
        return <NewsCategory>[];
      }
      return decoded
          .whereType<Map>()
          .map((dynamic item) => NewsCategory.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList();
    } catch (_) {
      return <NewsCategory>[];
    }
  }

  static List<NewsArticle> _decodeArticles(String raw) {
    try {
      final dynamic decoded = jsonDecode(raw);
      if (decoded is! List) {
        return <NewsArticle>[];
      }
      return decoded
          .whereType<Map>()
          .map((dynamic item) => NewsArticle.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList();
    } catch (_) {
      return <NewsArticle>[];
    }
  }
}

extension on NewsCategory {
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'categoryId': categoryId,
      'categoryCode': categoryCode,
      'categoryName': categoryName,
      'sortOrder': sortOrder,
      'status': status,
    };
  }
}

extension on NewsArticle {
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'articleId': articleId,
      'categoryId': categoryId,
      'categoryCode': categoryCode,
      'categoryName': categoryName,
      'articleTitle': articleTitle,
      'summary': summary,
      'coverImage': coverImage,
      'articleContent': articleContent,
      'sortOrder': sortOrder,
      'topFlag': topFlag,
      'status': status,
    };
  }
}
