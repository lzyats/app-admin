import 'package:flutter/material.dart';
import 'package:myapp/config/app_localizations.dart';
import 'package:myapp/request/point_api.dart';

class AccountPointRecordsPage extends StatefulWidget {
  const AccountPointRecordsPage({super.key});

  @override
  State<AccountPointRecordsPage> createState() => _AccountPointRecordsPageState();
}

class _AccountPointRecordsPageState extends State<AccountPointRecordsPage> {
  final List<PointLog> _items = <PointLog>[];
  final ScrollController _controller = ScrollController();

  bool _loading = false;
  bool _loadingMore = false;
  bool _noMore = false;
  int _pageNum = 1;
  static const int _pageSize = 10;
  static const double _scrollThreshold = 160;

  PointAccount _account = const PointAccount(
    availablePoints: 0,
    frozenPoints: 0,
    totalEarned: 0,
    totalSpent: 0,
  );

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
      final PointAccount account = await PointApi.getMyPointAccount();
      final List<PointLog> list = await PointApi.getMyPointLogs(
        pageNum: _pageNum,
        pageSize: _pageSize,
      );
      if (!mounted) return;
      setState(() {
        _account = account;
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
      final List<PointLog> list = await PointApi.getMyPointLogs(
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
        title: Text(isZh ? '积分记录' : 'Point Records'),
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

    return ListView.builder(
      controller: _controller,
      padding: const EdgeInsets.all(16),
      itemCount: _items.length + 2,
      itemBuilder: (BuildContext context, int index) {
        if (index == 0) {
          return _buildAccountCard(isZh);
        }
        if (index == _items.length + 1) {
          return _buildFooter(isZh);
        }
        final PointLog item = _items[index - 1];
        return _buildItem(item, isZh);
      },
    );
  }

  Widget _buildAccountCard(bool isZh) {
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
          Text(
            isZh ? '积分账户' : 'Point Account',
            style: const TextStyle(
              color: Color(0xFFE9F3FF),
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: <Widget>[
              Expanded(
                child: _stat(
                  isZh ? '可用' : 'Available',
                  _account.availablePoints.toString(),
                  const Color(0xFF38FFB3),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _stat(
                  isZh ? '冻结' : 'Frozen',
                  _account.frozenPoints.toString(),
                  const Color(0xFFFFA500),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: <Widget>[
              Expanded(
                child: _stat(
                  isZh ? '累计获得' : 'Total Earned',
                  _account.totalEarned.toString(),
                  const Color(0xFF39E6FF),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _stat(
                  isZh ? '累计消耗' : 'Total Spent',
                  _account.totalSpent.toString(),
                  const Color(0xFFFF6B6B),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _stat(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0A1220).withOpacity(0.45),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0x33FFFFFF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            label,
            style: const TextStyle(color: Color(0xFF9DB1C9), fontSize: 12),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItem(PointLog item, bool isZh) {
    final bool positive = item.points >= 0;
    final Color amountColor = positive ? const Color(0xFF38FFB3) : const Color(0xFFFF6B6B);
    final String amount = (positive ? '+' : '') + item.points.toString();

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
                  '${isZh ? '变动' : 'Change'}: $amount',
                  style: TextStyle(
                    color: amountColor,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
              Text(
                item.createTime,
                style: const TextStyle(color: Color(0xFF9DB1C9), fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _kv(isZh ? '变动前' : 'Before', item.pointsBefore.toString()),
          _kv(isZh ? '变动后' : 'After', item.pointsAfter.toString()),
          if (item.sourceType.isNotEmpty) _kv(isZh ? '来源' : 'Source', item.sourceType),
          if (item.sourceNo.isNotEmpty) _kv(isZh ? '编号' : 'No', item.sourceNo),
          if (item.remark.trim().isNotEmpty) _kv(isZh ? '备注' : 'Remark', item.remark.trim()),
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
    if (_items.isEmpty && !_loading) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 18),
        child: Center(
          child: Text(
            isZh ? '暂无记录' : 'No records',
            style: const TextStyle(color: Color(0xFF9DB1C9), fontSize: 12),
          ),
        ),
      );
    }
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
}
