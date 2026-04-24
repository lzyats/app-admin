import 'package:flutter/material.dart';
import 'package:myapp/config/app_localizations.dart';
import 'package:myapp/pages/line/line_controller.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class LinePage extends StatefulWidget {
  const LinePage({super.key});

  @override
  /// 创建线路页面状态对象。
  State<LinePage> createState() => _LinePageState();
}

class _LinePageState extends State<LinePage> {
  late final LineController _controller;

  @override
  /// 初始化控制器并加载线路数据。
  void initState() {
    super.initState();
    _controller = LineController();
    _controller.loadCurrentSelection();
  }

  @override
  /// 释放线路控制器资源。
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  /// 构建线路页面主体。
  Widget build(BuildContext context) {
    final i18n = AppLocalizations.of(context);
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        return Scaffold(
          appBar: AppBar(
            title: Text(i18n.t('lineTitle')),
            actions: [
              IconButton(
                tooltip: i18n.t('lineScanAdd'),
                onPressed: _onScanAdd,
                icon: const Icon(Icons.qr_code_scanner_rounded),
              ),
            ],
          ),
          body: _controller.loading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              i18n.t('lineDesc'),
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                          TextButton(
                            onPressed: _controller.testingAll ? null : _onTestAll,
                            child: Text(_controller.testingAll ? i18n.t('lineTesting') : i18n.t('lineTestAll')),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        itemCount: _controller.hosts.length,
                        itemBuilder: (BuildContext context, int index) {
                          final host = _controller.hosts[index];
                          final int? latency = _controller.latencyOf(index);
                          final bool testing = _controller.testingOf(index);
                          final bool selected = _controller.selectedIndex == index;
                          final String latencyText = testing
                              ? i18n.t('lineTesting')
                              : latency == null
                                  ? '${i18n.t('lineLatencyPrefix')} --'
                                  : '${i18n.t('lineLatencyPrefix')} ${latency}ms';

                          return Card(
                            child: RadioListTile<int>(
                              value: index,
                              groupValue: _controller.selectedIndex,
                              onChanged: (int? value) {
                                if (value != null) {
                                  _controller.select(value);
                                }
                              },
                              title: Text(host.name),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('${i18n.t('lineHttpPrefix')} ${host.httpUrl}'),
                                  Text(latencyText),
                                  const SizedBox(height: 4),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: OutlinedButton(
                                      onPressed: testing ? null : () => _controller.testOne(index),
                                      child: Text(testing ? i18n.t('lineTesting') : i18n.t('lineTestCurrent')),
                                    ),
                                  ),
                                ],
                              ),
                              selected: selected,
                            ),
                          );
                        },
                      ),
                    ),
                    SafeArea(
                      top: false,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                        child: SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: _controller.saving ? null : _onSaveAndApply,
                            child: Text(_controller.saving ? i18n.t('lineSwitching') : i18n.t('lineSaveAndSwitch')),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }

  /// 触发全部线路测速并提示结果。
  Future<void> _onTestAll() async {
    await _controller.testAll();
    if (!mounted) {
      return;
    }
    final i18n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(i18n.t('lineTestDone'))));
  }

  /// 保存线路并立即应用切换。
  Future<void> _onSaveAndApply() async {
    await _controller.applySelection();
    if (!mounted) {
      return;
    }
    final i18n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(i18n.t('lineSwitchDone'))));
  }

  /// 打开扫码页并处理扫码添加线路。
  Future<void> _onScanAdd() async {
    final String? raw = await Navigator.of(context).push<String>(
      MaterialPageRoute<String>(builder: (_) => const _LineQrScanPage()),
    );

    if (!mounted || raw == null || raw.trim().isEmpty) {
      return;
    }

    final LineActionResult result = await _controller.addByQrRaw(raw);
    if (!mounted) {
      return;
    }
    final i18n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(i18n.t(result.messageKey))));
  }
}

class _LineQrScanPage extends StatefulWidget {
  const _LineQrScanPage();

  @override
  /// 创建扫码页面状态对象。
  State<_LineQrScanPage> createState() => _LineQrScanPageState();
}

class _LineQrScanPageState extends State<_LineQrScanPage> {
  bool _handled = false;

  @override
  /// 构建扫码页面。
  Widget build(BuildContext context) {
    final i18n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(i18n.t('lineScanAdd'))),
      body: Stack(
        children: [
          MobileScanner(
            onDetect: (BarcodeCapture capture) {
              if (_handled) {
                return;
              }
              final String raw = capture.barcodes.first.rawValue ?? '';
              if (raw.trim().isEmpty) {
                return;
              }
              _handled = true;
              Navigator.of(context).pop(raw);
            },
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              color: Colors.black54,
              padding: const EdgeInsets.all(16),
              child: Text(
                i18n.t('lineScanHint'),
                style: const TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
