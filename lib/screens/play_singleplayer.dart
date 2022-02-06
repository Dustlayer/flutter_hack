import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hack/models/cube.dart';
import 'package:flutter_hack/models/keyboard_meta_keys_manager.dart';
import 'package:provider/provider.dart';

class PlaySingleplayerScreen extends StatefulWidget {
  const PlaySingleplayerScreen({Key? key}) : super(key: key);

  @override
  _PlaySingleplayerScreenState createState() => _PlaySingleplayerScreenState();
}

class _PlaySingleplayerScreenState extends State<PlaySingleplayerScreen>
    with SingleTickerProviderStateMixin {
  late final FocusNode focus;
  late final FocusAttachment _nodeAttachment;
  Cube cube = Cube();

  late AnimationController _controller;

  // bool isShiftPressed = false;

  @override
  void initState() {
    super.initState();
    focus = FocusNode(debugLabel: 'ShiftHandler');
    _nodeAttachment = focus.attach(context, onKey: (node, event) {
      Provider.of<KeyboardMetaKeysManager>(context, listen: false)
          .isShiftPressed = event.isShiftPressed;
      return KeyEventResult.handled;
    });
    focus.requestFocus();

    // shift indicator animation
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 125),
    );
  }

  @override
  void dispose() {
    focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _nodeAttachment.reparent();
    return Scaffold(
      body: Column(
        children: [
          const Spacer(flex: 1),
          // Expanded(flex: 4, child: CubeWidget(cube)),
          Expanded(
              flex: 4,
              child: Container(
                  alignment: Alignment.center,
                  decoration:
                      BoxDecoration(border: Border.all(color: Colors.red)),
                  child: TestStack(cube: cube))),
          const Spacer(flex: 1),
          Expanded(
            flex: 1,
            child: Consumer<KeyboardMetaKeysManager>(
              builder: (context, manager, _) {
                if (manager.isShiftPressed) {
                  _controller.forward();
                } else {
                  _controller.animateBack(0.0);
                }
                return RotationTransition(
                  turns: Tween(begin: 0.0, end: 0.25).animate(_controller),
                  child: const FittedBox(
                    fit: BoxFit.fill,
                    child: Icon(Icons.height_rounded),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class TestStack extends StatefulWidget {
  final Cube cube;
  const TestStack({Key? key, required this.cube}) : super(key: key);

  @override
  _TestStackState createState() => _TestStackState();
}

class _TestStackState extends State<TestStack> with TickerProviderStateMixin {
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
    final int calcDuration =
        (200 * pow(e, -(actionQueue.length - 1 - offset)) + 50).round();
    return Duration(milliseconds: calcDuration);
  }

  void _handleScroll(double direction, int rowIndex, int columnIndex) {
    bool isShiftPressed =
        Provider.of<KeyboardMetaKeysManager>(context, listen: false)
            .isShiftPressed;
    bool scrolledUp = direction > 0 ? true : false;
    if (isShiftPressed && scrolledUp) {
      actionQueue.add(CubeActionCall(CubeAction.turnRowRight, rowIndex));
    } else if (isShiftPressed && !scrolledUp) {
      actionQueue.add(CubeActionCall(CubeAction.turnRowLeft, rowIndex));
    } else if (!isShiftPressed && scrolledUp) {
      actionQueue.add(CubeActionCall(CubeAction.turnColumnDown, columnIndex));
    } else if (!isShiftPressed && !scrolledUp) {
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
    if ([CubeAction.turnColumnUp, CubeAction.turnColumnDown]
            .contains(call.action) &&
        call.index == indexColumn) {
      result =
          call.action == CubeAction.turnColumnUp ? indexRow - 1 : indexRow + 1;
    }
    return result;
  }

  int _getNextColumnIndex(CubeActionCall call, int indexRow, int indexColumn) {
    int result = indexColumn;
    if ([CubeAction.turnRowLeft, CubeAction.turnRowRight]
            .contains(call.action) &&
        call.index == indexRow) {
      result = call.action == CubeAction.turnRowRight
          ? indexColumn + 1
          : indexColumn - 1;
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final int cubeWidth = widget.cube.width;
    final int cubeHeight = widget.cube.height;

    CubeActionCall? currentAction =
        actionQueue.isNotEmpty ? actionQueue[0] : null;
    Widget returnWidget = Scaffold(
      body: Container(
        decoration: BoxDecoration(
            border: Border.all(
          color: Colors.amber,
          width: 5,
        )),
        child: AspectRatio(
          aspectRatio: 1,
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              final Size biggest = constraints.biggest;
              // 1/x the width, dynamically from the cube height / width
              final double width1_x = biggest.width / cubeWidth;
              final double height1_x = biggest.height / cubeHeight;
              return Stack(
                clipBehavior: Clip.antiAlias,
                children: List.generate(
                  cubeWidth * cubeHeight,
                  (index) {
                    final int indexRow = index ~/ cubeWidth;
                    final int indexColumn = index % cubeWidth;
                    final Block block =
                        widget.cube.front.blocks[indexRow][indexColumn];
                    int nextIndexRow = indexRow;
                    int nextIndexColumn = indexColumn;
                    if (currentAction != null) {
                      nextIndexRow = _getNextRowIndex(
                          currentAction, indexRow, indexColumn);
                      nextIndexColumn = _getNextColumnIndex(
                          currentAction, indexRow, indexColumn);
                    }
                    return PositionedTransition(
                      key: ValueKey(block),
                      rect: RelativeRectTween(
                        begin: RelativeRect.fromLTRB(
                          indexColumn * width1_x,
                          indexRow * height1_x,
                          (cubeWidth - 1 - indexColumn) * width1_x,
                          (cubeHeight - 1 - indexRow) * height1_x,
                        ),
                        end: RelativeRect.fromLTRB(
                          nextIndexColumn * width1_x,
                          nextIndexRow * height1_x,
                          (cubeWidth - 1 - nextIndexColumn) * width1_x,
                          (cubeHeight - 1 - nextIndexRow) * height1_x,
                        ),
                      ).animate(CurvedAnimation(
                        parent: _controller,
                        curve: Curves.easeInOutQuart,
                      )),
                      child: TestCubeTile(block,
                          onScroll: (double direction) =>
                              _handleScroll(direction, indexRow, indexColumn)),
                    );
                  },
                )..addAll(
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
                          block = widget.cube.front.top.blocks[cubeHeight - 1]
                              [indexColumn];
                        } else if (index < cubeWidth + 2 * cubeHeight) {
                          // left and right side outside of cube
                          int normalizedIndex = index - cubeWidth;
                          indexRow = normalizedIndex ~/ 2;
                          indexColumn =
                              normalizedIndex % 2 == 0 ? -1 : cubeWidth;
                          block = indexColumn == -1
                              ? widget.cube.front.left.blocks[indexRow]
                                  [cubeWidth - 1]
                              : widget.cube.front.right.blocks[indexRow][0];
                        } else {
                          // row below cube
                          int normalizedIndex =
                              index - cubeWidth - 2 * cubeHeight;
                          indexRow = cubeHeight;
                          indexColumn = normalizedIndex % cubeWidth;
                          block =
                              widget.cube.front.bottom.blocks[0][indexColumn];
                        }
                        int nextIndexRow = indexRow;
                        int nextIndexColumn = indexColumn;
                        if (currentAction != null) {
                          nextIndexRow = _getNextRowIndex(
                              currentAction, indexRow, indexColumn);
                          nextIndexColumn = _getNextColumnIndex(
                              currentAction, indexRow, indexColumn);
                        }
                        return PositionedTransition(
                          key: ValueKey(block),
                          rect: RelativeRectTween(
                            begin: RelativeRect.fromLTRB(
                              indexColumn * width1_x,
                              indexRow * height1_x,
                              (cubeWidth - 1 - indexColumn) * width1_x,
                              (cubeHeight - 1 - indexRow) * height1_x,
                            ),
                            end: RelativeRect.fromLTRB(
                              nextIndexColumn * width1_x,
                              nextIndexRow * height1_x,
                              (cubeWidth - 1 - nextIndexColumn) * width1_x,
                              (cubeHeight - 1 - nextIndexRow) * height1_x,
                            ),
                          ).animate(CurvedAnimation(
                            parent: _controller,
                            curve: Curves.easeInOutQuart,
                          )),
                          child: TestCubeTile(block,
                              onScroll: (double direction) => _handleScroll(
                                  direction, indexRow, indexColumn)),
                        );
                      },
                    ),
                  ),
              );
            },
          ),
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
  final Function(double scrollDirection) onScroll;
  final Block _block;

  const TestCubeTile(this._block, {Key? key, required this.onScroll})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerSignal: (pointerSignal) {
        if (pointerSignal is PointerScrollEvent) {
          onScroll(pointerSignal.scrollDelta.direction);
        }
      },
      child: Container(
        decoration: BoxDecoration(border: Border.all()),
        child: Center(
          child: Text(
            _block.id,
            style: const TextStyle(fontSize: 35),
          ),
        ),
      ),
    );
  }
}
