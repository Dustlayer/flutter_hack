// ignore_for_file: non_constant_identifier_names

import 'package:flutter_hack/constants.dart';

bool kUnchecked = false;

class IVec {
  final int x, y, z;

  IVec(this.x, this.y, [this.z = 0]) {
    if (!kUnchecked) {
      if (2 < squareLength()) {
        assert(false, "x + y + z > 2!");
      }
    }
  }

  static IVec get X => IVec(1, 0, 0);
  static IVec get Y => IVec(0, 1, 0);
  static IVec get Z => IVec(0, 0, 1);

  static IVec get RIGHT => X;
  static IVec get LEFT => -X;
  static IVec get FRONT => Z;
  static IVec get BACK => -Z;
  static IVec get UP => Y;
  static IVec get DOWN => -Y;

  String asDirection() {
    // only works for 'single-directions' as of now
    // e.g. (1, 1, 0) which would be right-up, is not a thing yet
    assert(squareLength() == 1);
    if (0 < x) return "Right";
    if (0 < y) return "Up";
    if (0 < z) return "Front";
    if (x < 0) return "Left";
    if (y < 0) return "Down";
    if (z < 0) return "Back";
    throw kForked;
  }

  int squareLength() {
    // x, y, z \in [-1, 0, 1] => x ** 2 = |x|, ...
    return x.abs() + y.abs() + z.abs();
  }

  int dot(IVec other) {
    return x * other.x + y * other.y + z * other.z;
  }

  IVec cross(IVec other) {
    return IVec(
      y * other.z - z * other.y,
      z * other.x - x * other.z,
      x * other.y - y * other.x,
    );
  }

  IVec operator +(IVec other) {
    return IVec(x + other.x, y + other.y, z + other.z);
  }

  IVec operator -(IVec other) {
    return IVec(x - other.x, y - other.y, z - other.z);
  }

  IVec operator *(int s) {
    return IVec(x * s, y * s, z * s);
  }

  IVec operator -() {
    return this * -1;
  }


  @override
  String toString() => "[$x, $y, $z]";

  @override
  bool operator ==(Object other) {
    if (other is IVec) return x == other.x && y == other.y && z == other.z;
    return false;
  }

  @override
  int get hashCode => Object.hashAll([x, y, z]);

  static void checkIsRight() {
    // +z
    assert(IVec.X.cross(IVec.Y) == IVec.Z);
    assert(IVec.Y.cross(-IVec.X) == IVec.Z);
    assert((-IVec.X).cross(-IVec.Y) == IVec.Z);
    assert((-IVec.Y).cross(IVec.X) == IVec.Z);

    // -z
    assert(IVec.Y.cross(IVec.X) == -IVec.Z);
    assert(IVec.X.cross(-IVec.Y) == -IVec.Z);
    assert((-IVec.Y).cross(-IVec.X) == -IVec.Z);
    assert((-IVec.X).cross(IVec.Y) == -IVec.Z);

    // +y
    assert(IVec.X.cross(-IVec.Z) == IVec.Y);
    assert((-IVec.Z).cross(-IVec.X) == IVec.Y);
    assert((-IVec.X).cross(IVec.Z) == IVec.Y);
    assert((IVec.Z).cross(IVec.X) == IVec.Y);

    // -y
    assert(IVec.Z.cross(-IVec.X) == -IVec.Y);
    assert((-IVec.X).cross(-IVec.Z) == -IVec.Y);
    assert((-IVec.Z).cross(IVec.X) == -IVec.Y);
    assert((IVec.X).cross(IVec.Z) == -IVec.Y);

    // +x
    assert(IVec.Y.cross(IVec.Z) == IVec.X);
    assert(IVec.Z.cross(-IVec.Y) == IVec.X);
    assert((-IVec.Y).cross(-IVec.Z) == IVec.X);
    assert((-IVec.Z).cross(IVec.Y) == IVec.X);

    // -x
    assert(IVec.Z.cross(IVec.Y) == -IVec.X);
    assert(IVec.Y.cross(-IVec.Z) == -IVec.X);
    assert((-IVec.Z).cross(-IVec.Y) == -IVec.X);
    assert((-IVec.Y).cross(IVec.Z) == -IVec.X);

  }
}

class IMat {
  static String notAUnitVector(String name) {
    return "$name must be a unit vector (|$name| == 1)";
  }

  final IVec i, j, k; // each of these only has a single component set

  IMat.new(this.i, this.j, this.k) {
    if (!kUnchecked) {
      assert(i.squareLength() == 1, notAUnitVector('I'));
      assert(j.squareLength() == 1, notAUnitVector('J'));
      assert(k.squareLength() == 1, notAUnitVector('K'));
    }
  }

  factory IMat.identity() {
    return IMat(IVec.X, IVec.Y, IVec.Z);
  }

