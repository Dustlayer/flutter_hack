// ignore_for_file: avoid_print

///
/// Currently unused;; only for reference
import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hack/models/cube.dart';

class CubeWidget extends StatefulWidget {
  Cube cube;

  CubeWidget({Key? key, required this.cube}) : super(key: key);

  @override
  _CubeWidgetState createState() => _CubeWidgetState();
}

class _CubeWidgetState extends State<CubeWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));
  double _sliderValue = 0.0;

  late final Animation<double> animation = CurvedAnimation(
    parent: _controller,
    curve: Curves.linear,
  );

  @override
  void initState() {
    _controller.repeat(reverse: true);
    animation.addListener(() {
      setState(() {
        _sliderValue = animation.value;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
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
                    end: Offset(-1.0, 0.0),
                  ).animate(animation),
                  child: Container(
                    color: Colors.white,
                    child: Transform(
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.003)
                        ..rotateY(pi / 2 * animation.value),
                      alignment: FractionalOffset.centerRight,
                      // child: TestStack(key: const ValueKey(1), cube: widget.cube),
                      child: Container(
                        color: Colors.lightGreen,
                      ),
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
                      // child: TestStack(key: const ValueKey(2), cube: Cube.fromFace(widget.cube.front.right)),
                      child: Container(
                        color: Colors.lightBlue,
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: Slider(
            value: _sliderValue,
            max: 1.0,
            label: _sliderValue.round().toString(),
            onChanged: (double value) {
              setState(() {
                _sliderValue = value;
                _controller.value = _sliderValue;
              });
            },
          ),
        ),
      ],
    );
  }
}
