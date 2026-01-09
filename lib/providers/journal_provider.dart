import 'package:flutter/foundation.dart';
import '../models/journal_entry.dart';
import '../services/database_service.dart';
import 'package:uuid/uuid.dart';

class JournalProvider with ChangeNotifier {
  final DatabaseService _db = DatabaseService.instance;
  final _uuid = const Uuid();

  List<JournalEntry> _entries = [];
  JournalEntry? _todayEntry;
  int _streakDays = 0;
  bool _isLoading = false;

  List<JournalEntry> get entries => _entries;
  JournalEntry? get todayEntry => _todayEntry;
  int get streakDays => _streakDays;
  bool get isLoading => _isLoading;
  bool get hasTodayEntry => _todayEntry != null;

  Future<void> loadEntries() async {
    _isLoading = true;
    notifyListeners();

    try {
      _entries = await _db.getAllJournalEntries();
      await loadTodayEntry();
      await loadStreakDays();
    } catch (e) {
      debugPrint('Error loading journal entries: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadTodayEntry() async {
    try {
      _todayEntry = await _db.getJournalEntryByDate(DateTime.now());
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading today entry: $e');
    }
  }

  Future<void> loadStreakDays() async {
    try {
      _streakDays = await _db.getStreakDays();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading streak days: $e');
    }
  }

  Future<bool> createEntry({
    required String success1,
    required String success2,
    required String success3,
    int? mood,
    List<String>? tags,
    String? todayLearned,
    String? tomorrowAction,
  }) async {
    try {
      final now = DateTime.now();
      final entry = JournalEntry(
        id: _uuid.v4(),
        date: now,
        success1: success1,
        success2: success2,
        success3: success3,
        mood: mood,
        tags: tags ?? [],
        todayLearned: todayLearned,
        tomorrowAction: tomorrowAction,
        createdAt: now,
        updatedAt: now,
      );

      await _db.createJournalEntry(entry);
      _todayEntry = entry;
      _entries.insert(0, entry);
      await loadStreakDays();
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error creating journal entry: $e');
      return false;
    }
  }

  Future<bool> updateEntry(JournalEntry entry) async {
    try {
      final updatedEntry = entry.copyWith(updatedAt: DateTime.now());
      await _db.updateJournalEntry(updatedEntry);

      final index = _entries.indexWhere((e) => e.id == entry.id);
      if (index != -1) {
        _entries[index] = updatedEntry;
      }

      if (_todayEntry?.id == entry.id) {
        _todayEntry = updatedEntry;
      }

      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error updating journal entry: $e');
      return false;
    }
  }

  Future<bool> deleteEntry(String id) async {
    try {
      await _db.deleteJournalEntry(id);
      _entries.removeWhere((e) => e.id == id);

      if (_todayEntry?.id == id) {
        _todayEntry = null;
      }

      await loadStreakDays();
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error deleting journal entry: $e');
      return false;
    }
  }

  // 获取随机成功条目用于回顾
  String? getRandomSuccess() {
    if (_entries.isEmpty) return null;

    final allSuccesses = <String>[];
    for (var entry in _entries) {
      allSuccesses.addAll(entry.getAllSuccesses());
    }

    if (allSuccesses.isEmpty) return null;

    allSuccesses.shuffle();
    return allSuccesses.first;
  }

  // 获取最近N天的条目
  List<JournalEntry> getRecentEntries(int days) {
    final cutoffDate = DateTime.now().subtract(Duration(days: days));
    return _entries.where((entry) => entry.date.isAfter(cutoffDate)).toList();
  }
}
