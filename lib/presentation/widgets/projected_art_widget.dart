
import 'package:flutter/animation.dart';
import 'package:gallery_walkthrough/presentation/pages/art_page.dart';
import 'package:gallery_walkthrough/presentation/pages/camera_page.dart';
import 'package:gallery_walkthrough/presentation/widgets/v3_widget.dart';

import 'corridor_painter_widget.dart';
class ProjectedArt {
  const ProjectedArt(this.art, this.points, this.depth);
  final Art art;
  final List<Offset> points;
  final double depth;
}

List<ProjectedArt> visibleArt(Camera camera) {
  final result = <ProjectedArt>[];
  for (final art in collection) {
    final x = art.side * 2.18;
    const halfWidth = 0.85; // Total width: 1.7 m
    const bottomY = 0.90;   // Distance from floor
    const topY = 3.00;      // Total height: 2.1 m

    final z0 = art.side < 0 ? art.z - halfWidth : art.z + halfWidth;
    final z1 = art.side < 0 ? art.z + halfWidth : art.z - halfWidth;
    final corners = [
      V3(x, topY, z0),
      V3(x, topY, z1),
      V3(x, bottomY, z1),
      V3(x, bottomY, z0),
    ].map(camera.view).toList();

    if (corners.any((p) => p.z <= Camera.near)) continue;
    final projected = corners.map(camera.project).toList();
    if (projected.any((p) => !p.dx.isFinite || !p.dy.isFinite)) continue;

    final bounds = polygon(projected).getBounds();
    if (!bounds.overlaps(Offset.zero & camera.size) || bounds.width < 2) {
      continue;
    }
    result.add(ProjectedArt(
      art,
      projected,
      corners.fold<double>(0, (sum, p) => sum + p.z) / 4,
    ));
  }
  result.sort((a, b) => b.depth.compareTo(a.depth));
  return result;
}