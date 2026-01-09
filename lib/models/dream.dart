/// 梦想模型
class Dream {
  final String id;
  final String title;
  final String? imagePath;
  final double targetAmount;
  final DateTime targetDate;
  final String? reason;
  final double currentAmount;
  final DateTime createdAt;
  final DateTime updatedAt;

  Dream({
    required this.id,
    required this.title,
    this.imagePath,
    required this.targetAmount,
    required this.targetDate,
    this.reason,
    this.currentAmount = 0.0,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'imagePath': imagePath,
      'targetAmount': targetAmount,
      'targetDate': targetDate.toIso8601String(),
      'reason': reason,
      'currentAmount': currentAmount,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Dream.fromMap(Map<String, dynamic> map) {
    return Dream(
      id: map['id'],
      title: map['title'],
      imagePath: map['imagePath'],
      targetAmount: map['targetAmount'],
      targetDate: DateTime.parse(map['targetDate']),
      reason: map['reason'],
      currentAmount: map['currentAmount'] ?? 0.0,
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }

  Dream copyWith({
    String? id,
    String? title,
    String? imagePath,
    double? targetAmount,
    DateTime? targetDate,
    String? reason,
    double? currentAmount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Dream(
      id: id ?? this.id,
      title: title ?? this.title,
      imagePath: imagePath ?? this.imagePath,
      targetAmount: targetAmount ?? this.targetAmount,
      targetDate: targetDate ?? this.targetDate,
      reason: reason ?? this.reason,
      currentAmount: currentAmount ?? this.currentAmount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  double get progress {
    if (targetAmount == 0) return 0;
    return (currentAmount / targetAmount).clamp(0.0, 1.0);
  }

  double get remainingAmount {
    return (targetAmount - currentAmount).clamp(0.0, double.infinity);
  }

  bool get isCompleted {
    return currentAmount >= targetAmount;
  }

  int get daysRemaining {
    return targetDate.difference(DateTime.now()).inDays;
  }
}
