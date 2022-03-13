import 'dart:collection';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hack/constants.dart';

import 'package:flutter_hack/vector_math.dart';
import 'package:flutter_hack/models/cube/rotation_move.dart';
import 'package:flutter_hack/models/cube/slice_move.dart';

import 'face.dart';
import 'block.dart';
import 'face_view.dart';


class Cube {
  IMat mat = IMat.identity();
  final Map<IVec, Face> faces;

  Cube(this.faces) {
    _debugPrint();
  }

  FaceView getFrontView() {
    if (kDebugMode) print("GetFrontView");
    return FaceView(_getFaceAt(IVec.FRONT), mat);
  }

  void rotate(RotationMove move) {
    IVec cubeAxis = mat.dotV(move.axis);
    IMat rot = IMat.rotate90(cubeAxis);
    mat = rot.dotM(mat);
    _debugPrint();
  }

  void slice(SliceMove move) {
    Face front = _getFaceAt(IVec.FRONT);
    IVec worldSliceAxis = move.axis;
    IVec worldSliceIndex = move.index;
    if (kDebugMode) print("Slice: Front=$front, worldSliceAxis=$worldSliceAxis, worldSliceIndex=$worldSliceIndex");

    // find first block on front face
    IVec worldBlockPos = worldSliceAxis + worldSliceIndex;
    IVec cubeBlockPos = mat.dotV(worldBlockPos);
    Block block = front.getBlockAt(cubeBlockPos);

    // find actual slice index, direction and first face position
    IVec cubeSliceIndex = mat.dotV(worldSliceIndex);
    IVec cubeSliceAxis = mat.dotV(worldSliceAxis);
    IVec cubeFacePosition = mat.front;

    // todo: not needed, just debugging
    Block first = block;
    if (kDebugMode) {
      print("Slice start: cubeAxis=$cubeSliceAxis, cubeIndex=$cubeSliceIndex, cubePosition=$cubeFacePosition");
      print("\tface=${faces[cubeFacePosition]}, block=$block");
    }

    // do slicing, cube has 4 faces -> slice 4x
    for (int i = 0; i < 4; i++) {
      // 1) go to 'next' face
      // (we took the block from the front face, so the first face to push on is the next one)
      IVec tmp = cubeFacePosition;
      cubeFacePosition = cubeSliceAxis;
      cubeSliceAxis = -tmp;

      // 2) push
      Face face = faces[cubeFacePosition]!;
      if (kDebugMode) {
        print("Slice $i: cubeAxis=$cubeSliceAxis, cubePosition=$cubeFacePosition");
        print("\tface=$face, block=$block");
      }
      block = face.push(block, cubeSliceAxis, cubeSliceIndex);
    }

    if (kDebugMode) {
      print("Left over block: $block (should be $first)");
      if (block != first) {
        assert(false);
      }
    }
  }

  int solvedFaces() {
    int solved = 0;
    for (Face f in faces.values) {
      if (f.isSolved()) {
        solved += 1;
      }
    }

    return solved;
  }

  Block predictSlice(SliceMove move) {
    Face front = _getFaceAt(IVec.FRONT);
    IVec worldSliceAxis = move.axis;
    IVec worldSliceIndex = move.index;

    // find first block on front face
    IVec worldBlockPos = worldSliceAxis + worldSliceIndex;
    IVec cubeBlockPos = mat.dotV(worldBlockPos);
    Block block = front.getBlockAt(cubeBlockPos);

    // find actual slice index, direction and first face position
    IVec cubeSliceIndex = mat.dotV(worldSliceIndex);
    IVec cubeSliceAxis = mat.dotV(worldSliceAxis);
    IVec cubeFacePosition = mat.front;

    IVec tmp = cubeSliceAxis;
    cubeSliceAxis = cubeFacePosition;
    cubeFacePosition = -tmp;

    Face face = faces[cubeFacePosition]!;
    block = face.predictPush(cubeSliceAxis, cubeSliceIndex);
    if (kDebugMode) print("Predict slice: front: $front, face=$face, block=$block");

    return block;
  }

  FaceView predictRotation(RotationMove move) {
    IVec cubeAxis = mat.dotV(move.axis);
    IMat rot = IMat.rotate90(cubeAxis);
    IMat newMat = rot.dotM(mat);

    return FaceView(faces[newMat.dotV(IVec.FRONT)]!, newMat);
  }

  Face _getFaceAt(IVec at) {
    return faces[mat.dotV(at)]!;
  }

  static Cube generate(int nMovesShuffle) {
    /*
     *     X
     *     🡡
     *     ■ 🡢 Y
     *   🡧
     * Z
     *
     */
    Map<IVec, Face> faces = {
      IVec.X: Face.generate("R", IMat.rotate90(IVec.Y), Colors.green),
      -IVec.X: Face.generate("L", IMat.rotate90(-IVec.Y), Colors.amber),
      IVec.Y: Face.generate("U", IMat.rotate90(-IVec.X), Colors.cyan),
      -IVec.Y: Face.generate("D", IMat.rotate90(IVec.X), Colors.deepPurple),
      IVec.Z: Face.generate("F", IMat.identity(), Colors.deepOrange),
      -IVec.Z: Face.generate("B", IMat.rotate90(IVec.X).dotM(IMat.rotate90(IVec.X)), Colors.pink),
    };

    Cube cube = Cube(faces);
    shuffleCube(cube, nMovesShuffle);

    // check everything is alright once (in debug mode)
    if (kDebugMode) {
      Set<Block> seenBlocks = HashSet();

      for (Face face in cube.faces.values) {
        face.blocks.foreach((b) {
          if (seenBlocks.contains(b)) {
            assert(false);
          }
          seenBlocks.add(b);
        });
      }
    }

    return cube;
  }

  static void shuffleCube(Cube cube, int nMoves) {
    double pRotate = .3;
    Random ra = Random();

    List<RotationMove> rotationMoves = [
      RotationMove.up(),
      RotationMove.down(),
      RotationMove.left(),
      RotationMove.right(),
    ];
    List<SliceMove Function(int)> sliceMoves = [
      (i) => SliceMove.up(i),
      (i) => SliceMove.down(i),
      (i) => SliceMove.left(i),
      (i) => SliceMove.right(i),
    ];

    for (int i = 0; i < nMoves; i++) {
      if (ra.nextDouble() <= pRotate) {
        cube.rotate(rotationMoves[ra.nextInt(rotationMoves.length)]);
      }
      else {
        int rawIndex = ra.nextInt(kSize);
        cube.slice(sliceMoves[ra.nextInt(sliceMoves.length)](rawIndex));
      }
    }
  }

  // ----------------- //
  //    Debug stuff    //
  // ----------------- //

  void debug() {
    // debug hook, just put a break point here and press D
    // ignore: unused_local_variable
    int i = 0;
  }

  void _debugPrint() {
    if (!kDebugMode) return;

    // ignore: avoid_print
    print("Cube: $mat");
    faces.forEach((_, f) {
      // ignore: avoid_print
      print("${f.dbgName}^T: ${f.mat.getTransposed()}");
    });
  }
}
