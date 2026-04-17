class WorkoutModel {
  final String id;
  final String userId;
  final String category;
  final String exerciseName;
  final int sets;
  final int reps;
  final double weight; // 🔥 Added weight
  final DateTime createdAt;

  WorkoutModel({
    required this.id,
    required this.userId,
    required this.category,
    required this.exerciseName,
    required this.sets,
    required this.reps,
    required this.weight,
    required this.createdAt,
  });

  /// 🔥 Volume calculation
  double get volume => sets * reps * weight;

  /// 🔥 From Supabase JSON
  factory WorkoutModel.fromMap(Map<String, dynamic> map) {
    return WorkoutModel(
      id: map['id']?.toString() ?? '',
      userId: map['user_id']?.toString() ?? '',
      category: map['category'] ?? '',
      exerciseName: map['exercise_name'] ?? '',
      sets: (map['sets'] ?? 0) as int,
      reps: (map['reps'] ?? 0) as int,
      weight: (map['weight'] ?? 0).toDouble(),
      createdAt: DateTime.tryParse(map['created_at'] ?? '') ??
          DateTime.now(),
    );
  }

  /// 🔥 For Insert
  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'category': category,
      'exercise_name': exerciseName,
      'sets': sets,
      'reps': reps,
      'weight': weight,
    };
  }

  /// 🔥 For Update
  Map<String, dynamic> toUpdateMap() {
    return {
      'category': category,
      'exercise_name': exerciseName,
      'sets': sets,
      'reps': reps,
      'weight': weight,
    };
  }

  /// 🔥 CopyWith (Very Important)
  WorkoutModel copyWith({
    String? id,
    String? userId,
    String? category,
    String? exerciseName,
    int? sets,
    int? reps,
    double? weight,
    DateTime? createdAt,
  }) {
    return WorkoutModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      category: category ?? this.category,
      exerciseName: exerciseName ?? this.exerciseName,
      sets: sets ?? this.sets,
      reps: reps ?? this.reps,
      weight: weight ?? this.weight,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}