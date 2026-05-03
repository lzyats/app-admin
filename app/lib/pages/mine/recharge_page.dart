import 'package:flutter/material.dart';

import 'package:myapp/config/app_localizations.dart';
import 'package:myapp/request/recharge_api.dart';
import 'package:myapp/tools/app_bootstrap_tool.dart';
import 'package:myapp/widgets/currency_brand_badge.dart';

class RechargePage extends StatefulWidget {
  const RechargePage({super.key});

  @override
  State<RechargePage> createState() => _RechargePageState();
}

class _RechargePageState extends State<RechargePage> {
  static const List<double> _presetAmounts = <double>[400, 600, 800, 1000, 1200, 2000];

  final TextEditingController _amountController = TextEditingController();

  bool _submitting = false;
  int _selectedPresetIndex = -1;
  String _selectedCurrencyType = 'CNY';
  String _selectedRechargeMethod = 'RMB';

  bool get _isDualMode => AppBootstrapTool.config.investCurrencyMode == 2;

  @override
  void initState() {
    super.initState();
    _selectedCurrencyType = 'CNY';
    _selectedRechargeMethod = 'RMB';
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _pickPreset(int index) {
    setState(() {
      _selectedPresetIndex = index;
      _amountController.text = _presetAmounts[index].toStringAsFixed(0);
    });
  }

  void _pickMethod(String currencyType, String rechargeMethod) {
    setState(() {
      _selectedCurrencyType = _isDualMode ? currencyType : 'CNY';
      _selectedRechargeMethod = _isDualMode ? rechargeMethod : 'RMB';
    });
  }

  Future<void> _submit() async {
    final double? amount = _resolveAmount();
    if (amount == null || amount <= 0) {
      _showSnackBar(AppLocalizations.of(context).t('rechargeNeedAmount'), error: true);
      return;
    }
    if (_isDualMode && _selectedRechargeMethod.isEmpty) {
      _showSnackBar(AppLocalizations.of(context).t('rechargeNeedMethod'), error: true);
      return;
    }

    setState(() {
      _submitting = true;
    });
    try {
      await RechargeApi.submitRecharge(
        amount: amount,
        currencyType: _isDualMode ? _selectedCurrencyType : 'CNY',
        rechargeMethod: _isDualMode ? _selectedRechargeMethod : 'RMB',
      );
      if (!mounted) {
        return;
      }
      _showSnackBar(AppLocalizations.of(context).t('rechargeSubmitSuccess'));
      _amountController.clear();
      setState(() {
        _selectedPresetIndex = -1;
        _selectedCurrencyType = 'CNY';
        _selectedRechargeMethod = 'RMB';
      });
    } catch (_) {
      if (mounted) {
        _showSnackBar(AppLocalizations.of(context).t('rechargeSubmitFailed'), error: true);
      }
    } finally {
      if (mounted) {
        setState(() {
          _submitting = false;
        });
      }
    }
  }

  void _showSnackBar(String text, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        backgroundColor: error ? const Color(0xFFFF6B6B) : const Color(0xFF38FFB3),
      ),
    );
  }

  String _currencyLabel(String currencyType) {
    return currencyType.toUpperCase() == 'USD'
        ? 'USDT'
        : AppLocalizations.of(context).t('assetsRmb');
  }

  double? _resolveAmount() {
    if (_selectedPresetIndex >= 0 && _selectedPresetIndex < _presetAmounts.length) {
      final double presetAmount = _presetAmounts[_selectedPresetIndex];
      if (presetAmount > 0) {
        return presetAmount;
      }
    }

    final String raw = _amountController.text.trim();
    if (raw.isEmpty) {
      return null;
    }
    final String normalized = raw.replaceAll(',', '').replaceAll('，', '');
    final double? parsed = double.tryParse(normalized);
    if (parsed == null) {
      return null;
    }
    return parsed;
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations i18n = AppLocalizations.of(context);
    final List<_RechargeMethodOption> methods = _isDualMode
        ? <_RechargeMethodOption>[
            _RechargeMethodOption(
              currencyType: 'CNY',
              rechargeMethod: 'RMB',
              title: i18n.t('rechargeMethodRmb'),
              color: const Color(0xFF39E6FF),
            ),
            _RechargeMethodOption(
              currencyType: 'USD',
              rechargeMethod: 'USDT',
              title: i18n.t('rechargeMethodUsd'),
              color: const Color(0xFFFFA500),
            ),
          ]
        : <_RechargeMethodOption>[
            _RechargeMethodOption(
              currencyType: 'CNY',
              rechargeMethod: 'RMB',
              title: i18n.t('rechargeMethodRmb'),
              color: const Color(0xFF39E6FF),
            ),
          ];

    return Scaffold(
      backgroundColor: const Color(0xFF07111F),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(i18n.t('mineRecharge')),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Stack(
        children: <Widget>[
          const Positioned(
            top: -80,
            right: -70,
            child: _GlowBlob(
              size: 210,
              colors: <Color>[Color(0x2239E6FF), Color(0x00000000)],
            ),
          ),
          const Positioned(
            top: 140,
            left: -90,
            child: _GlowBlob(
              size: 180,
              colors: <Color>[Color(0x1A38FFB3), Color(0x00000000)],
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _buildHeroCard(i18n),
                  const SizedBox(height: 18),
                  Text(
                    i18n.t('rechargeAmountTitle'),
                    style: const TextStyle(
                      color: Color(0xFFEAF5FF),
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 1.58,
                    ),
                    itemCount: _presetAmounts.length,
                    itemBuilder: (BuildContext context, int index) {
                      final bool selected = _selectedPresetIndex == index;
                      final double amount = _presetAmounts[index];
                      return GestureDetector(
                        onTap: () => _pickPreset(index),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          decoration: BoxDecoration(
                            gradient: selected
                                ? const LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: <Color>[Color(0xFF1E3758), Color(0xFF12253E)],
                                  )
                                : const LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: <Color>[Color(0xFF101C30), Color(0xFF0D1728)],
                                  ),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: selected ? const Color(0xFF39E6FF) : const Color(0x334CE3FF),
                              width: selected ? 1.5 : 1,
                            ),
                            boxShadow: <BoxShadow>[
                              BoxShadow(
                                color: Colors.black.withOpacity(selected ? 0.18 : 0.12),
                                blurRadius: selected ? 18 : 12,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Stack(
                            children: <Widget>[
                              Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Text(
                                      amount.toStringAsFixed(0),
                                      style: TextStyle(
                                        color: selected ? const Color(0xFF39E6FF) : const Color(0xFFEAF5FF),
                                        fontSize: 23,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _currencyLabel(_selectedCurrencyType),
                                      style: const TextStyle(
                                        color: Color(0xFF9DB1C9),
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (selected)
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: Container(
                                    width: 22,
                                    height: 22,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF39E6FF),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.check,
                                      size: 14,
                                      color: Color(0xFF0A1220),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildAmountCard(i18n),
                  const SizedBox(height: 18),
                  Text(
                    i18n.t('rechargeMethodTitle'),
                    style: const TextStyle(
                      color: Color(0xFFEAF5FF),
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Column(
                    children: methods.map((_RechargeMethodOption option) {
                      final bool selected = _selectedCurrencyType == option.currencyType &&
                          _selectedRechargeMethod == option.rechargeMethod;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: GestureDetector(
                          onTap: () => _pickMethod(option.currencyType, option.rechargeMethod),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: selected
                                  ? const LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: <Color>[Color(0xFF1D3558), Color(0xFF13253D)],
                                    )
                                  : const LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: <Color>[Color(0xFF101C30), Color(0xFF0D1728)],
                                    ),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: selected ? const Color(0xFF39E6FF) : const Color(0x334CE3FF),
                                width: selected ? 1.5 : 1,
                              ),
                              boxShadow: <BoxShadow>[
                                BoxShadow(
                                  color: Colors.black.withOpacity(selected ? 0.18 : 0.12),
                                  blurRadius: selected ? 18 : 12,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Row(
                              children: <Widget>[
                                CurrencyBrandBadge(
                                  currencyType: option.currencyType,
                                  size: 54,
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        option.title,
                                        style: TextStyle(
                                          color: selected ? const Color(0xFF39E6FF) : const Color(0xFFEAF5FF),
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        _currencyLabel(option.currencyType),
                                        style: const TextStyle(
                                          color: Color(0xFF9DB1C9),
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  selected ? Icons.check_circle : Icons.radio_button_unchecked,
                                  color: selected ? const Color(0xFF39E6FF) : const Color(0xFF9DB1C9),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: double.infinity,
                    height: 54,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: <Color>[Color(0xFF39E6FF), Color(0xFF38FFB3)],
                      ),
                      borderRadius: BorderRadius.circular(27),
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                          color: const Color(0xFF39E6FF).withOpacity(0.22),
                          blurRadius: 18,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: _submitting ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor: const Color(0xFF0A1220),
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(27),
                        ),
                      ),
                      child: _submitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Color(0xFF0A1220),
                              ),
                            )
                          : Text(
                              i18n.t('rechargeSubmit'),
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
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

  Widget _buildHeroCard(AppLocalizations i18n) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[Color(0xFF18253B), Color(0xFF0E1728)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0x334CE3FF)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withOpacity(0.22),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: <Widget>[
          Positioned(
            right: -12,
            top: -8,
            child: Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0x2239E6FF),
                border: Border.all(color: const Color(0x2239E6FF)),
              ),
            ),
          ),
          Positioned(
            right: 18,
            top: 18,
            child: Icon(
              Icons.account_balance_wallet_outlined,
              size: 56,
              color: const Color(0xFF39E6FF).withOpacity(0.12),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: <Widget>[
                  _buildHeroChip(
                    icon: Icons.payments_outlined,
                    text: i18n.t('rechargeAmountTitle'),
                    color: const Color(0xFF39E6FF),
                  ),
                  _buildHeroChip(
                    icon: Icons.account_balance_wallet_outlined,
                    text: i18n.t('rechargeMethodTitle'),
                    color: const Color(0xFF38FFB3),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                i18n.t('mineRecharge'),
                style: const TextStyle(
                  color: Color(0xFFEAF5FF),
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  height: 1.05,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                i18n.t('rechargeCustomAmount'),
                style: const TextStyle(
                  color: Color(0xFF9DB1C9),
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAmountCard(AppLocalizations i18n) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[Color(0xFF111D31), Color(0xFF0E1726)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0x334CE3FF)),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0x2239E6FF),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.edit_note, color: Color(0xFF39E6FF)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  i18n.t('rechargeCustomAmount'),
                  style: const TextStyle(
                    color: Color(0xFFEAF5FF),
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  i18n.t('rechargeAmountPlaceholder'),
                  style: const TextStyle(
                    color: Color(0xFF9DB1C9),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 132,
            child: TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              textAlign: TextAlign.right,
              style: const TextStyle(color: Color(0xFFEAF5FF), fontSize: 16),
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
                hintText: '0.00',
              ),
              onChanged: (_) {
                if (_selectedPresetIndex != -1) {
                  setState(() {
                    _selectedPresetIndex = -1;
                  });
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroChip({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.24)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _RechargeMethodOption {
  _RechargeMethodOption({
    required this.currencyType,
    required this.rechargeMethod,
    required this.title,
    required this.color,
  });

  final String currencyType;
  final String rechargeMethod;
  final String title;
  final Color color;
}

class _GlowBlob extends StatelessWidget {
  const _GlowBlob({
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
