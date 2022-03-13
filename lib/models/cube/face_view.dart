import 'dart:math';

import 'package:flutter_hack/vector_math.dart';
import 'package:flutter_hack/models/cube/view_matrix.dart';

import 'block.dart';
import 'face.dart';

///
/// Retains the current view on a face
/// even if the cube rotates
///
class FaceView {

  Face face;
  IMat cubeMat;
  IMat faceMat;

  FaceView(this.face, this.cubeMat) : faceMat = face.mat;

  /// Block access
  /// ------------
  ///
  /// Returns the block on the front face at given position.
  /// Indices are in Ui-Space meaning tl-br
  /// +--------+--------+--------+
  /// | (0, 0) | (1, 0) | (2, 0) |
  /// +--------+--------+--------+
  /// | (0, 1) | (1, 1) | (2, 1) |
  /// +--------+--------+--------+
  /// | (0, 2) | (1, 2) | (2, 2) |
  /// +--------+--------+--------+
  ///
  Block getBlockAt(int x, int y) {
    IVec at = ViewMatrix.toCubeSpace(Point(x, y));
    // do cube work
    IVec cubeAt = cubeMat.dotV(at);

    // do face work
    IMat faceMatInv = faceMat.getTransposed();
    IVec faceAt = faceMatInv.dotV(cubeAt);

    // if (faceAt.z != 0) {
    //   assert(false);
    // }

    return face.blocks.get(faceAt.x, faceAt.y);
  }

}