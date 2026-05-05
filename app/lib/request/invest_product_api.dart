import 'dart:async';
import 'dart:convert';

import 'package:myapp/request/api_client.dart';
import 'package:myapp/request/api_response.dart';
import 'package:myapp/request/ruoyi_endpoints.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InvestProductItem {
  const InvestProductItem({
    required this.productId,
    required this.productName,
    required this.currency,
    required this.cardTheme,
    required this.riskTag,
    required this.singleRate,
    required this.groupRate,
    required this.cycleDays,
    required this.investMode,
    required this.minInvestAmount,
    required this.maxInvestAmount,
    required this.redPacketPerUnit,
    required this.progressPercent,
    required this.groupEnabled,
    required this.coverImage,
    required this.galleryImages,
    required this.productContent,
    required this.tradeRuleContent,
    required this.growthPerUnit,
    required this.limitLevel,
    required this.limitTimes,
    required this.totalShares,
    required this.soldShares,
    required this.remainingShares,
    required this.totalAmount,
    required this.soldAmount,
    required this.remainingAmount,
    required this.tagNames,
    required this.startTime,
    required this.endTime,
    required this.userInvestCount,
    required this.canOrder,
    required this.orderDisabledReason,
  });

  final int productId;
  final String productName;
  final String currency;
  final String cardTheme;
  final String riskTag;
  final double singleRate;
  final double groupRate;
  final int cycleDays;
  final String investMode;
  final double minInvestAmount;
  final double maxInvestAmount;
  final double redPacketPerUnit;
  final double progressPercent;
  final bool groupEnabled;
  final String coverImage;
  final List<String> galleryImages;
  final String productContent;
  final String tradeRuleContent;
  final double growthPerUnit;
  final int limitLevel;
  final int limitTimes;
  final int totalShares;
  final int soldShares;
  final int remainingShares;
  final double totalAmount;
  final double soldAmount;
  final double remainingAmount;
  final List<String> tagNames;
  final String startTime;
  final String endTime;
  final int userInvestCount;
  final bool canOrder;
  final String orderDisabledReason;

  factory InvestProductItem.fromJson(Map<String, dynamic> json) {
    return InvestProductItem(
      productId: _toInt(json['productId']),
      productName: _toString(json['productName']),
      currency: _toString(json['currency']),
      cardTheme: _toString(json['cardTheme']),
      riskTag: _toString(json['riskTag']),
      singleRate: _toDouble(json['singleRate']),
      groupRate: _toDouble(json['groupRate']),
      cycleDays: _toInt(json['cycleDays']),
      investMode: _toString(json['investMode']).isEmpty ? 'SHARE' : _toString(json['investMode']).toUpperCase(),
      minInvestAmount: _toDouble(json['minInvestAmount']),
      maxInvestAmount: _toDouble(json['maxInvestAmount']),
      redPacketPerUnit: _toDouble(json['redPacketPerUnit']),
      progressPercent: _toDouble(json['progressPercent']),
      groupEnabled: _toString(json['groupEnabled']) == '1',
      coverImage: _toString(json['coverImage']),
      galleryImages: _toStringList(json['galleryImages']),
      productContent: _toString(json['productContent']),
      tradeRuleContent: _toString(json['tradeRuleContent']),
      growthPerUnit: _toDouble(json['growthPerUnit']),
      limitLevel: _toInt(json['limitLevel']),
      limitTimes: _toInt(json['limitTimes']),
      totalShares: _toInt(json['totalShares']),
      soldShares: _toInt(json['soldShares']),
      remainingShares: _toInt(json['remainingShares']),
      totalAmount: _toDouble(json['totalAmount']),
      soldAmount: _toDouble(json['soldAmount']),
      remainingAmount: _toDouble(json['remainingAmount']),
      tagNames: _toStringList(json['tagNames']),
      startTime: _toString(json['startTime']),
      endTime: _toString(json['endTime']),
      userInvestCount: _toInt(json['userInvestCount']),
      canOrder: _toBool(json['canOrder'], defaultValue: true),
      orderDisabledReason: _toString(json['orderDisabledReason']),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'productId': productId,
      'productName': productName,
      'currency': currency,
      'cardTheme': cardTheme,
      'riskTag': riskTag,
      'singleRate': singleRate,
      'groupRate': groupRate,
      'cycleDays': cycleDays,
      'investMode': investMode,
      'minInvestAmount': minInvestAmount,
      'maxInvestAmount': maxInvestAmount,
      'redPacketPerUnit': redPacketPerUnit,
      'progressPercent': progressPercent,
      'groupEnabled': groupEnabled ? '1' : '0',
      'coverImage': coverImage,
      'galleryImages': galleryImages,
      'productContent': productContent,
      'tradeRuleContent': tradeRuleContent,
      'growthPerUnit': growthPerUnit,
      'limitLevel': limitLevel,
      'limitTimes': limitTimes,
      'totalShares': totalShares,
      'soldShares': soldShares,
      'remainingShares': remainingShares,
      'totalAmount': totalAmount,
      'soldAmount': soldAmount,
      'remainingAmount': remainingAmount,
      'tagNames': tagNames,
      'startTime': startTime,
      'endTime': endTime,
      'userInvestCount': userInvestCount,
      'canOrder': canOrder,
      'orderDisabledReason': orderDisabledReason,
    };
  }
}

