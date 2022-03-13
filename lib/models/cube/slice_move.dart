import 'dart:math';

import 'package:flutter_hack/vector_math.dart';
import 'package:flutter_hack/models/cube/view_matrix.dart';

/// Slice moves
/// -----------
/// The direction is which face we want to slice to
/// The index is which row/column we want to slice.
/// Indices are in Ui-Space, so tl-br:
///      | col0 | col1 | col2 |
/// -----+------+------+------+
/// row0 |      |      |      |
/// -----+------+------+------+
/// row1 |      |      |      |
/// -----+------+------+------+
/// row2 |      |      |      |
/// -----+------+------+------+
///
/// e.g.:
/// - to slice the top row to the right we call sliceRight(0)
/// - to slice the top bottom row to the left we call sliceLeft(2)
/// - to slice the center column up we call sliceUp(1)
///
class SliceMove {
  final IVec axis;
  final IVec index;
  final int rawIndex;

  SliceMove(this.axis, this.index, this.rawIndex);

  factory SliceMove.up(int index) {
    return SliceMove(IVec.UP, ViewMatrix.toCubeSpace(Point(index, 1)), index);
  }

  factory SliceMove.down(int index) {
    return SliceMove(IVec.DOWN, ViewMatrix.toCubeSpace(Point(index, 1)), index);
  }

  factory SliceMove.left(int index) {
    return SliceMove(IVec.LEFT, ViewMatrix.toCubeSpace(Point(1, index)), index);
  }

  factory SliceMove.right(int index) {
    return SliceMove(IVec.RIGHT, ViewMatrix.toCubeSpace(Point(1, index)), index);
  }
}