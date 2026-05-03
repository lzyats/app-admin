import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:myapp/config/app_config.dart';
import 'package:myapp/request/api_client.dart';
import 'package:myapp/tools/encrypt_tool.dart';
import 'package:myapp/tools/line_host_tool.dart';

class LineController extends ChangeNotifier {
  final List<RequestHost> _hosts = <RequestHost>[];
  int _selectedIndex = 0;
  bool _loading = false;
  bool _saving = false;
  bool _testingAll = false;
  final Map<int, int?> _latencyMap = <int, int?>{};
  final Map<int, bool> _testingMap = <int, bool>{};

  int get selectedIndex => _selectedIndex;
  bool get loading => _loading;
  bool get saving => _saving;
  bool get testingAll => _testingAll;
  List<RequestHost> get hosts => _hosts;

  int? latencyOf(int index) => _latencyMap[index];
  bool testingOf(int index) => _testingMap[index] ?? false;

  Future<void> loadCurrentSelection() async {
    _loading = true;
    notifyListeners();

    try {
      final List<RequestHost> allHosts = await LineHostTool.getAllHosts();
      _hosts
        ..clear()
        ..addAll(_filterHosts(allHosts));

      final RequestHost current = await LineHostTool.getProxyUpstreamHost();
      final int index = hosts.indexWhere((RequestHost item) => item.httpUrl == current.httpUrl);
      _selectedIndex = index < 0 ? 0 : index;
    } catch (e, s) {
      debugPrint('loadCurrentSelection error: $e');
      debugPrint('$s');
      _hosts
        ..clear()
        ..addAll(_filterHosts(AppConfig.requestHost));
      _selectedIndex = 0;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  void select(int index) {
    if (index < 0 || index >= hosts.length) {
      return;
    }
    _selectedIndex = index;
    notifyListeners();
  }

  Future<void> applySelection() async {
    if (_selectedIndex < 0 || _selectedIndex >= hosts.length) {
      return;
    }

    _saving = true;
    notifyListeners();

    await LineHostTool.setCurrentHost(hosts[_selectedIndex]);
    await ApiClient.instance.refreshBaseUrl();

    _saving = false;
    notifyListeners();
  }

  Future<void> testOne(int index) async {
    if (index < 0 || index >= hosts.length) {
      return;
    }
    if (_testingMap[index] == true) {
      return;
    }

    _testingMap[index] = true;
    notifyListeners();

    final Stopwatch watch = Stopwatch()..start();
    try {
      final Dio dio = Dio(
        BaseOptions(
          connectTimeout: const Duration(seconds: 4),
          receiveTimeout: const Duration(seconds: 4),
          sendTimeout: const Duration(seconds: 4),
          validateStatus: (_) => true,
        ),
      );
      await dio.get<dynamic>(hosts[index].httpUrl);
      watch.stop();
      _latencyMap[index] = watch.elapsedMilliseconds;
    } catch (_) {
      _latencyMap[index] = null;
    } finally {
      _testingMap[index] = false;
      notifyListeners();
    }
  }

  Future<void> testAll() async {
    if (_testingAll) {
      return;
    }
    _testingAll = true;
    notifyListeners();

    for (int i = 0; i < hosts.length; i++) {
      await testOne(i);
    }

    _testingAll = false;
    notifyListeners();
  }

  Future<LineActionResult> addByQrRaw(String raw) async {
    final String text = raw.trim();
    if (text.isEmpty) {
      return const LineActionResult('lineQrEmpty');
    }

    String plainJson;
    try {
      plainJson = EncryptTool.decryptLineQrText(text);
    } catch (_) {
      return const LineActionResult('lineQrDecryptFailed');
    }

    RequestHost? host;
    try {
      final dynamic decoded = jsonDecode(plainJson);
      if (decoded is Map<String, dynamic>) {
        host = RequestHost.fromJson(decoded);
      } else if (decoded is Map) {
        host = RequestHost.fromJson(Map<String, dynamic>.from(decoded));
      }
    } catch (_) {
      host = null;
    }

    if (host == null) {
      return const LineActionResult('lineQrInvalidData');
    }

    final RequestHost safeHost = host;
    final bool added = await LineHostTool.addCustomHost(safeHost);
    _hosts
      ..clear()
      ..addAll(_filterHosts(await LineHostTool.getAllHosts()));

    final int index = _hosts.indexWhere((RequestHost item) => item.httpUrl == safeHost.httpUrl && item.wsUrl == safeHost.wsUrl);
    if (index >= 0) {
      _selectedIndex = index;
    }
    notifyListeners();

    if (!added) {
      return const LineActionResult('lineQrExists');
    }
    return const LineActionResult('lineQrAddSuccess');
  }

  List<RequestHost> _filterHosts(List<RequestHost> hosts) {
    if (!_hideLoopbackHosts) {
      return hosts;
    }
    return hosts.where((RequestHost host) => !_isLoopbackHost(host.httpUrl)).toList();
  }

  bool get _hideLoopbackHosts => !kIsWeb;

  bool _isLoopbackHost(String httpUrl) {
    try {
      final Uri uri = Uri.parse(httpUrl);
      final String host = uri.host.toLowerCase();
      return host == '127.0.0.1' || host == 'localhost' || host == '::1';
    } catch (_) {
      return false;
    }
  }
}

class LineActionResult {
  const LineActionResult(this.messageKey);

  final String messageKey;
}