class InvestProductApi {
  const InvestProductApi._();

  static const Duration _cacheMaxAge = Duration(minutes: 20);
  static const String _productsCacheKey = 'invest.products.cache.v1';
  static const String _tagGroupsCacheKey = 'invest.products.tags.v1';
  static const String _updatedAtKey = 'invest.products.cache.updatedAt.v1';
  static const Duration _homeHotCacheMaxAge = Duration(minutes: 15);
  static const String _homeHotCacheKey = 'invest.home.hot.cache.v1';
  static const String _homeHotUpdatedAtKey = 'invest.home.hot.cache.updatedAt.v1';

  static Future<InvestProductCatalog> fetchCatalog({bool forceRefresh = false}) async {
    if (!forceRefresh) {
      final InvestProductCatalog? cached = await _readCache(allowStale: true);
      if (cached != null) {
        final bool fresh = await _readCache() != null;
        if (!fresh) {
          unawaited(_refreshInBackground());
        }
        return cached;
      }
    }
    try {
      final List<InvestProductItem> remoteProducts = await _fetchProductsRemote();
      final InvestProductCatalog current =
          InvestProductCatalog(products: remoteProducts, tagGroups: _buildTagGroups(remoteProducts));
      await _saveCache(current);
      return current;
    } catch (_) {
      final InvestProductCatalog? cached = await _readCache(allowStale: true);
      if (cached != null) {
        return cached;
      }
      rethrow;
    }
  }

  static Future<List<String>> getCachedTagGroups() async {
    final InvestProductCatalog? cached = await _readCache(allowStale: true);
    return cached?.tagGroups ?? const <String>['全部'];
  }

  static Future<List<InvestProductItem>> fetchProducts() async {
    return _fetchProductsRemote();
  }

  static Future<List<InvestProductItem>> getCachedHomeHotProducts() async {
    return (await _readHomeHotCache(allowStale: true)) ?? const <InvestProductItem>[];
  }

  static Future<List<InvestProductItem>> fetchHomeHotProducts({bool forceRefresh = false}) async {
    if (!forceRefresh) {
      final List<InvestProductItem>? cached = await _readHomeHotCache(allowStale: true);
      if (cached != null) {
        final bool fresh = await _readHomeHotCache() != null;
        if (!fresh) {
          unawaited(_refreshHomeHotInBackground());
        }
        return cached;
      }
    }
    try {
      final List<InvestProductItem> remote = await _fetchHomeHotProductsRemote();
      await _saveHomeHotCache(remote);
      return remote;
    } catch (_) {
      return (await _readHomeHotCache(allowStale: true)) ?? const <InvestProductItem>[];
    }
  }

