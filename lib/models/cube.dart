class Block {
  String id;
  int value;

  Block(this.id, this.value);

  @override
  String toString() => 'Block $id (value=$value)';
}

class Face {
  late Face left, right, top, bottom;
  List<List<Block>> blocks = List.empty(growable: true);

  final int _width, _height;
  bool _isShifting = false;

  int get width => _width;

  int get height => _height;

  Face(int width, int height, String id)
      : _width = width,
        _height = height {
    for (int r = 0; r < height; r++) {
      List<Block> row = List.empty(growable: true);
      for (int c = 0; c < width; c++) {
        row.add(Block("$r-$c ($id)", 0));
      }
      blocks.add(row);
    }
  }

  void init(Face left, Face right, Face top, Face bottom) {
    this.left = left;
    this.right = right;
    this.top = top;
    this.bottom = bottom;
  }

  void shiftUp(int colIndex) {
    top.pushFromBottom(colIndex, blocks.first[colIndex]);
  }

  void shiftDown(int colIndex) {
    bottom.pushFromTop(colIndex, blocks.last[colIndex]);
  }

  void shiftRight(int rowIndex) {
    right.pushFromLeft(rowIndex, blocks[rowIndex].last);
  }

  void shiftLeft(int rowIndex) {
    left.pushFromRight(rowIndex, blocks[rowIndex].first);
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
}

class Cube {
  late Face front;
  int width;
  int height;

  Cube([this.width = 3, this.height = 3]) {
    reset();
  }

  void reset() {
    Face front = Face(width, height, "front");
    Face right = Face(width, height, "right");
    Face back = Face(width, height, "back");
    Face left = Face(width, height, "left");
    Face top = Face(width, height, "top");
    Face bottom = Face(width, height, "bottom");

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

    this.front = front;
  }

  void turnLeft() {
    front = front.right;
  }

  void turnRight() {
    front = front.left;
  }

  void turnUp() {
    front = front.top;
  }

  void turnDown() {
    // for what?!
    front = front.bottom;
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
}
