import 'dart:convert';

import 'package:myapp/request/api_client.dart';
import 'package:myapp/request/api_response.dart';
import 'package:myapp/request/ruoyi_endpoints.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MinerApi {
  const MinerApi._();

  static const String _overviewCacheKey = 'miner.overview.cache.v1';
  static const String _overviewUpdatedAtKey = 'miner.overview.cache.updatedAt.v1';

  static Future<Map<String, dynamic>> fetchOverview() async {
    final ApiResponse<dynamic> resp = await ApiClient.instance.get(
      RuoYiEndpoints.minerOverview,
      encrypt: false,
    );
    final Map<String, dynamic> data =
        (resp.data as Map?)?.cast<String, dynamic>() ?? <String, dynamic>{};
    if (data.isNotEmpty) {
      await _saveOverviewCache(data);
    }
    return data;
  }

  static Future<Map<String, dynamic>> getCachedOverview() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String raw = (prefs.getString(_overviewCacheKey) ?? '').trim();
    if (raw.isEmpty) {
      return <String, dynamic>{};
    }
    try {
      final dynamic decoded = jsonDecode(raw);
      if (decoded is Map) {
        return Map<String, dynamic>.from(decoded);
      }
      return <String, dynamic>{};
    } catch (_) {
      return <String, dynamic>{};
    }
  }

  static Future<List<dynamic>> fetchAvailable() async {
    final ApiResponse<dynamic> resp = await ApiClient.instance.get(
      RuoYiEndpoints.minerAvailable,
      encrypt: false,
    );
    return (resp.data as List?) ?? <dynamic>[];
  }

  static Future<Map<String, dynamic>> claim({required int minerId}) async {
    final ApiResponse<dynamic> resp = await ApiClient.instance.post(
      RuoYiEndpoints.minerClaim,
      data: <String, dynamic>{'minerId': minerId},
      encrypt: true,
    );
    return (resp.data as Map?)?.cast<String, dynamic>() ?? <String, dynamic>{};
  }

  static Future<Map<String, dynamic>> collect() async {
    final ApiResponse<dynamic> resp = await ApiClient.instance.post(
      RuoYiEndpoints.minerCollect,
      data: <String, dynamic>{},
      encrypt: true,
    );
    return (resp.data as Map?)?.cast<String, dynamic>() ?? <String, dynamic>{};
  }

  static Future<Map<String, dynamic>> exchange({
    required String requestNo,
    required double wagAmount,
  }) async {
    final ApiResponse<dynamic> resp = await ApiClient.instance.post(
      RuoYiEndpoints.minerExchange,
      data: <String, dynamic>{
        'requestNo': requestNo,
        'wagAmount': wagAmount,
      },
      encrypt: true,
    );
    return (resp.data as Map?)?.cast<String, dynamic>() ?? <String, dynamic>{};
  }

  static Future<List<dynamic>> fetchRewardLogs() async {
    final ApiResponse<dynamic> resp = await ApiClient.instance.get(
      RuoYiEndpoints.minerRewardLogs,
      encrypt: false,
    );
    return (resp.data as List?) ?? <dynamic>[];
  }

  static Future<List<dynamic>> fetchExchangeLogs() async {
    final ApiResponse<dynamic> resp = await ApiClient.instance.get(
      RuoYiEndpoints.minerExchangeLogs,
      encrypt: false,
    );
    return (resp.data as List?) ?? <dynamic>[];
  }

  static Future<void> _saveOverviewCache(Map<String, dynamic> data) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_overviewCacheKey, jsonEncode(data));
    await prefs.setInt(_overviewUpdatedAtKey, DateTime.now().millisecondsSinceEpoch);
  }
}
