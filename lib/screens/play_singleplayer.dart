import 'package:flutter/material.dart';

class PlaySingleplayerScreen extends StatelessWidget {
  PlaySingleplayerScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Text("play singleplayer screen",
            style: TextStyle(
              color: Colors.green,
              decorationColor: Colors.blue,
            )));
  }
}
