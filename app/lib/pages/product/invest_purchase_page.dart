import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:myapp/config/app_images.dart';
import 'package:myapp/config/app_localizations.dart';
import 'package:myapp/request/auth_api.dart';
import 'package:myapp/request/api_client.dart';
import 'package:myapp/request/app_config_api.dart';
import 'package:myapp/request/card_package_api.dart';
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
  final TextEditingController _joinGroupNoController = TextEditingController();
  int _purchaseShares = 1;
  CardPackageItem? _selectedCoupon;
  bool _submitting = false;
  AppLocalizations get i18n => AppLocalizations.of(context)!;

  @override
  void initState() {
    super.initState();
    _future = InvestProductApi.fetchProductDetail(widget.productId);
  }

  @override
  void dispose() {
    _amountController.dispose();
    _payPwdController.dispose();
    _joinGroupNoController.dispose();
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
        title: Text(widget.groupMode ? i18n.t('purchaseGroupTitle') : i18n.t('purchaseTitle')),
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
                child: Text(i18n.t('signRetry')),
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
                const SizedBox(height: 10),
                _buildInputCard(
                  i18n.t('purchaseJoinGroupNo'),
                  i18n.t('purchaseJoinGroupHint'),
                  _joinGroupNoController,
                  false,
                ),
              ],
              const SizedBox(height: 10),
              _buildInputCard(
                i18n.t('purchaseAmount'),
                item.investMode == 'AMOUNT' ? i18n.t('purchaseAmountHint') : i18n.t('purchaseAmountAutoHint'),
                _amountController,
                false,
                readOnly: item.investMode != 'AMOUNT',
                onChanged: item.investMode == 'AMOUNT' ? (String value) => _handleAmountChanged(item, value) : null,
              ),
              if (item.investMode != 'AMOUNT') ...<Widget>[
                const SizedBox(height: 10),
                _buildSharesCard(item),
              ],
              const SizedBox(height: 10),
              _buildCouponCard(item),
              const SizedBox(height: 10),
              _buildPaymentSummary(item),
              const SizedBox(height: 10),
              _buildInputCard(i18n.t('payPassword'), i18n.t('payPasswordRequired'), _payPwdController, true),
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
            text: TextSpan(
              children: <InlineSpan>[
                TextSpan(text: i18n.t('purchaseNeedMembersPrefix'), style: const TextStyle(color: Colors.white, fontSize: 21, fontWeight: FontWeight.w700)),
                const TextSpan(text: '2', style: TextStyle(color: Color(0xFFFF5B4A), fontSize: 21, fontWeight: FontWeight.w700)),
                TextSpan(text: i18n.t('purchaseNeedMembersSuffix'), style: const TextStyle(color: Colors.white, fontSize: 21, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(i18n.t('purchaseGroupCountdownHint'), style: const TextStyle(color: Color(0xFF8592BF), fontSize: 20 / 1.2)),
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
          Text('✓ ${i18n.t('purchaseGroupBenefit1')}', style: const TextStyle(color: Color(0xFF7E8DBB), fontSize: 15)),
          const SizedBox(height: 4),
          Text('✓ ${i18n.t('purchaseGroupBenefit2')}', style: const TextStyle(color: Color(0xFF7E8DBB), fontSize: 15)),
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
    ValueChanged<String>? onChanged,
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
              onChanged: onChanged,
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
          SizedBox(
            width: 110,
            child: Text(i18n.t('purchaseShares'), style: const TextStyle(color: Colors.white, fontSize: 35 / 2, fontWeight: FontWeight.w600)),
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

  Widget _buildCouponCard(InvestProductItem item) {
    final double amount = _currentOrderAmount(item);
    final CardPackageItem? coupon = _selectedCoupon;
    final bool couponEnabled = item.couponEnabled;
    final bool couponValid = coupon == null ? false : _isCouponSelectable(coupon, item, amount);
    final bool hasSelection = coupon != null;
    final double discount = couponValid ? _couponDiscountAmount(coupon!, amount) : 0;
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF111747),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  '优惠券核销',
                  style: const TextStyle(color: Colors.white, fontSize: 35 / 2, fontWeight: FontWeight.w600),
                ),
              ),
              if (couponEnabled)
                TextButton(
                  onPressed: () => _openCouponPicker(item),
                  child: Text(
                    hasSelection ? '重新选择' : '选择优惠券',
                    style: const TextStyle(color: Color(0xFF39E6FF), fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ),
              if (!couponEnabled)
                const Text(
                  '当前产品不支持优惠券',
                  style: TextStyle(color: Color(0xFF7B88B6), fontSize: 12),
                ),
            ],
          ),
          const SizedBox(height: 8),
          if (!hasSelection)
            const Text(
              '未选择优惠券',
              style: TextStyle(color: Color(0xFF8A97C4), fontSize: 13),
            )
          else ...<Widget>[
            Text(
              '${_couponDisplayName(coupon!)} · ${_couponTypeLabel(coupon.cardType)}',
              style: const TextStyle(color: Color(0xFFE5EEFF), fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              '满${_fmt(_couponMinAmount(coupon))}减${_fmt(_couponDiscountAmount(coupon, amount))}',
              style: TextStyle(
                color: couponValid ? const Color(0xFF8A97C4) : const Color(0xFFFF8A80),
                fontSize: 12,
              ),
            ),
            if (!couponValid) ...<Widget>[
              const SizedBox(height: 4),
              const Text(
                '当前优惠券不满足使用条件',
                style: TextStyle(color: Color(0xFFFF8A80), fontSize: 12),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildPaymentSummary(InvestProductItem item) {
    final double amount = _currentOrderAmount(item);
    final CardPackageItem? coupon = _selectedCoupon;
    final bool couponValid = coupon != null && _isCouponSelectable(coupon, item, amount);
    final double discount = couponValid ? _couponDiscountAmount(coupon!, amount) : 0;
    final double payAmount = (amount - discount).clamp(0, double.infinity);
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0E143C),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF24356C)),
      ),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            '支付预览',
            style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          _summaryRow('投资本金', _fmt(amount)),
          _summaryRow('优惠抵扣', '-${_fmt(discount)}', valueColor: const Color(0xFFFF8A80)),
          _summaryRow('实际支付', _fmt(payAmount), valueColor: const Color(0xFF38FFB3), bold: true),
        ],
      ),
    );
  }

  Widget _summaryRow(String title, String value, {Color valueColor = const Color(0xFFDFE8FF), bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              title,
              style: const TextStyle(color: Color(0xFF8A97C4), fontSize: 13),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontSize: 14,
              fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTips(InvestProductItem item) {
    return Text(
      i18n
          .t('purchaseTipRange')
          .replaceAll('{min}', _fmt(item.minInvestAmount))
          .replaceAll('{max}', _fmt(item.maxInvestAmount))
          .replaceAll('{times}', '${item.limitTimes <= 0 ? 1 : item.limitTimes}'),
      textAlign: TextAlign.center,
      style: const TextStyle(color: Color(0xFF7B88B6), fontSize: 32 / 2),
    );
  }

  Future<void> _openCouponPicker(InvestProductItem item) async {
    if (!item.couponEnabled) {
      _toast('当前产品暂不支持优惠券');
      return;
    }
    final double amount = _currentOrderAmount(item);
    List<CardPackageItem> coupons;
    try {
      coupons = await CardPackageApi.fetchCoupons();
    } catch (_) {
      _toast('优惠券加载失败，请稍后重试');
      return;
    }
    final List<CardPackageItem> usableCoupons = coupons.where((CardPackageItem coupon) => _isCouponSelectable(coupon, item, amount)).toList();
    if (!mounted) {
      return;
    }
    final CardPackageItem? selected = await showModalBottomSheet<CardPackageItem?>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF0B1033),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (BuildContext dialogContext) {
        CardPackageItem? tempSelected = _selectedCoupon;
        return StatefulBuilder(
          builder: (BuildContext context, void Function(VoidCallback) setSheetState) {
            return SafeArea(
              child: Padding(
                padding: EdgeInsets.only(
                  left: 14,
                  right: 14,
                  top: 12,
                  bottom: 12 + MediaQuery.of(context).viewInsets.bottom,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        const Expanded(
                          child: Text(
                            '选择优惠券',
                            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(dialogContext),
                          icon: const Icon(Icons.close, color: Colors.white),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    if (usableCoupons.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Text(
                          '没有可用于本次购买的优惠券',
                          style: TextStyle(color: Color(0xFF8A97C4), fontSize: 14),
                        ),
                      )
                    else
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 420),
                        child: ListView.separated(
                          shrinkWrap: true,
                          itemCount: usableCoupons.length + 1,
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (BuildContext context, int index) {
                            if (index == 0) {
                              final bool noneSelected = tempSelected == null;
                              return _couponSelectTile(
                                title: '不使用优惠券',
                                subtitle: '保持原价支付',
                                selected: noneSelected,
                                onTap: () {
                                  setSheetState(() => tempSelected = null);
                                },
                              );
                            }
                            final CardPackageItem coupon = usableCoupons[index - 1];
                            final bool selected = tempSelected?.userCouponId == coupon.userCouponId;
                            return _couponSelectTile(
                              title: '${_couponDisplayName(coupon)} · ${_couponTypeLabel(coupon.cardType)}',
                              subtitle: '满${_fmt(_couponMinAmount(coupon))}减${_fmt(_couponDiscountAmount(coupon, amount))}',
                              selected: selected,
                              onTap: () {
                                setSheetState(() => tempSelected = coupon);
                              },
                            );
                          },
                        ),
                      ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(dialogContext, tempSelected),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1B3CF4),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                        ),
                        child: const Text(
                          '确定',
                          style: TextStyle(color: Color(0xFF35DAFF), fontSize: 16, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
    if (!mounted) {
      return;
    }
    setState(() {
      _selectedCoupon = selected;
    });
  }

  Widget _couponSelectTile({
    required String title,
    required String subtitle,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF19225A) : const Color(0xFF111747),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? const Color(0xFF39E6FF) : const Color(0xFF24356C)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                ),
                if (selected)
                  const Icon(Icons.check_circle, color: Color(0xFF39E6FF), size: 20),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: const TextStyle(color: Color(0xFF8A97C4), fontSize: 12, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }

  double _currentOrderAmount(InvestProductItem item) {
    final bool shareMode = item.investMode != 'AMOUNT';
    if (shareMode) {
      return _calcShareModeAmount(item, _purchaseShares);
    }
    return double.tryParse(_amountController.text.trim()) ?? 0;
  }

  void _handleAmountChanged(InvestProductItem item, String value) {
    if (_selectedCoupon == null) {
      return;
    }
    final double amount = _currentOrderAmount(item);
    if (!_isCouponSelectable(_selectedCoupon!, item, amount)) {
      setState(() {
        _selectedCoupon = null;
      });
    }
  }

  bool _isCouponSelectable(CardPackageItem coupon, InvestProductItem item, double amount) {
    if (!item.couponEnabled) {
      return false;
    }
    if (coupon.userStatus.trim() != '0') {
      return false;
    }
    final String type = coupon.cardType.trim().toUpperCase();
    if (type != 'CASH' && type != 'FULL_REDUCTION') {
      return false;
    }
    final DateTime now = DateTime.now();
    if (coupon.startTime != null && now.isBefore(coupon.startTime!)) {
      return false;
    }
    if (coupon.endTime != null && !now.isBefore(coupon.endTime!)) {
      return false;
    }
    if (!_couponMatchesProduct(coupon, item.productId)) {
      return false;
    }
    final double minAmount = _couponMinAmount(coupon);
    if (minAmount > 0 && amount < minAmount) {
      return false;
    }
    final double discount = _couponDiscountAmount(coupon, amount);
    return discount > 0 && amount >= discount;
  }

  bool _couponMatchesProduct(CardPackageItem coupon, int productId) {
    final String scope = (coupon.scopeType ?? '').trim().toUpperCase();
    if (scope.isEmpty || scope == 'GLOBAL') {
      return true;
    }
    final String raw = (coupon.productIdsJson ?? '').trim();
    if (raw.isEmpty) {
      return false;
    }
    try {
      final dynamic data = jsonDecode(raw);
      if (data is List) {
        for (final dynamic item in data) {
          if ('${item ?? ''}'.trim() == '$productId') {
            return true;
          }
        }
      }
    } catch (_) {
      return false;
    }
    return false;
  }

  double _couponMinAmount(CardPackageItem coupon) {
    return coupon.minAmount ?? 0;
  }

  double _couponDiscountAmount(CardPackageItem coupon, double amount) {
    final double discount = coupon.discountAmount ?? 0;
    if (discount <= 0 || amount <= 0) {
      return 0;
    }
    return discount > amount ? amount : discount;
  }

  String _couponDisplayName(CardPackageItem coupon) {
    final String name = coupon.cardName.trim();
    if (name.isNotEmpty) {
      return name;
    }
    return _couponTypeLabel(coupon.cardType);
  }

  String _couponTypeLabel(String type) {
    final String normalized = type.trim().toUpperCase();
    if (normalized == 'CASH') {
      return i18n.t('cardPackageTypeCash');
    }
    if (normalized == 'FULL_REDUCTION') {
      return i18n.t('cardPackageTypeReduction');
    }
    if (normalized == 'RATE_BOOST') {
      return i18n.t('cardPackageTypeRateBoost');
    }
    if (normalized == 'EXPERIENCE') {
      return i18n.t('cardPackageTypeExperience');
    }
    return i18n.t('cardPackageTypeUnknown');
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
            : Text(i18n.t('submit'), style: const TextStyle(color: Color(0xFF35DAFF), fontSize: 20, fontWeight: FontWeight.w700)),
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
      _toast(i18n.t('purchaseSelectShares'));
      return;
    }
    if (amount <= 0) {
      _toast(shareMode ? i18n.t('purchaseConfigUnitAmount') : i18n.t('purchaseInputValidAmount'));
      return;
    }
    final CardPackageItem? coupon = _selectedCoupon;
    if (coupon != null && !_isCouponSelectable(coupon, item, amount)) {
      _toast('当前优惠券不满足使用条件');
      return;
    }
    final double couponDiscount = coupon != null && _isCouponSelectable(coupon, item, amount)
        ? _couponDiscountAmount(coupon, amount)
        : 0;
    final double payAmount = (amount - couponDiscount).clamp(0, double.infinity);
    final String? walletError = await _validateWalletBalance(item.currency, payAmount);
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
      _toast(i18n.t('purchaseSignedSkip'));
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
      _toast(i18n.t('payPasswordRequired'));
      return;
    }

    setState(() => _submitting = true);
    try {
      final String reqNo = _buildClientReqNo(item.productId, amount);
      final String joinGroupNo = _joinGroupNoController.text.trim();
      final bool submitGroupMode = widget.groupMode || joinGroupNo.isNotEmpty;
      await InvestOrderApi.submit(
        productId: item.productId,
        amount: amount,
        purchaseShares: shareMode ? _purchaseShares : 0,
        payPwd: payPwd,
        agreed: result.agreed,
        signatureData: result.signatureBase64,
        contractText: preview.contractText,
        clientReqNo: reqNo,
        groupMode: submitGroupMode,
        userCouponId: coupon != null && _isCouponSelectable(coupon, item, amount) ? coupon.userCouponId : null,
        joinGroupNo: joinGroupNo,
      );
      if (!mounted) return;
      _toast(i18n.t('purchaseSubmitSuccess'), success: true);
      Navigator.pop(context);
    } catch (e) {
      _toast(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  void _toast(String msg, {bool success = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: success ? const Color(0xFF38FFB3) : const Color(0xFFFFA500),
      ),
    );
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
      title: i18n.t('payPasswordRequired'),
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
      if (!mounted) {
        return false;
      }
      final Object? result = await Navigator.pushNamed(
        context,
        AppRouter.payPasswordSet,
        arguments: <String, dynamic>{'userId': profile.userId},
      );
      if (result == true) {
        final AuthUserProfile latest = await AuthApi.getInfo();
        return latest.payPasswordSet == 1;
      }
      _toast(i18n.t('purchaseNeedSetPayPassword'));
      return false;
    } catch (_) {
      _toast(i18n.t('purchasePayPasswordCheckFailed'));
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
      _toast(i18n.t('purchaseSharesExceeded'));
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
      return item.orderDisabledReason.isEmpty ? i18n.t('productOrderDisabled') : item.orderDisabledReason;
    }
    final DateTime now = DateTime.now();
    final DateTime? startTime = _parseDateTime(item.startTime);
    if (startTime != null && now.isBefore(startTime)) {
      return i18n.t('productNotStarted');
    }
    final DateTime? endTime = _parseDateTime(item.endTime);
    if (endTime != null && now.isAfter(endTime)) {
      return i18n.t('productExpired');
    }
    if (item.progressPercent >= 100) {
      return i18n.t('productProgressFull');
    }
    if (item.remainingAmount <= 0 && item.remainingShares <= 0) {
      return i18n.t('productSoldOut');
    }
    if (item.limitTimes > 0 && item.userInvestCount >= item.limitTimes) {
      return item.limitTimes == 1
          ? i18n.t('productNoRepurchase')
          : i18n.t('productLimitReached').replaceAll('{times}', '${item.limitTimes}');
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
        return i18n.t('purchaseWalletMissing').replaceAll('{currency}', target);
      }
      if (wallet.availableBalance < amount) {
        return i18n.t('purchaseBalanceNotEnough');
      }
      return null;
    } catch (_) {
      return i18n.t('purchaseBalanceCheckFailed');
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
  AppLocalizations get i18n => AppLocalizations.of(context)!;

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
                    Text(i18n.t('purchaseContractTitle'), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
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
                      _line(i18n.t('purchasePartyA'), widget.preview.platformName),
                      _line(
                        i18n.t('purchasePartyB'),
                        widget.preview.realName.trim().isNotEmpty
                            ? widget.preview.realName
                            : widget.preview.investorNo,
                      ),
                      _line(i18n.t('purchaseInvestAmount'), '¥${widget.preview.amount.toStringAsFixed(0)}'),
                      _line(i18n.t('purchaseInvestPeriod'), '${widget.preview.cycleDays}${i18n.t('signDayUnit')}'),
                      _line(i18n.t('purchaseExpectedRate'), '${widget.preview.rate.toStringAsFixed(3)}%'),
                      const SizedBox(height: 16),
                      Text(i18n.t('purchaseContractTerms'), style: const TextStyle(fontSize: 22, color: Color(0xFF8A8A8A), fontWeight: FontWeight.w600)),
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
                        Text(i18n.t('purchaseAgreeTerms'), style: const TextStyle(fontSize: 20 / 1.2)),
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
                        child: Text(i18n.t('submit'), style: const TextStyle(fontSize: 22 / 1.2, fontWeight: FontWeight.w700)),
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
                Text(i18n.t('purchasePartyA'), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                Text(i18n.t('purchaseStamp'), style: const TextStyle(fontSize: 12, color: Color(0xFF7B7B7B))),
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
                Text(i18n.t('purchasePartyB'), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                Text(i18n.t('purchaseSignature'), style: const TextStyle(fontSize: 12, color: Color(0xFF7B7B7B))),
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
                        ? Text(i18n.t('purchaseTapToSign'), style: const TextStyle(color: Color(0xFF6374A8)))
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
    final String? result = await SignatureTool.show(context, title: i18n.t('purchasePartyBSignTitle'));
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(i18n.t('purchaseNeedSignature')),
          backgroundColor: Color(0xFFFFA500),
        ),
      );
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
