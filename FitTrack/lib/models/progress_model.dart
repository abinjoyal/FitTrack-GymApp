class ProgressModel {
  final String id;
  final String userId;
  final double weight;
  final DateTime date;

  ProgressModel({
    required this.id,
    required this.userId,
    required this.weight,
    required this.date,
  });

  factory ProgressModel.fromMap(Map<String, dynamic> map) {
    return ProgressModel(
      id: map['id'],
      userId: map['user_id'],
      weight: (map['weight'] as num).toDouble(),
      date: DateTime.parse(map['date']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'weight': weight,
      'date': date.toIso8601String(),
    };
  }
}