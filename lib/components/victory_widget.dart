import 'package:flutter/material.dart';

class VictoryWidget extends StatelessWidget {
  final int turns;
  final Duration duration;

  VictoryWidget({Key? key, required this.turns, required this.duration}) : super(key: key);

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
    return SizedBox.expand(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black45.withOpacity(0.7),
        ),
        child: Center(
          child: Text(
            "Victory in $turns Turns and in ${_durationToString(duration)}!",
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}
