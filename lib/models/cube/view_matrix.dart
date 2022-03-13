import 'dart:math';

import 'package:flutter_hack/vector_math.dart';
import 'package:flutter_hack/constants.dart';

///
/// View Matrix
/// -----------
///
/// Used to convert view space coordinates
/// to cube space and vice versa.
///
/// Note: We're using dart:math.Point as Ui-Side type
/// because our IVec and IMat class expect only values in [-1, ... 1]
/// we could just remove the checks, but for sake of error checking within the cube
/// we will leave this restriction and work around it.
///
///
/// Ui coordinates:
/// (0, 0)  (1, 0)  (2, 0)
/// (0, 1)  (1, 1)  (2, 1)
/// (0, 2)  (1, 2)  (2, 2)
/// Cube coordinates:
/// (-1,  1), (0,  1), (1,  1)
/// (-1,  0), (0,  0), (1,  0)
/// (-1, -1), (0, -1), (1, -1)
class ViewMatrix {
  // we don't have translation matrices
  // so we'll have to do this by hand.
  // we could in theory use a matrix for the y-axis transformation
  // but that's just overkill.

  static IVec toCubeSpace(Point inViewSpace) {
    return IVec(
      inViewSpace.x.toInt() - kHalfSize,
      kHalfSize - inViewSpace.y.toInt(), // view-space y is inverted (top is 0, bottom is n)
    );
  }

  static Point toViewSpace(IVec inCubeSpace) {
    return Point(
      inCubeSpace.x + kHalfSize,
      inCubeSpace.y - kHalfSize,
    );
  }

}