  IVec get right => dotV(IVec.RIGHT);
  IVec get left => dotV(IVec.LEFT);
  IVec get up => dotV(IVec.UP);
  IVec get down => dotV(IVec.DOWN);
  IVec get front => dotV(IVec.FRONT);
  IVec get back => dotV(IVec.BACK);

  IVec dotV(IVec vec) {
    return i * vec.x + j * vec.y + k * vec.z;
  }

  IMat dotM(IMat mat) {
    return IMat(dotV(mat.i), dotV(mat.j), dotV(mat.k));
  }

  IMat getTransposed() {
    return IMat(
      IVec(
        i.x,
        j.x,
        k.x,
      ),
      IVec(
        i.y,
        j.y,
        k.y,
      ),
      IVec(i.z, j.z, k.z),
    );
  }

  @override
  String toString() {
    return "R: ${right.asDirection()}, U:${up.asDirection()}, F: ${front.asDirection()}";
  }

  @override
  int get hashCode => Object.hashAll([i, j, k]);

  // Rotation matrix from axis and angle: https://en.wikipedia.org/wiki/Rotation_matrix#In_three_dimensions
  static IMat rotate90(IVec axis) {
    assert(axis.squareLength() == 1, notAUnitVector("axis"));

    // i' = (
    // cos(90) + x^2 * (1 - cos(90)),
    // y * x * (1 - cos(90)) + z * sin(90),
    // z * x * (1 - cos(90)) - y * sin(90),
    // );

    IVec iPrime = IVec(
      axis.x.abs(),
      axis.y * axis.x + axis.z,
      axis.z * axis.x - axis.y,
    );

    // j' = (
    // x * y * (1 - cos(90)) - z * sin(90),
    // cos(90) + y^2 * (1 - cos(90)),
    // z * y * (1 - cos(90)) + x sin(90),
    // );
    IVec jPrime = IVec(
      axis.x * axis.y - axis.z,
      axis.y.abs(),
      axis.z * axis.y + axis.x,
    );

    // k' = (
    // x * z * (1 - cos(90)) + y * sin(90),
    // y * z * (1 - cos(90)) - x * sin(90),
    // cos(90) + z^2 * (1 - cos(90)),
    // );
    IVec kPrime = IVec(
      axis.x * axis.z + axis.y,
      axis.y * axis.z - axis.x,
      axis.z.abs(),
    );

    return IMat(iPrime, jPrime, kPrime);
  }

  // make sure it works ;_;
  static void checkItsRight() {
    // ------------------------ //
    //    validate rotations    //
    // ------------------------ //

    // +x
    IMat rotX = IMat.rotate90(IVec.X);
    assert(rotX.dotV(IVec.X) == IVec.X);
    assert(rotX.dotV(IVec.Y) == IVec.Z);
    assert(rotX.dotV(IVec.Z) == -IVec.Y);

    // -x
    IMat rotXNeg = IMat.rotate90(-IVec.X);
    assert(rotXNeg.dotV(IVec.X) == IVec.X);
    assert(rotXNeg.dotV(IVec.Y) == -IVec.Z);
    assert(rotXNeg.dotV(IVec.Z) == IVec.Y);

    // +y
    IMat rotY = IMat.rotate90(IVec.Y);
    assert(rotY.dotV(IVec.X) == -IVec.Z);
    assert(rotY.dotV(IVec.Y) == IVec.Y);
    assert(rotY.dotV(IVec.Z) == IVec.X);

    // -y
    IMat rotYNeg = IMat.rotate90(-IVec.Y);
    assert(rotYNeg.dotV(IVec.X) == IVec.Z);
    assert(rotYNeg.dotV(IVec.Y) == IVec.Y);
    assert(rotYNeg.dotV(IVec.Z) == -IVec.X);

    // +z
    IMat rotZ = IMat.rotate90(IVec.Z);
    assert(rotZ.dotV(IVec.X) == IVec.Y);
    assert(rotZ.dotV(IVec.Y) == -IVec.X);
    assert(rotZ.dotV(IVec.Z) == IVec.Z);

    // -z
    IMat rotZNeg = IMat.rotate90(-IVec.Z);
    assert(rotZNeg.dotV(IVec.X) == -IVec.Y);
    assert(rotZNeg.dotV(IVec.Y) == IVec.X);
    assert(rotZNeg.dotV(IVec.Z) == IVec.Z);

    kUnchecked = true;
    IMat src = IMat(IVec(1, 2, 3), IVec(4, 5, 6), IVec(7, 8, 9));
    IMat srcT = IMat(IVec(1, 4, 7), IVec(2, 5, 8), IVec(3, 6, 9));

    assert(src.getTransposed() == srcT);
    kUnchecked = false;
  }

  @override
  bool operator ==(Object other) {
    if (other is IMat) return i == other.i && j == other.j && k == other.k;
    return false;
  }
}

void main() {
  IMat.checkItsRight();
  IVec.checkIsRight();
}
