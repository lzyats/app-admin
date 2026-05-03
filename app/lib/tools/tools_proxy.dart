import 'dart:io';
import 'package:myapp/tools/runtime_proxy.dart';

typedef UpstreamResolver = Future<Uri> Function();

class ToolsProxy {
  HttpServer? _server;
  final UpstreamResolver upstreamResolver;

  ToolsProxy({required this.upstreamResolver});

  Future<int> start() async {
    _server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    _server!.listen(_handle);
    return _server!.port;
  }

  Future<void> _handle(HttpRequest req) async {
    // 1) 探活
    if (req.method == 'GET' && req.uri.path == '/__ping') {
      req.response.statusCode = 200;
      req.response.write('ok');
      await req.response.close();
      return;
    }

    // 调试信息
    print('[LocalProxy] Request headers: ${req.headers}');
    print('[LocalProxy] Request uri: ${req.uri}');
    print('[LocalProxy] Request method: ${req.method}');
    
    // 2) Debug-only：本地鉴权（防止同机其它组件乱打）
    final token = req.headers.value('x-local-proxy');
    print('[LocalProxy] Received x-local-proxy token: $token');
    print('[LocalProxy] Expected token: ${RuntimeProxy.authToken}');
    print('[LocalProxy] RuntimeProxy.enabled: ${RuntimeProxy.enabled}');
    
    if (RuntimeProxy.enabled && token != RuntimeProxy.authToken) {
      print('[LocalProxy] Authentication failed: token mismatch');
      req.response.statusCode = 403;
      req.response.write('forbidden');
      await req.response.close();
      return;
    }
    
    print('[LocalProxy] Authentication successful');

    // ignore: avoid_print
    print('[LocalProxy] <= ${req.method} ${req.uri}');

    final upstreamBase = await upstreamResolver();

    final upstreamUrl = upstreamBase.replace(
      path: _joinPath(upstreamBase.path, req.uri.path),
      query: req.uri.query,
    );

    final bodyBytes = await req.fold<List<int>>(<int>[], (a, b) => a..addAll(b));

    final client = HttpClient();
    try {
      final upstreamReq = await client.openUrl(req.method, upstreamUrl);

      // copy headers (filter hop-by-hop + potential mismatch headers)
      req.headers.forEach((name, values) {
        final lower = name.toLowerCase();
        if (_isHopByHop(lower)) return;

        // ✅ 必改：避免长度/压缩导致的问题
        if (lower == 'content-length') return;
        if (lower == 'accept-encoding') return;

        // 本地鉴权头不转发给上游
        if (lower == 'x-local-proxy') return;

        for (final v in values) {
          upstreamReq.headers.add(name, v);
        }
      });

      // ensure Host matches upstream
      upstreamReq.headers.set(HttpHeaders.hostHeader, upstreamBase.authority);

      upstreamReq.add(bodyBytes);

      final upstreamResp = await upstreamReq.close();

      req.response.statusCode = upstreamResp.statusCode;

      upstreamResp.headers.forEach((name, values) {
        final lower = name.toLowerCase();
        if (_isHopByHop(lower)) return;
        for (final v in values) {
          req.response.headers.add(name, v);
        }
      });

      await upstreamResp.pipe(req.response);
    } catch (e) {
      // ignore: avoid_print
      print('[LocalProxy] upstream error: $e');

      req.response.statusCode = 502;
      req.response.write('bad_gateway');
      await req.response.close();
    } finally {
      client.close(force: true);
    }
  }

  static bool _isHopByHop(String header) {
    return header == 'connection' ||
        header == 'keep-alive' ||
        header == 'proxy-authenticate' ||
        header == 'proxy-authorization' ||
        header == 'te' ||
        header == 'trailers' ||
        header == 'transfer-encoding' ||
        header == 'upgrade';
  }

  static String _joinPath(String a, String b) {
    if (a.isEmpty || a == '/') return b.startsWith('/') ? b : '/$b';
    final left = a.endsWith('/') ? a.substring(0, a.length - 1) : a;
    final right = b.startsWith('/') ? b : '/$b';
    return left + right;
  }

  Future<void> stop() async {
    await _server?.close(force: true);
    _server = null;
  }
}