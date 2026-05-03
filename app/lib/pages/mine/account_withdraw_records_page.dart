import 'package:flutter/material.dart';
import 'package:myapp/config/app_localizations.dart';
import 'package:myapp/request/withdraw_api.dart';

class AccountWithdrawRecordsPage extends StatefulWidget {
  const AccountWithdrawRecordsPage({super.key});

  @override
  State<AccountWithdrawRecordsPage> createState() =>
      _AccountWithdrawRecordsPageState();
}

class _AccountWithdrawRecordsPageState extends State<AccountWithdrawRecordsPage> {
  final List<WithdrawOrder> _items = <WithdrawOrder>[];
  final ScrollController _controller = ScrollController();

  bool _loading = false;
  bool _loadingMore = false;
  bool _noMore = false;
  int _pageNum = 1;
  static const int _pageSize = 10;
  static const double _scrollThreshold = 160;

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
    if (_loadingMore || _loading || _noMore) return;
    if (!_controller.hasClients) return;
    if (_controller.position.pixels >=
        _controller.position.maxScrollExtent - _scrollThreshold) {
      _loadMore();
    }
  }

  Future<void> _refresh() async {
    if (_loading) return;
    setState(() {
      _loading = true;
      _noMore = false;
      _pageNum = 1;
    });
    try {
      final List<WithdrawOrder> list = await WithdrawApi.getMyWithdrawList(
        pageNum: _pageNum,
        pageSize: _pageSize,
      );
      if (!mounted) return;
      setState(() {
        _items
          ..clear()
          ..addAll(list);
        _noMore = list.length < _pageSize;
      });
    } catch (e) {
      if (!mounted) return;
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
    if (_loadingMore || _loading || _noMore) return;
    setState(() {
      _loadingMore = true;
    });
    try {
      final int next = _pageNum + 1;
      final List<WithdrawOrder> list = await WithdrawApi.getMyWithdrawList(
        pageNum: next,
        pageSize: _pageSize,
      );
      if (!mounted) return;
      setState(() {
        _pageNum = next;
        _items.addAll(list);
        _noMore = list.length < _pageSize;
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

  @override
  Widget build(BuildContext context) {
    final AppLocalizations i18n = AppLocalizations.of(context);
    final bool isZh = i18n.locale.languageCode == 'zh';
    return Scaffold(
      backgroundColor: const Color(0xFF0A1220),
      appBar: AppBar(
        title: Text(isZh ? '提现记录' : 'Withdraw Records'),
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
            child: _buildBody(isZh),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(bool isZh) {
    if (_loading && _items.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF39E6FF)),
      );
    }
    if (_items.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: <Widget>[
          const SizedBox(height: 120),
          Center(
            child: Text(
              isZh ? '暂无记录' : 'No records',
              style: const TextStyle(color: Color(0xFF9DB1C9)),
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      controller: _controller,
      padding: const EdgeInsets.all(16),
      itemCount: _items.length + 1,
      itemBuilder: (BuildContext context, int index) {
        if (index >= _items.length) {
          return _buildFooter(isZh);
        }
        return _buildItem(_items[index], isZh);
      },
    );
  }

  Widget _buildItem(WithdrawOrder item, bool isZh) {
    final _StatusView status = _formatWithdrawStatus(item.status, isZh);
    final String amount = item.amount.toStringAsFixed(2);
    final String time = (item.submitTime ?? '').isEmpty
        ? (item.reviewTime ?? '')
        : item.submitTime ?? '';

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
                  '${isZh ? '金额' : 'Amount'}: $amount ${item.currencyType}',
                  style: const TextStyle(
                    color: Color(0xFFE9F3FF),
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: status.color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: status.color),
                ),
                child: Text(
                  status.label,
                  style: TextStyle(
                    color: status.color,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _kv(isZh ? '订单号' : 'Order', item.orderNo),
          if (item.requestNo.isNotEmpty) _kv(isZh ? '请求号' : 'Request', item.requestNo),
          if (item.withdrawMethod.isNotEmpty) _kv(isZh ? '方式' : 'Method', item.withdrawMethod),
          if (time.isNotEmpty) _kv(isZh ? '时间' : 'Time', time),
          if ((item.rejectReason ?? '').trim().isNotEmpty)
            _kv(isZh ? '原因' : 'Reason', item.rejectReason!.trim(),
                valueColor: const Color(0xFFFF6B6B)),
        ],
      ),
    );
  }

  Widget _kv(String k, String v, {Color valueColor = const Color(0xFF9DB1C9)}) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        children: <Widget>[
          SizedBox(
            width: 70,
            child: Text(
              k,
              style: const TextStyle(color: Color(0xFF9DB1C9), fontSize: 12),
            ),
          ),
          Expanded(
            child: Text(
              v,
              style: TextStyle(color: valueColor, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(bool isZh) {
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
        padding: const EdgeInsets.symmetric(vertical: 18),
        child: Center(
          child: Text(
            isZh ? '没有更多了' : 'No more',
            style: const TextStyle(color: Color(0xFF9DB1C9), fontSize: 12),
          ),
        ),
      );
    }
    return const SizedBox(height: 24);
  }

  _StatusView _formatWithdrawStatus(int status, bool isZh) {
    switch (status) {
      case 1:
        return _StatusView(
          isZh ? '已通过' : 'Approved',
          const Color(0xFF38FFB3),
        );
      case 2:
        return _StatusView(
          isZh ? '已驳回' : 'Rejected',
          const Color(0xFFFF6B6B),
        );
      default:
        return _StatusView(
          isZh ? '待审核' : 'Pending',
          const Color(0xFFFFA500),
        );
    }
  }
}

class _StatusView {
  const _StatusView(this.label, this.color);

  final String label;
  final Color color;
}
