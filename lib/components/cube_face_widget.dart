import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hack/constants.dart';
import 'package:flutter_hack/models/cube/block.dart';
import 'package:flutter_hack/models/cube/face_view.dart';
import 'package:flutter_hack/models/cube/slice_move.dart';
import 'package:flutter_hack/models/keyboard_meta_keys_manager.dart';
import 'package:flutter_hack/vector_math.dart';
import 'package:provider/provider.dart';

class CubeFace extends StatefulWidget {
  final FaceView face;
  final bool isFrontFace;
  final void Function(SliceMove) onAction;
  final void Function() onEndMove;
  final Block Function(SliceMove) onNextBlock;

  const CubeFace(
      {Key? key,
      required this.face,
      required this.isFrontFace,
      required this.onAction,
      required this.onNextBlock,
      required this.onEndMove})
      : super(key: key);

  @override
  _CubeFaceState createState() => _CubeFaceState();
}

class _CubeFaceState extends State<CubeFace> with TickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    duration: const Duration(milliseconds: 500),
    vsync: this,
  );
  late final CurvedAnimation _curvedAnimation = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeInOutQuart,
  );
  List<SliceMove> actionQueue = List.empty(growable: true);
  Block? nextBlock;
  SliceMove? nextAction;

  @override
  void initState() {
    _controller.addStatusListener((status) {
      // animation is also completed on first build,
      // so the queue must be empty to react to next queue item
      if (status == AnimationStatus.completed && actionQueue.isNotEmpty) {
        // update cube object and remove action from queue
        setState(() {
          SliceMove call = actionQueue.removeAt(0);
          _controller.reset();
          // update duration for next animation,
          // otherwise duration stays the same from _handleScroll
          _controller.duration = _calcAnimationDuration();
          // update cube after animation played
          widget.onAction(call);
          // callback to signal that last move was done (for victory check)
          if (actionQueue.isEmpty) {
            widget.onEndMove();
          }
        });
      } else if (status == AnimationStatus.completed && actionQueue.isEmpty) {
        _controller.reset();
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

    SliceMove? move;
    if (manager.isShiftPressed && scrolledUp) {
      // actionQueue.add(CubeActionCall(CubeAction.turnRowRight, rowIndex));
      move = SliceMove.left(rowIndex);
    } else if (manager.isShiftPressed && !scrolledUp) {
      // actionQueue.add(CubeActionCall(CubeAction.turnRowLeft, rowIndex));
      move = SliceMove.right(rowIndex);
    } else if (!manager.isShiftPressed && scrolledUp) {
      // actionQueue.add(CubeActionCall(CubeAction.turnColumnUp, columnIndex));
      move = SliceMove.down(columnIndex);
    } else if (!manager.isShiftPressed && !scrolledUp) {
      // actionQueue.add(CubeActionCall(CubeAction.turnColumnDown, columnIndex));
      move = SliceMove.up(columnIndex);
    }

    if (move != null) {
      actionQueue.add(move);
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

  int _getNewBlockStartRowIndex(SliceMove move) {
    if (move.axis == IVec.DOWN) {
      return -1;
    } else if (move.axis == IVec.UP) {
      return kSize;
    } else if (move.axis == IVec.RIGHT || move.axis == IVec.LEFT) {
      return move.rawIndex;
    }
    throw kForked;
  }

  int _getNewBlockStartColumnIndex(SliceMove move) {
    if (move.axis == IVec.RIGHT) {
      return -1;
    } else if (move.axis == IVec.LEFT) {
      return kSize;
    } else if (move.axis == IVec.UP || move.axis == IVec.DOWN) {
      return move.rawIndex;
    }
    throw kForked;
  }

  int _getNextRowIndex(SliceMove call, int indexRow, int indexColumn) {
    int result = indexRow;
    if ((call.axis == IVec.UP || call.axis == IVec.DOWN) && call.rawIndex == indexColumn) {
      result = call.axis == IVec.DOWN ? indexRow + 1 : indexRow - 1;
    }
    return result;
  }

  int _getNextColumnIndex(SliceMove call, int indexRow, int indexColumn) {
    int result = indexColumn;
    if ((call.axis == IVec.RIGHT || call.axis == IVec.LEFT) && call.rawIndex == indexRow) {
      result = call.axis == IVec.RIGHT ? indexColumn + 1 : indexColumn - 1;
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    const int cubeWidth = kSize;
    const int cubeHeight = kSize;

    if (actionQueue.isNotEmpty) {
      nextAction = actionQueue[0];
      nextBlock = widget.onNextBlock(nextAction!);
    } else {
      nextAction = null;
      nextBlock = null;
    }

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
                  final Block block = widget.face.getBlockAt(indexColumn, indexRow);
                  int nextIndexRow = indexRow;
                  int nextIndexColumn = indexColumn;
                  if (nextBlock != null) {
                    nextIndexRow = _getNextRowIndex(nextAction!, indexRow, indexColumn);
                    nextIndexColumn = _getNextColumnIndex(nextAction!, indexRow, indexColumn);
                  }
                  return PositionedTransition(
                    key: ObjectKey(block),
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
                    ).animate(_curvedAnimation),
                    child: TestCubeTile(block, key: ValueKey(index)),
                  );
                },
              ),
            );
            // add incoming block
            if (nextAction != null) {
              // add incoming block
              int indexRow = _getNewBlockStartRowIndex(nextAction!);
              int indexColumn = _getNewBlockStartColumnIndex(nextAction!);
              int nextIndexRow = _getNextRowIndex(nextAction!, indexRow, indexColumn);
              int nextIndexColumn = _getNextColumnIndex(nextAction!, indexRow, indexColumn);

              stackChildren.add(
                PositionedTransition(
                  key: ObjectKey(nextBlock),
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
                  ).animate(_curvedAnimation),
                  child: TestCubeTile(nextBlock!, key: ObjectKey(nextBlock)),
                ),
              );
            }
            // add scrollHandlers if this is the front facing cube side
            if (widget.isFrontFace) {
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
    if (nextAction != null) {
      _controller.duration = _calcAnimationDuration();
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
          color: Colors.lightBlue,
        ),
        alignment: Alignment.center,
        child: Text(
          _block.toString(),
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 35),
        ),
      ),
    );
  }
}
