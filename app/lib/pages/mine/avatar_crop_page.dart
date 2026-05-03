import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:myapp/config/app_localizations.dart';

class AvatarCropPage extends StatefulWidget {
  final Uint8List imageBytes;
  final String title;

  const AvatarCropPage({
    super.key,
    required this.imageBytes,
    required this.title,
  });

  @override
  State<AvatarCropPage> createState() => _AvatarCropPageState();
}

class _AvatarCropPageState extends State<AvatarCropPage> {
  final GlobalKey _cropKey = GlobalKey();
  final TransformationController _controller = TransformationController();

  ui.Image? _decodedImage;
  Size? _cropSize;
  double _minScale = 1.0;
  int _quarterTurns = 0;
  bool _isSaving = false;
  bool _fitUpdatePending = false;

  AppLocalizations get i18n => AppLocalizations.of(context)!;

  @override
  void initState() {
    super.initState();
    _decodeImage();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _decodeImage() async {
    try {
      final ui.Image decoded = await _decodeToUiImage(widget.imageBytes);
      if (!mounted) {
        return;
      }
      setState(() {
        _decodedImage = decoded;
      });
      _requestFitUpdate();
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(i18n.t('saveFailed'))),
      );
      Navigator.of(context).pop();
    }
  }

  Future<ui.Image> _decodeToUiImage(Uint8List bytes) {
    return ui.instantiateImageCodec(bytes).then((ui.Codec codec) {
      return codec.getNextFrame().then((ui.FrameInfo frame) => frame.image);
    });
  }

  void _requestFitUpdate() {
    if (_fitUpdatePending) {
      return;
    }
    _fitUpdatePending = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fitUpdatePending = false;
      if (!mounted) {
        return;
      }
      _applyFitTransform();
    });
  }

  void _applyFitTransform() {
    if (_decodedImage == null || _cropSize == null) {
      return;
    }

    final double imageWidth = _quarterTurns.isOdd
        ? _decodedImage!.height.toDouble()
        : _decodedImage!.width.toDouble();
    final double imageHeight = _quarterTurns.isOdd
        ? _decodedImage!.width.toDouble()
        : _decodedImage!.height.toDouble();

    final double scale = math.max(
      _cropSize!.width / imageWidth,
      _cropSize!.height / imageHeight,
    );
    final double translateX = (_cropSize!.width - imageWidth * scale) / 2;
    final double translateY = (_cropSize!.height - imageHeight * scale) / 2;

    setState(() {
      _minScale = scale;
      _controller.value = Matrix4.identity()
        ..translate(translateX, translateY)
        ..scale(scale);
    });
  }

  void _rotate(int turns) {
    setState(() {
      _quarterTurns = (_quarterTurns + turns) % 4;
      if (_quarterTurns < 0) {
        _quarterTurns += 4;
      }
    });
    _requestFitUpdate();
  }

  void _zoom(double factor) {
    final double currentScale = _controller.value.getMaxScaleOnAxis();
    final double targetScale = (currentScale * factor).clamp(_minScale, _minScale * 6.0);
    if (currentScale <= 0 || (targetScale - currentScale).abs() < 0.001) {
      return;
    }
    final double actualFactor = targetScale / currentScale;
    _controller.value = Matrix4.copy(_controller.value)..scale(actualFactor);
  }

  void _resetTransform() {
    _requestFitUpdate();
  }

  Future<void> _confirmCrop() async {
    if (_isSaving) {
      return;
    }
    final RenderObject? renderObject = _cropKey.currentContext?.findRenderObject();
    if (renderObject is! RenderRepaintBoundary) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final double pixelRatio = MediaQuery.of(context).devicePixelRatio;
      final ui.Image image = await renderObject.toImage(pixelRatio: pixelRatio);
      final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        throw Exception('crop failed');
      }
      final Uint8List bytes = byteData.buffer.asUint8List();
      if (!mounted) {
        return;
      }
      Navigator.of(context).pop(bytes);
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(i18n.t('saveFailed'))),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color background = const Color(0xFF0A1220);
    final Color panelColor = const Color(0xFF101C30);

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        elevation: 0,
        centerTitle: true,
        title: Text(
          widget.title,
          style: const TextStyle(
            color: Color(0xFFE9F3FF),
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Color(0xFFE9F3FF)),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final double side = constraints.maxWidth;
                    final Size cropSize = Size(side, side);
                    if (_cropSize != cropSize) {
                      _cropSize = cropSize;
                      _requestFitUpdate();
                    }

                    return Column(
                      children: [
                        const SizedBox(height: 8),
                        Text(
                          'Pinch to zoom and drag to adjust',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.72),
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: side,
                          height: side,
                          child: Stack(
                            children: [
                              RepaintBoundary(
                                key: _cropKey,
                                child: Container(
                                  width: side,
                                  height: side,
                                  color: Colors.black,
                                  child: _decodedImage == null
                                      ? const Center(
                                          child: CircularProgressIndicator(
                                            color: Color(0xFF39E6FF),
                                          ),
                                        )
                                      : ClipRect(
                                          child: InteractiveViewer(
                                            transformationController: _controller,
                                            constrained: false,
                                            boundaryMargin: const EdgeInsets.all(200),
                                            minScale: _minScale,
                                            maxScale: _minScale * 6.0,
                                            panEnabled: true,
                                            scaleEnabled: true,
                                            child: RotatedBox(
                                              quarterTurns: _quarterTurns,
                                              child: SizedBox(
                                                width: _decodedImage!.width.toDouble(),
                                                height: _decodedImage!.height.toDouble(),
                                                child: Image.memory(
                                                  widget.imageBytes,
                                                  fit: BoxFit.fill,
                                                  filterQuality: FilterQuality.high,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                ),
                              ),
                              Positioned.fill(
                                child: IgnorePointer(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: const Color(0x5539E6FF),
                                        width: 1.5,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: panelColor,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0x334CE3FF)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildControlButton(
                                icon: Icons.rotate_left,
                                label: 'Left',
                                onPressed: _decodedImage == null ? null : () => _rotate(-1),
                              ),
                              _buildControlButton(
                                icon: Icons.remove,
                                label: 'Zoom Out',
                                onPressed: _decodedImage == null ? null : () => _zoom(0.9),
                              ),
                              _buildControlButton(
                                icon: Icons.add,
                                label: 'Zoom In',
                                onPressed: _decodedImage == null ? null : () => _zoom(1.1),
                              ),
                              _buildControlButton(
                                icon: Icons.rotate_right,
                                label: 'Right',
                                onPressed: _decodedImage == null ? null : () => _rotate(1),
                              ),
                              _buildControlButton(
                                icon: Icons.refresh,
                                label: 'Reset',
                                onPressed: _decodedImage == null ? null : _resetTransform,
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isSaving || _decodedImage == null ? null : _confirmCrop,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF39E6FF),
                    foregroundColor: const Color(0xFF0A1220),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26),
                    ),
                  ),
                  child: Text(
                    i18n.t('commonConfirm'),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
  }) {
    final bool enabled = onPressed != null;
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
      child: Opacity(
        opacity: enabled ? 1.0 : 0.4,
        child: SizedBox(
          width: 60,
          child: Column(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF16263F),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0x334CE3FF)),
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: const Color(0xFF39E6FF),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF9DB1C9),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
