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
  /// 判断指定线路当前是否处于测速状态。
  bool testingOf(int index) => _testingMap[index] ?? false;

  /// 加载当前线路选择并同步到内存状态。
  Future<void> loadCurrentSelection() async {
    _loading = true;
    notifyListeners();

    try {
      _hosts
        ..clear()
        ..addAll(await LineHostTool.getAllHosts());

      final RequestHost current = await LineHostTool.getCurrentHost();
      final int index = hosts.indexWhere((RequestHost item) => item.httpUrl == current.httpUrl);
      _selectedIndex = index < 0 ? 0 : index;
    } catch (e, s) {
      debugPrint('loadCurrentSelection error: $e');
      debugPrint('$s');
      _hosts
        ..clear()
        ..addAll(AppConfig.requestHost);
      _selectedIndex = 0;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// 选中指定线路索引。
  void select(int index) {
    if (index < 0 || index >= hosts.length) {
      return;
    }
    _selectedIndex = index;
    notifyListeners();
  }

  /// 保存当前选中的线路并立即刷新请求基地址。
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

  /// 测试单条线路连通性并记录延迟。
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

  /// 依次测试全部线路。
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

  /// 解析扫码内容并添加自定义线路。
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
      ..addAll(await LineHostTool.getAllHosts());

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
}

class LineActionResult {
  /// 创建线路动作结果对象。
  const LineActionResult(this.messageKey);

  final String messageKey;
}
