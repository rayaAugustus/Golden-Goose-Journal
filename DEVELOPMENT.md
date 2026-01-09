# 金鹅日记 - 开发指南

## 项目概述

金鹅日记是一个基于Flutter开发的移动应用，灵感来源于《小狗钱钱》一书。应用通过成功日记、72小时挑战和梦想储蓄罐三大核心功能，帮助用户建立行动力和储蓄习惯。

## 技术架构

### 核心技术栈
- **Flutter**: 3.10.4+
- **Dart**: 3.10.4+
- **状态管理**: Provider
- **本地数据库**: SQLite (sqflite)
- **本地通知**: flutter_local_notifications
- **UI字体**: Google Fonts

### 架构模式
采用 **MVVM (Model-View-ViewModel)** 架构：
- **Model**: 数据模型层 (`lib/models/`)
- **View**: UI展示层 (`lib/pages/`)
- **ViewModel**: 业务逻辑层 (`lib/providers/`)
- **Service**: 服务层 (`lib/services/`)

## 项目结构详解

```
lib/
├── config/                      # 配置文件
│   ├── theme.dart              # 主题配置（颜色、字体、组件样式）
│   └── constants.dart          # 常量定义（文案、限制、模板）
│
├── models/                      # 数据模型
│   ├── journal_entry.dart      # 成功日记模型
│   ├── challenge.dart          # 72小时挑战模型
│   ├── dream.dart              # 梦想模型
│   └── deposit.dart            # 存入记录模型
│
├── services/                    # 服务层
│   ├── database_service.dart   # 数据库服务（CRUD操作）
│   └── notification_service.dart # 通知服务（提醒管理）
│
├── providers/                   # 状态管理
│   ├── journal_provider.dart   # 日记状态管理
│   ├── challenge_provider.dart # 挑战状态管理
│   └── dream_provider.dart     # 梦想状态管理
│
├── pages/                       # 页面
│   ├── main_navigation.dart    # 底部导航
│   ├── home_page.dart          # 今日页（首页）
│   │
│   ├── journal/                # 日记模块
│   │   ├── journal_list_page.dart    # 日记列表
│   │   └── write_journal_page.dart   # 写日记
│   │
│   ├── challenge/              # 挑战模块
│   │   ├── challenge_list_page.dart  # 挑战列表
│   │   └── create_challenge_page.dart # 创建挑战
│   │
│   └── dream/                  # 梦想模块
│       ├── dream_list_page.dart      # 梦想列表
│       ├── create_dream_page.dart    # 创建梦想
│       └── deposit_dialog.dart       # 存入对话框
│
└── main.dart                    # 应用入口
```

## 核心功能实现

### 1. 成功日记模块

**数据流程**:
```
用户输入 → JournalProvider → DatabaseService → SQLite
         ↓
    UI更新 ← notifyListeners()
```

**关键代码**:
```dart
// 创建日记
await provider.createEntry(
  success1: '...',
  success2: '...',
  success3: '...',
);

// 获取连续天数
final streakDays = await db.getStreakDays();
```

### 2. 72小时挑战模块

**提醒机制**:
- 创建挑战时自动设置24小时和1小时提醒
- 使用 `flutter_local_notifications` 实现本地通知
- 完成或放弃挑战时取消提醒

**关键代码**:
```dart
// 创建挑战并设置提醒
await provider.createChallenge(
  title: '...',
  minimalAction: '...',
);
await notifications.scheduleChallengeReminders(challenge);
```

### 3. 梦想储蓄罐模块

**进度计算**:
```dart
double get progress {
  if (targetAmount == 0) return 0;
  return (currentAmount / targetAmount).clamp(0.0, 1.0);
}
```

**存入流程**:
1. 用户选择梦想
2. 输入金额和来源
3. 创建存入记录
4. 自动更新梦想的当前金额

## 数据库设计

### 表结构

#### journal_entries (成功日记)
```sql
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
```

#### challenges (72小时挑战)
```sql
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
```

#### dreams (梦想)
```sql
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
```

#### deposits (存入记录)
```sql
CREATE TABLE deposits (
  id TEXT PRIMARY KEY,
  dreamId TEXT NOT NULL,
  amount REAL NOT NULL,
  source TEXT,
  note TEXT,
  createdAt TEXT NOT NULL,
  FOREIGN KEY (dreamId) REFERENCES dreams (id) ON DELETE CASCADE
)
```

## 开发流程

### 1. 环境搭建

