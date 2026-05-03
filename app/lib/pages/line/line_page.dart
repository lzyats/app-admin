import 'package:flutter/material.dart';
import 'package:myapp/config/app_config.dart';
import 'package:myapp/config/app_localizations.dart';
import 'package:myapp/pages/line/line_controller.dart';
import 'package:myapp/res/app_colors.dart';
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
        final int safeSelectedIndex = _controller.hosts.isEmpty
            ? -1
            : _controller.selectedIndex.clamp(0, _controller.hosts.length - 1);
        final RequestHost? selectedHost = safeSelectedIndex >= 0
            ? _controller.hosts[safeSelectedIndex]
            : null;
        return Scaffold(
          backgroundColor: const Color(0xFF0A1220),
          appBar: AppBar(
            backgroundColor: const Color(0xFF0A1220),
            elevation: 0,
            foregroundColor: AppColors.textPrimary,
            title: Text(i18n.t('lineTitle')),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: IconButton.filledTonal(
                  tooltip: i18n.t('lineScanAdd'),
                  onPressed: _onScanAdd,
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.primary.withOpacity(0.12),
                    foregroundColor: AppColors.textPrimary,
                  ),
                  icon: const Icon(Icons.qr_code_scanner_rounded),
                ),
              ),
            ],
          ),
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: <Color>[
                  Color(0xFF0A1220),
                  Color(0xFF0D1B2A),
                ],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: _controller.loading
                  ? const Center(child: CircularProgressIndicator())
                  : Column(
                      children: [
                        Expanded(
                          child: ListView(
                            padding: const EdgeInsets.fromLTRB(0, 0, 0, 132),
                            children: [
                              _buildOverviewCard(
                                context: context,
                                description: i18n.t('lineDesc'),
                                selectedHost: selectedHost,
                                safeSelectedIndex: safeSelectedIndex,
                              ),
                              const SizedBox(height: 16),
                              ...List<Widget>.generate(_controller.hosts.length,
                                  (int index) {
                                final RequestHost host =
                                    _controller.hosts[index];
                                return Padding(
                                  padding: EdgeInsets.only(
                                      bottom:
                                          index == _controller.hosts.length - 1
                                              ? 0
                                              : 14),
                                  child: _buildHostCard(
                                    context: context,
                                    host: host,
                                    index: index,
                                    isSelected: safeSelectedIndex == index,
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                        _buildBottomBar(context),
                      ],
                    ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildOverviewCard({
    required BuildContext context,
    required String description,
    required RequestHost? selectedHost,
    required int safeSelectedIndex,
  }) {
    final i18n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xCC101C30),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0x334CE3FF)),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x66000000),
            blurRadius: 28,
            offset: Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: AppColors.primary.withOpacity(0.1),
                ),
                child: const Icon(Icons.hub_rounded, color: AppColors.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  i18n.t('lineTitle'),
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              FilledButton.tonalIcon(
                onPressed: _controller.testingAll ? null : _onTestAll,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.secondary.withOpacity(0.12),
                  foregroundColor: AppColors.textPrimary,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  textStyle: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600),
                ),
                icon: Icon(
                    _controller.testingAll
                        ? Icons.hourglass_top_rounded
                        : Icons.speed_rounded,
                    size: 18),
                label: Text(_controller.testingAll
                    ? i18n.t('lineTesting')
                    : i18n.t('lineTestAll')),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            description,
            style: const TextStyle(
              color: AppColors.textSecondary,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: const Color(0x661A2A40),
              border: Border.all(color: const Color(0x223CE3FF)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        selectedHost?.name ?? i18n.t('lineTitle'),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        selectedHost == null
                            ? '${i18n.t('lineLatencyPrefix')} --'
                            : '${i18n.t('lineHttpPrefix')} ${selectedHost.httpUrl}',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12.5,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: AppColors.primary.withOpacity(0.08),
                    border: Border.all(color: const Color(0x334CE3FF)),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.radio_button_checked_rounded,
                          color: AppColors.primary, size: 18),
                      const SizedBox(height: 4),
                      Text(
                        safeSelectedIndex < 0
                            ? '--'
                            : '${safeSelectedIndex + 1}',
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHostCard({
    required BuildContext context,
    required RequestHost host,
    required int index,
    required bool isSelected,
  }) {
    final i18n = AppLocalizations.of(context);
    final int? latency = _controller.latencyOf(index);
    final bool testing = _controller.testingOf(index);
    final Color accentColor =
        isSelected ? AppColors.primary : AppColors.textSecondary;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => _controller.select(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: const Color(0xCC101C30),
            border: Border.all(
              color: isSelected
                  ? const Color(0x664CE3FF)
                  : const Color(0x223CE3FF),
              width: isSelected ? 1.2 : 1,
            ),
            boxShadow: const <BoxShadow>[
              BoxShadow(
                color: Color(0x22000000),
                blurRadius: 14,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: accentColor.withOpacity(isSelected ? 0.14 : 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      isSelected ? Icons.lan_rounded : Icons.lan_outlined,
                      color: accentColor,
                      size: 21,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          host.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 15.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${i18n.t('lineHttpPrefix')} ${host.httpUrl}',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12.5,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _buildLatencyChip(
                        context: context,
                        testing: testing,
                        latency: latency,
                      ),
                      const SizedBox(height: 8),
                      Icon(
                        isSelected
                            ? Icons.check_circle_rounded
                            : Icons.chevron_right_rounded,
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.textSecondary,
                        size: 20,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                margin: const EdgeInsets.only(left: 56),
                height: 1,
                color: const Color(0x223CE3FF),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const SizedBox(width: 56),
                  Expanded(
                    child: Text(
                      testing
                          ? i18n.t('lineTesting')
                          : latency == null
                              ? '${i18n.t('lineLatencyPrefix')} --'
                              : '${i18n.t('lineLatencyPrefix')} ${latency}ms',
                      style: TextStyle(
                        color: _latencyTextColor(
                          testing: testing,
                          latency: latency,
                        ),
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton.icon(
                    onPressed:
                        testing ? null : () => _controller.testOne(index),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textPrimary,
                      side: const BorderSide(color: Color(0x334CE3FF)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                    ),
                    icon: Icon(
                      testing
                          ? Icons.hourglass_top_rounded
                          : Icons.network_ping_rounded,
                      size: 16,
                    ),
                    label: Text(
                      testing
                          ? i18n.t('lineTesting')
                          : i18n.t('lineTestCurrent'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLatencyChip({
    required BuildContext context,
    required bool testing,
    required int? latency,
  }) {
    final i18n = AppLocalizations.of(context);
    final Color color = _latencyTextColor(testing: testing, latency: latency);
    final String text = testing
        ? i18n.t('lineTesting')
        : latency == null
            ? '--'
            : '${latency}ms';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: color.withOpacity(0.14),
        border: Border.all(color: color.withOpacity(0.32)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    final i18n = AppLocalizations.of(context);
    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
        decoration: BoxDecoration(
          color: const Color(0xCC101C30),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0x223CE3FF)),
          boxShadow: const <BoxShadow>[
            BoxShadow(
              color: Color(0x66000000),
              blurRadius: 28,
              offset: Offset(0, 14),
            ),
          ],
        ),
        child: SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: _controller.saving ? null : _onSaveAndApply,
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(54),
              backgroundColor: AppColors.primary,
              foregroundColor: const Color(0xFF061420),
              textStyle:
                  const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
            icon: Icon(_controller.saving
                ? Icons.sync_rounded
                : Icons.swap_horiz_rounded),
            label: Text(_controller.saving
                ? i18n.t('lineSwitching')
                : i18n.t('lineSaveAndSwitch')),
          ),
        ),
      ),
    );
  }

  Color _latencyTextColor({
    required bool testing,
    required int? latency,
  }) {
    if (testing) {
      return const Color(0xFF7DEBFF);
    }
    if (latency == null) {
      return const Color(0xFFFF8F8F);
    }
    if (latency <= 120) {
      return const Color(0xFF54F3B1);
    }
    if (latency <= 240) {
      return const Color(0xFFFFD166);
    }
    return const Color(0xFFFFA36C);
  }

  /// 触发全部线路测速并提示结果。
  Future<void> _onTestAll() async {
    await _controller.testAll();
    if (!mounted) {
      return;
    }
    final i18n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(i18n.t('lineTestDone'))));
  }

  /// 保存线路并立即应用切换。
  Future<void> _onSaveAndApply() async {
    await _controller.applySelection();
    if (!mounted) {
      return;
    }
    final i18n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(i18n.t('lineSwitchDone'))));
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
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(i18n.t(result.messageKey))));
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
      backgroundColor: const Color(0xFF0A1220),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A1220),
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        title: Text(i18n.t('lineScanAdd')),
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: <Color>[
                  Color(0xFF0A1220),
                  Color(0xFF0D1B2A),
                ],
              ),
            ),
          ),
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
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xCC101C30),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0x334CE3FF)),
                boxShadow: const <BoxShadow>[
                  BoxShadow(
                    color: Color(0x66000000),
                    blurRadius: 28,
                    offset: Offset(0, 14),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: AppColors.primary.withOpacity(0.1),
                    ),
                    child: const Icon(Icons.qr_code_2_rounded,
                        color: AppColors.primary),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      i18n.t('lineScanHint'),
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        height: 1.45,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
