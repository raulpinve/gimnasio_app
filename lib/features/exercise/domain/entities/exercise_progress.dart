class ExerciseProgress {
  final String date;
  final double value;

  const ExerciseProgress({
    // Constructor constante para rendimiento
    required this.date,
    required this.value,
  });

  factory ExerciseProgress.fromJson(Map<String, dynamic> json) {
    final rawValue = json['value'];
    double processedValue = 0.0;

    if (rawValue != null) {
      if (rawValue is num) {
        processedValue = rawValue.toDouble();
      } else if (rawValue is String) {
        processedValue = double.tryParse(rawValue) ?? 0.0;
      }
    }

    return ExerciseProgress(
      date: json['date']?.toString() ?? '',
      value: processedValue,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'value': value,
    };
  }
}
