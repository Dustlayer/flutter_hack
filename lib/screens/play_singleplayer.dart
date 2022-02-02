import 'package:flutter/material.dart';
import 'package:flutter_hack/components/cube_widget.dart';
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
          Expanded(flex: 4, child: CubeWidget(cube)),
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
  const TestStack({Key? key}) : super(key: key);

  @override
  _TestStackState createState() => _TestStackState();
}

class _TestStackState extends State<TestStack> with TickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    duration: const Duration(seconds: 2),
    vsync: this,
  )..repeat(reverse: true);

  int width = 300;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              final double width1_3 = biggest.width / 3;
              final double height1_3 = biggest.height / 3;
              return Stack(
                fit: StackFit.expand,
                clipBehavior: Clip.hardEdge,
                children: List.generate(
                  9,
                  (index) {
                    return Positioned(
                      top: index ~/ 3 * height1_3,
                      bottom: (2 - index ~/ 3) * height1_3,
                      left: index % 3 * width1_3,
                      right: (2 - index % 3) * width1_3,
                      child: TestCubeTile(index: index),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class TestCubeTile extends StatelessWidget {
  static const List<Color> colors = [
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.lime,
    Colors.brown,
    Colors.amberAccent,
    Colors.lightGreenAccent,
    Colors.lightBlueAccent,
    Colors.cyan,
  ];
  final int index;
  const TestCubeTile({Key? key, required this.index}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: colors[index],
        border: Border.all(width: 2, color: colors[index]),
      ),
      alignment: Alignment.center,
      child: Text(index.toString()),
    );
  }
}
