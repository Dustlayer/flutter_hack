import 'package:flutter/material.dart';

import '../components/back_widget.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
            key: UniqueKey(),
            flex: 1,
            child: const FittedBox(
              alignment: Alignment.centerLeft,
              child: BackWidget(),
            ),
          ),
          Expanded(
            flex: 7,
            child: Center(
              child: Text(
                "Leaderboard coming soon\n...\nprobably",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.green),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
