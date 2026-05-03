import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:myapp/config/app_config.dart';

class LineHostTool {
  const LineHostTool._();

  static const String _cacheKeyHttpUrl = 'line_selected_http_url';
  static const String _cacheKeyCustomHosts = 'line_custom_hosts_json';
  static int _revision = 0;

  static int get revision => _revision;

  /// 读取当前生效线路，缓存为空时回退默认线路。
  static Future<RequestHost> getCurrentHost() async {
    final List<RequestHost> allHosts = await getAllHosts();
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String cachedHttpUrl = (prefs.getString(_cacheKeyHttpUrl) ?? '').trim();

    if (cachedHttpUrl.isEmpty) {
      return AppConfig.defaultRequestHost;
    }

    for (final RequestHost host in allHosts) {
      if (host.httpUrl == cachedHttpUrl) {
        if (_isLoopbackHost(host.httpUrl)) {
          final RequestHost fallback = await _firstNonLoopbackHost();
          if (fallback.httpUrl != host.httpUrl) {
            await setCurrentHost(fallback);
          }
          return fallback;
        }
        return host;
      }
    }

    final RequestHost fallback = await _firstNonLoopbackHost();
    if (fallback.httpUrl.isNotEmpty) {
      await setCurrentHost(fallback);
    }
    return fallback;
  }

  /// 获取当前代理应转发到的上游线路。
  /// 当本地代理启用时，避免选择 127.0.0.1 / localhost 之类的回环地址，
  /// 否则代理会把请求转回设备本身，导致 502。
  static Future<RequestHost> getProxyUpstreamHost() async {
    final RequestHost current = await getCurrentHost();
    if (_isLoopbackHost(current.httpUrl)) {
      return _firstNonLoopbackHost();
    }
    return current;
  }

  /// 保存当前生效线路到本地缓存。
  static Future<void> setCurrentHost(RequestHost host) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cacheKeyHttpUrl, host.httpUrl);
    _revision++;
  }

  /// 获取“内置线路 + 自定义线路”的完整列表。
  static Future<List<RequestHost>> getAllHosts() async {
    final List<RequestHost> result = <RequestHost>[
      ...AppConfig.requestHost,
      ...await getCustomHosts(),
    ];
    return result;
  }

  /// 获取本地缓存的自定义线路列表。
  static Future<List<RequestHost>> getCustomHosts() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String raw = (prefs.getString(_cacheKeyCustomHosts) ?? '').trim();
    if (raw.isEmpty) {
      return <RequestHost>[];
    }

    try {
      final dynamic decoded = jsonDecode(raw);
      if (decoded is! List) {
        return <RequestHost>[];
      }
      final List<RequestHost> result = <RequestHost>[];
      for (final dynamic item in decoded) {
        if (item is Map<String, dynamic>) {
          final RequestHost? host = RequestHost.fromJson(item);
          if (host != null) {
            result.add(host);
          }
        } else if (item is Map) {
          final RequestHost? host = RequestHost.fromJson(Map<String, dynamic>.from(item));
          if (host != null) {
            result.add(host);
          }
        }
      }
      return result;
    } catch (_) {
      return <RequestHost>[];
    }
  }

  /// 新增一条自定义线路（自动去重）。
  static Future<bool> addCustomHost(RequestHost host) async {
    final List<RequestHost> allHosts = await getAllHosts();
    for (final RequestHost item in allHosts) {
      if (item.httpUrl == host.httpUrl && item.wsUrl == host.wsUrl) {
        return false;
      }
    }

    final List<RequestHost> customHosts = await getCustomHosts();
    customHosts.add(host);

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String raw = jsonEncode(customHosts.map((RequestHost e) => e.toJson()).toList());
    await prefs.setString(_cacheKeyCustomHosts, raw);
    _revision++;
    return true;
  }

  /// 清除当前线路缓存标记。
  static Future<void> clearCurrentHost() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cacheKeyHttpUrl);
    _revision++;
  }

  static bool _isLoopbackHost(String httpUrl) {
    try {
      final Uri uri = Uri.parse(httpUrl);
      final String host = uri.host.toLowerCase();
      return host == '127.0.0.1' || host == 'localhost' || host == '::1';
    } catch (_) {
      return false;
    }
  }

  static Future<RequestHost> _firstNonLoopbackHost() async {
    final List<RequestHost> allHosts = await getAllHosts();
    for (final RequestHost host in allHosts) {
      if (!_isLoopbackHost(host.httpUrl)) {
        return host;
      }
    }
    return AppConfig.defaultRequestHost;
  }
}
