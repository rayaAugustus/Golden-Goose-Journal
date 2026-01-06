class TransactionEntry {
  TransactionEntry({
    required this.id,
    required this.type,
    required this.amount,
    required this.occurredAt,
    required this.createdAt,
    required this.updatedAt,
    this.categoryId,
    this.note,
  });

  final String id;
  final String type;
  final double amount;
  final String? categoryId;
  final String? note;
  final DateTime occurredAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'type': type,
      'amount': amount,
      'category_id': categoryId,
      'note': note,
      'occurred_at': occurredAt.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory TransactionEntry.fromMap(Map<String, Object?> map) {
    return TransactionEntry(
      id: map['id'] as String,
      type: map['type'] as String,
      amount: (map['amount'] as num).toDouble(),
      categoryId: map['category_id'] as String?,
      note: map['note'] as String?,
      occurredAt: DateTime.parse(map['occurred_at'] as String),
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }
}

class JournalEntry {
  JournalEntry({
    required this.id,
    required this.content,
    required this.entryDate,
    required this.createdAt,
    required this.updatedAt,
    this.title,
    this.mood,
  });

  final String id;
  final String? title;
  final String content;
  final String? mood;
  final DateTime entryDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'mood': mood,
      'entry_date': entryDate.toIso8601String().split('T').first,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory JournalEntry.fromMap(Map<String, Object?> map) {
    return JournalEntry(
      id: map['id'] as String,
      title: map['title'] as String?,
      content: map['content'] as String,
      mood: map['mood'] as String?,
      entryDate: DateTime.parse(map['entry_date'] as String),
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }
}

class Goal {
  Goal({
    required this.id,
    required this.name,
    required this.targetAmount,
    required this.currentAmount,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.dueDate,
  });

  final String id;
  final String name;
  final double targetAmount;
  final double currentAmount;
  final String? dueDate;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'name': name,
      'target_amount': targetAmount,
      'current_amount': currentAmount,
      'due_date': dueDate,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory Goal.fromMap(Map<String, Object?> map) {
    return Goal(
      id: map['id'] as String,
      name: map['name'] as String,
      targetAmount: (map['target_amount'] as num).toDouble(),
      currentAmount: (map['current_amount'] as num).toDouble(),
      dueDate: map['due_date'] as String?,
      status: map['status'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }
}

class Category {
  Category({
    required this.id,
    required this.name,
    required this.type,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String name;
  final String type;
  final DateTime createdAt;
  final DateTime updatedAt;

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory Category.fromMap(Map<String, Object?> map) {
    return Category(
      id: map['id'] as String,
      name: map['name'] as String,
      type: map['type'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }
}
