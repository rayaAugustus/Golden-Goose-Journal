/// 存入记录模型
class Deposit {
  final String id;
  final String dreamId;
  final double amount;
  final DepositSource? source;
  final String? note;
  final DateTime createdAt;

  Deposit({
    required this.id,
    required this.dreamId,
    required this.amount,
    this.source,
    this.note,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'dreamId': dreamId,
      'amount': amount,
      'source': source?.name,
      'note': note,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Deposit.fromMap(Map<String, dynamic> map) {
    return Deposit(
      id: map['id'],
      dreamId: map['dreamId'],
      amount: map['amount'],
      source: map['source'] != null
          ? DepositSource.values.firstWhere(
              (e) => e.name == map['source'],
              orElse: () => DepositSource.other,
            )
          : null,
      note: map['note'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  Deposit copyWith({
    String? id,
    String? dreamId,
    double? amount,
    DepositSource? source,
    String? note,
    DateTime? createdAt,
  }) {
    return Deposit(
      id: id ?? this.id,
      dreamId: dreamId ?? this.dreamId,
      amount: amount ?? this.amount,
      source: source ?? this.source,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

enum DepositSource {
  salary,    // 工资
  sideBusiness, // 副业
  savings,   // 节省
  reward,    // 奖励
  other,     // 其他
}

extension DepositSourceExtension on DepositSource {
  String get displayName {
    switch (this) {
      case DepositSource.salary:
        return '工资';
      case DepositSource.sideBusiness:
        return '副业';
      case DepositSource.savings:
        return '节省';
      case DepositSource.reward:
        return '奖励';
      case DepositSource.other:
        return '其他';
    }
  }
}