```bash
# 检查Flutter环境
flutter doctor

# 安装依赖
flutter pub get

# 运行应用
flutter run
```

### 2. 添加新功能

**步骤**:
1. 在 `models/` 中定义数据模型
2. 在 `services/database_service.dart` 中添加CRUD方法
3. 在 `providers/` 中创建状态管理类
4. 在 `pages/` 中实现UI界面
5. 更新路由和导航

**示例 - 添加新的数据类型**:
```dart
// 1. 创建模型
class NewFeature {
  final String id;
  final String name;
  // ...
}

// 2. 添加数据库方法
Future<NewFeature> createNewFeature(NewFeature feature) async {
  final db = await database;
  await db.insert('new_features', feature.toMap());
  return feature;
}

// 3. 创建Provider
class NewFeatureProvider with ChangeNotifier {
  List<NewFeature> _features = [];
  
  Future<void> loadFeatures() async {
    _features = await _db.getAllNewFeatures();
    notifyListeners();
  }
}

// 4. 在UI中使用
Consumer<NewFeatureProvider>(
  builder: (context, provider, child) {
    return ListView.builder(
      itemCount: provider.features.length,
      itemBuilder: (context, index) {
        // ...
      },
    );
  },
)
```

### 3. 调试技巧

**日志输出**:
```dart
import 'package:flutter/foundation.dart';

debugPrint('Debug message: $variable');
```

**数据库调试**:
```dart
// 查看数据库路径
final dbPath = await getDatabasesPath();
print('Database path: $dbPath');

// 查询所有数据
final results = await db.query('table_name');
print('Results: $results');
```

**Provider调试**:
```dart
// 在Provider中添加日志
@override
void notifyListeners() {
  debugPrint('Provider updated: ${_items.length} items');
  super.notifyListeners();
}
```

## 性能优化

### 1. 列表优化
- 使用 `ListView.builder` 而非 `ListView`
- 实现懒加载和分页

### 2. 数据库优化
- 添加索引提高查询速度
- 使用事务处理批量操作
- 定期清理过期数据

### 3. 状态管理优化
- 使用 `Consumer` 而非 `Provider.of`
- 避免不必要的 `notifyListeners()`
- 使用 `Selector` 精确监听

## 测试

### 单元测试
```dart
test('Calculate dream progress', () {
  final dream = Dream(
    id: '1',
    title: 'Test',
    targetAmount: 1000,
    currentAmount: 500,
    // ...
  );
  
  expect(dream.progress, 0.5);
});
```

### Widget测试
```dart
testWidgets('Home page displays streak days', (tester) async {
  await tester.pumpWidget(MyApp());
  
  expect(find.text('连续行动'), findsOneWidget);
});
```

## 发布流程

### Android
```bash
# 构建APK
flutter build apk --release

# 构建App Bundle (推荐)
flutter build appbundle --release
```

### iOS
```bash
# 构建iOS应用
flutter build ios --release

# 使用Xcode打开项目进行签名和发布
open ios/Runner.xcworkspace
```

## 常见问题

### Q1: 数据库迁移
**A**: 修改 `database_service.dart` 中的版本号和 `onUpgrade` 方法：
```dart
return await openDatabase(
  path,
  version: 2, // 增加版本号
  onCreate: _createDB,
  onUpgrade: (db, oldVersion, newVersion) async {
    if (oldVersion < 2) {
      // 执行迁移SQL
      await db.execute('ALTER TABLE ...');
    }
  },
);
```

### Q2: 通知不显示
**A**: 检查权限配置：
- Android: `android/app/src/main/AndroidManifest.xml`
- iOS: `ios/Runner/Info.plist`

### Q3: 图片选择失败
**A**: 添加权限：
- Android: 在 `AndroidManifest.xml` 中添加存储权限
- iOS: 在 `Info.plist` 中添加相册访问权限

## 贡献指南

1. Fork 项目
2. 创建特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 开启 Pull Request

## 代码规范

- 遵循 [Effective Dart](https://dart.dev/guides/language/effective-dart) 规范
- 使用 `flutter_lints` 进行代码检查
- 保持代码简洁，避免过度工程
- 添加必要的注释和文档

## 资源链接

- [Flutter官方文档](https://flutter.dev/docs)
- [Provider文档](https://pub.dev/packages/provider)
- [SQLite教程](https://www.sqlitetutorial.net/)
- [Material Design 3](https://m3.material.io/)

---

**Happy Coding! 🚀**
