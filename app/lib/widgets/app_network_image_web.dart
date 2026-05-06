import 'package:flutter/material.dart';

class AppNetworkImage extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final String url = src.trim();
    if (url.isEmpty) {
      return _buildFallback();
    }
    return Image.network(
      url,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: errorBuilder ?? (_, __, ___) => _buildFallback(),
      color: color,
      opacity: opacity,
      colorBlendMode: colorBlendMode,
      alignment: alignment,
      gaplessPlayback: gaplessPlayback,
      filterQuality: filterQuality,
      loadingBuilder: (_, child, loadingProgress) {
        if (loadingProgress == null) {
          return child;
        }
        return SizedBox(
          width: width,
          height: height,
          child: const Center(
            child: SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFallback() {
    return SizedBox(
      width: width,
      height: height,
      child: const Icon(Icons.broken_image_outlined),
    );
  }
}
