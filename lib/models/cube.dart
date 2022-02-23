// ignore_for_file: avoid_print

import 'dart:math';

import 'package:flutter/material.dart';

class Block {
  String id;
  int value;

  Block(this.id, this.value);

  @override
  String toString() => 'Block $id (value=$value)';
}

class Face {
  late Face left, right, top, bottom;
  List<List<Block>> blocks;

  final int _width, _height;
  bool _isShifting = false;

  int get width => _width;

  int get height => _height;

  Face(this.blocks, int width, int height)
      : _width = width,
        _height = height;

  factory Face.random(int width, int height, String id) {
    var random = Random();

    List<List<Block>> blocks = List.empty(growable: true);
    for (int r = 0; r < height; r++) {
      List<Block> row = List.empty(growable: true);
      for (int c = 0; c < width; c++) {
        var color = Color.fromARGB(255, random.nextInt(255), random.nextInt(255), random.nextInt(255));
        row.add(Block("$r-$c ($id)", color.value)); // use color.value to convert to hex as value is an int
      }
      blocks.add(row);
    }

    return Face(blocks, width, height);
  }

  factory Face.fromFace(Face other) {
    // silly deep copy for block list
    List<List<Block>> blocksCopy = List.empty(growable: true);
    for (List<Block> row in other.blocks) {
      List<Block> rowCopy = List.empty(growable: true);

      for (Block block in row) {
        rowCopy.add(block);
      }
      blocksCopy.add(rowCopy);
    }

    return Face(blocksCopy, other._width, other._height);
  }

  void init(Face left, Face right, Face top, Face bottom) {
    this.left = left;
    this.right = right;
    this.top = top;
    this.bottom = bottom;
  }

  void shiftUp(int colIndex) {
    if (colIndex < height && colIndex >= 0) {
      top.pushFromBottom(colIndex, blocks.first[colIndex]);
    }
  }

  void shiftDown(int colIndex) {
    if (colIndex < height && colIndex >= 0) {
      bottom.pushFromTop(colIndex, blocks.last[colIndex]);
    }
  }

  void shiftRight(int rowIndex) {
    if (rowIndex < width && rowIndex >= 0) {
      right.pushFromLeft(rowIndex, blocks[rowIndex].last);
    }
  }

  void shiftLeft(int rowIndex) {
    if (rowIndex < width && rowIndex >= 0) {
      left.pushFromRight(rowIndex, blocks[rowIndex].first);
    }
  }

  void pushFromLeft(int rowIndex, Block block) {
    if (!_isShifting) {
      _isShifting = true;
      List<Block> row = blocks[rowIndex];
      row.insert(0, block);
      Block overflow = row.removeLast();
      right.pushFromLeft(rowIndex, overflow);
      _isShifting = false;
    }
  }

  void pushFromRight(int rowIndex, Block block) {
    if (!_isShifting) {
      _isShifting = true;
      List<Block> row = blocks[rowIndex];
      row.add(block);
      Block overflow = row.removeAt(0);
      left.pushFromRight(rowIndex, overflow);
      _isShifting = false;
    }
  }

  void pushFromTop(int colIndex, Block block) {
    // insert at top and 'push' all blocks down once
    if (!_isShifting) {
      _isShifting = true;

      Block prev = block;
      for (int i = 0; i < blocks.length; i++) {
        Block curr = blocks[i][colIndex];
        blocks[i][colIndex] = prev;
        prev = curr;
      }

      // prev now is bottommost block -> push to next face
      bottom.pushFromTop(colIndex, prev);
      _isShifting = false;
    }
  }

  void pushFromBottom(int colIndex, Block block) {
    if (!_isShifting) {
      _isShifting = true;
      // insert at bottom and 'push' all blocks up once
      Block prev = block;
      for (int i = blocks.length - 1; 0 <= i; i--) {
        Block curr = blocks[i][colIndex];
        blocks[i][colIndex] = prev;
        prev = curr;
      }

      // prev now is topmost block -> push to next face
      top.pushFromBottom(colIndex, prev);
      _isShifting = false;
    }
  }

  void cycleClockwise() {
    // top -> right -> bottom -> left -> top

    var tmp = top;
    top = left;
    left = bottom;
    bottom = right;
    right = tmp;

    // cycle blocks
    blocks = rotateBlocks(blocks);
  }

