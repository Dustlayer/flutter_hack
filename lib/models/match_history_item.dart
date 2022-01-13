class MatchHistoryItem {
  final String id;
  final int durationMilliseconds;
  final DateTime dateTimeFinished;
  final bool won;

  MatchHistoryItem({
    required this.id,
    required this.dateTimeFinished,
    required this.durationMilliseconds,
    required this.won,
  });
}
