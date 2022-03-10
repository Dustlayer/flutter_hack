// ignore_for_file: avoid_print

const String kFORKED = "forked";
const int kSIZE = 3;

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

// grid:
//   column major
// directions:
//  1 -> clockwise
// -1 -> counter clockwise
void cycleGrid<T>(List<List<T>> grid, int size, int direction) {
  if (size % 2 == 0) throw UnimplementedError(); // todo: could fix for even grids - lazy me

  int start = -size ~/ 2;
  int halfSize = (size + 1) ~/ 2;

  for (int i = 0; i < halfSize; i++) {
    for (int j = 0; j < halfSize - 1; j++) {
      T item = grid[i][j];
      int x = start + i;
      int y = start + j;

      // its a square -> 4 block per cycle
      for (int r = 0; r < 4; r++) {
        int tmpX = x;
        x = -direction * y;
        y = direction * tmpX;

        // local coordinates (lx, ly € [0, ... size])
        int lx = x - start;
        int ly = y - start;

        T tmp = grid[lx][ly];
        grid[lx][ly] = item;
        item = tmp;
      }
    }
  }
}

//
// Helper class to create empty 'arrays' (lists with initial null values) (still sucks lol)
class FNS<T> {
  // aka fuck null safety

  T? _data;
  T get value => _data!;
  set value(T? data) => _data = data;

  FNS([this._data]);
}

class Block {
  String id;

  Block(this.id);

  @override
  String toString() => id;
}

class Face {
  List<List<Block>> blocks; // column major -> block = blocks[x (row)][y (column)];
  late Face _left, _right, _up, _down;
  bool moving = false;

  // for debugging
  String id;

  Face(this.id, this.blocks);

  factory Face.generate(String baseId) {
    return Face(baseId, List.generate(kSIZE, (x) => List.generate(kSIZE, (y) => Block("$baseId-$x-$y"))));
  }

  void init(Face left, Face right, Face up, Face down) {
    _left = left;
    _right = right;
    _up = up;
    _down = down;
  }

  void push(Block block, Face from, int sliceIndex) {
    if (moving) return;

    // figure out how to push
    int x = 0, y = 0, dx = 0, dy = 0;
    Face to;
    if (from == _left) {
      to = _right;
      dx = 1;
      y = sliceIndex;
    } else if (from == _right) {
      to = _left;
      x = 2;
      dx = -1;
      y = sliceIndex;
    } else if (from == _up) {
      to = _down;
      dy = 1;
      x = sliceIndex;
    } else if (from == _down) {
      to = _up;
      y = 2;
      dy = -1;
      x = sliceIndex;
    } else {
      throw kFORKED;
    }

    // push
    moving = true;
    Block leftover = _push(x, y, dx, dy, block);
    to.push(leftover, this, sliceIndex);
    moving = false;
  }

  Block _push(int x0, int y0, int dx, int dy, Block block) {
    for (int i = 0; i < kSIZE; i++) {
      int x = x0 + dx * i;
      int y = y0 + dy * i;
      Block tmp = blocks[x][y];
      blocks[x][y] = block;
      block = tmp;
    }
    return block;
  }

  Block predictPush(Block block, Face from, int sliceIndex) {
    // figure out how to push
    int x = 0, y = 0, dx = 0, dy = 0;
    Face to;
    if (from == _left) {
      to = _right;
      dx = 1;
      y = sliceIndex;
    } else if (from == _right) {
      to = _left;
      x = 2;
      dx = -1;
      y = sliceIndex;
    } else if (from == _up) {
      to = _down;
      dy = 1;
      x = sliceIndex;
    } else if (from == _down) {
      to = _up;
      y = 2;
      dy = -1;
      x = sliceIndex;
    } else {
      throw kFORKED;
    }


    Block leftover = _predictPush(x, y, dx, dy);


    // push
    moving = true;
    Block out = block;
    if (!to.moving)  out = to.predictPush(leftover, this, sliceIndex);
    moving = false;

    return out;
  }

  Block _predictPush(int x0, int y0, int dx, int dy) {
    int x = x0 + dx * (kSIZE - 1);
    int y = y0 + dy * (kSIZE - 1);
    return blocks[x][y];
  }

