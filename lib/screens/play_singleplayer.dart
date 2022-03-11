import 'package:auto_size_text/auto_size_text.dart';
import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hack/components/keyboard_indicator.dart';
import 'package:flutter_hack/models/cube.dart';
import 'package:provider/provider.dart';

import '../components/cube_widget.dart';
import '../components/game_status_widget.dart';
import '../models/keyboard_meta_keys_manager.dart';

class PlaySingleplayerScreen extends StatefulWidget {
  const PlaySingleplayerScreen({Key? key}) : super(key: key);

  @override
  _PlaySingleplayerScreenState createState() => _PlaySingleplayerScreenState();
}

// todo: remove later
void NoOp() {}

class _PlaySingleplayerScreenState extends State<PlaySingleplayerScreen> with SingleTickerProviderStateMixin {
  late final FocusNode focus;
  late final FocusAttachment _nodeAttachment;
  Cube cube = Cube.generate();
  // game stats for the leaderboard
  int _turnCounter = 0;
  DateTime dateTimeStart = DateTime.now();

  // bool isShiftPressed = false;

  @override
  void initState() {
    super.initState();
    focus = FocusNode(debugLabel: 'MetaKeysHandler');
    _nodeAttachment = focus.attach(context, onKey: (node, event) {
      if (event.logicalKey == LogicalKeyboardKey.keyD) {
        // todo: remove later
        NoOp();
      }

      Provider.of<KeyboardMetaKeysManager>(context, listen: false).setWithEvent(event);

      return KeyEventResult.skipRemainingHandlers;
    });
    focus.requestFocus();
  }

  @override
  void dispose() {
    focus.dispose();
    super.dispose();
  }

  void _handleMove() {
    setState(() {
      _turnCounter += 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    _nodeAttachment.reparent();
    return Scaffold(
      backgroundColor: Colors.black87,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            key: UniqueKey(),
            flex: 1,
            child: FittedBox(
              alignment: Alignment.centerLeft,
              child: InkWell(
                customBorder: const CircleBorder(),
                hoverColor: Colors.deepPurple.withOpacity(0.15),
                onTap: () =>
                    Beamer.of(context).canBeamBack ? Beamer.of(context).beamBack() : Navigator.of(context).maybePop(),
                child: const Padding(
                  padding: EdgeInsets.all(3),
                  child: Icon(
                    Icons.arrow_back,
                    color: Colors.green,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Spacer(flex: 1),
                Expanded(
                  flex: 1,
                  child: CubeWidget(
                    key: ObjectKey(cube),
                    the_cube: cube,
                    onMove: _handleMove,
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: GameStatus(
                    dateTimeStart: dateTimeStart,
                    turnsCount: _turnCounter,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(flex: 1),
          Expanded(
            flex: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: AutoSizeText(
                      "A",
                      style: Theme.of(context).primaryTextTheme.labelMedium?.copyWith(fontSize: 200),
                    ),
                  ),
                ),
                const ShiftIndicator(),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: AutoSizeText(
                      "S",
                      style: Theme.of(context).primaryTextTheme.labelMedium?.copyWith(fontSize: 200),
                    ),
                  ),
                ),
                const AltIndicator(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
