import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hack/navigation/page_routes.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('3D Puzzle')),
      body: Row(
        children: [
          const Spacer(flex: 3),
          Expanded(
            flex: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  flex: 3,
                  child: MenuButton(
                    text: 'Singleplayer',
                    onPressed: () =>
                        context.beamToNamed(PageRoutes.singleplayer),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: MenuButton(
                      onPressed: () =>
                          context.beamToNamed(PageRoutes.multiplayer),
                      text: 'Multiplayer'),
                ),
                Expanded(
                  flex: 3,
                  child: MenuButton(
                      onPressed: () =>
                          context.beamToNamed(PageRoutes.leaderboard),
                      text: 'Leaderboard'),
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
  MenuButton({Key? key, required this.text, required this.onPressed})
      : super(key: key);

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
      child: TextButton(
          onPressed: () => onPressed(),
          child: Text(text, style: menuTextStyle)),
    );
  }
}
