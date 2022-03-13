import 'package:flutter_hack/vector_math.dart';

/// Rotation moves
/// --------------
///
/// The direction is which face we want to rotate to.
///
/// e.g. to rotate from font to top we call rotateUp()
class RotationMove {
  final IVec axis;

  RotationMove(this.axis);

  factory RotationMove.up() {
    return RotationMove(-IVec.X);
  }

  factory RotationMove.down() {
    return RotationMove(IVec.X);
  }

  factory RotationMove.left() {
    return RotationMove(-IVec.Y);
  }

  factory RotationMove.right() {
    return RotationMove(IVec.Y);
  }
}