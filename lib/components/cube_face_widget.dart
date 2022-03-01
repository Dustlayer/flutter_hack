import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/cube.dart';
import '../models/keyboard_meta_keys_manager.dart';

class CubeFace extends StatefulWidget {
  final Face face;
  final bool isFrontFace;
  final Block Function(CubeActionCall) onAction;

  const CubeFace({Key? key, required this.face, required this.isFrontFace, required this.onAction}) : super(key: key);

  @override
  _CubeFaceState createState() => _CubeFaceState();
}

class _CubeFaceState extends State<CubeFace> with TickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    duration: const Duration(milliseconds: 500),
    vsync: this,
  );
  List<CubeActionCall> actionQueue = List.empty(growable: true);
  Block? nextBlock;
  CubeActionCall? nextAction;

  @override
  void initState() {
    _controller.addStatusListener((status) {
      // animation is also completed on first build,
      // so the queue must be empty to react to next queue item
      if (status == AnimationStatus.completed && actionQueue.isNotEmpty) {
        // update cube object and remove action from queue
        startNextAnimaton();
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Duration _calcAnimationDuration({int offset = 0}) {
    final int calcDuration = (200 * pow(e, -(actionQueue.length - 1 - offset)) + 50).round();
    return Duration(milliseconds: calcDuration);
  }

  void _handleScroll(double direction, int rowIndex, int columnIndex) {
    KeyboardMetaKeysManager manager = Provider.of<KeyboardMetaKeysManager>(context, listen: false);
    bool scrolledUp = direction > 0 ? true : false;

    if (manager.isAltPressed) {
      // Cube should be turned, so ignore Scroll
      return;
    }

    if (manager.isShiftPressed && scrolledUp) {
      actionQueue.add(CubeActionCall(CubeAction.turnRowRight, rowIndex));
    } else if (manager.isShiftPressed && !scrolledUp) {
      actionQueue.add(CubeActionCall(CubeAction.turnRowLeft, rowIndex));
    } else if (!manager.isShiftPressed && scrolledUp) {
      actionQueue.add(CubeActionCall(CubeAction.turnColumnDown, columnIndex));
    } else if (!manager.isShiftPressed && !scrolledUp) {
      actionQueue.add(CubeActionCall(CubeAction.turnColumnUp, columnIndex));
    }

    // start animation if queue was empty before
    if (actionQueue.length == 1) {
      startNextAnimaton();
    } else if (actionQueue.length > 1) {
      // accelerate animation, scale with queue length
      _controller.duration = _calcAnimationDuration();
      // call forward() to adopt new duration on the fly
      if (_controller.isAnimating) _controller.forward();
    }
  }

  void startNextAnimaton() {
    setState(() {
      if (actionQueue.isNotEmpty) {
        nextAction = actionQueue.removeAt(0);
        nextBlock = widget.onAction(nextAction!);

        // reset controller
        _controller.duration = _calcAnimationDuration();
        _controller.forward(from: 0);

        // set directions
      } else {
        _controller.reset();
        nextBlock = null;
        nextAction = null;
      }

      void printGrid<T>(List<List<T>> grid) {
        for (int i = 0; i < grid.length; i++) {
          String line = "";
          for (int j = 0; j < grid.length; j++) {
            line += "${grid[j][i]}  ";
          }

          print(line);
        }
      }
      printGrid(widget.face.blocks);
    });
  }

  int _getNextRowIndex(CubeActionCall call, int indexRow, int indexColumn) {
    int result = indexRow;
    if ([CubeAction.turnColumnUp, CubeAction.turnColumnDown].contains(call.action) && call.index == indexColumn) {
      result = call.action == CubeAction.turnColumnUp ? indexRow + 1 : indexRow - 1;
    }
    return result;
  }

  int _getNextColumnIndex(CubeActionCall call, int indexRow, int indexColumn) {
    int result = indexColumn;
    if ([CubeAction.turnRowLeft, CubeAction.turnRowRight].contains(call.action) && call.index == indexRow) {
      result = call.action == CubeAction.turnRowRight ? indexColumn + 1 : indexColumn - 1;
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    const int cubeWidth = kSIZE;
    const int cubeHeight = kSIZE;

    // CubeActionCall? currentAction = actionQueue.isNotEmpty ? actionQueue[0] : null;

    Widget returnWidget = Center(
      child: AspectRatio(
        aspectRatio: 1,
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final Size biggest = constraints.biggest;
            // 1/x the width, dynamically from the cube height / width
            final double width1X = biggest.width / cubeWidth;
            final double height1X = biggest.height / cubeHeight;
            List<Widget> stackChildren = List.empty(growable: true);
            // add default cube face to stack
            stackChildren.addAll(
              List.generate(
                cubeWidth * cubeHeight,
                (index) {
                  final int indexRow = index ~/ cubeWidth;
                  final int indexColumn = index % cubeWidth;
                  final Block block = widget.face.blocks[indexColumn][indexRow];
                  int nextIndexRow = indexRow;
                  int nextIndexColumn = indexColumn;
                  if (nextBlock != null) {
                    nextIndexRow = _getNextRowIndex(nextAction!, indexRow, indexColumn);
                    nextIndexColumn = _getNextColumnIndex(nextAction!, indexRow, indexColumn);
                  }
                  return PositionedTransition(
                    // key: ObjectKey(block),
                    rect: RelativeRectTween(
                      begin: RelativeRect.fromLTRB(
                        indexColumn * width1X,
                        indexRow * height1X,
                        (cubeWidth - 1 - indexColumn) * width1X,
                        (cubeHeight - 1 - indexRow) * height1X,
                      ),
                      end: RelativeRect.fromLTRB(
                        nextIndexColumn * width1X,
                        nextIndexRow * height1X,
                        (cubeWidth - 1 - nextIndexColumn) * width1X,
                        (cubeHeight - 1 - nextIndexRow) * height1X,
                      ),
                    ).animate(CurvedAnimation(
                      parent: _controller,
                      curve: Curves.easeInOutQuart,
                    )),
                    child: TestCubeTile(block, key: ValueKey(index)),
                  );
                },
              ),
            );
            // add blocks out of bounds and scrollHandlers if this is the front facing cube side
            if (widget.isFrontFace) {
              // add out of bounds blocks
              stackChildren.addAll(
                List.generate(
                  2 * cubeWidth + 2 * cubeWidth,
                  (index) {
                    // generate Tiles outside Bounds of cube;
                    int indexRow = -1;
                    int indexColumn = -1;
                    if (index ~/ cubeWidth == 0) {
                      // in row above first row
                      indexRow = -1;
                      indexColumn = index % cubeWidth;
                    } else if (index < cubeWidth + 2 * cubeHeight) {
                      // left and right side outside of cube
                      int normalizedIndex = index - cubeWidth;
                      indexRow = normalizedIndex ~/ 2;
                      indexColumn = normalizedIndex % 2 == 0 ? -1 : cubeWidth;
                    } else {
                      // row below cube
                      int normalizedIndex = index - cubeWidth - 2 * cubeHeight;
                      indexRow = cubeHeight;
                      indexColumn = normalizedIndex % cubeWidth;
                    }
                    int nextIndexRow = indexRow;
                    int nextIndexColumn = indexColumn;
                    if (nextAction != null) {
                      nextIndexRow = _getNextRowIndex(nextAction!, indexRow, indexColumn);
                      nextIndexColumn = _getNextColumnIndex(nextAction!, indexRow, indexColumn);
                    }

                    Block block = nextBlock ?? Block("Dummy-Id");

                    return PositionedTransition(
                      // key: ObjectKey(block),
                      rect: RelativeRectTween(
                        begin: RelativeRect.fromLTRB(
                          indexColumn * width1X,
                          indexRow * height1X,
                          (cubeWidth - 1 - indexColumn) * width1X,
                          (cubeHeight - 1 - indexRow) * height1X,
                        ),
                        end: RelativeRect.fromLTRB(
                          nextIndexColumn * width1X,
                          nextIndexRow * height1X,
                          (cubeWidth - 1 - nextIndexColumn) * width1X,
                          (cubeHeight - 1 - nextIndexRow) * height1X,
                        ),
                      ).animate(CurvedAnimation(
                        parent: _controller,
                        curve: Curves.easeInOutQuart,
                      )),
                      child: TestCubeTile(block, key: ValueKey(index)),
                    );
                  },
                ),
              );
              // add scroll handlers
              stackChildren.addAll(
                List.generate(
                  cubeHeight * cubeWidth,
                  (index) {
                    // add (Scroll-)Listeners to render over all tiles
                    final int indexRow = index ~/ cubeWidth;
                    final int indexColumn = index % cubeWidth;
                    return Positioned(
                      key: ValueKey(index),
                      left: indexColumn * width1X,
                      top: indexRow * height1X,
                      right: (cubeWidth - 1 - indexColumn) * width1X,
                      bottom: (cubeHeight - 1 - indexRow) * height1X,
                      child: Listener(
                        behavior: HitTestBehavior.opaque,
                        onPointerSignal: (pointerSignal) {
                          if (pointerSignal is PointerScrollEvent) {
                            _handleScroll(pointerSignal.scrollDelta.direction, indexRow, indexColumn);
                          }
                        },
                      ),
                    );
                  },
                ),
              );
            }
            return Stack(
              clipBehavior: Clip.antiAlias,
              children: stackChildren,
            );
          },
        ),
      ),
    );
    return returnWidget;
  }
}

class TestCubeTile extends StatelessWidget {
  final Block _block;

  const TestCubeTile(this._block, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(),
          borderRadius: BorderRadius.circular(15),
          color: Colors.lightBlue,
        ),
        alignment: Alignment.center,
        child: Text(
          _block.id,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 35),
        ),
      ),
    );
  }
}
