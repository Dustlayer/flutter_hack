class Grid<T> {
  final int width, height;
  final List<List<T?>> _data;

  Grid(this.width, this.height, this._data);

  factory Grid.empty(int width, int height) {
    return Grid.generate(width, height, (_, __) => null);
  }

  factory Grid.generate(int width, int height, T? Function(int, int) factory) {
    return Grid(
      width,
      height,
      List.generate(
        width,
        (x) => List.generate(
          height,
          (y) => factory(x - width ~/ 2, y - height ~/ 2),
          growable: false,
        ),
        growable: false,
      ),
    );
  }

  T get(int x, int y) {
    int nx = normalizeX(x);
    int ny = normalizeY(y);

    if (nx < 0 || ny < 0 || width <= nx || height <= ny) {
      assert(false);
    }

    return _data[nx][ny]!;
  }

  void set(int x, int y, T value) {
    int nx = normalizeX(x);
    int ny = normalizeY(y);

    if (nx < 0 || ny < 0 || width <= nx || height <= ny) {
      assert(false);
    }
    _data[nx][ny] = value;
  }

  int normalizeX(int x) {
    return x + width ~/ 2;
  }

  int normalizeY(int y) {
    return y + height ~/ 2;
  }

  bool checkAll(bool Function(T) test) {
    for (List<T?> column in _data) {
      for (T? t in column) {
        if (!test(t!)) return false;
      }
    }
    return true;
  }

  void foreach(void Function(T) f) {
    for (List<T?> column in _data) {
      for (T? t in column) {
        f(t!);
      }
    }
  }
}
