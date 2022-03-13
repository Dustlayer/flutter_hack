import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hack/components/back_widget.dart';
import 'package:flutter_hack/components/keyboard_indicator.dart';
import 'package:flutter_hack/components/victory_widget.dart';
import 'package:flutter_hack/models/cube/cube.dart';
import 'package:provider/provider.dart';

import '../components/cube_widget.dart';
import '../components/game_status_widget.dart';
import '../models/keyboard_meta_keys_manager.dart';

class PlaySingleplayerScreen extends StatefulWidget {
  final int minFacesSolvedForVictory;

  const PlaySingleplayerScreen(this.minFacesSolvedForVictory, {Key? key}) : super(key: key);

  @override
  _PlaySingleplayerScreenState createState() => _PlaySingleplayerScreenState();
}

class _PlaySingleplayerScreenState extends State<PlaySingleplayerScreen> with SingleTickerProviderStateMixin {
  late final FocusNode focus;
  late final FocusAttachment _nodeAttachment;
  Cube cube = Cube.generate(100);
  // game stats for the leaderboard
  int _turnCounter = 0;
  DateTime dateTimeStart = DateTime.now();
  bool _victorious = false;
  Duration? _victoryDuration;

  // bool isShiftPressed = false;

  void _resetGame() {
    setState(() {
      cube = Cube.generate(100);
      _turnCounter = 0;
      dateTimeStart = DateTime.now();
      _victorious = false;
      _victoryDuration = null;
    });
  }

  @override
  void initState() {
    super.initState();
    focus = FocusNode(debugLabel: 'MetaKeysHandler');
    _nodeAttachment = focus.attach(context, onKey: (node, event) {
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

  void _checkForVictory() {
    if (widget.minFacesSolvedForVictory <= cube.solvedFaces() && !_victorious) {
      // Victory
      setState(() {
        _victorious = true;
        _victoryDuration = DateTime.now().difference(dateTimeStart);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    _nodeAttachment.reparent();
    return Scaffold(
      backgroundColor: Colors.black87,
      body: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                key: UniqueKey(),
                flex: 1,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: const [
                          FittedBox(
                            child: BackWidget(),
                          ),
                        ],
                      ),
                    ),
                    Positioned.fill(
                      child: Center(
                        child: AutoSizeText(
                          "Match the colors of one side",
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 5,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Spacer(flex: 1),
                    Expanded(
                      flex: 1,
                      child: CubeWidget(
                        key: ObjectKey(cube),
                        cube: cube,
                        onMove: _handleMove,
                        onEndMove: _checkForVictory,
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: GameStatus(
                        key: UniqueKey(),
                        dateTimeStart: dateTimeStart,
                        turnsCount: _turnCounter,
                        timerActive: !_victorious,
                      ),
                    ),
                  ],
                ),
              ),
              const Expanded(
                flex: 1,
                child: IndicatorContainer(labelText: "A", indicator: ShiftIndicator()),
              ),
              const Expanded(
                flex: 1,
                child: IndicatorContainer(labelText: "S", indicator: AltIndicator()),
              ),
            ],
          ),
          if (_victorious)
            Positioned.fill(
              child: VictoryWidget(
                turns: _turnCounter,
                duration: _victoryDuration!,
                onReplay: _resetGame,
              ),
            ),
        ],
      ),
    );
  }
}
