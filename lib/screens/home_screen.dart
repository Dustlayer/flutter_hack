import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hack/navigation/page_routes.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: Row(
        children: [
          const Spacer(flex: 3),
          Expanded(
            flex: 5,
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  flex: 5,
                  child: FittedBox(
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      hoverColor: Colors.deepPurple.withOpacity(0.15),
                      onTap: () => context.beamToNamed(PageRoutes.singleplayer),
                      child: const Padding(
                          padding: EdgeInsets.all(3),
                          child: Icon(
                            Icons.videogame_asset,
                            color: Colors.green,
                          )),
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: FittedBox(
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      hoverColor: Colors.deepPurple.withOpacity(0.15),
                      onTap: () => context.beamToNamed(PageRoutes.leaderboard),
                      child: const Padding(
                          padding: EdgeInsets.all(3),
                          child: Icon(
                            Icons.leaderboard,
                            color: Colors.green,
                          )),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Spacer(flex: 3),
        ],
      ),
    );
  }
}

class MenuButton extends StatelessWidget {
  MenuButton({Key? key, required this.text, required this.onPressed}) : super(key: key);

  final String text;
  final Function onPressed;

  final TextStyle menuTextStyle = const TextStyle(fontSize: 45);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.greenAccent, width: 3),
        borderRadius: const BorderRadius.all(Radius.circular(20)),
      ),
      child: TextButton(onPressed: () => onPressed(), child: Text(text, style: menuTextStyle)),
    );
  }
}
