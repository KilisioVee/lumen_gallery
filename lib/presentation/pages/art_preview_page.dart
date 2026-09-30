import 'package:flutter/material.dart';

import '../widgets/corridor_painter_widget.dart';
import 'art_page.dart';

class ArtPreview extends CustomPainter {
  ArtPreview(this.art);
  final Art art;

  @override
  void paint(Canvas canvas, Size size) => paintArt(canvas, size, art);

  @override
  bool shouldRepaint(covariant ArtPreview oldDelegate) =>
      oldDelegate.art != art;
}
