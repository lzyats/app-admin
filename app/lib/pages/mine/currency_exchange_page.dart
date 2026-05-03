import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:myapp/config/app_images.dart';
import 'package:myapp/request/app_config_api.dart';
import 'package:myapp/request/auth_api.dart';
import 'package:myapp/request/withdraw_api.dart';
import 'package:myapp/tools/currency_tool.dart';

class CurrencyExchangePage extends StatefulWidget {
  const CurrencyExchangePage({
    super.key,
    this.initialFromCurrency,
  });

  final String? initialFromCurrency;

  @override
  State<CurrencyExchangePage> createState() => _CurrencyExchangePageState();
}

class _CurrencyExchangePageState extends State<CurrencyExchangePage> {
  final TextEditingController _amountController = TextEditingController();

  String _fromCurrency = 'CNY';
  String _toCurrency = 'USD';
  double _amount = 0.0;
  double _exchangeRate = 7.0;
  bool _isLoading = true;
  bool _isExchanging = false;
  AppBootstrapConfigData? _appConfig;
  List<WithdrawWalletItem> _wallets = <WithdrawWalletItem>[];

  bool get _supportDirectRmbToUsd => _appConfig?.supportRmbToUsd ?? true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      final AppBootstrapConfigData appConfig = await AppConfigApi.bootstrap();
      final List<WithdrawWalletItem> wallets = await WithdrawApi.getWallets();
      if (!mounted) {
        return;
      }
      setState(() {
        _appConfig = appConfig;
        _wallets = wallets;
        _exchangeRate = appConfig.usdRate;
        _resolveDirection();
        _isLoading = false;
        _isExchanging = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('加载兑换页面失败，请稍后重试'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _resolveDirection() {
    final String requested = _normalizeCurrency(widget.initialFromCurrency);
    if (requested == 'USD') {
      _fromCurrency = 'USD';
      _toCurrency = 'CNY';
    } else {
      _fromCurrency = 'CNY';
      _toCurrency = 'USD';
    }
  }

  String _normalizeCurrency(String? currencyType) {
    return currencyType?.toUpperCase() == 'USD' ? 'USD' : 'CNY';
  }

  WithdrawWalletItem? _walletByCurrency(String currencyType) {
    for (final WithdrawWalletItem wallet in _wallets) {
      if (wallet.currencyType.toUpperCase() == currencyType.toUpperCase()) {
        return wallet;
      }
    }
    return null;
  }

  double _balanceOf(String currencyType) {
    final WithdrawWalletItem? wallet = _walletByCurrency(currencyType);
    return wallet?.availableBalance ?? 0;
  }

  double _quotaOfUsdToRmb() {
    final WithdrawWalletItem? cnyWallet = _walletByCurrency('CNY');
    return cnyWallet?.usdExchangeQuota ?? 0;
  }

  String _currencyName(String currencyType) {
    return currencyType.toUpperCase() == 'USD' ? 'USDT' : '人民币';
  }

  String _currencyImage(String currencyType) {
    return AppImages.currencyBrand(currencyType, usePurpleVariant: true);
  }

  double _calculateExchangeAmount() {
    return CurrencyTool.convert(_normalizedAmount(), _fromCurrency, _toCurrency, _exchangeRate);
  }

  double? _displayExchangeRate() {
    if (_exchangeRate <= 0) {
      return null;
    }
    return CurrencyTool.convert(1, _fromCurrency, _toCurrency, _exchangeRate);
  }

  double _normalizedAmount() {
    return CurrencyTool.roundMoney(_amount);
  }

  void _switchCurrencies() {
    setState(() {
      final String temp = _fromCurrency;
      _fromCurrency = _toCurrency;
      _toCurrency = temp;
      _amountController.clear();
      _amount = 0;
    });
  }

  Future<void> _exchange() async {
    if (_isExchanging) {
      return;
    }
    final double amount = _normalizedAmount();
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('请输入兑换金额'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final double fromBalance = _balanceOf(_fromCurrency);
    if (amount > fromBalance) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${_currencyName(_fromCurrency)}余额不足'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!_supportDirectRmbToUsd && _fromCurrency == 'CNY') {
      final double quota = _quotaOfUsdToRmb();
      if (amount > quota) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('可兑换美元额度不足'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    setState(() {
      _isExchanging = true;
    });

    try {
      await AuthApi.exchangeCurrency(_fromCurrency, _toCurrency, amount);
      await _loadData();
      if (mounted) {
        setState(() {
          _amountController.clear();
          _amount = 0;
        });
      }
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('兑换成功'),
          backgroundColor: Color(0xFF38FFB3),
        ),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('兑换失败，请稍后重试'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isExchanging = false;
        });
      }
    }
  }

  Widget _buildWalletSummary() {
    final String rmbBalance = _balanceOf('CNY').toStringAsFixed(2);
    final String usdBalance = _balanceOf('USD').toStringAsFixed(2);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF111B2F),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0x334CE3FF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              const Icon(Icons.account_balance_wallet_outlined, color: Color(0xFF39E6FF), size: 18),
              const SizedBox(width: 8),
              const Text(
                '账户余额',
                style: TextStyle(
                  color: Color(0xFFEAF5FF),
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: <Widget>[
              Expanded(
                child: _miniBalanceCard(
                  label: '人民币',
                  value: rmbBalance,
                  iconPath: _currencyImage('CNY'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _miniBalanceCard(
                  label: 'USDT',
                  value: usdBalance,
                  iconPath: _currencyImage('USD'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _supportDirectRmbToUsd
                ? '支持人民币与USDT双向自由兑换'
                : 'USDT兑换人民币会增加可兑换额度，人民币兑换USDT会消耗可兑换额度',
            style: const TextStyle(
              color: Color(0xFF9DB1C9),
              fontSize: 12,
            ),
          ),
          if (!_supportDirectRmbToUsd) ...<Widget>[
            const SizedBox(height: 8),
            Text(
              '可兑换美元额度：${_quotaOfUsdToRmb().toStringAsFixed(2)}',
              style: const TextStyle(
                color: Color(0xFF9DB1C9),
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _miniBalanceCard({
    required String label,
    required String value,
    required String iconPath,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[Color(0xFF171F35), Color(0xFF111A2D)],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0x1AFFFFFF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Image.asset(iconPath, width: 22, height: 22, fit: BoxFit.contain),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF9DB1C9),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFFEAF5FF),
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountCard() {
    final List<String> sourceOptions = <String>['CNY', 'USD'];
    final List<String> targetOptions = <String>['CNY', 'USD'];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF111B2F),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0x334CE3FF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            '兑换金额',
            style: TextStyle(
              color: Color(0xFFEAF5FF),
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}$')),
            ],
            onChanged: (String value) {
              setState(() {
                _amount = double.tryParse(value) ?? 0;
              });
            },
            decoration: InputDecoration(
              hintText: '请输入兑换金额',
              hintStyle: const TextStyle(color: Color(0x669DB1C9)),
              filled: true,
              fillColor: const Color(0x0FFFFFFF),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
            style: const TextStyle(
              color: Color(0xFFEAF5FF),
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: <Widget>[
              Expanded(
                child: _currencySelect(
                  title: '从',
                  value: _fromCurrency,
                  options: sourceOptions,
                  onChanged: (String value) {
                    setState(() {
                      _fromCurrency = value;
                      if (_fromCurrency == _toCurrency) {
                        _toCurrency = value == 'CNY' ? 'USD' : 'CNY';
                      }
                    });
                  },
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: _switchCurrencies,
                child: Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: const Color(0x1A39E6FF),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0x334CE3FF)),
                  ),
                  child: const Icon(Icons.swap_horiz, color: Color(0xFF39E6FF)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _currencySelect(
                  title: '到',
                  value: _toCurrency,
                  options: targetOptions,
                  onChanged: (String value) {
                    setState(() {
                      _toCurrency = value;
                      if (_fromCurrency == _toCurrency) {
                        _fromCurrency = value == 'CNY' ? 'USD' : 'CNY';
                      }
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            '兑换汇率：1 ${_currencyName(_fromCurrency)} = ${_displayExchangeRate()?.toStringAsFixed(2) ?? '--'} ${_currencyName(_toCurrency)}',
            style: const TextStyle(
              color: Color(0xFF9DB1C9),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '预计到账：${_calculateExchangeAmount().toStringAsFixed(2)} ${_currencyName(_toCurrency)}',
            style: const TextStyle(
              color: Color(0xFFEAF5FF),
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _currencySelect({
    required String title,
    required String value,
    required List<String> options,
    required ValueChanged<String> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0x0FFFFFFF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x1AFFFFFF)),
      ),
      child: Row(
        children: <Widget>[
          Text(
            '$title ',
            style: const TextStyle(
              color: Color(0xFF9DB1C9),
              fontSize: 13,
            ),
          ),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                isExpanded: true,
                dropdownColor: const Color(0xFF111B2F),
                iconEnabledColor: const Color(0xFF39E6FF),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    onChanged(newValue);
                  }
                },
                items: options.map((String currency) {
                  return DropdownMenuItem<String>(
                    value: currency,
                    child: Text(
                      _currencyName(currency),
                      style: const TextStyle(color: Color(0xFFEAF5FF)),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: _isExchanging ? null : _exchange,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(26),
          ),
          padding: EdgeInsets.zero,
        ),
        child: Ink(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: <Color>[Color(0xFF7B3CFF), Color(0xFF2D7BFF)],
            ),
            borderRadius: BorderRadius.circular(26),
          ),
          child: Container(
            alignment: Alignment.center,
            child: _isExchanging
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    '确认兑换',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF07111F),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('货币互换'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Stack(
        children: <Widget>[
          const Positioned(
            top: -120,
            right: -100,
            child: _CircleGlow(
              size: 260,
              colors: <Color>[Color(0x2239E6FF), Color(0x00000000)],
            ),
          ),
          const Positioned(
            top: 140,
            left: -80,
            child: _CircleGlow(
              size: 180,
              colors: <Color>[Color(0x1A38FFB3), Color(0x00000000)],
            ),
          ),
          SafeArea(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFF39E6FF)),
                  )
                : RefreshIndicator(
                    color: const Color(0xFF39E6FF),
                    onRefresh: _loadData,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          _buildWalletSummary(),
                          const SizedBox(height: 16),
                          _buildAmountCard(),
                          const SizedBox(height: 24),
                          _buildSubmitButton(),
                        ],
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _CircleGlow extends StatelessWidget {
  const _CircleGlow({
    required this.size,
    required this.colors,
  });

  final double size;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: colors),
      ),
    );
  }
}
