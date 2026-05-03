import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:myapp/widgets/app_image_cache_io.dart';

class AppNetworkImage extends StatefulWidget {
  const AppNetworkImage({
    super.key,
    required this.src,
    this.width,
    this.height,
    this.fit,
    this.errorBuilder,
    this.color,
    this.opacity,
    this.colorBlendMode,
    this.alignment = Alignment.center,
    this.gaplessPlayback = false,
    this.filterQuality = FilterQuality.medium,
  });

  final String src;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final ImageErrorWidgetBuilder? errorBuilder;
  final Color? color;
  final Animation<double>? opacity;
  final BlendMode? colorBlendMode;
  final AlignmentGeometry alignment;
  final bool gaplessPlayback;
  final FilterQuality filterQuality;

  @override
  State<AppNetworkImage> createState() => _AppNetworkImageState();
}

class _AppNetworkImageState extends State<AppNetworkImage> {
  Future<Uint8List?>? _bytesFuture;

  @override
  void initState() {
    super.initState();
    _loadBytes();
  }

  @override
  void didUpdateWidget(covariant AppNetworkImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.src != widget.src) {
      _loadBytes();
    }
  }

  void _loadBytes() {
    _bytesFuture = AppImageCache.instance.getBytes(widget.src);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.src.trim().isEmpty) {
      return _buildError();
    }

    return FutureBuilder<Uint8List?>(
      future: _bytesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return _buildLoading();
        }
        final Uint8List? bytes = snapshot.data;
        if (bytes == null || bytes.isEmpty) {
          return _buildError();
        }
        return Image.memory(
          bytes,
          width: widget.width,
          height: widget.height,
          fit: widget.fit,
          errorBuilder: widget.errorBuilder,
          color: widget.color,
          opacity: widget.opacity,
          colorBlendMode: widget.colorBlendMode,
          alignment: widget.alignment,
          gaplessPlayback: widget.gaplessPlayback,
          filterQuality: widget.filterQuality,
        );
      },
    );
  }

  Widget _buildLoading() {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: const Center(
        child: SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }

  Widget _buildError() {
    if (widget.errorBuilder != null) {
      return widget.errorBuilder!(
        context,
        Exception('Image load failed'),
        StackTrace.current,
      );
    }
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: const Icon(Icons.broken_image_outlined),
    );
  }
}
