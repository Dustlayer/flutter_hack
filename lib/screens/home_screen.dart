import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hack/navigation/page_routes.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

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