  void cycleCounterClockwise() {
    // top -> left -> bottom -> right -> top

    // cycle faces
    var tmpFace = top;
    top = right;
    right = bottom;
    bottom = left;
    left = tmpFace;

    // cycle blocks
    blocks = rotateBlocks(blocks, counterClockwise: true);
  }

  static List<List<Block>> rotateBlocks(List<List<Block>> blocks, {bool counterClockwise = false}) {
    int m = blocks.length;
    int n = blocks[0].length;

    int flip = counterClockwise ? -1 : 1;

    int cx = n ~/ 2;
    int cy = m ~/ 2;

    List<List<Block>> rotated = List.generate(
      blocks.length,
          (index) => List.generate(
        blocks[0].length,
            (index) => Block("THIS SHOULD NOT BE VISIBLE", -1),
        growable: false,
      ),
      growable: false,
    );

    for (int r = 0; r < m; r++) {
      for (int c = 0; c < n; c++) {
        int x = c - cx;
        int y = r - cy;

        int x_ = -flip * y;
        int y_ = flip * x;

        int r_ = (y_ + cy).toInt();
        int c_ = (x_ + cx).toInt();


        rotated[r_][c_] = blocks[r][c];
      }
    }

    return rotated;
  }
}

enum CubeAction {
  turnRowRight,
  turnRowLeft,
  turnColumnDown,
  turnColumnUp,
}

class CubeActionCall {
  final CubeAction action;
  final int index;

  CubeActionCall(this.action, this.index);

  @override
  String toString() => "$action ($index)";
}

class Cube {
  late Face front;
  int width;
  int height;

  Cube(this.front, Face right, Face back, Face left, Face top, Face bottom)
      : width = front.width,
        height = front.height {
    // set up face references
    // the 'strips' are
    // horizontal: font right back left front
    // vertical: front top back bottom front

    front.init(left, right, top, bottom);
    right.init(front, back, top, bottom);
    back.init(right, left, bottom, top);
    left.init(back, front, top, bottom);

    top.init(left, right, back, front);
    bottom.init(left, right, front, back);
  }

  Cube.linked(this.front)
      : width = front.width,
        height = front.height;

  factory Cube.random({int width = 3, int height = 3}) {
    return Cube(
      Face.random(width, height, "front"),
      Face.random(width, height, "right"),
      Face.random(width, height, "back"),
      Face.random(width, height, "left"),
      Face.random(width, height, "top"),
      Face.random(width, height, "bottom"),
    );
  }

  void turnLeft() {
    front.top.cycleClockwise();
    front.bottom.cycleCounterClockwise();

    front = front.right;
  }

  void turnRight() {
    front.top.cycleCounterClockwise();
    front.bottom.cycleClockwise();

    front = front.left;
  }

  void turnUp() {
    front.right.cycleClockwise();
    front.left.cycleCounterClockwise();

    front = front.bottom;
  }

  void turnDown() {
    // for what?! - ¯\_(ツ)_/¯
    front.right.cycleCounterClockwise();
    front.left.cycleClockwise();

    front = front.top;
  }

  void turnRowRight(int rowIndex) {
    front.shiftRight(rowIndex);
  }

  void turnRowLeft(int rowIndex) {
    front.shiftLeft(rowIndex);
  }

  void turnColumnUp(int colIndex) {
    front.shiftUp(colIndex);
  }

  void turnColumnDown(int colIndex) {
    front.shiftDown(colIndex);
  }

  void executeCubeAction(CubeActionCall actionCall) {
    switch (actionCall.action) {
      case CubeAction.turnColumnUp:
        {
          turnColumnUp(actionCall.index);
        }
        break;
      case CubeAction.turnColumnDown:
        {
          turnColumnDown(actionCall.index);
        }
        break;
      case CubeAction.turnRowLeft:
        {
          turnRowLeft(actionCall.index);
        }
        break;
      case CubeAction.turnRowRight:
        {
          turnRowRight(actionCall.index);
        }
        break;
    }
  }

  Cube deepCopy() {
    Face newFront = Face.fromFace(front);
    Face newRight = Face.fromFace(front.right);
    Face newBack = Face.fromFace(front.left.left);
    Face newLeft = Face.fromFace(front.left);
    Face newTop = Face.fromFace(front.top);
    Face newBottom = Face.fromFace(front.bottom);

    return Cube(newFront, newRight, newBack, newLeft, newTop, newBottom);
  }
}