  void rotate(bool clockwise) {
    // rotate connections to neighbours
    if (clockwise) {
      Face tmp = _right;
      _right = _up;
      _up = _left;
      _left = _down;
      _down = tmp;
    } else {
      Face tmp = _left;
      _left = _up;
      _up = _right;
      _right = _down;
      _down = tmp;
    }

    // rotate blocks so orientation is right
    cycleGrid(blocks, kSIZE, clockwise ? 1 : -1);
  }

  Face get left => _left;
  Face get right => _right;
  Face get up => _up;
  Face get down => _down;

  // helper to get the actual next face in given direction
  // because internally these might be mirrored (back face)
  Face next(Face from) {
    if (from == _left) {
      return _right;
    } else if (from == _right) {
      return _left;
    } else if (from == _up) {
      return _down;
    } else if (from == _down) {
      return _up;
    } else {
      throw kFORKED;
    }
  }
}

class Cube {
  Face front;
  List<Face> faces;

  Cube(this.front, this.faces);

  factory Cube.generate() {
    /// generate faces
    Face front = Face.generate("F");
    Face back = Face.generate("B");
    Face up = Face.generate("U");
    Face down = Face.generate("D");
    Face left = Face.generate("L");
    Face right = Face.generate("R");

    /// init connections
    front.init(left, right, up, down);
    back.init(right, left, down, up);
    right.init(front, back, up, down);
    left.init(back, front, up, down);
    up.init(left, right, back, front);
    down.init(left, right, front, back);

    return Cube(front, [front, back, up, down, left, right]);
  }

  Face rotateLeft() {
    front.up.rotate(false);
    front.down.rotate(false);
    front = front.right;
    return front;
  }

  Face rotateRight() {
    front.up.rotate(true);
    front.down.rotate(true);
    front = front.left;
    return front;
  }

  Face rotateUp() {
    front.right.rotate(false);
    front.left.rotate(true);
    front = front.down;
    return front;
  }

  Face rotateDown() {
    front.right.rotate(true);
    front.left.rotate(false);
    front = front.up;
    return front;
  }

  void sliceLeft(int sliceIndex) {
    front.left.push(front.blocks.first[sliceIndex], front, sliceIndex);
  }

  void sliceRight(int sliceIndex) {
    front.right.push(front.blocks.last[sliceIndex], front, sliceIndex);
  }

  void sliceUp(int sliceIndex) {
    front.up.push(front.blocks[sliceIndex].first, front, sliceIndex);
  }

  void sliceDown(int sliceIndex) {
    front.down.push(front.blocks[sliceIndex].last, front, sliceIndex);
  }

  Block predictSliceLeft(int sliceIndex) {
    return front.left.predictPush(front.blocks.first[sliceIndex], front, sliceIndex);
  }

  Block predictSliceRight(int sliceIndex) {
    return front.right.predictPush(front.blocks.last[sliceIndex], front, sliceIndex);
  }

  Block predictSliceUp(int sliceIndex) {
    return front.up.predictPush(front.blocks[sliceIndex].first, front, sliceIndex);
  }

  Block predictSliceDown(int sliceIndex) {
    return front.down.predictPush(front.blocks[sliceIndex].last, front, sliceIndex);
  }

  Face get left => front.left;
  Face get right => front.right;
  Face get up => front.up;
  Face get down => front.down;
  Face get back => front.up.next(front);

  void executeCubeAction(CubeActionCall action) {
    switch (action.action) {
      case CubeAction.turnColumnUp:
        return sliceDown(action.index);
      case CubeAction.turnColumnDown:
        return sliceUp(action.index);
      case CubeAction.turnRowLeft:
        return sliceLeft(action.index);
      case CubeAction.turnRowRight:
        return sliceRight(action.index);
      default:
        throw kFORKED;
    }
  }

  Block forecastAction(CubeActionCall action) {
    switch (action.action) {
      case CubeAction.turnColumnUp:
        return predictSliceDown(action.index);
      case CubeAction.turnColumnDown:
        return predictSliceUp(action.index);
      case CubeAction.turnRowLeft:
        return predictSliceLeft(action.index);
      case CubeAction.turnRowRight:
        return predictSliceRight(action.index);
      default:
        throw kFORKED;
    }
  }
}
