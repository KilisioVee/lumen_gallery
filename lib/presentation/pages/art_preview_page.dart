import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../widgets/corridor_painter_widget.dart';
import 'art_page.dart';

class ArtPreview extends CustomPainter {
  ArtPreview(this.image);
  final ui.Image? image;

  @override
  void paint(Canvas canvas, Size size) => paintArt(canvas, size, image);

  @override
  bool shouldRepaint(covariant ArtPreview oldDelegate) =>
      oldDelegate.image != image;
}

