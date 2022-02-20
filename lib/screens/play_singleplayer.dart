import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hack/components/keyboard_indicator.dart';
import 'package:flutter_hack/models/cube.dart';
import 'package:provider/provider.dart';

import '../components/cube_widget.dart';
import '../models/keyboard_meta_keys_manager.dart';

class PlaySingleplayerScreen extends StatefulWidget {
  const PlaySingleplayerScreen({Key? key}) : super(key: key);

  @override
  _PlaySingleplayerScreenState createState() => _PlaySingleplayerScreenState();
}

class _PlaySingleplayerScreenState extends State<PlaySingleplayerScreen> with SingleTickerProviderStateMixin {
  late final FocusNode focus;
  late final FocusAttachment _nodeAttachment;
  Cube cube = Cube();

  // bool isShiftPressed = false;

  @override
  void initState() {
    super.initState();
    focus = FocusNode(debugLabel: 'MetaKeysHandler');
    _nodeAttachment = focus.attach(context, onKey: (node, event) {
      Provider.of<KeyboardMetaKeysManager>(context, listen: false).setWithEvent(event);

      return KeyEventResult.handled;
    });
    focus.requestFocus();
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
            flex: 5,
            child: Center(child: CubeWidget(cube: cube)),
          ),
          const Spacer(flex: 1),
          Expanded(
            flex: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: const [
                Center(
                  child: Text(
                    "A",
                  ),
                ),
                ShiftIndicator(),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: const [
                Center(
                  child: Text(
                    "S",
                  ),
                ),
                AltIndicator(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
