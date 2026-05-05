import 'package:flutter/material.dart';
import 'package:myapp/config/app_images.dart';
import 'package:myapp/config/app_localizations.dart';
import 'package:myapp/request/invest_order_api.dart';

class AccountAllRecordsPage extends StatefulWidget {
  const AccountAllRecordsPage({super.key});

  @override
  State<AccountAllRecordsPage> createState() => _AccountAllRecordsPageState();
}

class _AccountAllRecordsPageState extends State<AccountAllRecordsPage> {
  final List<InvestWalletLogItem> _items = <InvestWalletLogItem>[];
  final ScrollController _controller = ScrollController();

  bool _loading = false;
  bool _loadingMore = false;
  bool _noMore = false;
  int _pageNum = 1;
  static const int _pageSize = 10;
  static const double _scrollThreshold = 160;
  AppLocalizations get i18n => AppLocalizations.of(context)!;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onScroll);
    _refresh();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_loading || _loadingMore || _noMore) {
      return;
    }
    if (!_controller.hasClients) {
      return;
    }
    if (_controller.position.pixels >=
        _controller.position.maxScrollExtent - _scrollThreshold) {
      _loadMore();
    }
  }

  Future<void> _refresh() async {
    if (_loading) {
      return;
    }
    setState(() {
      _loading = true;
      _loadingMore = false;
      _noMore = false;
      _pageNum = 1;
    });
    try {
      final PagedWalletLogData page = await InvestOrderApi.fetchWalletLogs(
        pageNum: _pageNum,
        pageSize: _pageSize,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _items
          ..clear()
          ..addAll(page.rows);
        _noMore = _items.length >= page.total || page.rows.length < _pageSize;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: const Color(0xFFFF6B6B),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Future<void> _loadMore() async {
    if (_loading || _loadingMore || _noMore) {
      return;
    }
    setState(() {
      _loadingMore = true;
    });
    try {
      final int nextPage = _pageNum + 1;
      final PagedWalletLogData page = await InvestOrderApi.fetchWalletLogs(
        pageNum: nextPage,
        pageSize: _pageSize,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _pageNum = nextPage;
        _items.addAll(page.rows);
        _noMore = _items.length >= page.total || page.rows.length < _pageSize;
      });
    } catch (_) {
    } finally {
      if (mounted) {
        setState(() {
          _loadingMore = false;
        });
      }
    }
  }

  String _time(DateTime? t) {
    if (t == null) {
      return '--';
    }
    final DateTime local = t.toLocal();
    String d(int v) => v.toString().padLeft(2, '0');
    return '${local.year}-${d(local.month)}-${d(local.day)} ${d(local.hour)}:${d(local.minute)}';
  }

  bool _isPositiveFlow(String type) {
    final String t = type.toLowerCase();
    return t == 'recharge' ||
        t == 'redeem' ||
        t == 'profit' ||
        t == 'exchange_in' ||
        t == 'invest_level_bonus' ||
        t == 'invest_team_bonus' ||
        t == 'invest_red_packet';
  }

  String _typeText(String type) {
    switch (type.toLowerCase()) {
      case 'recharge':
        return i18n.t('walletTypeRecharge');
      case 'withdraw':
        return i18n.t('walletTypeWithdraw');
      case 'invest':
        return i18n.t('walletTypeInvest');
      case 'redeem':
        return i18n.t('walletTypeRedeem');
      case 'profit':
        return i18n.t('walletTypeProfit');
      case 'exchange_in':
        return i18n.t('walletTypeExchangeIn');
      case 'exchange_out':
        return i18n.t('walletTypeExchangeOut');
      case 'invest_level_bonus':
        return i18n.t('walletTypeLevelBonus');
      case 'invest_team_bonus':
        return i18n.t('walletTypeTeamBonus');
      case 'invest_red_packet':
        return i18n.t('walletTypeRedPacket');
      default:
        return type.isEmpty ? i18n.t('walletTypeDefault') : type;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1220),
      appBar: AppBar(
        title: Text(i18n.t('walletAllTitle')),
        backgroundColor: const Color(0xFF0A1220),
        elevation: 0,
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
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: _refresh,
            child: _buildBody(),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading && _items.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF39E6FF)),
      );
    }
    if (_items.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: <Widget>[
          SizedBox(height: 120),
          Center(
            child: Text(i18n.t('recordEmpty'), style: const TextStyle(color: Color(0xFF9DB1C9))),
          ),
        ],
      );
    }
    return ListView.builder(
      controller: _controller,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: _items.length + 1,
      itemBuilder: (_, int index) {
        if (index >= _items.length) {
          return _buildFooter();
        }
        return _buildItem(_items[index]);
      },
    );
  }

  Widget _buildItem(InvestWalletLogItem item) {
    final bool positive = _isPositiveFlow(item.type);
    final Color amountColor =
        positive ? const Color(0xFF38FFB3) : const Color(0xFFFF6B6B);
    final String amount =
        '${positive ? '+' : '-'}${item.amount.abs().toStringAsFixed(2)} ${item.currencyType}';
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xCC101C30),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x334CE3FF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  _typeText(item.type),
                  style: const TextStyle(
                    color: Color(0xFFE9F3FF),
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Image.asset(
                    AppImages.currencyBrand(item.currencyType),
                    width: 16,
                    height: 16,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    amount,
                    style: TextStyle(
                      color: amountColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${i18n.t('orderNo')}: ${item.orderNo.isEmpty ? '--' : item.orderNo}',
            style: const TextStyle(color: Color(0xFF9DB1C9), fontSize: 12),
          ),
          const SizedBox(height: 4),
          Text(
            '${i18n.t('time')}: ${_time(item.createTime)}',
            style: const TextStyle(color: Color(0xFF9DB1C9), fontSize: 12),
          ),
          if (item.remark.trim().isNotEmpty) ...<Widget>[
            const SizedBox(height: 4),
            Text(
              '${i18n.t('remark')}: ${item.remark.trim()}',
              style: const TextStyle(color: Color(0xFF9DB1C9), fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFooter() {
    if (_loadingMore) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 18),
        child: Center(
          child: SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Color(0xFF39E6FF),
            ),
          ),
        ),
      );
    }
    if (_noMore) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 18),
        child: Center(
          child: Text(
            i18n.t('noMore'),
            style: const TextStyle(color: Color(0xFF9DB1C9), fontSize: 12),
          ),
        ),
      );
    }
    return const SizedBox(height: 24);
  }
}
