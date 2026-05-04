import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class SignatureTool {
  SignatureTool._();

  static Future<String?> show(
    BuildContext context, {
    String title = '签名',
  }) {
    return Navigator.of(context).push<String>(
      MaterialPageRoute<String>(
        builder: (_) => _SignaturePadPage(title: title),
      ),
    );
  }
}

class _SignaturePadPage extends StatefulWidget {
  const _SignaturePadPage({
    required this.title,
  });

  final String title;

  @override
  State<_SignaturePadPage> createState() => _SignaturePadPageState();
}

class _SignaturePadPageState extends State<_SignaturePadPage> {
  final List<Offset?> _points = <Offset?>[];
  final GlobalKey _signKey = GlobalKey();
  bool _drawing = false;

  bool get _signed => _points.any((Offset? e) => e != null);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: <Widget>[
            Expanded(
              child: RepaintBoundary(
                key: _signKey,
                child: Listener(
                  behavior: HitTestBehavior.opaque,
                  onPointerDown: _handlePointerDown,
                  onPointerMove: _handlePointerMove,
                  onPointerUp: _handlePointerUp,
                  onPointerCancel: _handlePointerCancel,
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7FAFF),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFD8E1EF)),
                    ),
                    child: CustomPaint(
                      painter: _SignaturePainter(_points),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: <Widget>[
                TextButton(
                  onPressed: () => setState(() => _points.clear()),
                  child: const Text('清空'),
                ),
                const Spacer(),
                SizedBox(
                  width: 120,
                  child: ElevatedButton(
                    onPressed: _signed ? _confirm : null,
                    child: const Text('确认提交'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirm() async {
    try {
      final RenderRepaintBoundary? boundary = _signKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return;
      final ui.Image image = await boundary.toImage(pixelRatio: 2.0);
      final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;
      final Uint8List bytes = byteData.buffer.asUint8List();
      if (!mounted) return;
      Navigator.pop(context, 'data:image/png;base64,${base64Encode(bytes)}');
    } catch (_) {}
  }

  void _handlePointerDown(PointerDownEvent event) {
    final RenderBox? box = _signKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return;
    final Offset local = box.globalToLocal(event.position);
    setState(() {
      _drawing = true;
      _points.add(local);
    });
  }

  void _handlePointerMove(PointerMoveEvent event) {
    if (!_drawing) return;
    final RenderBox? box = _signKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return;
    final Offset local = box.globalToLocal(event.position);
    setState(() => _points.add(local));
  }

  void _handlePointerUp(PointerUpEvent event) {
    if (!_drawing) return;
    setState(() {
      _drawing = false;
      _points.add(null);
    });
  }

  void _handlePointerCancel(PointerCancelEvent event) {
    if (!_drawing) return;
    setState(() {
      _drawing = false;
      _points.add(null);
    });
  }
}

class _SignaturePainter extends CustomPainter {
  const _SignaturePainter(this.points);

  final List<Offset?> points;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = const Color(0xFF1E3D86)
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 2.8
      ..style = PaintingStyle.stroke;
    for (int i = 0; i < points.length - 1; i++) {
      final Offset? p1 = points[i];
      final Offset? p2 = points[i + 1];
      if (p1 != null && p2 != null) {
        canvas.drawLine(p1, p2, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _SignaturePainter oldDelegate) => oldDelegate.points != points;
}
