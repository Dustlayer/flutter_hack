import 'package:flutter/material.dart';

import 'match_history_item.dart';

class MatchHistoryManager extends ChangeNotifier {
  final _matchHistoryItems = <MatchHistoryItem>[];

  List<MatchHistoryItem> get matchHistoryItems =>
      List.unmodifiable(_matchHistoryItems);

  void deleteItem(int index) {
    _matchHistoryItems.removeAt(index);
    notifyListeners();
  }

  void addItem(MatchHistoryItem item) {
    _matchHistoryItems.add(item);
    notifyListeners();
  }

  void updateItem(int index, MatchHistoryItem item) {
    _matchHistoryItems[index] = item;
    notifyListeners();
  }
}
