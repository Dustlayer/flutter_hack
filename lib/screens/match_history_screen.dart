import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_hack/components/match_history_list.dart';
import 'package:flutter_hack/models/match_history_item.dart';
import 'package:flutter_hack/models/match_history_manager.dart';
import 'package:uuid/uuid.dart';

import '../components/match_history_list.dart';
import 'empty_match_history_screen.dart';

class MatchHistoryScreen extends StatelessWidget {
  const MatchHistoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Provider.of<MatchHistoryManager>(context, listen: false).addItem(
              MatchHistoryItem(
                  id: const Uuid().v1(),
                  dateTimeFinished: DateTime.now(),
                  durationMilliseconds: Random().nextInt(600000),
                  won: Random().nextBool()));
        },
      ),
      body: buildMatchHistoryScreen(),
    );
  }

  Widget buildMatchHistoryScreen() {
    return Consumer<MatchHistoryManager>(builder: (context, manager, child) {
      if (manager.matchHistoryItems.isNotEmpty) {
        return MatchHistoryListScreen(manager: manager);
      } else {
        return const EmptyMatchHistoryScreen();
      }
    });
  }
}
