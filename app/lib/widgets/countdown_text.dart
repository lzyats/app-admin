import 'dart:async';

import 'package:flutter/material.dart';

class CountdownText extends StatefulWidget {
  const CountdownText({
    super.key,
    required this.initialSeconds,
    this.prefix = '',
    this.textStyle,
    this.onFinished,
    this.finishedText = '00:00:00',
  });

  final int initialSeconds;
  final String prefix;
  final TextStyle? textStyle;
  final VoidCallback? onFinished;
  final String finishedText;

  @override
  State<CountdownText> createState() => _CountdownTextState();
}

class _CountdownTextState extends State<CountdownText> {
  Timer? _timer;
  late int _remainSeconds;

  @override
  void initState() {
    super.initState();
    _remainSeconds = widget.initialSeconds < 0 ? 0 : widget.initialSeconds;
    _start();
  }

  @override
  void didUpdateWidget(covariant CountdownText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialSeconds != widget.initialSeconds) {
      _remainSeconds = widget.initialSeconds < 0 ? 0 : widget.initialSeconds;
      _start();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _start() {
    _timer?.cancel();
    if (_remainSeconds <= 0) {
      widget.onFinished?.call();
      return;
    }
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_remainSeconds <= 1) {
        timer.cancel();
        setState(() {
          _remainSeconds = 0;
        });
        widget.onFinished?.call();
        return;
      }
      setState(() {
        _remainSeconds -= 1;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final String value = _remainSeconds <= 0 ? widget.finishedText : _formatHms(_remainSeconds);
    return Text(
      '${widget.prefix}$value',
      style: widget.textStyle,
    );
  }

  String _formatHms(int seconds) {
    int remain = seconds;
    final int hour = remain ~/ 3600;
    remain = remain % 3600;
    final int minute = remain ~/ 60;
    final int second = remain % 60;
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}:${second.toString().padLeft(2, '0')}';
  }
}
