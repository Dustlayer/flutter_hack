// ignore_for_file: avoid_print

import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'models/models.dart';
import 'navigation/page_routes.dart';
import 'screens/screens.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  final routerDelegate = BeamerDelegate(
    locationBuilder: RoutesLocationBuilder(
      routes: {
        PageRoutes.home: (context, state, data) => HomeScreen(),
        PageRoutes.leaderboard: (context, state, data) => LeaderboardScreen(),
        // '/play': (context, state, data) => PlayScreen(),
        PageRoutes.singleplayer: (context, state, data) => CubeTestWidget(Cube()),
        PageRoutes.multiplayer: (context, state, data) => PlayMultiplayerScreen(),
        PageRoutes.multiplayerGame: (context, state, data) => PlayMultiplayerScreen(
              gameId: state.pathParameters['gameId'],
            ),
      },
    ),
  );

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => MatchHistoryManager()),
      ],
      child: MaterialApp.router(
        title: 'Flutter Puzzle Hack',
        theme: ThemeData(
          primarySwatch: Colors.green,
        ),
        routerDelegate: routerDelegate,
        routeInformationParser: BeamerParser(),
        backButtonDispatcher: BeamerBackButtonDispatcher(delegate: routerDelegate),
      ),
    );
  }
}

// todo: move below to own files
const TextStyle _kButtonTextStyle = TextStyle(fontSize: 30);
const double _kDummySpacing = 160.0;

/// widget to display all faces of the cube
/// Used to test the cube ^.^
class CubeTestWidget extends StatefulWidget {
  final Cube cube;

  const CubeTestWidget(this.cube, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => CubeTestWidgetState();
}

class CubeTestWidgetState extends State<CubeTestWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // cube
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                // dummy containers for spacing;; hardcoded cuz lazy and this is just for testing
                Container(height: _kDummySpacing),
                buildFace(widget.cube.front.left),
              ], // left
            ),
            Column(
              children: [
                buildFace(widget.cube.front.top), // top
                buildFace(widget.cube.front, true), // front
                buildFace(widget.cube.front.bottom), // bottom
                buildFace(widget.cube.front.bottom.bottom), // back
              ], // front
            ),
            Column(
              children: [
                Container(height: _kDummySpacing),
                buildFace(widget.cube.front.right),
              ], // right
            ),
            Column(
              children: [
                Container(height: _kDummySpacing),
                buildFace(widget.cube.front.right.right),
              ], // back
            )
          ],
        ),

        // filler
        Expanded(
          child: Container(),
        ),

        // controls
        Container(
          color: Colors.grey,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              MaterialButton(
                  child: const Text("Reset"),
                  onPressed: () {
                    setState(() {
                      widget.cube.reset();
                    });
                  }),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildFace(Face face, [bool addMoveButtons = false]) {
    return Container(
      margin: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blueAccent),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Up button row
          if (addMoveButtons)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: List.generate(face.width + 2, (index) {
                if (index == 0 || index == face.width + 1) {
                  // filler for corners
                  return const MaterialButton(
                    child: Text(""),
                    onPressed: null,
                  );
                }
                return MaterialButton(
                  child: const Text(
                    "^",
                    style: _kButtonTextStyle,
                  ),
                  onPressed: () {
                    setState(() {
                      int ndx = index - 1;
                      print("Move up (col=$ndx})");
                      widget.cube.turnColumnUp(ndx);
                    });
                  },
                );
              }).toList(),
            ),

          // actual rows;; see https://stackoverflow.com/a/54995553
          ...face.blocks.asMap().map((i, r) => MapEntry(i, buildRow(i, r, addMoveButtons))).values.toList(),

          // Down button row
          if (addMoveButtons)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: List.generate(face.width + 2, (index) {
                if (index == 0 || index == face.width + 1) {
                  // filler for corners
                  return const MaterialButton(
                    child: Text(""),
                    onPressed: null,
                  );
                }

                // actual move buttons
                return MaterialButton(
                  child: const Text(
                    "v",
                    style: _kButtonTextStyle,
                  ),
                  onPressed: () {
                    setState(() {
                      int ndx = index - 1;
                      print("Move down (col=$ndx})");
                      widget.cube.turnColumnDown(ndx);
                    });
                  },
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget buildRow(int index, List<Block> fromRow, bool addMoveButtons) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // move left button
        if (addMoveButtons)
          MaterialButton(
            child: const Text(
              "<",
              style: _kButtonTextStyle,
            ),
            onPressed: () {
              setState(() {
                print("Move row left (row=$index)");
                widget.cube.turnRowLeft(index);
              });
            },
          ),

        // actual blocks
        ...fromRow.map((b) => BlockButton(b)).toList(),

        // move right button
        if (addMoveButtons)
          MaterialButton(
            child: const Text(
              ">",
              style: _kButtonTextStyle,
            ),
            onPressed: () {
              setState(() {
                print("Move row right (row=$index)");
                widget.cube.turnRowRight(index);
              });
            },
          ),
      ],
    );
  }
}

class BlockButton extends StatelessWidget {
  final VoidCallback? onPressed = null; // tmp
  final Block _block;

  const BlockButton(this._block, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialButton(onPressed: onPressed, child: Text(_block.id));
  }
}

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

  Cube() {
    reset();
  }

  void reset() {
    Face front = Face(3, 3, "front");
    Face right = Face(3, 3, "right");
    Face back = Face(3, 3, "back");
    Face left = Face(3, 3, "left");
    Face top = Face(3, 3, "top");
    Face bottom = Face(3, 3, "bottom");

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
