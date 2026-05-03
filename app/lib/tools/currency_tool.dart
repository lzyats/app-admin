import 'dart:math';

/// 货币工具类
class CurrencyTool {
  /// 币种列表
  static const List<CurrencyInfo> currencies = [
    CurrencyInfo(code: 'CNY', name: '人民币', symbol: '¥'),
    CurrencyInfo(code: 'USD', name: '美元', symbol: ''),
  ];

  /// 根据币种代码获取币种信息
  static CurrencyInfo? getCurrencyByCode(String code) {
    return currencies.firstWhere((c) => c.code == code, orElse: () => currencies[0]);
  }

  /// 币种信息
  static CurrencyInfo getCurrency(String code) {
    return getCurrencyByCode(code) ?? currencies[0];
  }

  /// 汇率映射（CNY为基准）
  static Map<String, double> getExchangeRates(double usdRate) {
    return {
      'CNY': 1.0,
      'USD': usdRate,
    };
  }

  /// 货币转换
  /// [amount] 金额
  /// [fromCurrency] 源币种
  /// [toCurrency] 目标币种
  /// [usdRate] 美元汇率
  static double convert(double amount, String fromCurrency, String toCurrency, double usdRate) {
    if (fromCurrency == toCurrency) return roundMoney(amount);
    
    final rates = getExchangeRates(usdRate);
    // 先转换为CNY
    double amountInCNY = amount;
    if (fromCurrency != 'CNY') {
      amountInCNY = amount * rates[fromCurrency]!;
    }
    // 再转换为目标币种
    if (toCurrency != 'CNY') {
      return roundMoney(amountInCNY / rates[toCurrency]!);
    }
    return roundMoney(amountInCNY);
  }

  /// 将金额统一到小数点后两位
  static double roundMoney(double value) {
    return double.parse(value.toStringAsFixed(2));
  }

  /// 格式化货币显示
  static String format(double amount, String currency, {int decimals = 2}) {
    final currencyInfo = getCurrency(currency);
    final formattedAmount = amount.toStringAsFixed(decimals);
    return '${currencyInfo.symbol}$formattedAmount';
  }

  /// 解析货币字符串
  static double parse(String value, String currency) {
    // 移除货币符号
    final currencyInfo = getCurrency(currency);
    String cleanValue = value.replaceAll(currencyInfo.symbol, '').replaceAll(',', '');
    return double.tryParse(cleanValue) ?? 0.0;
  }
}

/// 币种信息
class CurrencyInfo {
  final String code; // 币种代码
  final String name; // 币种名称
  final String symbol; // 货币符号

  const CurrencyInfo({
    required this.code,
    required this.name,
    required this.symbol,
  });
}
