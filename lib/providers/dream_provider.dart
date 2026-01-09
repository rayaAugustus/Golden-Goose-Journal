import 'package:flutter/foundation.dart';
import '../models/dream.dart';
import '../models/deposit.dart';
import '../services/database_service.dart';
import 'package:uuid/uuid.dart';

class DreamProvider with ChangeNotifier {
  final DatabaseService _db = DatabaseService.instance;
  final _uuid = const Uuid();

  List<Dream> _dreams = [];
  final Map<String, List<Deposit>> _deposits = {};
  bool _isLoading = false;

  List<Dream> get dreams => _dreams;
  bool get isLoading => _isLoading;

  List<Dream> get activeDreams {
    return _dreams.where((d) => !d.isCompleted).toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  List<Dream> get completedDreams {
    return _dreams.where((d) => d.isCompleted).toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  Dream? get topDream {
    if (activeDreams.isEmpty) return null;
    return activeDreams.first;
  }

  Future<void> loadDreams() async {
    _isLoading = true;
    notifyListeners();

    try {
      _dreams = await _db.getAllDreams();
    } catch (e) {
      debugPrint('Error loading dreams: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createDream({
    required String title,
    String? imagePath,
    required double targetAmount,
    required DateTime targetDate,
    String? reason,
  }) async {
    try {
      final now = DateTime.now();
      final dream = Dream(
        id: _uuid.v4(),
        title: title,
        imagePath: imagePath,
        targetAmount: targetAmount,
        targetDate: targetDate,
        reason: reason,
        currentAmount: 0.0,
        createdAt: now,
        updatedAt: now,
      );

      await _db.createDream(dream);
      _dreams.add(dream);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error creating dream: $e');
      return false;
    }
  }

  Future<bool> updateDream(Dream dream) async {
    try {
      final updated = dream.copyWith(updatedAt: DateTime.now());
      await _db.updateDream(updated);

      final index = _dreams.indexWhere((d) => d.id == dream.id);
      if (index != -1) {
        _dreams[index] = updated;
      }

      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error updating dream: $e');
      return false;
    }
  }

  Future<bool> deleteDream(String id) async {
    try {
      await _db.deleteDream(id);
      _dreams.removeWhere((d) => d.id == id);
      _deposits.remove(id);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error deleting dream: $e');
      return false;
    }
  }

  Dream? getDreamById(String id) {
    try {
      return _dreams.firstWhere((d) => d.id == id);
    } catch (e) {
      return null;
    }
  }

  // ==================== 存入记录管理 ====================

  Future<List<Deposit>> loadDeposits(String dreamId) async {
    try {
      final deposits = await _db.getDepositsByDreamId(dreamId);
      _deposits[dreamId] = deposits;
      notifyListeners();
      return deposits;
    } catch (e) {
      debugPrint('Error loading deposits: $e');
      return [];
    }
  }

  List<Deposit> getDeposits(String dreamId) {
    return _deposits[dreamId] ?? [];
  }

  Future<bool> addDeposit({
    required String dreamId,
    required double amount,
    DepositSource? source,
    String? note,
  }) async {
    try {
      final deposit = Deposit(
        id: _uuid.v4(),
        dreamId: dreamId,
        amount: amount,
        source: source,
        note: note,
        createdAt: DateTime.now(),
      );

      await _db.createDeposit(deposit);

      // 更新本地梦想数据
      final dream = getDreamById(dreamId);
      if (dream != null) {
        final updated = dream.copyWith(
          currentAmount: dream.currentAmount + amount,
          updatedAt: DateTime.now(),
        );
        final index = _dreams.indexWhere((d) => d.id == dreamId);
        if (index != -1) {
          _dreams[index] = updated;
        }
      }

      // 更新存入记录列表
      if (_deposits.containsKey(dreamId)) {
        _deposits[dreamId]!.insert(0, deposit);
      }

      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error adding deposit: $e');
      return false;
    }
  }

  Future<bool> deleteDeposit(String depositId, String dreamId) async {
    try {
      await _db.deleteDeposit(depositId);

      // 更新存入记录列表
      if (_deposits.containsKey(dreamId)) {
        _deposits[dreamId]!.removeWhere((d) => d.id == depositId);
      }

      // 重新加载梦想以更新金额
      final dream = await _db.getDreamById(dreamId);
      if (dream != null) {
        final index = _dreams.indexWhere((d) => d.id == dreamId);
        if (index != -1) {
          _dreams[index] = dream;
        }
      }

      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error deleting deposit: $e');
      return false;
    }
  }

  // 获取总存入金额
  double getTotalDeposits() {
    return _dreams.fold(0.0, (sum, dream) => sum + dream.currentAmount);
  }
}
