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
