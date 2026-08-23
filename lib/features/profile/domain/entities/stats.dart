class Stats {
  final int totalWorkouts;
  final int currentStreak;

  Stats({required this.totalWorkouts, required this.currentStreak});

  factory Stats.fromJSON(Map<String, dynamic> json) {
    return Stats(
      totalWorkouts: json['totalWorkouts'] is int
          ? json['totalWorkouts']
          : int.tryParse(json['totalWorkouts']?.toString() ?? ''),
      currentStreak: json['currentStreak'] is int
          ? json['currentStreak']
          : int.tryParse(json['currentStreak']?.toString() ?? ''),
    );
  }
}
