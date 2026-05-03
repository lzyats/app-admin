import 'package:flutter/material.dart';

import 'package:myapp/config/app_localizations.dart';
import 'package:myapp/request/yebao_api.dart';
import 'package:myapp/tools/app_bootstrap_tool.dart';

class YebaoOrdersPage extends StatefulWidget {
  const YebaoOrdersPage({super.key});

  @override
  State<YebaoOrdersPage> createState() => _YebaoOrdersPageState();
}

class _YebaoOrdersPageState extends State<YebaoOrdersPage> {
  late Future<List<YebaoOrderItem>> _future;

  @override
  void initState() {
    super.initState();
    _future = YebaoApi.fetchMyOrders();
  }

  Future<void> _refresh() async {
    setState(() {
      _future = YebaoApi.fetchMyOrders();
    });
    await _future;
  }

  String _text(AppLocalizations i18n, String key) {
    return i18n.t(key);
  }

  String _money(double value) {
    return value.toStringAsFixed(2);
  }

  String _dateTime(DateTime? dateTime) {
    if (dateTime == null) {
      return '--';
    }
    final DateTime local = dateTime.toLocal();
    String twoDigits(int value) => value.toString().padLeft(2, '0');
    return '${local.year}-${twoDigits(local.month)}-${twoDigits(local.day)} ${twoDigits(local.hour)}:${twoDigits(local.minute)}';
  }

  bool _canRedeem(YebaoOrderItem item) {
    if (!AppBootstrapTool.config.yebaoRedeemAfter24h) {
      return true;
    }
    final DateTime? nextSettleTime = item.nextSettleTime;
    if (nextSettleTime == null) {
      return false;
    }
    return DateTime.now().isAfter(nextSettleTime);
  }

  String _formatDuration(Duration duration) {
    final Duration normalized = duration.isNegative ? Duration.zero : duration;
    final int totalSeconds = normalized.inSeconds;
    final int days = normalized.inDays;
    final int hours = (totalSeconds % 86400) ~/ 3600;
    final int minutes = (totalSeconds % 3600) ~/ 60;
    final int seconds = totalSeconds % 60;
    String twoDigits(int value) => value.toString().padLeft(2, '0');
    if (days > 0) {
      return '${days}d ${twoDigits(hours)}:${twoDigits(minutes)}:${twoDigits(seconds)}';
    }
    return '${twoDigits(hours)}:${twoDigits(minutes)}:${twoDigits(seconds)}';
  }

  String _redeemRemainingText(AppLocalizations i18n, YebaoOrderItem item) {
    if (!AppBootstrapTool.config.yebaoRedeemAfter24h) {
      return _text(i18n, 'yebaoRedeemAvailable');
    }
    final DateTime? nextSettleTime = item.nextSettleTime;
    if (nextSettleTime == null) {
      return _text(i18n, 'yebaoRedeemAvailable');
    }
    final Duration remaining = nextSettleTime.difference(DateTime.now());
    if (remaining.isNegative) {
      return _text(i18n, 'yebaoRedeemAvailable');
    }
    return '${_text(i18n, 'yebaoRedeemRemainingTime')}: ${_formatDuration(remaining)}';
  }

