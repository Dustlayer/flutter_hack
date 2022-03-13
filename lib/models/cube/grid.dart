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
    return _data[nx][ny]!;
  }

  void set(int x, int y, T value) {
    _data[normalizeX(x)][normalizeY(y)] = value;
  }

  int normalizeX(int x) {
    return x + width ~/ 2;
  }

  int normalizeY(int y) {
    return y + height ~/ 2;
  }
}
