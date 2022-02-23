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
  final Cube cube;
  
  final Key cubeKey = const ValueKey("cube");
  final Key cubeTransitionKey = const ValueKey("cube");
  final Key nextCubeKey = const ValueKey("nextCube");
  final Key nextCubeTransitionKey = const ValueKey("nextCube");

  const CubeWidget({Key? key, required this.cube}) : super(key: key);

  @override
  _CubeWidgetState createState() => _CubeWidgetState();
}

class _CubeWidgetState extends State<CubeWidget> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1000),
  );
  Cube? _nextCube;
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
    _nextCube = widget.cube.deepCopy();
    _nextCube!.turnLeft();
    _turnYDirection = 0;
    _turnXDirection = -1;
    _frontAnimationAlignment = FractionalOffset.centerRight;
    _nextAnimationAlignment = FractionalOffset.centerLeft;
    _controller.forward(from: 0.0);
  }

  void _rotateToLeft() {
    _nextCube = widget.cube.deepCopy();
    _nextCube!.turnRight();
    _turnYDirection = 0;
    _turnXDirection = 1;
    _frontAnimationAlignment = FractionalOffset.centerLeft;
    _nextAnimationAlignment = FractionalOffset.centerRight;
    _controller.forward(from: 0.0);
  }

  void _rotateToTop() {
    _nextCube = widget.cube.deepCopy();
    _nextCube!.turnDown();
    _turnYDirection = -1;
    _turnXDirection = 0;
    _frontAnimationAlignment = FractionalOffset.topCenter;
    _nextAnimationAlignment = FractionalOffset.bottomCenter;
    _controller.forward(from: 0.0);
  }

  void _rotateToBottom() {
    _nextCube = widget.cube.deepCopy();
    _nextCube!.turnUp();
    _turnYDirection = 1;
    _turnXDirection = 0;
    _frontAnimationAlignment = FractionalOffset.bottomCenter;
    _nextAnimationAlignment = FractionalOffset.topCenter;
    _controller.forward(from: 0.0);
  }

  @override
  void initState() {
    animation.addListener(() {
      setState(() {});
    });
    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          // try fix the scroll bug
          widget.cube.front = _nextCube!.front;
          _nextCube = null;

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

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Stack(
        clipBehavior: Clip.antiAlias,
        children: <Widget>[
          SlideTransition(
            key: widget.cubeTransitionKey,
            position: Tween<Offset>(
              begin: Offset.zero,
              end: Offset(1.0 * _turnXDirection, -1.0 * _turnYDirection),
            ).animate(animation),
            child: Container(
              color: Colors.transparent,
              child: Transform(
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.003)
                  ..rotateY(pi / 2 * animation.value * -_turnXDirection)
                  ..rotateX(pi / 2 * animation.value * -_turnYDirection),
                alignment: _frontAnimationAlignment,
                child: CubeFace(key: widget.cubeKey, cube: widget.cube),
              ),
            ),
          ),
          if (_nextCube != null)
            SlideTransition(
              key: widget.nextCubeTransitionKey,
              position: Tween<Offset>(
                begin: Offset(-1.0 * _turnXDirection, 1.0 * _turnYDirection),
                end: Offset.zero,
              ).animate(animation),
              child: Container(
                color: Colors.transparent,
                child: Transform(
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.003)
                    ..rotateY(pi / 2 * (animation.value - 1) * -_turnXDirection)
                    ..rotateX(pi / 2 * (animation.value - 1) * -_turnYDirection),
                  alignment: _nextAnimationAlignment,
                  child: CubeFace(key: widget.nextCubeKey, cube: _nextCube!),
                ),
              ),
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
