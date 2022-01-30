import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hack/models/cube.dart';
import 'package:flutter_hack/models/keyboard_meta_keys_manager.dart';
import 'package:provider/provider.dart';

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
          ...face.blocks
              .asMap()
              .map((i, r) => MapEntry(i, buildRow(i, r, addMoveButtons)))
              .values
              .toList(),

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
        ...fromRow.map((b) => BlockTestButton(b)).toList(),

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

class BlockTestButton extends StatelessWidget {
  final VoidCallback? onPressed = null; // tmp
  final Block _block;

  const BlockTestButton(this._block, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(border: Border.all()),
        child: Listener(
            onPointerSignal: (pointerSignal) {
              if (pointerSignal is PointerScrollEvent) {
                bool isShiftPressed =
                    Provider.of<KeyboardMetaKeysManager>(context, listen: false)
                        .isShiftPressed;
                print(
                    'Scrolled, ScrollDelta: ${pointerSignal.scrollDelta.direction}, ShiftPressed: $isShiftPressed');
              }
            },
            child:
                MaterialButton(onPressed: onPressed, child: Text(_block.id))));
  }
}

class CubeWidget extends StatefulWidget {
  final Cube _cube;

  const CubeWidget(this._cube, {Key? key}) : super(key: key);

  @override
  _CubeWidgetState createState() => _CubeWidgetState();
}

class _CubeWidgetState extends State<CubeWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(widget._cube.height, (indexRow) {
        return Expanded(
          child: Row(
            children: List.generate(widget._cube.width, (indexColumn) {
              Block block = widget._cube.front.blocks[indexRow][indexColumn];
              return Expanded(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: BlockButton(
                    block,
                    onScroll: (double direction) =>
                        _handleScroll(direction, indexRow, indexColumn),
                  ),
                ),
              );
            }),
          ),
        );
      }),
    );
  }

  void _handleScroll(double direction, int rowIndex, int columnIndex) {
    bool isShiftPressed =
        Provider.of<KeyboardMetaKeysManager>(context, listen: false)
            .isShiftPressed;
    bool scrolledUp = direction > 0 ? true : false;
    if (isShiftPressed && scrolledUp) {
      setState(() {
        widget._cube.turnRowRight(rowIndex);
      });
    } else if (isShiftPressed && !scrolledUp) {
      setState(() {
        widget._cube.turnRowLeft(rowIndex);
      });
    } else if (!isShiftPressed && scrolledUp) {
      setState(() {
        widget._cube.turnColumnDown(columnIndex);
      });
    } else if (!isShiftPressed && !scrolledUp) {
      setState(() {
        widget._cube.turnColumnUp(columnIndex);
      });
    }
  }
}

class BlockButton extends StatelessWidget {
  final Function(double scrollDirection) onScroll; // tmp
  final Block _block;

  const BlockButton(this._block, {Key? key, required this.onScroll})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(border: Border.all()),
      child: Listener(
        onPointerSignal: (pointerSignal) {
          if (pointerSignal is PointerScrollEvent) {
            bool isShiftPressed =
                Provider.of<KeyboardMetaKeysManager>(context, listen: false)
                    .isShiftPressed;
            print(
                'Scrolled, ScrollDelta: ${pointerSignal.scrollDelta.direction}, ShiftPressed: $isShiftPressed');
            onScroll(pointerSignal.scrollDelta.direction);
          }
        },
        child: Center(
          child: Text(
            _block.id,
            style: const TextStyle(fontSize: 45),
          ),
        ),
      ),
    );
  }
}
