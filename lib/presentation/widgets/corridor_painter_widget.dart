import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:gallery_walkthrough/presentation/widgets/projected_art_widget.dart';
import 'package:gallery_walkthrough/presentation/widgets/v3_widget.dart';

import '../../main.dart';
import '../pages/art_page.dart';
import '../pages/camera_page.dart';

class CorridorPainter extends CustomPainter {
  CorridorPainter(this.camera, this.paintings);
  final Camera camera;
  final List<ProjectedArt> paintings;

  void surface(Canvas canvas, List<V3> corners, Color color) {
    final points = camera.surface(corners);
    if (points.length >= 3) {
      canvas.drawPath(polygon(points), Paint()..color = color);
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.clipRect(Offset.zero & size);
    canvas.drawRect(
        Offset.zero & size, Paint()..color = const Color(0xFFF7F3EA));

    const start = -8.0, end = 30.0, width = 2.2, height = 3.5;

    surface(
        canvas,
        const [
          V3(-width, 0, end),
          V3(width, 0, end),
          V3(width, height, end),
          V3(-width, height, end),
        ],
        const Color(0xFFEAE2D5));
    surface(
        canvas,
        const [
          V3(-width, height, start),
          V3(width, height, start),
          V3(width, height, end),
          V3(-width, height, end),
        ],
        const Color(0xFFFFFCF6));
    surface(
        canvas,
        const [
          V3(-width, 0, start),
          V3(-width, height, start),
          V3(-width, height, end),
          V3(-width, 0, end),
        ],
        const Color(0xFFECE4D6));
    surface(
        canvas,
        const [
          V3(width, 0, start),
          V3(width, 0, end),
          V3(width, height, end),
          V3(width, height, start),
        ],
        const Color(0xFFF8F1E5));

    final carpet = polygon(camera.surface(const [
      V3(-width, 0, start),
      V3(width, 0, start),
      V3(width, 0, end),
      V3(-width, 0, end),
    ]));
    canvas.drawPath(
      carpet,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF879AA6), Color(0xFF4E6574)],
        ).createShader(Offset.zero & size),
    );

    canvas.save();
    canvas.clipPath(carpet);
    final random = math.Random(17);
    final fibre = Paint();
    for (var i = 0; i < 1600; i++) {
      fibre.color =
      i.isEven ? const Color(0x16E7EFF3) : const Color(0x121D3444);
      canvas.drawCircle(
        Offset(random.nextDouble() * size.width,
            random.nextDouble() * size.height),
        0.55 + random.nextDouble() * 0.55,
        fibre,
      );
    }
    canvas.restore();

    for (final side in [-1.0, 1.0]) {
      final x = side * 2.195;
      surface(
          canvas,
          [
            V3(x, 0, start),
            V3(x, 0.10, start),
            V3(x, 0.10, end),
            V3(x, 0, end),
          ],
          const Color(0xFFC9BDAB));
    }

    for (double z = 2; z < 29; z += 3) {
      surface(
          canvas,
          [
            V3(-0.32, 3.48, z - 0.16),
            V3(0.32, 3.48, z - 0.16),
            V3(0.32, 3.48, z + 0.16),
            V3(-0.32, 3.48, z + 0.16),
          ],
          const Color(0xFFFFFFEE));
    }

    for (final painting in paintings) {
      final path = polygon(painting.points);
      canvas.drawShadow(path, const Color(0x77000000), 3, false);
      canvas.save();
      canvas.transform(quadMatrix(painting.points, 180, 220).storage);
      paintArt(canvas, const Size(180, 220), painting.art);
      canvas.restore();
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CorridorPainter oldDelegate) => true;
}
Path polygon(List<Offset> points) {
  final path = Path();
  if (points.isEmpty) return path;
  path.moveTo(points.first.dx, points.first.dy);
  for (final p in points.skip(1)) {
    path.lineTo(p.dx, p.dy);
  }
  return path..close();
}
Matrix4 quadMatrix(List<Offset> p, double width, double height) {
  final dx1 = p[1].dx - p[2].dx, dx2 = p[3].dx - p[2].dx;
  final dy1 = p[1].dy - p[2].dy, dy2 = p[3].dy - p[2].dy;
  final sx = p[0].dx - p[1].dx + p[2].dx - p[3].dx;
  final sy = p[0].dy - p[1].dy + p[2].dy - p[3].dy;
  final determinant = dx1 * dy2 - dx2 * dy1;
  final g =
  determinant.abs() < 1e-9 ? 0.0 : (sx * dy2 - dx2 * sy) / determinant;
  final h =
  determinant.abs() < 1e-9 ? 0.0 : (dx1 * sy - sx * dy1) / determinant;

  final matrix = Matrix4.zero();
  matrix.setEntry(0, 0, (p[1].dx - p[0].dx + g * p[1].dx) / width);
  matrix.setEntry(0, 1, (p[3].dx - p[0].dx + h * p[3].dx) / height);
  matrix.setEntry(0, 3, p[0].dx);
  matrix.setEntry(1, 0, (p[1].dy - p[0].dy + g * p[1].dy) / width);
  matrix.setEntry(1, 1, (p[3].dy - p[0].dy + h * p[3].dy) / height);
  matrix.setEntry(1, 3, p[0].dy);
  matrix.setEntry(2, 2, 1);
  matrix.setEntry(3, 0, g / width);
  matrix.setEntry(3, 1, h / height);
  matrix.setEntry(3, 3, 1);
  return matrix;
}
void paintArt(Canvas canvas, Size size, Art art) {
  final outer = Offset.zero & size;
  canvas.drawRect(outer, Paint()..color = const Color(0xFF654932));
  canvas.drawRect(outer.deflate(3), Paint()..color = const Color(0xFFC6AC7F));
  canvas.drawRect(outer.deflate(7), Paint()..color = const Color(0xFFF5EDDC));

  final inner = outer.deflate(15);
  canvas.save();
  canvas.clipRect(inner);
  canvas.drawRect(
    inner,
    Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: art.colors,
      ).createShader(inner),
  );
  canvas.drawCircle(
    Offset(size.width * 0.66, size.height * 0.32),
    size.width * 0.19,
    Paint()
      ..color = const Color(0x44FFFFFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7,
  );
  final hill = Path()
    ..moveTo(inner.left, inner.bottom * 0.8)
    ..quadraticBezierTo(
        size.width * 0.4, size.height * 0.43, inner.right, inner.bottom * 0.73)
    ..lineTo(inner.right, inner.bottom)
    ..lineTo(inner.left, inner.bottom)
    ..close();
  canvas.drawPath(hill, Paint()..color = const Color(0x33000000));
  canvas.restore();
}
