import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:myapp/config/app_config.dart';
import 'package:myapp/tools/runtime_proxy.dart';
import 'package:myapp/tools/tools_proxy.dart';
import 'package:myapp/tools/line_host_tool.dart';

class LocalProxyManager {
  LocalProxyManager._();

  static final LocalProxyManager instance = LocalProxyManager._();

  ToolsProxy? _httpProxy;
  bool _isStarting = false;
  Completer<void>? _startCompleter;

  /// 启动本地 HTTP 代理
  Future<void> startHttpProxy() async {
    if (_httpProxy != null && RuntimeProxy.httpReady) {
      return;
    }

    if (_isStarting) {
      return _startCompleter?.future;
    }

    _startCompleter = Completer<void>();
    _isStarting = true;

    try {
      // 停止现有代理
      await stopHttpProxy();

      // 创建新的代理实例
      _httpProxy = ToolsProxy(
        upstreamResolver: () async {
          final host = await LineHostTool.getProxyUpstreamHost();
          return Uri.parse(host.httpUrl);
        },
      );

      // 启动代理并获取端口
      final port = await _httpProxy!.start();
      RuntimeProxy.httpPort = port;
      RuntimeProxy.httpReady = true;

      debugPrint('Local HTTP proxy started on port: $port');
      debugPrint('Local HTTP proxy base URL: ${RuntimeProxy.httpBaseUrl()}');

      _startCompleter?.complete();
    } catch (e) {
      debugPrint('Failed to start local HTTP proxy: $e');
      _startCompleter?.completeError(e);
    } finally {
      _isStarting = false;
      _startCompleter = null;
    }
  }

  /// 停止本地 HTTP 代理
  Future<void> stopHttpProxy() async {
    if (_httpProxy != null) {
      await _httpProxy!.stop();
      _httpProxy = null;
    }
    RuntimeProxy.httpReady = false;
    RuntimeProxy.httpPort = 0;
    debugPrint('Local HTTP proxy stopped');
  }

  /// 检查本地 HTTP 代理是否就绪
  bool isHttpProxyReady() {
    return _httpProxy != null && RuntimeProxy.httpReady;
  }

  /// 获取本地 HTTP 代理的基础 URL
  String getHttpProxyBaseUrl() {
    if (!isHttpProxyReady()) {
      throw Exception('Local HTTP proxy is not ready');
    }
    return RuntimeProxy.httpBaseUrl();
  }
}
