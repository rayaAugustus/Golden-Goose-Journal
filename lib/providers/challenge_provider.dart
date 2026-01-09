import 'package:flutter/foundation.dart';
import '../models/challenge.dart';
import '../services/database_service.dart';
import '../services/notification_service.dart';
import 'package:uuid/uuid.dart';

class ChallengeProvider with ChangeNotifier {
  final DatabaseService _db = DatabaseService.instance;
  final NotificationService _notifications = NotificationService.instance;
  final _uuid = const Uuid();

  List<Challenge> _challenges = [];
  bool _isLoading = false;

  List<Challenge> get challenges => _challenges;
  bool get isLoading => _isLoading;

  List<Challenge> get activeChallenges {
    return _challenges
        .where((c) => c.status == ChallengeStatus.inProgress)
        .toList()
      ..sort((a, b) => a.deadline.compareTo(b.deadline));
  }

  List<Challenge> get completedChallenges {
    return _challenges
        .where((c) => c.status == ChallengeStatus.completed)
        .toList()
      ..sort((a, b) => b.completedAt!.compareTo(a.completedAt!));
  }

  int get activeCount => activeChallenges.length;
  int get completedCount => completedChallenges.length;

  Future<void> loadChallenges() async {
    _isLoading = true;
    notifyListeners();

    try {
      _challenges = await _db.getAllChallenges();
      // 检查并更新过期的挑战
      await _checkExpiredChallenges();
    } catch (e) {
      debugPrint('Error loading challenges: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _checkExpiredChallenges() async {
    final now = DateTime.now();
    bool hasChanges = false;

    for (var challenge in _challenges) {
      if (challenge.status == ChallengeStatus.inProgress &&
          challenge.deadline.isBefore(now)) {
        final expired = challenge.copyWith(status: ChallengeStatus.expired);
        await _db.updateChallenge(expired);
        
        final index = _challenges.indexWhere((c) => c.id == challenge.id);
        if (index != -1) {
          _challenges[index] = expired;
          hasChanges = true;
        }
      }
    }

    if (hasChanges) {
      notifyListeners();
    }
  }

  Future<bool> createChallenge({
    required String title,
    required String minimalAction,
    DateTime? deadline,
    String? dreamId,
  }) async {
    try {
      final now = DateTime.now();
      final challenge = Challenge(
        id: _uuid.v4(),
        title: title,
        minimalAction: minimalAction,
        deadline: deadline ?? now.add(const Duration(hours: 72)),
        dreamId: dreamId,
        status: ChallengeStatus.inProgress,
        createdAt: now,
      );

      await _db.createChallenge(challenge);
      await _notifications.scheduleChallengeReminders(challenge);
      
      _challenges.add(challenge);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error creating challenge: $e');
      return false;
    }
  }

  Future<bool> completeChallenge({
    required String id,
    String? evidence,
    String? reflection,
  }) async {
    try {
      final challenge = _challenges.firstWhere((c) => c.id == id);
      final completed = challenge.copyWith(
        status: ChallengeStatus.completed,
        completionEvidence: evidence,
        reflection: reflection,
        completedAt: DateTime.now(),
      );

      await _db.updateChallenge(completed);
      await _notifications.cancelChallengeReminders(id);

      final index = _challenges.indexWhere((c) => c.id == id);
      if (index != -1) {
        _challenges[index] = completed;
      }

      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error completing challenge: $e');
      return false;
    }
  }

  Future<bool> abandonChallenge(String id, {String? reason}) async {
    try {
      final challenge = _challenges.firstWhere((c) => c.id == id);
      final abandoned = challenge.copyWith(
        status: ChallengeStatus.abandoned,
        reflection: reason,
      );

      await _db.updateChallenge(abandoned);
      await _notifications.cancelChallengeReminders(id);

      final index = _challenges.indexWhere((c) => c.id == id);
      if (index != -1) {
        _challenges[index] = abandoned;
      }

      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error abandoning challenge: $e');
      return false;
    }
  }

  Future<bool> deleteChallenge(String id) async {
    try {
      await _db.deleteChallenge(id);
      await _notifications.cancelChallengeReminders(id);
      _challenges.removeWhere((c) => c.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error deleting challenge: $e');
      return false;
    }
  }

  Challenge? getChallengeById(String id) {
    try {
      return _challenges.firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }

  // 获取与梦想关联的挑战
  List<Challenge> getChallengesByDreamId(String dreamId) {
    return _challenges.where((c) => c.dreamId == dreamId).toList();
  }
}
