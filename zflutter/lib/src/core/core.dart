import 'dart:math' as math;
import 'dart:ui';

import 'package:quiver/core.dart';

export 'path_command.dart';
export 'render/render_box.dart';
export 'render/render_shape.dart';
export 'renderer.dart';
export 'widgets/box_adapter.dart';
export 'widgets/positioned.dart';
export 'widgets/shape.dart';
export 'widgets/widget.dart';

const tau = math.pi * 2;

// A immutable 3D vector
// Todo: Add unit test for this. It is important
class ZVector {
  final double x;
  final double y;
  final double z;

  const ZVector(this.x, this.y, this.z);

  const ZVector.only({this.x = 0, this.y = 0, this.z = 0});

  const ZVector.all(double value)
      : this.x = value,
        this.y = value,
        this.z = value;
  static const ZVector zero = ZVector.all(0);
  static const ZVector identity = ZVector.all(1);

  bool operator ==(v) => v is ZVector && x == v.x && y == v.y && z == v.z;

  int get hashCode => hash3(x.hashCode, y.hashCode, z.hashCode);

  ZVector add({double x = 0, double y = 0, double z = 0}) {
    return ZVector(this.x + x, this.y + y, this.z + z);
  }

  ZVector subtract({double x = 0, double y = 0, double z = 0}) {
    return ZVector(this.x - x, this.y - y, this.z - z);
  }

  ZVector subtractVector(ZVector v) {
    return ZVector(this.x - v.x, this.y - v.y, this.z - v.z);
  }

  ZVector addVector(ZVector v) {
    return ZVector(this.x + v.x, this.y + v.y, this.z + v.z);
  }

  ZVector rotate(ZVector? rotation) {
    if (rotation == null) return this;

    return this.rotateZ(rotation.z).rotateY(rotation.y).rotateX(rotation.x);
  }

  ZVector rotateZ(double angle) {
    return _rotateProperty(angle, Axis.x, Axis.y);
  }

  ZVector rotateX(double angle) {
    return _rotateProperty(angle, Axis.y, Axis.z);
  }

  ZVector rotateY(double angle) {
    return _rotateProperty(angle, Axis.x, Axis.z);
  }

  ZVector _rotateProperty(double? angle, Axis propA, Axis propB) {
    if (angle == null || angle % tau == 0) {
      return this;
    }
    var cos = math.cos(angle);
    var sin = math.sin(angle);
    var a = toMap[propA]!;
    var b = toMap[propB]!;

    return replaceAxisInMap(
        {propA: a * cos - b * sin, propB: b * cos + a * sin});
  }

  replaceAxisInMap(Map<Axis, double> axis) {
    double? x, y, z;
    axis.forEach((key, value) {
      if (key == Axis.x) x = value;
      if (key == Axis.y) y = value;
      if (key == Axis.z) z = value;
    });
    return ZVector(x ?? this.x, y ?? this.y, z ?? this.z);
  }

  Map<Axis, double> get toMap => {
        Axis.x: x,
        Axis.y: y,
        Axis.z: z,
      };

  ZVector multiply(ZVector? scale) {
    if (scale == null) return this;
    final mx = scale.x;
    final my = scale.y;
    final mz = scale.z;
    return ZVector(x * mx, y * my, z * mz);
  }

  ZVector divide(ZVector? scale) {
    if (scale == null) return this;
    final mx = scale.x;
    final my = scale.y;
    final mz = scale.z;
    return ZVector(x / mx, y / my, z / mz);
  }

  ZVector multiplyScalar(num? scale) {
    if (scale == null) return this;
    final m = scale;
    return ZVector(x * m, y * m, z * m);
  }

  ZVector transform(ZVector translation, ZVector rotation, ZVector scale) {
    return this.multiply(scale).rotate(rotation).addVector(translation);
  }

  static ZVector lerp(ZVector a, ZVector? b, double t) {
    final double? x = lerpDouble(a.x, b?.x ?? 0.0, t);
    final double? y = lerpDouble(a.y, b?.y ?? 0.0, t);
    final double? z = lerpDouble(a.z, b?.z ?? 0.0, t);
    return ZVector(x!, y!, z!);
  }

  double magnitude() {
    var sum = this.x * this.x + this.y * this.y + this.z * this.z;
    return getMagnitudeSqrt(sum);
  }

  double getMagnitudeSqrt(double sum) {
    // PERF: check if sum ~= 1 and skip sqrt
    if ((sum - 1).abs() < 0.00000001) {
      return 1;
    }
    return math.sqrt(sum);
  }

  double magnitude2d() {
    var sum = this.x * this.x + this.y * this.y;
    return getMagnitudeSqrt(sum);
  }

  ZVector copy() {
    return ZVector(this.x, this.y, this.z);
  }

  ZVector copyWith({double? x, double? y, double? z}) {
    return ZVector(x ?? this.x, y ?? this.y, z ?? this.z);
  }

  ZVector operator +(ZVector v) => addVector(v);

  ZVector operator -(ZVector v) => subtractVector(v);

  ZVector operator *(ZVector v) => multiply(v);

  ZVector operator /(ZVector v) => multiply(v);

  /// Cross product.
  ZVector cross(ZVector other) {
    final double _x = x;
    final double _y = y;
    final double _z = z;
    final double ox = other.x;
    final double oy = other.y;
    final double oz = other.z;
    return ZVector.only(
      x: _y * oz - _z * oy,
      y: _z * ox - _x * oz,
      z: _x * oy - _y * ox,
    );
  }

  ZVector unit() {
    var total = magnitude();
    return ZVector(x / total, y / total, z / total);
  }

  @override
  String toString() {
    return 'V($x, $y, $z)';
  }
}

enum Axis { x, y, z }
