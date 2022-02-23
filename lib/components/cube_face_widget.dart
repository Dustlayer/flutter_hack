import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/cube.dart';
import '../models/keyboard_meta_keys_manager.dart';

class CubeFace extends StatefulWidget {
  final Cube cube;

  const CubeFace({Key? key, required this.cube}) : super(key: key);

  @override
  _CubeFaceState createState() => _CubeFaceState();
}

class _CubeFaceState extends State<CubeFace> with TickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    duration: const Duration(milliseconds: 500),
    vsync: this,
  );
  List<CubeActionCall> actionQueue = List.empty(growable: true);

  @override
  void initState() {
    _controller.addStatusListener((status) {
      // animation is also completed on first build,
      // so the queue must be empty to react to next queue item
      if (status == AnimationStatus.completed && actionQueue.isNotEmpty) {
        // update cube object and remove action from queue
        setState(() {
          CubeActionCall call = actionQueue[0];
          actionQueue.removeAt(0);
          _controller.reset();
          // update duration for next animation,
          // otherwise duration stays the same from _handleScroll
          _controller.duration = _calcAnimationDuration();
          // update cube after animation played
          widget.cube.executeCubeAction(call);

          widget.cube.checkIntegrity();
        });
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
      setState(() {
        _controller.duration = _calcAnimationDuration();
        _controller.forward(from: 0);
      });
    } else if (actionQueue.length > 1) {
      // accelerate animation, scale with queue length
      _controller.duration = _calcAnimationDuration();
      // call forward() to adopt new duration on the fly
      if (_controller.isAnimating) _controller.forward();
    }
  }

  int _getNextRowIndex(CubeActionCall call, int indexRow, int indexColumn) {
    int result = indexRow;
    if ([CubeAction.turnColumnUp, CubeAction.turnColumnDown].contains(call.action) && call.index == indexColumn) {
      result = call.action == CubeAction.turnColumnUp ? indexRow - 1 : indexRow + 1;
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
    final int cubeWidth = widget.cube.width;
    final int cubeHeight = widget.cube.height;

    CubeActionCall? currentAction = actionQueue.isNotEmpty ? actionQueue[0] : null;
    Widget returnWidget = Center(
      child: AspectRatio(
        aspectRatio: 1,
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final Size biggest = constraints.biggest;
            // 1/x the width, dynamically from the cube height / width
            final double width1X = biggest.width / cubeWidth;
            final double height1X = biggest.height / cubeHeight;
            return Stack(
              clipBehavior: Clip.antiAlias,
              children: List.generate(
                cubeWidth * cubeHeight,
                (index) {
                  final int indexRow = index ~/ cubeWidth;
                  final int indexColumn = index % cubeWidth;
                  final Block block = widget.cube.front.blocks[indexRow][indexColumn];
                  int nextIndexRow = indexRow;
                  int nextIndexColumn = indexColumn;
                  if (currentAction != null) {
                    nextIndexRow = _getNextRowIndex(currentAction, indexRow, indexColumn);
                    nextIndexColumn = _getNextColumnIndex(currentAction, indexRow, indexColumn);
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
                    child: TestCubeTile(block),
                  );
                },
              )
                ..addAll(
                  List.generate(
                    2 * cubeWidth + 2 * cubeWidth,
                    (index) {
                      // generate Tiles outside Bounds of cube
                      Block block = Block("Dummy-ID", 0);
                      int indexRow = -1;
                      int indexColumn = -1;
                      if (index ~/ cubeWidth == 0) {
                        // in row above first row
                        indexRow = -1;
                        indexColumn = index % cubeWidth;
                        block = widget.cube.front.top.blocks[cubeHeight - 1][indexColumn];
                      } else if (index < cubeWidth + 2 * cubeHeight) {
                        // left and right side outside of cube
                        int normalizedIndex = index - cubeWidth;
                        indexRow = normalizedIndex ~/ 2;
                        indexColumn = normalizedIndex % 2 == 0 ? -1 : cubeWidth;
                        block = indexColumn == -1
                            ? widget.cube.front.left.blocks[indexRow][cubeWidth - 1]
                            : widget.cube.front.right.blocks[indexRow][0];
                      } else {
                        // row below cube
                        int normalizedIndex = index - cubeWidth - 2 * cubeHeight;
                        indexRow = cubeHeight;
                        indexColumn = normalizedIndex % cubeWidth;
                        block = widget.cube.front.bottom.blocks[0][indexColumn];
                      }
                      int nextIndexRow = indexRow;
                      int nextIndexColumn = indexColumn;
                      if (currentAction != null) {
                        nextIndexRow = _getNextRowIndex(currentAction, indexRow, indexColumn);
                        nextIndexColumn = _getNextColumnIndex(currentAction, indexRow, indexColumn);
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
                        child: TestCubeTile(block),
                      );
                    },
                  ),
                )
                ..addAll(List.generate(cubeHeight * cubeWidth, (index) {
                  // add (Scroll-)Listeners to render over all tiles
                  final int indexRow = index ~/ cubeWidth;
                  final int indexColumn = index % cubeWidth;
                  return Positioned(
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
                })),
            );
          },
        ),
      ),
    );
    // start animation, statusListener will handle state update
    if (currentAction != null) {
      _controller.forward(from: 0);
    }
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
          color: Color(_block.value),
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
