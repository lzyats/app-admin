import 'api_client.dart';
import 'api_response.dart';

class HttpClient {
  HttpClient._();

  static ApiClient get api => ApiClient.instance;

  static Future<ApiResponse<dynamic>> get(
    String path, {
    Map<String, dynamic>? query,
    bool encrypt = true,
    bool retry = true,
  }) {
    return api.get(path, query: query, encrypt: encrypt, retry: retry);
  }

  static Future<ApiResponse<dynamic>> post(
    String path, {
    dynamic data,
    bool encrypt = true,
    bool retry = true,
  }) {
    return api.post(path, data: data, encrypt: encrypt, retry: retry);
  }
}
