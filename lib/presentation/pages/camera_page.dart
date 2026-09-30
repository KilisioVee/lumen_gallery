import 'dart:math' as math;
import 'dart:ui';

import '../widgets/v3_widget.dart';

class Camera {
  const Camera(this.size, this.position, this.yaw, this.pitch);
  final Size size;
  final double position, yaw, pitch;
  static const near = 0.12;

  V3 view(V3 p) {
    final z = p.z - position;
    return V3(
      p.x * math.cos(yaw) - z * math.sin(yaw),
      p.y - 1.65,
      p.x * math.sin(yaw) + z * math.cos(yaw),
    );
  }

  Offset project(V3 p) {
    final focal = size.width * 0.95;
    return Offset(
      size.width / 2 + focal * p.x / p.z,
      size.height * (0.48 + pitch) - focal * p.y / p.z,
    );
  }

  List<Offset> surface(List<V3> world) {
    final points = world.map(view).toList();
    final clipped = <V3>[];
    for (var i = 0; i < points.length; i++) {
      final a = points[i], b = points[(i + 1) % points.length];
      final aInside = a.z >= near, bInside = b.z >= near;
      if (aInside) clipped.add(a);
      if (aInside != bInside) {
        clipped.add(a.lerp(b, (near - a.z) / (b.z - a.z)));
      }
    }
    return clipped.map(project).toList();
  }
}