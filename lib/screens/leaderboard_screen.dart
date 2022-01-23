import 'package:flutter/material.dart';

class LeaderboardScreen extends StatelessWidget {
  LeaderboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Leaderboard')),
      body: Center(
        child: Text("leaderboardscreen"),
      ),
    );
  }
}