  static Future<List<InvestProductItem>> _fetchProductsRemote() async {
    final ApiResponse<dynamic> response = await ApiClient.instance.get(
      RuoYiEndpoints.appInvestProductList,
      encrypt: true,
    );
    final dynamic raw = response.data;
    final dynamic payload = raw is Map<String, dynamic>
        ? (raw['data'] ?? raw)
        : response.raw['data'] ?? response.raw;
    final dynamic rowsAny = payload is Map<String, dynamic> ? payload['rows'] : payload;
    if (rowsAny is! List) {
      return const <InvestProductItem>[];
    }
    return rowsAny
        .whereType<Map>()
        .map((Map item) => InvestProductItem.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  static Future<InvestProductItem> fetchProductDetail(int productId) async {
    final ApiResponse<dynamic> response = await ApiClient.instance.get(
      '${RuoYiEndpoints.appInvestProductDetail}/$productId',
      encrypt: true,
    );
    final dynamic raw = response.data;
    final dynamic payload = raw is Map<String, dynamic>
        ? (raw['data'] ?? raw)
        : response.raw['data'] ?? response.raw;
    final Map<String, dynamic> map = payload is Map
        ? Map<String, dynamic>.from(payload as Map)
        : <String, dynamic>{};
    return InvestProductItem.fromJson(map);
  }

  static Future<List<InvestProductItem>> _fetchHomeHotProductsRemote() async {
    final ApiResponse<dynamic> response = await ApiClient.instance.get(
      RuoYiEndpoints.appInvestProductHomeHot,
      encrypt: true,
    );
    final dynamic raw = response.data;
    final dynamic payload = raw is Map<String, dynamic>
        ? (raw['data'] ?? raw)
        : response.raw['data'] ?? response.raw;
    final dynamic rowsAny = payload is Map<String, dynamic> ? payload['rows'] : payload;
    if (rowsAny is! List) {
      return const <InvestProductItem>[];
    }
    return rowsAny
        .whereType<Map>()
        .map((Map item) => InvestProductItem.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  static Future<void> _refreshInBackground() async {
    try {
      final List<InvestProductItem> remoteProducts = await _fetchProductsRemote();
      final InvestProductCatalog current =
          InvestProductCatalog(products: remoteProducts, tagGroups: _buildTagGroups(remoteProducts));
      await _saveCache(current);
    } catch (_) {}
  }

  static Future<void> _refreshHomeHotInBackground() async {
    try {
      final List<InvestProductItem> remote = await _fetchHomeHotProductsRemote();
      await _saveHomeHotCache(remote);
    } catch (_) {}
  }

  static Future<void> _saveCache(InvestProductCatalog value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<Map<String, dynamic>> productMaps =
        value.products.map((InvestProductItem e) => e.toJson()).toList();
    await prefs.setString(_productsCacheKey, jsonEncode(productMaps));
    await prefs.setString(_tagGroupsCacheKey, jsonEncode(value.tagGroups));
    await prefs.setInt(_updatedAtKey, DateTime.now().millisecondsSinceEpoch);
  }

  static Future<InvestProductCatalog?> _readCache({bool allowStale = false}) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String productsRaw = (prefs.getString(_productsCacheKey) ?? '').trim();
    if (productsRaw.isEmpty) {
      return null;
    }
    final int? updatedAt = prefs.getInt(_updatedAtKey);
    if (!allowStale && !_isCacheFresh(updatedAt)) {
      return null;
    }
    try {
      final dynamic productsDecoded = jsonDecode(productsRaw);
      if (productsDecoded is! List) {
        return null;
      }
      final List<InvestProductItem> products = productsDecoded
          .whereType<Map>()
          .map((Map e) => InvestProductItem.fromJson(Map<String, dynamic>.from(e)))
          .toList();

      final String tagsRaw = (prefs.getString(_tagGroupsCacheKey) ?? '').trim();
      List<String> tags = const <String>[];
      if (tagsRaw.isNotEmpty) {
        final dynamic tagsDecoded = jsonDecode(tagsRaw);
        if (tagsDecoded is List) {
          tags = tagsDecoded.map((dynamic e) => '$e').where((String e) => e.trim().isNotEmpty).toList();
        }
      }
      if (tags.isEmpty) {
        tags = _buildTagGroups(products);
      } else if (!tags.contains('全部')) {
        tags = <String>['全部', ...tags];
      }
      return InvestProductCatalog(products: products, tagGroups: tags);
    } catch (_) {
      return null;
    }
  }

  static Future<void> _saveHomeHotCache(List<InvestProductItem> items) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<Map<String, dynamic>> values =
        items.map((InvestProductItem e) => e.toJson()).toList();
    await prefs.setString(_homeHotCacheKey, jsonEncode(values));
    await prefs.setInt(_homeHotUpdatedAtKey, DateTime.now().millisecondsSinceEpoch);
  }

  static Future<List<InvestProductItem>?> _readHomeHotCache({bool allowStale = false}) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String raw = (prefs.getString(_homeHotCacheKey) ?? '').trim();
    if (raw.isEmpty) {
      return null;
    }
    final int? updatedAt = prefs.getInt(_homeHotUpdatedAtKey);
    if (!allowStale && !_isHomeHotCacheFresh(updatedAt)) {
      return null;
    }
    try {
      final dynamic decoded = jsonDecode(raw);
      if (decoded is! List) {
        return const <InvestProductItem>[];
      }
      return decoded
          .whereType<Map>()
          .map((Map e) => InvestProductItem.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (_) {
      return const <InvestProductItem>[];
    }
  }

  static bool _isCacheFresh(int? updatedAt) {
    if (updatedAt == null) {
      return true;
    }
    final int ageMs = DateTime.now().millisecondsSinceEpoch - updatedAt;
    return ageMs >= 0 && ageMs <= _cacheMaxAge.inMilliseconds;
  }

  static bool _isHomeHotCacheFresh(int? updatedAt) {
    if (updatedAt == null) {
      return true;
    }
    final int ageMs = DateTime.now().millisecondsSinceEpoch - updatedAt;
    return ageMs >= 0 && ageMs <= _homeHotCacheMaxAge.inMilliseconds;
  }

  static List<String> _buildTagGroups(List<InvestProductItem> products) {
    final List<String> tags = <String>[];
    for (final InvestProductItem item in products) {
      for (final String tag in item.tagNames) {
        final String text = tag.trim();
        if (text.isNotEmpty && !tags.contains(text)) {
          tags.add(text);
        }
      }
    }
    return <String>['全部', ...tags];
  }
}

class InvestProductCatalog {
  const InvestProductCatalog({
    required this.products,
    required this.tagGroups,
  });

  final List<InvestProductItem> products;
  final List<String> tagGroups;
}

String _toString(dynamic value) => (value ?? '').toString().trim();

int _toInt(dynamic value) {
  if (value is int) {
    return value;
  }
  return int.tryParse('${value ?? 0}') ?? 0;
}

double _toDouble(dynamic value) {
  if (value is num) {
    return value.toDouble();
  }
  return double.tryParse('${value ?? 0}') ?? 0;
}

bool _toBool(dynamic value, {bool defaultValue = false}) {
  if (value == null) {
    return defaultValue;
  }
  if (value is bool) {
    return value;
  }
  final String raw = value.toString().trim().toLowerCase();
  if (raw == '1' || raw == 'true' || raw == 'yes') {
    return true;
  }
  if (raw == '0' || raw == 'false' || raw == 'no') {
    return false;
  }
  return defaultValue;
}

List<String> _toStringList(dynamic value) {
  if (value is List) {
    return value.map((dynamic e) => '$e').where((String e) => e.trim().isNotEmpty).toList();
  }
  final String raw = _toString(value);
  if (raw.isEmpty) {
    return const <String>[];
  }
  return raw
      .split(',')
      .map((String e) => e.trim())
      .where((String e) => e.isNotEmpty)
      .toList();
}
