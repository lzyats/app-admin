import 'package:flutter/material.dart';
import 'package:myapp/request/api_client.dart';
import 'package:myapp/request/api_response.dart';

class HttpClient {
  HttpClient._();

  /// 获取全局 API 客户端实例。
  static ApiClient get api => ApiClient.instance;

  /// 对外暴露简化版 GET 请求方法。
  static Future<ApiResponse<dynamic>> get(
    String path, {
    Map<String, dynamic>? query,
    bool encrypt = true,
    bool retry = true,
  }) {
    return api.get(path, query: query, encrypt: encrypt, retry: retry);
  }

  /// 对外暴露简化版 POST 请求方法。
  static Future<ApiResponse<dynamic>> post(
    String path, {
    dynamic data,
    bool encrypt = true,
    bool retry = true,
  }) {
    return api.post(path, data: data, encrypt: encrypt, retry: retry);
  }

  /// 对外暴露简化版 PUT 请求方法。
  static Future<ApiResponse<dynamic>> put(
    String path, {
    dynamic data,
    bool encrypt = true,
    bool retry = true,
  }) {
    return api.put(path, data: data, encrypt: encrypt, retry: retry);
  }
}