import 'package:flutter/material.dart';

class AppCard extends StatelessWidget {
  const AppCard({super.key, required this.child});

  final Widget child;

  @override
  /// 构建通用卡片容器。
  Widget build(BuildContext context) {
    return Card(child: child);
  }
}
