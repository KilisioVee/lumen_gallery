class V3 {
  const V3(this.x, this.y, this.z);
  final double x, y, z;
  V3 lerp(V3 b, double t) =>
      V3(x + (b.x - x) * t, y + (b.y - y) * t, z + (b.z - z) * t);
}