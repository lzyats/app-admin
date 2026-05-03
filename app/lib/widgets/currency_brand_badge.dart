import 'package:flutter/material.dart';
import 'package:myapp/config/app_images.dart';

class CurrencyBrandBadge extends StatelessWidget {
  const CurrencyBrandBadge({
    super.key,
    required this.currencyType,
    this.size = 52,
    this.usePurpleVariant = false,
  });

  final String currencyType;
  final double size;
  final bool usePurpleVariant;

  bool get _isUsd => currencyType.toUpperCase() == 'USD';

  @override
  Widget build(BuildContext context) {
    final bool isUsd = _isUsd;
    final Color primary = isUsd ? const Color(0xFF2FD28F) : const Color(0xFF2D7BFF);
    final Color secondary = isUsd ? const Color(0xFF0E9F65) : const Color(0xFF184CB8);
    final String imagePath = AppImages.currencyBrand(
      currencyType,
      usePurpleVariant: usePurpleVariant,
    );

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[primary.withOpacity(0.95), secondary.withOpacity(0.95)],
        ),
        borderRadius: BorderRadius.circular(size * 0.28),
        border: Border.all(color: Colors.white.withOpacity(0.18)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: primary.withOpacity(0.22),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: <Widget>[
          Positioned(
            right: -size * 0.18,
            top: -size * 0.18,
            child: Container(
              width: size * 0.68,
              height: size * 0.68,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.08),
              ),
            ),
          ),
          Positioned(
            left: size * 0.10,
            bottom: size * 0.10,
            child: Container(
              width: size * 0.24,
              height: size * 0.06,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.28),
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: EdgeInsets.all(size * 0.16),
              child: Image.asset(
                imagePath,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.high,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
