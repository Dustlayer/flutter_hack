import 'package:auto_size_text/auto_size_text.dart';
import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';

import '../navigation/page_routes.dart';

class VictoryWidget extends StatelessWidget {
  final int turns;
  final Duration duration;
  final void Function() onReplay;

  VictoryWidget({Key? key, required this.turns, required this.duration, required this.onReplay}) : super(key: key);

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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              const Spacer(flex: 4),
              Expanded(
                flex: 2,
                child: AutoSizeText(
                  "Congrats!\nVictory in $turns Turns and in ${_durationToString(duration)}h!",
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
              Expanded(
                flex: 1,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Spacer(flex: 6),
                    Expanded(
                      flex: 4,
                      child: ElevatedButton(
                        onPressed: () => context.beamToNamed(PageRoutes.home),
                        child: const AspectRatio(
                          aspectRatio: 1,
                          child: SizedBox.expand(
                            child: FittedBox(
                              fit: BoxFit.fill,
                              child: Icon(
                                Icons.home,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const Spacer(flex: 1),
                    Expanded(
                      flex: 4,
                      child: ElevatedButton(
                        onPressed: () => onReplay(),
                        child: const AspectRatio(
                          aspectRatio: 1,
                          child: SizedBox.expand(
                            child: FittedBox(
                              fit: BoxFit.fill,
                              child: Icon(
                                Icons.refresh,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const Spacer(flex: 6),
                  ],
                ),
              ),
              const Spacer(flex: 3),
            ],
          ),
        ),
      ),
    );
  }
}
