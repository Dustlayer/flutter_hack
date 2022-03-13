import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

class GameStatus extends StatefulWidget {
  final DateTime dateTimeStart;
  final int turnsCount;
  final bool timerActive;

  const GameStatus({Key? key, required this.dateTimeStart, required this.turnsCount, this.timerActive = true})
      : super(key: key);

  @override
  _GameStatusState createState() => _GameStatusState();
}

class _GameStatusState extends State<GameStatus> {
  DateTime dateTimeNow = DateTime.now();
  late final Timer timer;

  @override
  void initState() {
    if (widget.timerActive) {
      timer = Timer.periodic(const Duration(seconds: 1), (_) {
        setState(() {
          dateTimeNow = DateTime.now();
        });
      });
    }
    super.initState();
  }

  @override
  void didUpdateWidget(covariant GameStatus oldWidget) {
    // enable or disable timer if widget is updated
    if (widget.timerActive != oldWidget.timerActive) {
      if (!widget.timerActive) {
        timer.cancel();
      } else if (widget.timerActive) {
        timer = Timer.periodic(const Duration(seconds: 1), (_) {
          setState(() {
            dateTimeNow = DateTime.now();
          });
        });
      }
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  static String _padLeft2(Object object) {
    return object.toString().padLeft(2, '0');
  }

  static String _durationToString(Duration duration) {
    int hours = duration.inHours;
    int minutes = duration.inMinutes - (60 * hours);
    int seconds = duration.inSeconds - (60 * minutes) - (3600 * hours);
    return "${_padLeft2(hours)}:${_padLeft2(minutes)}:${_padLeft2(seconds)}";
  }

  @override
  Widget build(BuildContext context) {
    Duration diff = dateTimeNow.difference(widget.dateTimeStart);
    return SizedBox.expand(
      child: Padding(
        padding: const EdgeInsets.all(150),
        child: Column(
          children: [
            Expanded(
              child: AutoSizeText(
                _durationToString(diff),
                wrapWords: false,
                style: Theme.of(context).primaryTextTheme.labelMedium?.copyWith(fontSize: 200),
              ),
            ),
            Expanded(
              child: AutoSizeText(
                widget.turnsCount.toString() + " turns",
                wrapWords: false,
                style: Theme.of(context).primaryTextTheme.labelMedium?.copyWith(fontSize: 200),
              ),
            ),
          ],
        ),
      ),
    );
  }
}