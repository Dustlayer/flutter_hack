import 'package:flutter/material.dart';

class PlayMultiplayerScreen extends StatelessWidget {
  PlayMultiplayerScreen({Key? key, this.gameId}) : super(key: key);

  String? gameId;

  @override
  Widget build(BuildContext context) {
    // String gameIdString = gameId.toString();
    if (gameId != null) {
      return Text("play Mutliplayer with gameId $gameId");
    } else {
      return Text("Insert gameID: ______");
    }
  }
}
