import 'dart:html' as html;
import 'dart:ui_web' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AppNetworkImage extends StatelessWidget {
  static final Set<String> _registeredViewTypes = <String>{};

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
    final String viewType = 'app-network-image-${src.hashCode}';
    if (!_registeredViewTypes.contains(viewType)) {
      _registeredViewTypes.add(viewType);
      ui.platformViewRegistry.registerViewFactory(
        viewType,
        (int viewId) {
          final html.ImageElement img = html.ImageElement(src: src);
          img.style.width = '100%';
          img.style.height = '100%';
          img.style.objectFit = _objectFit();
          img.style.objectPosition = _objectPosition();
          img.style.display = 'block';
          if (width != null && width!.isFinite) {
            img.width = width!.round();
          }
          if (height != null && height!.isFinite) {
            img.height = height!.round();
          }
          if (color != null) {
            img.style.filter = 'opacity(${(opacity?.value ?? 1.0)})';
          }
          return img;
        },
      );
    }

    return SizedBox(
      width: width,
      height: height,
      child: HtmlElementView(viewType: viewType),
    );
  }

  String _objectFit() {
    switch (fit) {
      case BoxFit.cover:
        return 'cover';
      case BoxFit.fill:
        return 'fill';
      case BoxFit.contain:
        return 'contain';
      case BoxFit.fitWidth:
        return 'contain';
      case BoxFit.fitHeight:
        return 'cover';
      case BoxFit.none:
        return 'none';
      case BoxFit.scaleDown:
        return 'scale-down';
      case null:
        return 'contain';
    }
  }

  String _objectPosition() {
    if (alignment == Alignment.center) {
      return 'center center';
    }
    return 'center center';
  }
}
