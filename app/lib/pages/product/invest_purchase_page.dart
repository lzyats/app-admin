import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:myapp/config/app_images.dart';
import 'package:myapp/request/auth_api.dart';
import 'package:myapp/request/api_client.dart';
import 'package:myapp/request/app_config_api.dart';
import 'package:myapp/request/invest_order_api.dart';
import 'package:myapp/request/invest_product_api.dart';
import 'package:myapp/request/withdraw_api.dart';
import 'package:myapp/routers/app_router.dart';
import 'package:myapp/tools/app_bootstrap_tool.dart';
import 'package:myapp/tools/number_keyboard_tool.dart';
import 'package:myapp/tools/signature_tool.dart';
import 'package:myapp/widgets/app_network_image.dart';

class InvestPurchasePage extends StatefulWidget {
  const InvestPurchasePage({
    super.key,
    required this.productId,
    required this.groupMode,
  });

  final int productId;
  final bool groupMode;

  @override
  State<InvestPurchasePage> createState() => _InvestPurchasePageState();
}

class _InvestPurchasePageState extends State<InvestPurchasePage> {
  late Future<InvestProductItem> _future;
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _payPwdController = TextEditingController();
  int _purchaseShares = 1;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _future = InvestProductApi.fetchProductDetail(widget.productId);
  }

  @override
  void dispose() {
    _amountController.dispose();
    _payPwdController.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    setState(() {
      _future = InvestProductApi.fetchProductDetail(widget.productId);
    });
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF070A2D),
      appBar: AppBar(
        title: Text(widget.groupMode ? '拼团认购' : '产品认购'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: FutureBuilder<InvestProductItem>(
        future: _future,
        builder: (BuildContext context, AsyncSnapshot<InvestProductItem> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF39E6FF)));
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return Center(
              child: FilledButton(
                onPressed: _refresh,
                child: const Text('重试'),
              ),
            );
          }
          final InvestProductItem item = snapshot.data!;
          _syncAmountByMode(item);
          return ListView(
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 14),
            children: <Widget>[
              _buildHeroCard(item),
              if (widget.groupMode) ...<Widget>[
                const SizedBox(height: 10),
                _buildGroupCard(),
              ],
              const SizedBox(height: 10),
              _buildInputCard(
                '金额',
                item.investMode == 'AMOUNT' ? '请输入购买金额' : '自动按份数计算',
                _amountController,
                false,
                readOnly: item.investMode != 'AMOUNT',
              ),
              if (item.investMode != 'AMOUNT') ...<Widget>[
                const SizedBox(height: 10),
                _buildSharesCard(item),
              ],
              const SizedBox(height: 10),
              _buildInputCard('支付密码', '请输入支付密码', _payPwdController, true),
              const SizedBox(height: 10),
              _buildCurrencyLine(item),
              const SizedBox(height: 8),
              _buildTips(item),
              const SizedBox(height: 18),
              _buildSubmit(item),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeroCard(InvestProductItem item) {
    return Container(
      height: 210,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        image: const DecorationImage(
          image: AssetImage(AppImages.investCardBg),
          fit: BoxFit.cover,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    item.productName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '${item.singleRate.toStringAsFixed(3)}%',
                    style: const TextStyle(color: Color(0xFF236DEB), fontSize: 50 / 2, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
            Image.asset(
              _resolveProductHeroImage(item.currency),
              width: 164,
              height: 164,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const SizedBox(width: 164, height: 164),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupCard() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF111747),
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 10),
      child: Column(
        children: <Widget>[
          RichText(
            text: const TextSpan(
              children: <InlineSpan>[
                TextSpan(text: '只需 ', style: TextStyle(color: Colors.white, fontSize: 21, fontWeight: FontWeight.w700)),
                TextSpan(text: '2', style: TextStyle(color: Color(0xFFFF5B4A), fontSize: 21, fontWeight: FontWeight.w700)),
                TextSpan(text: ' 人即可成团', style: TextStyle(color: Colors.white, fontSize: 21, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Text('剩余 24 : 00 : 00 结束', style: TextStyle(color: Color(0xFF8592BF), fontSize: 20 / 1.2)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const CircleAvatar(radius: 22, backgroundColor: Colors.white, child: Icon(Icons.person, color: Color(0xFF3A4C77))),
              const SizedBox(width: 24),
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF2A3E71), width: 2),
                ),
                child: const Icon(Icons.add, color: Color(0xFF5C78AE)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text('✓ 享受拼团优惠价格', style: TextStyle(color: Color(0xFF7E8DBB), fontSize: 15)),
          const SizedBox(height: 4),
          const Text('✓ 成团后立即开始投资', style: TextStyle(color: Color(0xFF7E8DBB), fontSize: 15)),
        ],
      ),
    );
  }

  Widget _buildInputCard(
    String title,
    String hint,
    TextEditingController controller,
    bool obscure, {
    bool readOnly = false,
  }) {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF111747),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: <Widget>[
          SizedBox(
            width: 110,
            child: Text(title, style: const TextStyle(color: Colors.white, fontSize: 35 / 2, fontWeight: FontWeight.w600)),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              obscureText: obscure,
              obscuringCharacter: '•',
              keyboardType: obscure ? TextInputType.none : const TextInputType.numberWithOptions(decimal: true),
              readOnly: obscure || readOnly,
              onTap: obscure ? () => _openPayPasswordKeyboard(controller) : null,
              enableSuggestions: !obscure,
              autocorrect: !obscure,
              style: const TextStyle(color: Color(0xFFDFE8FF), fontSize: 34 / 2),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: const TextStyle(color: Color(0xFF5E6E9F), fontSize: 34 / 2),
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSharesCard(InvestProductItem item) {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF111747),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: <Widget>[
          const SizedBox(
            width: 110,
            child: Text('购买份数', style: TextStyle(color: Colors.white, fontSize: 35 / 2, fontWeight: FontWeight.w600)),
          ),
          const Spacer(),
          _stepBtn('-', () => _changeShares(item, -1)),
          Container(
            width: 62,
            alignment: Alignment.center,
            child: Text(
              '$_purchaseShares',
              style: const TextStyle(color: Color(0xFFDFE8FF), fontSize: 18, fontWeight: FontWeight.w700),
            ),
          ),
          _stepBtn('+', () => _changeShares(item, 1)),
        ],
      ),
    );
  }

  Widget _stepBtn(String text, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        width: 34,
        height: 34,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: const Color(0xFF2E8FFF)),
        ),
        child: Text(
          text,
          style: const TextStyle(color: Color(0xFF39E6FF), fontSize: 18, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  Widget _buildCurrencyLine(InvestProductItem item) {
    return Container(
      height: 66,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF111747),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: <Widget>[
          Image.asset(
            AppImages.currencyBrand(item.currency, usePurpleVariant: true),
            width: 22,
            height: 22,
            fit: BoxFit.contain,
          ),
          const SizedBox(width: 8),
          Text(item.currency, style: const TextStyle(color: Colors.white, fontSize: 37 / 2, fontWeight: FontWeight.w700)),
          const Spacer(),
          Text(_fmt(item.maxInvestAmount), style: const TextStyle(color: Color(0xFF8A97C4), fontSize: 36 / 2)),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right, color: Color(0xFF7685B3)),
        ],
      ),
    );
  }

  Widget _buildTips(InvestProductItem item) {
    return Text(
      '单笔最低${_fmt(item.minInvestAmount)}，最高${_fmt(item.maxInvestAmount)}，可投次数${item.limitTimes <= 0 ? 1 : item.limitTimes}',
      textAlign: TextAlign.center,
      style: const TextStyle(color: Color(0xFF7B88B6), fontSize: 32 / 2),
    );
  }

  Widget _buildSubmit(InvestProductItem item) {
    return SizedBox(
      height: 56,
      child: ElevatedButton(
        onPressed: _submitting ? null : () => _handleSubmit(item),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1B3CF4),
          disabledBackgroundColor: const Color(0xFF3552C2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        ),
        child: _submitting
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : const Text('提交', style: TextStyle(color: Color(0xFF35DAFF), fontSize: 20, fontWeight: FontWeight.w700)),
      ),
    );
  }

  Future<void> _handleSubmit(InvestProductItem item) async {
    final String? blockedReason = _resolveOrderBlockedReason(item);
    if (blockedReason != null && blockedReason.isNotEmpty) {
      _toast(blockedReason);
      return;
    }
    final bool payPasswordReady = await _ensurePayPasswordSet();
    if (!payPasswordReady) {
      return;
    }
    final bool shareMode = item.investMode != 'AMOUNT';
    final double amount = shareMode
        ? _calcShareModeAmount(item, _purchaseShares)
        : (double.tryParse(_amountController.text.trim()) ?? 0);
    if (shareMode && _purchaseShares <= 0) {
      _toast('请选择购买份数');
      return;
    }
    if (amount <= 0) {
      _toast(shareMode ? '请先配置单份金额' : '请输入正确金额');
      return;
    }
    final String? walletError = await _validateWalletBalance(item.currency, amount);
    if (walletError != null) {
      _toast(walletError);
      return;
    }
    final InvestContractPreview preview = await InvestOrderApi.previewContract(
      productId: item.productId,
      productName: item.productName,
      amount: amount,
      cycleDays: item.cycleDays,
      singleRate: item.singleRate,
    );
    _SignedContractResult? result;
    if (preview.signedBefore) {
      result = const _SignedContractResult(
        agreed: true,
        signatureBase64: '',
      );
      _toast('该产品已签约，本次无需重复签约');
    } else {
      final String contractStamp1 = AppBootstrapTool.config
          .getByItemString(AppConfigOptionItem.htimg1)
          .trim();
      final String contractStamp2 = AppBootstrapTool.config
          .getByItemString(AppConfigOptionItem.htimg2)
          .trim();
      if (!mounted) return;
      result = await showDialog<_SignedContractResult>(
        context: context,
        barrierDismissible: false,
        builder: (_) => _ContractSignDialog(
          preview: preview,
          contractStamp1: contractStamp1,
          contractStamp2: contractStamp2,
        ),
      );
    }
    if (result == null) {
      return;
    }
    final String payPwd = _payPwdController.text.trim();
    if (payPwd.isEmpty) {
      _toast('请输入支付密码');
      return;
    }

    setState(() => _submitting = true);
    try {
      final String reqNo = _buildClientReqNo(item.productId, amount);
      await InvestOrderApi.submit(
        productId: item.productId,
        amount: amount,
        purchaseShares: shareMode ? _purchaseShares : 0,
        payPwd: payPwd,
        agreed: result.agreed,
        signatureData: result.signatureBase64,
        contractText: preview.contractText,
        clientReqNo: reqNo,
        groupMode: widget.groupMode,
      );
      if (!mounted) return;
      _toast('签约并提交成功');
      Navigator.pop(context);
    } catch (e) {
      _toast(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  void _toast(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  String _fmt(double value) {
    if (value % 1 == 0) {
      return value.toStringAsFixed(0);
    }
    return value.toStringAsFixed(2);
  }

  String _buildClientReqNo(int productId, double amount) {
    final int now = DateTime.now().microsecondsSinceEpoch;
    final int cents = (amount * 100).round();
    return 'REQ_${widget.groupMode ? 'G' : 'S'}_${productId}_${cents}_$now';
  }

  String _resolveProductHeroImage(String currency) {
    final String key = currency.trim().toUpperCase();
    if (key == 'CNY') {
      return AppImages.investContractStamp; // assets/images/2.webp
    }
    return AppImages.investToken; // assets/images/t.webp
  }

  Future<void> _openPayPasswordKeyboard(TextEditingController controller) async {
    final bool payPasswordReady = await _ensurePayPasswordSet();
    if (!payPasswordReady) {
      return;
    }
    final String? value = await NumberKeyboardTool.show(
      context,
      title: '请输入支付密码',
      initialValue: controller.text.trim(),
      maxLength: 12,
    );
    if (!mounted || value == null) {
      return;
    }
    setState(() {
      controller.text = value;
    });
  }

  Future<bool> _ensurePayPasswordSet() async {
    try {
      AuthUserProfile profile = await AuthApi.getInfo();
      if (profile.payPasswordSet == 1) {
        return true;
      }
      profile = await AuthApi.getInfo(forceRefresh: true);
      if (profile.payPasswordSet == 1) {
        return true;
      }
      if (!mounted) {
        return false;
      }
      final Object? result = await Navigator.pushNamed(
        context,
        AppRouter.payPasswordSet,
        arguments: <String, dynamic>{'userId': profile.userId},
      );
      if (result == true) {
        final AuthUserProfile latest = await AuthApi.getInfo(forceRefresh: true);
        return latest.payPasswordSet == 1;
      }
      _toast('请先设置支付密码');
      return false;
    } catch (_) {
      _toast('暂时无法校验支付密码状态，请稍后重试');
      return false;
    }
  }

  void _changeShares(InvestProductItem item, int delta) {
    final int next = _purchaseShares + delta;
    if (next <= 0) {
      return;
    }
    final int maxByProduct = _resolveShareMax(item);
    if (maxByProduct > 0 && next > maxByProduct) {
      _toast('购买份数超出限制');
      return;
    }
    setState(() {
      _purchaseShares = next;
      _amountController.text = _fmtAmount(_calcShareModeAmount(item, _purchaseShares));
    });
  }

  void _syncAmountByMode(InvestProductItem item) {
    if (item.investMode == 'AMOUNT') {
      return;
    }
    if (_purchaseShares <= 0) {
      _purchaseShares = 1;
    }
    final int maxByProduct = _resolveShareMax(item);
    if (maxByProduct > 0 && _purchaseShares > maxByProduct) {
      _purchaseShares = maxByProduct;
    }
    final String text = _fmtAmount(_calcShareModeAmount(item, _purchaseShares));
    if (_amountController.text.trim() != text) {
      _amountController.text = text;
    }
  }

  int _resolveShareMax(InvestProductItem item) {
    int maxByRemain = item.remainingShares;
    if (maxByRemain <= 0 && item.totalShares > 0) {
      maxByRemain = item.totalShares - item.soldShares;
    }
    if (maxByRemain < 0) {
      maxByRemain = 0;
    }
    if (maxByRemain <= 0) {
      return 0;
    }
    if (item.maxInvestAmount <= 0 || item.minInvestAmount <= 0) {
      return maxByRemain;
    }
    final int maxByAmount = (item.maxInvestAmount / item.minInvestAmount).floor();
    if (maxByAmount <= 0) {
      return maxByRemain;
    }
    return maxByRemain < maxByAmount ? maxByRemain : maxByAmount;
  }

  double _calcShareModeAmount(InvestProductItem item, int shares) {
    if (item.minInvestAmount <= 0 || shares <= 0) {
      return 0;
    }
    return item.minInvestAmount * shares;
  }

  String _fmtAmount(double value) {
    if (value % 1 == 0) {
      return value.toStringAsFixed(0);
    }
    return value.toStringAsFixed(2);
  }

  String? _resolveOrderBlockedReason(InvestProductItem item) {
    if (!item.canOrder) {
      return item.orderDisabledReason.isEmpty ? '当前产品暂不可下单' : item.orderDisabledReason;
    }
    final DateTime now = DateTime.now();
    final DateTime? startTime = _parseDateTime(item.startTime);
    if (startTime != null && now.isBefore(startTime)) {
      return '产品未开始';
    }
    final DateTime? endTime = _parseDateTime(item.endTime);
    if (endTime != null && now.isAfter(endTime)) {
      return '产品已过有效期';
    }
    if (item.progressPercent >= 100) {
      return '产品进度已100%，暂不可下单';
    }
    if (item.remainingAmount <= 0 && item.remainingShares <= 0) {
      return '该产品已满额，暂不可下单';
    }
    if (item.limitTimes > 0 && item.userInvestCount >= item.limitTimes) {
      return item.limitTimes == 1 ? '该产品不可复购，您已订购过' : '该产品最多可认购${item.limitTimes}次，已达上限';
    }
    return null;
  }

  DateTime? _parseDateTime(String text) {
    final String raw = text.trim();
    if (raw.isEmpty) {
      return null;
    }
    final String normalized = raw.contains(' ') ? raw.replaceFirst(' ', 'T') : raw;
    return DateTime.tryParse(normalized);
  }

  Future<String?> _validateWalletBalance(String currency, double amount) async {
    try {
      final List<WithdrawWalletItem> wallets = await WithdrawApi.getWallets();
      final String target = _normalizeWalletCurrency(currency);
      WithdrawWalletItem? wallet;
      for (final WithdrawWalletItem item in wallets) {
        if (_normalizeWalletCurrency(item.currencyType) == target) {
          wallet = item;
          break;
        }
      }
      if (wallet == null) {
        return '${target}钱包不存在';
      }
      if (wallet.availableBalance < amount) {
        return '余额不足，无法成交';
      }
      return null;
    } catch (_) {
      return '暂时无法校验钱包余额，请稍后重试';
    }
  }

  String _normalizeWalletCurrency(String currency) {
    final String c = currency.trim().toUpperCase();
    if (c == 'USDT') {
      return 'USD';
    }
    return c == 'USD' ? 'USD' : 'CNY';
  }
}

class _ContractSignDialog extends StatefulWidget {
  const _ContractSignDialog({
    required this.preview,
    required this.contractStamp1,
    required this.contractStamp2,
  });

  final InvestContractPreview preview;
  final String contractStamp1;
  final String contractStamp2;

  @override
  State<_ContractSignDialog> createState() => _ContractSignDialogState();
}

class _ContractSignDialogState extends State<_ContractSignDialog> {
  bool _agreed = false;
  String _signatureBase64 = '';

  bool get _signed => _signatureBase64.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Container(
          color: Colors.white,
          child: Column(
            children: <Widget>[
              Container(
                height: 74,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                alignment: Alignment.center,
                child: Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    const Text('投资合同条款', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
                    Positioned(
                      right: 0,
                      child: IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close, size: 30),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(18, 14, 18, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      _line('甲方（平台方）', widget.preview.platformName),
                      _line(
                        '乙方（投资方）',
                        widget.preview.realName.trim().isNotEmpty
                            ? widget.preview.realName
                            : widget.preview.investorNo,
                      ),
                      _line('投资金额', '¥${widget.preview.amount.toStringAsFixed(0)}'),
                      _line('投资期限', '${widget.preview.cycleDays}天'),
                      _line('预期收益率', '${widget.preview.rate.toStringAsFixed(3)}%'),
                      const SizedBox(height: 16),
                      const Text('合同条款：', style: TextStyle(fontSize: 22, color: Color(0xFF8A8A8A), fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      Text(
                        widget.preview.contractText,
                        style: const TextStyle(fontSize: 16, color: Color(0xFF8D8D8D), height: 1.8),
                      ),
                      const SizedBox(height: 18),
                      _buildPartySignArea(),
                    ],
                  ),
                ),
              ),
              Container(
                color: const Color(0xFFF7FAFF),
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                child: Column(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Checkbox(
                          value: _agreed,
                          onChanged: (bool? v) => setState(() => _agreed = v ?? false),
                        ),
                        const Text('我已阅读并同意上述合同条款', style: TextStyle(fontSize: 20 / 1.2)),
                      ],
                    ),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: (!_agreed || !_signed) ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0A56D1),
                          disabledBackgroundColor: const Color(0xFF94A5D9),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                        ),
                        child: const Text('提交', style: TextStyle(fontSize: 22 / 1.2, fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPartySignArea() {
    final String? stampUrl = _resolvePrimaryStamp();
    final Uint8List? signBytes = _decodeSignatureBytes(_signatureBase64);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF7FAFF),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFD8E1EF)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text('甲方（平台方）', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                const Text('签章', style: TextStyle(fontSize: 12, color: Color(0xFF7B7B7B))),
                const SizedBox(height: 6),
                SizedBox(
                  height: 86,
                  child: stampUrl == null
                      ? Image.asset(
                          AppImages.investContractStamp,
                          width: 86,
                          height: 86,
                          fit: BoxFit.contain,
                        )
                      : AppNetworkImage(
                          src: stampUrl,
                          width: 86,
                          height: 86,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => Image.asset(
                            AppImages.investContractStamp,
                            width: 86,
                            height: 86,
                            fit: BoxFit.contain,
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF7FAFF),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFD8E1EF)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text('乙方（投资方）', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                const Text('签名', style: TextStyle(fontSize: 12, color: Color(0xFF7B7B7B))),
                const SizedBox(height: 6),
                InkWell(
                  onTap: _openSignaturePage,
                  child: Container(
                    height: 86,
                    width: double.infinity,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFFD8E1EF)),
                    ),
                    child: signBytes == null
                        ? const Text('点击签名', style: TextStyle(color: Color(0xFF6374A8)))
                        : Image.memory(signBytes, fit: BoxFit.contain),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String? _resolvePrimaryStamp() {
    final List<String> remoteStamps = <String>[
      widget.contractStamp1,
      widget.contractStamp2,
    ]
        .map((String e) => ApiClient.instance.resolveImageUrl(e) ?? '')
        .where((String e) => e.isNotEmpty)
        .toList();
    if (remoteStamps.isEmpty) {
      return null;
    }
    return remoteStamps.first;
  }

  Future<void> _openSignaturePage() async {
    final String? result = await SignatureTool.show(context, title: '乙方签名');
    if (!mounted || result == null) {
      return;
    }
    setState(() => _signatureBase64 = result);
  }

  Uint8List? _decodeSignatureBytes(String raw) {
    if (raw.trim().isEmpty) {
      return null;
    }
    try {
      final String payload = raw.contains(',') ? raw.split(',').last : raw;
      return base64Decode(payload);
    } catch (_) {
      return null;
    }
  }

  void _submit() {
    if (_signatureBase64.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('请先完成签名')));
      return;
    }
    Navigator.pop(
      context,
      _SignedContractResult(
        agreed: _agreed,
        signatureBase64: _signatureBase64,
      ),
    );
  }

  Widget _line(String key, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 160,
            child: Text(
              '$key：',
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
            ),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(color: Color(0xFF959595), fontSize: 18)),
          ),
        ],
      ),
    );
  }
}

class _SignedContractResult {
  const _SignedContractResult({
    required this.agreed,
    required this.signatureBase64,
  });

  final bool agreed;
  final String signatureBase64;
}
