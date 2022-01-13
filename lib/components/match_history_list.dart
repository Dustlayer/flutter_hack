import 'package:flutter/material.dart';
import 'package:flutter_hack/components/match_history_tile.dart';

import '../models/models.dart';

class MatchHistoryListScreen extends StatelessWidget {
  final MatchHistoryManager manager;

  const MatchHistoryListScreen({
    Key? key,
    required this.manager,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final matchHistoryItems = manager.matchHistoryItems;
    return ListView.separated(
      itemCount: matchHistoryItems.length,
      itemBuilder: (context, index) {
        final item = matchHistoryItems[index];
        return MatchHistoryTile(key: Key(item.id), item: item);
      },
      separatorBuilder: (context, index) {
        return const SizedBox(
          height: 16,
        );
      },
    );
  }
}
