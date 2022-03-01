// ignore_for_file: avoid_print

///
/// Currently unused;; only for reference
import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hack/models/cube.dart';
import 'package:flutter_hack/models/keyboard_meta_keys_manager.dart';
import 'package:provider/provider.dart';

import 'cube_face_widget.dart';

class CubeWidget extends StatefulWidget {
  final Cube the_cube;

  final Key cubeKey = const ValueKey("cube");
  final Key cubeTransitionKey = const ValueKey("cube");
  final Key nextCubeKey = const ValueKey("nextCube");
  final Key nextCubeTransitionKey = const ValueKey("nextCube");

  const CubeWidget({Key? key, required this.the_cube}) : super(key: key);

  @override
  _CubeWidgetState createState() => _CubeWidgetState();
}

class _CubeWidgetState extends State<CubeWidget> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 500),
  );
  late Face currentFace;
  Face? nextFace;

  int _turnYDirection = 0;
  int _turnXDirection = 0;

  // values will be overriden when animation starts
  FractionalOffset _frontAnimationAlignment = FractionalOffset.centerRight;
  FractionalOffset _nextAnimationAlignment = FractionalOffset.centerLeft;

  late final Animation<double> animation = CurvedAnimation(
    parent: _controller,
    curve: Curves.linear,
  );

  void _rotateToRight() {
    setState(() {
      nextFace = widget.the_cube.rotateLeft();

      _turnYDirection = 0;
      _turnXDirection = -1;
      _frontAnimationAlignment = FractionalOffset.centerRight;
      _nextAnimationAlignment = FractionalOffset.centerLeft;
      _controller.forward(from: 0.0);
    });
  }

  void _rotateToLeft() {
    setState(() {
      nextFace = widget.the_cube.rotateRight();
      _turnYDirection = 0;
      _turnXDirection = 1;
      _frontAnimationAlignment = FractionalOffset.centerLeft;
      _nextAnimationAlignment = FractionalOffset.centerRight;
      _controller.forward(from: 0.0);
    });
  }

  void _rotateToTop() {
    setState(() {
      nextFace = widget.the_cube.rotateDown();
      _turnYDirection = -1;
      _turnXDirection = 0;
      _frontAnimationAlignment = FractionalOffset.topCenter;
      _nextAnimationAlignment = FractionalOffset.bottomCenter;
      _controller.forward(from: 0.0);
    });
  }

  void _rotateToBottom() {
    setState(() {
      nextFace = widget.the_cube.rotateUp();
      _turnYDirection = 1;
      _turnXDirection = 0;
      _frontAnimationAlignment = FractionalOffset.bottomCenter;
      _nextAnimationAlignment = FractionalOffset.topCenter;
      _controller.forward(from: 0.0);
    });
  }

  @override
  void initState() {
    currentFace = widget.the_cube.front;
    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          // set widget.cube via parent
          currentFace = nextFace!;
          nextFace = null;
          // commented for performance reasons
          // widget.cube.checkIntegrity();

          // set data according to the desired state after animation
          _turnYDirection = 0;
          _turnXDirection = 0;
          _controller.reset();
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

  void _handleScroll(double direction) {
    if (animation.status == AnimationStatus.forward) {
      // dismiss scroll if animation is running
      return;
    }
    KeyboardMetaKeysManager manager = Provider.of<KeyboardMetaKeysManager>(context, listen: false);
    if (manager.isAltPressed) {
      if (manager.isShiftPressed) {
        if (direction.isNegative) {
          _rotateToRight();
        } else {
          _rotateToLeft();
        }
      } else {
        if (direction.isNegative) {
          _rotateToBottom();
        } else {
          _rotateToTop();
        }
      }
    }
  }

  Block _handleSliceMove(CubeActionCall action) {
    return widget.the_cube.executeCubeAction(action);
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Stack(
        clipBehavior: Clip.antiAlias,
        children: <Widget>[
          AnimatedBuilder(
            key: widget.cubeTransitionKey,
            animation: _controller,
            child: CubeFace(
              key: widget.cubeKey,
              face: currentFace,
              isFrontFace: true,
              onAction: _handleSliceMove,
            ),
            builder: (BuildContext context, Widget? child) {
              Matrix4 transform = Matrix4.identity()..setEntry(3, 2, 0.003);
              if (_turnXDirection != 0) {
                transform.rotateY(pi / 2 * animation.value * -_turnXDirection);
              } else if (_turnYDirection != 0) {
                transform.rotateX(pi / 2 * animation.value * -_turnYDirection);
              }
              return SlideTransition(
                key: widget.cubeTransitionKey,
                position: Tween<Offset>(
                  begin: Offset.zero,
                  end: Offset(1.0 * _turnXDirection, -1.0 * _turnYDirection),
                ).animate(animation),
                child: Container(
                  color: Colors.transparent,
                  child: Transform(
                    transform: transform,
                    alignment: _frontAnimationAlignment,
                    child: child,
                  ),
                ),
              );
            },
          ),
          if (nextFace != null)
            AnimatedBuilder(
              key: widget.nextCubeTransitionKey,
              animation: _controller,
              child: CubeFace(
                key: widget.nextCubeKey,
                face: nextFace!,
                isFrontFace: false,
                onAction: _handleSliceMove,
              ),
              builder: (BuildContext context, Widget? child) {
                Matrix4 transform = Matrix4.identity()..setEntry(3, 2, 0.003);
                if (_turnXDirection != 0) {
                  transform.rotateY(pi / 2 * (animation.value - 1) * -_turnXDirection);
                } else if (_turnYDirection != 0) {
                  transform.rotateX(pi / 2 * (animation.value - 1) * -_turnYDirection);
                }
                return SlideTransition(
                  key: widget.nextCubeTransitionKey,
                  position: Tween<Offset>(
                    begin: Offset(-1.0 * _turnXDirection, 1.0 * _turnYDirection),
                    end: Offset.zero,
                  ).animate(animation),
                  child: Container(
                    color: Colors.transparent,
                    child: Transform(
                      transform: transform,
                      alignment: _nextAnimationAlignment,
                      child: child,
                    ),
                  ),
                );
              },
            ),
          Positioned.fill(
            child: Listener(
              behavior: HitTestBehavior.translucent,
              onPointerSignal: (pointerSignal) {
                if (pointerSignal is PointerScrollEvent) {
                  _handleScroll(pointerSignal.scrollDelta.direction);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
