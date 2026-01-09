import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/journal_entry.dart';
import '../models/challenge.dart';
import '../models/dream.dart';
import '../models/deposit.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('golden_goose.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // 成功日记表
    await db.execute('''
      CREATE TABLE journal_entries (
        id TEXT PRIMARY KEY,
        date TEXT NOT NULL,
        success1 TEXT NOT NULL,
        success2 TEXT NOT NULL,
        success3 TEXT NOT NULL,
        mood INTEGER,
        tags TEXT,
        todayLearned TEXT,
        tomorrowAction TEXT,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      )
    ''');

    // 72小时挑战表
    await db.execute('''
      CREATE TABLE challenges (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        minimalAction TEXT NOT NULL,
        deadline TEXT NOT NULL,
        dreamId TEXT,
        status TEXT NOT NULL,
        completionEvidence TEXT,
        reflection TEXT,
        createdAt TEXT NOT NULL,
        completedAt TEXT
      )
    ''');

    // 梦想表
    await db.execute('''
      CREATE TABLE dreams (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        imagePath TEXT,
        targetAmount REAL NOT NULL,
        targetDate TEXT NOT NULL,
        reason TEXT,
        currentAmount REAL NOT NULL DEFAULT 0,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      )
    ''');

    // 存入记录表
    await db.execute('''
      CREATE TABLE deposits (
        id TEXT PRIMARY KEY,
        dreamId TEXT NOT NULL,
        amount REAL NOT NULL,
        source TEXT,
        note TEXT,
        createdAt TEXT NOT NULL,
        FOREIGN KEY (dreamId) REFERENCES dreams (id) ON DELETE CASCADE
      )
    ''');

    // 创建索引
    await db.execute('CREATE INDEX idx_journal_date ON journal_entries(date)');
    await db.execute('CREATE INDEX idx_challenge_status ON challenges(status)');
    await db.execute('CREATE INDEX idx_challenge_deadline ON challenges(deadline)');
    await db.execute('CREATE INDEX idx_deposit_dream ON deposits(dreamId)');
  }

  // ==================== 成功日记 CRUD ====================

  Future<JournalEntry> createJournalEntry(JournalEntry entry) async {
    final db = await database;
    await db.insert('journal_entries', entry.toMap());
    return entry;
  }

  Future<JournalEntry?> getJournalEntryByDate(DateTime date) async {
    final db = await database;
    final dateStr = date.toIso8601String().split('T')[0];
    final results = await db.query(
      'journal_entries',
      where: 'date LIKE ?',
      whereArgs: ['$dateStr%'],
    );

    if (results.isEmpty) return null;
    return JournalEntry.fromMap(results.first);
  }

  Future<List<JournalEntry>> getAllJournalEntries() async {
    final db = await database;
    final results = await db.query(
      'journal_entries',
      orderBy: 'date DESC',
    );
    return results.map((map) => JournalEntry.fromMap(map)).toList();
  }

  Future<List<JournalEntry>> getRecentJournalEntries(int limit) async {
    final db = await database;
    final results = await db.query(
      'journal_entries',
      orderBy: 'date DESC',
      limit: limit,
    );
    return results.map((map) => JournalEntry.fromMap(map)).toList();
  }

  Future<int> updateJournalEntry(JournalEntry entry) async {
    final db = await database;
    return await db.update(
      'journal_entries',
      entry.toMap(),
      where: 'id = ?',
      whereArgs: [entry.id],
    );
  }

  Future<int> deleteJournalEntry(String id) async {
    final db = await database;
    return await db.delete(
      'journal_entries',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // 获取连续打卡天数
  Future<int> getStreakDays() async {
    final db = await database;
    final results = await db.query(
      'journal_entries',
      orderBy: 'date DESC',
    );

    if (results.isEmpty) return 0;

    int streak = 0;
    DateTime? lastDate;

    for (var result in results) {
      final entry = JournalEntry.fromMap(result);
      final entryDate = DateTime(entry.date.year, entry.date.month, entry.date.day);

      if (lastDate == null) {
        final today = DateTime.now();
        final todayDate = DateTime(today.year, today.month, today.day);
        final yesterday = todayDate.subtract(const Duration(days: 1));

        if (entryDate == todayDate || entryDate == yesterday) {
          streak = 1;
          lastDate = entryDate;
        } else {
          break;
        }
      } else {
        final expectedDate = lastDate.subtract(const Duration(days: 1));
        if (entryDate == expectedDate) {
          streak++;
          lastDate = entryDate;
        } else {
          break;
        }
      }
    }

    return streak;
  }

  // ==================== 72小时挑战 CRUD ====================

  Future<Challenge> createChallenge(Challenge challenge) async {
    final db = await database;
    await db.insert('challenges', challenge.toMap());
    return challenge;
  }

  Future<Challenge?> getChallengeById(String id) async {
    final db = await database;
    final results = await db.query(
      'challenges',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (results.isEmpty) return null;
    return Challenge.fromMap(results.first);
  }

  Future<List<Challenge>> getAllChallenges() async {
    final db = await database;
    final results = await db.query(
      'challenges',
      orderBy: 'deadline ASC',
    );
    return results.map((map) => Challenge.fromMap(map)).toList();
  }

  Future<List<Challenge>> getActiveChallenges() async {
    final db = await database;
    final results = await db.query(
      'challenges',
      where: 'status = ?',
      whereArgs: [ChallengeStatus.inProgress.name],
      orderBy: 'deadline ASC',
      limit: 3,
    );
    return results.map((map) => Challenge.fromMap(map)).toList();
  }

  Future<int> updateChallenge(Challenge challenge) async {
    final db = await database;
    return await db.update(
      'challenges',
      challenge.toMap(),
      where: 'id = ?',
      whereArgs: [challenge.id],
    );
  }

  Future<int> deleteChallenge(String id) async {
    final db = await database;
    return await db.delete(
      'challenges',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ==================== 梦想 CRUD ====================

  Future<Dream> createDream(Dream dream) async {
    final db = await database;
    await db.insert('dreams', dream.toMap());
    return dream;
  }

  Future<Dream?> getDreamById(String id) async {
    final db = await database;
    final results = await db.query(
      'dreams',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (results.isEmpty) return null;
    return Dream.fromMap(results.first);
  }

  Future<List<Dream>> getAllDreams() async {
    final db = await database;
    final results = await db.query(
      'dreams',
      orderBy: 'updatedAt DESC',
    );
    return results.map((map) => Dream.fromMap(map)).toList();
  }

  Future<int> updateDream(Dream dream) async {
    final db = await database;
    return await db.update(
      'dreams',
      dream.toMap(),
      where: 'id = ?',
      whereArgs: [dream.id],
    );
  }

  Future<int> deleteDream(String id) async {
    final db = await database;
    return await db.delete(
      'dreams',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ==================== 存入记录 CRUD ====================

  Future<Deposit> createDeposit(Deposit deposit) async {
    final db = await database;
    await db.insert('deposits', deposit.toMap());

    // 更新梦想的当前金额
    final dream = await getDreamById(deposit.dreamId);
    if (dream != null) {
      final updatedDream = dream.copyWith(
        currentAmount: dream.currentAmount + deposit.amount,
        updatedAt: DateTime.now(),
      );
      await updateDream(updatedDream);
    }

    return deposit;
  }

  Future<List<Deposit>> getDepositsByDreamId(String dreamId) async {
    final db = await database;
    final results = await db.query(
      'deposits',
      where: 'dreamId = ?',
      whereArgs: [dreamId],
      orderBy: 'createdAt DESC',
    );
    return results.map((map) => Deposit.fromMap(map)).toList();
  }

  Future<int> deleteDeposit(String id) async {
    final db = await database;
    
    // 先获取存入记录
    final results = await db.query(
      'deposits',
      where: 'id = ?',
      whereArgs: [id],
    );
    
    if (results.isNotEmpty) {
      final deposit = Deposit.fromMap(results.first);
      
      // 更新梦想的当前金额
      final dream = await getDreamById(deposit.dreamId);
      if (dream != null) {
        final updatedDream = dream.copyWith(
          currentAmount: (dream.currentAmount - deposit.amount).clamp(0.0, double.infinity),
          updatedAt: DateTime.now(),
        );
        await updateDream(updatedDream);
      }
    }
    
    return await db.delete(
      'deposits',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ==================== 统计数据 ====================

  Future<Map<String, dynamic>> getStatistics() async {
    final db = await database;

    final journalCount = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM journal_entries'),
    ) ?? 0;

    final completedChallenges = Sqflite.firstIntValue(
      await db.rawQuery(
        'SELECT COUNT(*) FROM challenges WHERE status = ?',
        [ChallengeStatus.completed.name],
      ),
    ) ?? 0;

    final totalDeposits = Sqflite.firstIntValue(
      await db.rawQuery('SELECT SUM(amount) FROM deposits'),
    )?.toDouble() ?? 0.0;

    final streakDays = await getStreakDays();

    return {
      'journalCount': journalCount,
      'completedChallenges': completedChallenges,
      'totalDeposits': totalDeposits,
      'streakDays': streakDays,
    };
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
