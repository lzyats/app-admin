import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:myapp/request/http_client.dart';
import 'package:myapp/request/ruoyi_endpoints.dart';

class UserLevelOption {
  const UserLevelOption({
    required this.levelId,
    required this.level,
    required this.levelName,
    required this.requiredGrowthValue,
    required this.investBonus,
    this.icon,
    this.sortOrder,
    this.remark,
  });

  final int levelId;
  final int level;
  final String levelName;
  final int requiredGrowthValue;
  final double investBonus;
  final String? icon;
  final int? sortOrder;
  final String? remark;

  factory UserLevelOption.fromJson(Map<String, dynamic> json) {
    return UserLevelOption(
      levelId: _asInt(json['levelId'] ?? json['level_id']),
      level: _asInt(json['level']),
      levelName: (json['levelName'] ?? json['level_name'] ?? '').toString(),
      requiredGrowthValue: _asInt(
          json['requiredGrowthValue'] ?? json['required_growth_value']),
      investBonus: _asDouble(json['investBonus'] ?? json['invest_bonus']),
      icon: (json['icon'])?.toString(),
      sortOrder: _asNullableInt(json['sortOrder'] ?? json['sort_order']),
      remark: (json['remark'])?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'levelId': levelId,
      'level': level,
      'levelName': levelName,
      'requiredGrowthValue': requiredGrowthValue,
      'investBonus': investBonus,
      if (icon != null) 'icon': icon,
      if (sortOrder != null) 'sortOrder': sortOrder,
      if (remark != null) 'remark': remark,
    };
  }

  static int _asInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value.toString()) ?? 0;
  }

  static int? _asNullableInt(dynamic value) {
    if (value == null) return null;
    final String raw = value.toString().trim();
    if (raw.isEmpty) return null;
    return int.tryParse(raw);
  }

  static double _asDouble(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0;
  }
}

class UserLevelApi {
  UserLevelApi._();

  static const String _cacheKey = 'user.level.options.v1';
  static const String _cacheUpdatedAtKey = 'user.level.options.v1.updatedAt';
  static const Duration _cacheMaxAge = Duration(days: 7);

  static Future<List<UserLevelOption>> getOptions({bool forceRefresh = false}) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final int updatedAt = prefs.getInt(_cacheUpdatedAtKey) ?? 0;
    final String cachedRaw = prefs.getString(_cacheKey) ?? '';

    final bool cacheValid = cachedRaw.isNotEmpty &&
        updatedAt > 0 &&
        DateTime.now()
                .difference(DateTime.fromMillisecondsSinceEpoch(updatedAt))
                .compareTo(_cacheMaxAge) <
            0;

    if (!forceRefresh && cacheValid) {
      final cached = _parseOptionsJson(cachedRaw);
      if (cached.isNotEmpty) {
        return cached;
      }
    }

    try {
      final res = await HttpClient.get(
        RuoYiEndpoints.appUserLevelOptions,
        encrypt: true,
        retry: true,
      );
      final dynamic raw = res.data;
      final List<UserLevelOption> list = _mapToOptions(raw);
      final String rawJson = jsonEncode(list.map((e) => e.toJson()).toList());
      await prefs.setString(_cacheKey, rawJson);
      await prefs.setInt(
          _cacheUpdatedAtKey, DateTime.now().millisecondsSinceEpoch);
      return list;
    } catch (_) {
      if (cachedRaw.isNotEmpty) {
        final cached = _parseOptionsJson(cachedRaw);
        if (cached.isNotEmpty) {
          return cached;
        }
      }
      rethrow;
    }
  }

  static List<UserLevelOption> _parseOptionsJson(String rawJson) {
    try {
      final dynamic decoded = jsonDecode(rawJson);
      return _mapToOptions(decoded);
    } catch (_) {
      return <UserLevelOption>[];
    }
  }

  static List<UserLevelOption> _mapToOptions(dynamic raw) {
    final List list = raw is List
        ? raw
        : (raw is Map<String, dynamic> ? (raw['data'] ?? raw['list']) : const []);
    return list
        .whereType<Map<String, dynamic>>()
        .map((e) => UserLevelOption.fromJson(e))
        .toList();
  }
}
