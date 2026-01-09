/// 72小时挑战模型
class Challenge {
  final String id;
  final String title;
  final String minimalAction; // MVA - 最小可验证动作
  final DateTime deadline;
  final String? dreamId; // 关联的梦想ID
  final ChallengeStatus status;
  final String? completionEvidence;
  final String? reflection;
  final DateTime createdAt;
  final DateTime? completedAt;

  Challenge({
    required this.id,
    required this.title,
    required this.minimalAction,
    required this.deadline,
    this.dreamId,
    this.status = ChallengeStatus.inProgress,
    this.completionEvidence,
    this.reflection,
    required this.createdAt,
    this.completedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'minimalAction': minimalAction,
      'deadline': deadline.toIso8601String(),
      'dreamId': dreamId,
      'status': status.name,
      'completionEvidence': completionEvidence,
      'reflection': reflection,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  factory Challenge.fromMap(Map<String, dynamic> map) {
    return Challenge(
      id: map['id'],
      title: map['title'],
      minimalAction: map['minimalAction'],
      deadline: DateTime.parse(map['deadline']),
      dreamId: map['dreamId'],
      status: ChallengeStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => ChallengeStatus.inProgress,
      ),
      completionEvidence: map['completionEvidence'],
      reflection: map['reflection'],
      createdAt: DateTime.parse(map['createdAt']),
      completedAt: map['completedAt'] != null
          ? DateTime.parse(map['completedAt'])
          : null,
    );
  }

  Challenge copyWith({
    String? id,
    String? title,
    String? minimalAction,
    DateTime? deadline,
    String? dreamId,
    ChallengeStatus? status,
    String? completionEvidence,
    String? reflection,
    DateTime? createdAt,
    DateTime? completedAt,
  }) {
    return Challenge(
      id: id ?? this.id,
      title: title ?? this.title,
      minimalAction: minimalAction ?? this.minimalAction,
      deadline: deadline ?? this.deadline,
      dreamId: dreamId ?? this.dreamId,
      status: status ?? this.status,
      completionEvidence: completionEvidence ?? this.completionEvidence,
      reflection: reflection ?? this.reflection,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  Duration get timeRemaining {
    return deadline.difference(DateTime.now());
  }

  bool get isExpired {
    return DateTime.now().isAfter(deadline) && status == ChallengeStatus.inProgress;
  }

  bool get isCompleted {
    return status == ChallengeStatus.completed;
  }
}

enum ChallengeStatus {
  inProgress,
  completed,
  expired,
  abandoned,
}
