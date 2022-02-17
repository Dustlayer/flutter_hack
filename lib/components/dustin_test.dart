// ignore_for_file: avoid_print

///
/// Currently unused;; only for reference
import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hack/models/cube.dart';

import '../screens/play_singleplayer.dart';

class CubeWidget extends StatefulWidget {
  Cube cube;

  CubeWidget({Key? key, required this.cube}) : super(key: key);

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
    _nextCube = Cube.fromFace(widget.cube.front.right);
    _turnYDirection = 0;
    _turnXDirection = -1;
    _frontAnimationAlignment = FractionalOffset.centerRight;
    _nextAnimationAlignment = FractionalOffset.centerLeft;
    _controller.forward(from: 0.0);
  }

  void _rotateToLeft() {
    _nextCube = Cube.fromFace(widget.cube.front.left);
    _turnYDirection = 0;
    _turnXDirection = 1;
    _frontAnimationAlignment = FractionalOffset.centerLeft;
    _nextAnimationAlignment = FractionalOffset.centerRight;
    _controller.forward(from: 0.0);
  }

  void _rotateToTop() {
    _nextCube = Cube.fromFace(widget.cube.front.top);
    _turnYDirection = -1;
    _turnXDirection = 0;
    _frontAnimationAlignment = FractionalOffset.topCenter;
    _nextAnimationAlignment = FractionalOffset.bottomCenter;
    _controller.forward(from: 0.0);
  }

  void _rotateToBottom() {
    _nextCube = Cube.fromFace(widget.cube.front.bottom);
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
          // set data according to the desired state after animation
          widget.cube.front = _nextCube!.front;
          _nextCube = null;
          _turnYDirection = 0;
          _turnXDirection = 0;
          _controller.reset();
        });
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          flex: 2,
          child: Column(
            children: [
              ElevatedButton(
                child: Text('Turn Up'),
                onPressed: () => _rotateToTop(),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    child: Text('Turn Left'),
                    onPressed: () => _rotateToLeft(),
                  ),
                  ElevatedButton(
                    child: Text('Turn Right'),
                    onPressed: () => _rotateToRight(),
                  ),
                ],
              ),
              ElevatedButton(
                child: Text('Turn Down'),
                onPressed: () => _rotateToBottom(),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 5,
          child: AspectRatio(
            aspectRatio: 1,
            child: Stack(
              clipBehavior: Clip.antiAlias,
              children: <Widget>[
                SlideTransition(
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
                      child: CubeFace(key: const ValueKey(1), cube: widget.cube),
                    ),
                  ),
                ),
                if (_nextCube != null)
                  SlideTransition(
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
                        child: CubeFace(key: const ValueKey(2), cube: _nextCube!),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
