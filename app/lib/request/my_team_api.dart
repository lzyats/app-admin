import 'dart:async';
import 'dart:convert';
import 'package:myapp/request/api_client.dart';
import 'package:myapp/request/api_response.dart';
import 'package:myapp/request/ruoyi_endpoints.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyTeamStats {
  const MyTeamStats({
    required this.inviteCode,
    required this.userLevel,
    required this.teamLeaderLevel,
    required this.totalAsset,
    required this.totalIncome,
    required this.directTotalCount,
    required this.directValidCount,
    required this.directValidRate,
    required this.teamTotalCount,
    required this.teamValidCount,
    required this.teamValidRate,
    this.calcDate,
  });

  final String inviteCode;
  final int userLevel;
  final int teamLeaderLevel;
  final double totalAsset;
  final double totalIncome;
  final int directTotalCount;
  final int directValidCount;
  final double directValidRate;
  final int teamTotalCount;
  final int teamValidCount;
  final double teamValidRate;
  final String? calcDate;

  factory MyTeamStats.fromJson(Map<String, dynamic> json) {
    return MyTeamStats(
      inviteCode: (json['inviteCode'] ?? '').toString(),
      userLevel: _toInt(json['userLevel']),
      teamLeaderLevel: _toInt(json['teamLeaderLevel']),
      totalAsset: _toDouble(json['totalAsset']),
      totalIncome: _toDouble(json['totalIncome']),
      directTotalCount: _toInt(json['directTotalCount']),
      directValidCount: _toInt(json['directValidCount']),
      directValidRate: _toRate(json['directValidRate']),
      teamTotalCount: _toInt(json['teamTotalCount']),
      teamValidCount: _toInt(json['teamValidCount']),
      teamValidRate: _toRate(json['teamValidRate']),
      calcDate: (json['calcDate'] ?? '').toString().trim().isEmpty
          ? null
          : (json['calcDate'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'inviteCode': inviteCode,
      'userLevel': userLevel,
      'teamLeaderLevel': teamLeaderLevel,
      'totalAsset': totalAsset,
      'totalIncome': totalIncome,
      'directTotalCount': directTotalCount,
      'directValidCount': directValidCount,
      'directValidRate': directValidRate,
      'teamTotalCount': teamTotalCount,
      'teamValidCount': teamValidCount,
      'teamValidRate': teamValidRate,
      'calcDate': calcDate,
    };
  }
}

class MyTeamApi {
  const MyTeamApi._();

  static const Duration _cacheMaxAge = Duration(minutes: 10);
  static const String _cacheKey = 'my.team.stats.cache.v1';
  static const String _updatedAtKey = 'my.team.stats.cache.updatedAt.v1';

  static Future<MyTeamStats> getMyStats({bool forceRefresh = false}) async {
    if (!forceRefresh) {
      final MyTeamStats? cached = await _readCache(allowStale: true);
      if (cached != null) {
        final bool fresh = await _readCache() != null;
        if (!fresh) {
          unawaited(_refreshInBackground());
        }
        return cached;
      }
    }
    try {
      final MyTeamStats remote = await _fetchRemote();
      await _saveCache(remote);
      return remote;
    } catch (_) {
      final MyTeamStats? cached = await _readCache(allowStale: true);
      if (cached != null) {
        return cached;
      }
      rethrow;
    }
  }

  static Future<MyTeamStats> _fetchRemote() async {
    final ApiResponse<dynamic> response = await ApiClient.instance.get(
      RuoYiEndpoints.appTeamStatsMe,
      encrypt: true,
    );
    final dynamic raw = response.data;
    final dynamic payload = raw is Map<String, dynamic>
        ? (raw['data'] ?? raw)
        : response.raw['data'] ?? response.raw;
    final Map<String, dynamic> map = payload is Map
        ? Map<String, dynamic>.from(payload as Map)
        : <String, dynamic>{};
    return MyTeamStats.fromJson(map);
  }

  static Future<void> _refreshInBackground() async {
    try {
      final MyTeamStats remote = await _fetchRemote();
      await _saveCache(remote);
    } catch (_) {}
  }

  static Future<MyTeamStats?> _readCache({bool allowStale = false}) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String raw = (prefs.getString(_cacheKey) ?? '').trim();
    if (raw.isEmpty) {
      return null;
    }
    final int? updatedAt = prefs.getInt(_updatedAtKey);
    if (!allowStale && !_isCacheFresh(updatedAt)) {
      return null;
    }
    try {
      final dynamic decoded = jsonDecode(raw);
      if (decoded is! Map) {
        return null;
      }
      return MyTeamStats.fromJson(Map<String, dynamic>.from(decoded as Map));
    } catch (_) {
      return null;
    }
  }

  static Future<void> _saveCache(MyTeamStats value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cacheKey, jsonEncode(value.toJson()));
    await prefs.setInt(_updatedAtKey, DateTime.now().millisecondsSinceEpoch);
  }

  static bool _isCacheFresh(int? updatedAt) {
    if (updatedAt == null) {
      return true;
    }
    final int ageMs = DateTime.now().millisecondsSinceEpoch - updatedAt;
    return ageMs >= 0 && ageMs <= _cacheMaxAge.inMilliseconds;
  }
}

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

double _toRate(dynamic value) {
  final double v = _toDouble(value);
  if (v < 0) {
    return 0;
  }
  if (v > 1) {
    return 1;
  }
  return v;
}