  Future<void> _submitRedeem(YebaoOrderItem item) async {
    final AppLocalizations i18n = AppLocalizations.of(context)!;
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(_text(i18n, 'yebaoRedeemConfirm')),
          content: Text(item.orderNo.isNotEmpty ? item.orderNo : _text(i18n, 'yebaoRedeemConfirm')),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(_text(i18n, 'cancel')),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(_text(i18n, 'commonConfirm')),
            ),
          ],
        );
      },
    );
    if (confirmed != true) {
      return;
    }

    try {
      await YebaoApi.redeem(orderId: item.orderId);
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_text(i18n, 'yebaoRedeemSuccess'))),
      );
      await _refresh();
    } catch (error) {
      if (!mounted) {
        return;
      }
      final String message = error
          .toString()
          .replaceFirst('Exception: ', '')
          .replaceFirst('ServiceException: ', '');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: const Color(0xFFFF6B6B),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations i18n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: const Color(0xFF09072A),
      appBar: AppBar(
        title: Text(_text(i18n, 'yebaoRecentOrders')),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: FutureBuilder<List<YebaoOrderItem>>(
        future: _future,
        builder: (BuildContext context, AsyncSnapshot<List<YebaoOrderItem>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF39E6FF)),
            );
          }
          if (snapshot.hasError) {
            return _buildErrorState(i18n);
          }
          final List<YebaoOrderItem> orders = snapshot.data ?? <YebaoOrderItem>[];
          return RefreshIndicator(
            color: const Color(0xFF39E6FF),
            onRefresh: _refresh,
            child: orders.isEmpty
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(24),
                    children: <Widget>[
                      const SizedBox(height: 120),
                      const Icon(Icons.receipt_long_outlined, color: Color(0xFF39E6FF), size: 56),
                      const SizedBox(height: 12),
                      Text(
                        _text(i18n, 'yebaoNoOrders'),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xFFEAF5FF),
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _text(i18n, 'yebaoOrdersPageHint'),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xFF9DB1C9),
                          fontSize: 13,
                          height: 1.5,
                        ),
                      ),
                    ],
                  )
                : ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
                    itemBuilder: (BuildContext context, int index) {
                      final YebaoOrderItem item = orders[index];
                      return Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xCC101C30),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: const Color(0x334CE3FF)),
                        ),
                        child: Row(
                          children: <Widget>[
                            if (item.status == '0') ...<Widget>[
                              Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF39E6FF).withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.savings_outlined, color: Color(0xFF39E6FF), size: 22),
                              ),
                              const SizedBox(width: 12),
                            ],
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    item.orderNo.isNotEmpty ? item.orderNo : '--',
                                    style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${item.shares} ${_text(i18n, 'yebaoShareUnit')} / ${_money(item.principalAmount)}',
                                    style: const TextStyle(color: Color(0xFF9DB1C9), fontSize: 12),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _dateTime(item.investTime),
                                    style: const TextStyle(color: Color(0xFF7E93B2), fontSize: 11),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _redeemRemainingText(i18n, item),
                                    style: TextStyle(
                                      color: _canRedeem(item)
                                          ? const Color(0xFF38FFB3)
                                          : const Color(0xFFFFB74D),
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            if (item.status == '0') ...<Widget>[
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: <Widget>[
                                  Text(
                                    '+${_money(item.settledIncome)}',
                                    style: const TextStyle(
                                      color: Color(0xFF38FFB3),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  SizedBox(
                                    height: 30,
                                    child: OutlinedButton(
                                      onPressed: _canRedeem(item) ? () => _submitRedeem(item) : null,
                                      style: OutlinedButton.styleFrom(
                                        side: BorderSide(
                                          color: _canRedeem(item)
                                              ? const Color(0xFFFF6B6B)
                                              : const Color(0x66FF6B6B),
                                        ),
                                        foregroundColor: _canRedeem(item)
                                            ? const Color(0xFFFF6B6B)
                                            : const Color(0x66FF6B6B),
                                        padding: const EdgeInsets.symmetric(horizontal: 12),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                                      ),
                                      child: Text(
                                        _canRedeem(item)
                                            ? _text(i18n, 'yebaoRedeemButton')
                                            : _text(i18n, 'yebaoRedeemLocked'),
                                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ] else ...<Widget>[
                              Text(
                                '+${_money(item.settledIncome)}',
                                style: const TextStyle(
                                  color: Color(0xFF38FFB3),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ],
                        ),
                      );
                    },
                    separatorBuilder: (BuildContext context, int index) => const SizedBox(height: 10),
                    itemCount: orders.length,
                  ),
          );
        },
      ),
    );
  }

  Widget _buildErrorState(AppLocalizations i18n) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: <Widget>[
        const SizedBox(height: 140),
        const Icon(Icons.receipt_long_outlined, color: Color(0xFF39E6FF), size: 56),
        const SizedBox(height: 12),
        Text(
          _text(i18n, 'yebaoLoadFailed'),
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFFEAF5FF),
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          _text(i18n, 'yebaoLoadFailedHint'),
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFF9DB1C9),
            fontSize: 13,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 18),
        FilledButton(
          onPressed: _refresh,
          child: Text(_text(i18n, 'assetsRetry')),
        ),
      ],
    );
  }
}
