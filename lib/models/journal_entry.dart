/// 成功日记条目模型
class JournalEntry {
  final String id;
  final DateTime date;
  final String success1;
  final String success2;
  final String success3;
  final int? mood; // 1-5
  final List<String> tags;
  final String? todayLearned;
  final String? tomorrowAction;
  final DateTime createdAt;
  final DateTime updatedAt;

  JournalEntry({
    required this.id,
    required this.date,
    required this.success1,
    required this.success2,
    required this.success3,
    this.mood,
    this.tags = const [],
    this.todayLearned,
    this.tomorrowAction,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'success1': success1,
      'success2': success2,
      'success3': success3,
      'mood': mood,
      'tags': tags.join(','),
      'todayLearned': todayLearned,
      'tomorrowAction': tomorrowAction,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory JournalEntry.fromMap(Map<String, dynamic> map) {
    return JournalEntry(
      id: map['id'],
      date: DateTime.parse(map['date']),
      success1: map['success1'],
      success2: map['success2'],
      success3: map['success3'],
      mood: map['mood'],
      tags: map['tags'] != null && map['tags'].isNotEmpty
          ? (map['tags'] as String).split(',')
          : [],
      todayLearned: map['todayLearned'],
      tomorrowAction: map['tomorrowAction'],
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }

  JournalEntry copyWith({
    String? id,
    DateTime? date,
    String? success1,
    String? success2,
    String? success3,
    int? mood,
    List<String>? tags,
    String? todayLearned,
    String? tomorrowAction,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return JournalEntry(
      id: id ?? this.id,
      date: date ?? this.date,
      success1: success1 ?? this.success1,
      success2: success2 ?? this.success2,
      success3: success3 ?? this.success3,
      mood: mood ?? this.mood,
      tags: tags ?? this.tags,
      todayLearned: todayLearned ?? this.todayLearned,
      tomorrowAction: tomorrowAction ?? this.tomorrowAction,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  List<String> getAllSuccesses() {
    return [success1, success2, success3];
  }
}
