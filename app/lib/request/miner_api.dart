import 'package:myapp/request/api_client.dart';
import 'package:myapp/request/api_response.dart';
import 'package:myapp/request/ruoyi_endpoints.dart';

class MinerApi {
  const MinerApi._();

  static Future<Map<String, dynamic>> fetchOverview() async {
    final ApiResponse<dynamic> resp = await ApiClient.instance.get(
      RuoYiEndpoints.minerOverview,
      encrypt: false,
    );
    return (resp.data as Map?)?.cast<String, dynamic>() ?? <String, dynamic>{};
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
}
