// ignore_for_file: avoid_print

///
/// Currently unused;; only for reference

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hack/models/cube.dart';
import 'package:flutter_hack/models/keyboard_meta_keys_manager.dart';
import 'package:provider/provider.dart';
import 'package:flutter_hack/screens/play_singleplayer.dart';

class CubeWidget extends StatefulWidget {

  Cube cube;

  CubeWidget({Key? key, required this.cube}) : super(key: key);

  @override
  _CubeWidgetState createState() => _CubeWidgetState();
}

class _CubeWidgetState extends State<CubeWidget> with SingleTickerProviderStateMixin {

  late AnimationController _controller = AnimationController

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        SlideTransition(
          position: Tween<Offset>(
            begin: Offset.zero,
            end: Offset(-1.0, 0.0),
          ).animate(animation),
          child: Container(
            color: Colors.white,
            child: Transform(
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.003)
                ..rotateY(pi / 2 * animation.value),
              alignment: FractionalOffset.centerRight,
              child: TestStack(cube: widget.cube),
            ),
          ),
        ),
        SlideTransition(
          position: Tween<Offset>(
            begin: Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(animation),
          child: Container(
            color: Colors.white,
            child: Transform(
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.003)
                ..rotateY(pi / 2 * (animation.value - 1)),
              alignment: FractionalOffset.centerLeft,
              child: TestStack(cube: Cube.fromFace(widget.cube.front.right)),
            ),
          ),
        )
      ],
    );
  }
}
