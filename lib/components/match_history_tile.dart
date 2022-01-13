import 'package:flutter/material.dart';

import '../models/match_history_item.dart';

class MatchHistoryTile extends StatelessWidget {
  final MatchHistoryItem item;

  MatchHistoryTile({Key? key, required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(item.won ? 'Verloren' : 'Gewonnen'),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(item.dateTimeFinished.toString()),
              Text((item.durationMilliseconds ~/ 1000).toString()),
            ],
          ),
        ],
      ),
    );
  }
}
