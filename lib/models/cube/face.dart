import 'package:flutter/material.dart';
import 'package:flutter_hack/vector_math.dart';
import 'package:flutter_hack/constants.dart';

import 'block.dart';
import 'grid.dart';

class Face {
  final String _dbgName;

  final IMat mat;
  final Grid<Block> blocks;

  Face(this._dbgName, this.mat, this.blocks);

  String get dbgName => _dbgName;

  Block getBlockAt(IVec at) {
    IMat matInv = mat.getTransposed();
    IVec localAt = matInv.dotV(at);

    if (localAt.z != 0) {
      assert(false);
    }

    return blocks.get(localAt.x, localAt.y);
  }

  Block push(Block block, IVec cubeAxis, IVec cubeSliceIndex) {
    // figure out how to slice
    IMat matInv = mat.getTransposed();
    IVec localAxis = matInv.dotV(cubeAxis);
    IVec localIndex = matInv.dotV(cubeSliceIndex);

    // do the actual slicing (move blocks along axis over once)
    for (int i = 0; i < kSize; i++) {
      IVec localBlockPosition = localAxis * (-kHalfSize + i) + localIndex;
      if (localBlockPosition.z != 0) {
        assert(false);
      }
      Block tmp = blocks.get(localBlockPosition.x, localBlockPosition.y);
      blocks.set(localBlockPosition.x, localBlockPosition.y, block);
      block = tmp;
    }

    return block;
  }

  Block predictPush(IVec cubeAxis, IVec cubeSliceIndex) {
    // figure out how to slice
    IMat matInv = mat.getTransposed();
    IVec localAxis = matInv.dotV(cubeAxis);
    IVec localIndex = matInv.dotV(cubeSliceIndex);

    // get the last block on the slice
    IVec localBlockPosition = localAxis * (-kHalfSize + (kSize - 1)) + localIndex;
    if (localBlockPosition.z != 0) {
      assert(false);
    }
    return blocks.get(localBlockPosition.x, localBlockPosition.y);
  }

  bool isSolved() {
    Color reference = blocks.get(0, 0).color;
    return blocks.checkAll((b) => b.color == reference);
  }

  static Face generate(String _dbgName, IMat mat, Color color) {
    return Face(
      _dbgName,
      mat,
      Grid.generate(
        kSize,
        kSize,
        (x, y) => Block("($x | $y)", _dbgName, color),
      ),
    );
  }

  @override
  String toString() {
    return _dbgName;
  }
}
