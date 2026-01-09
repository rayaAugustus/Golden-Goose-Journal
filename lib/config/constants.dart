class AppConstants {
  // 应用信息
  static const String appName = '金鹅日记';
  static const String appVersion = '1.0.0';
  
  // 成功日记
  static const int minSuccessCount = 3;
  static const int maxSuccessCount = 5;
  static const int maxSuccessLength = 50;
  static const int maxLearnedLength = 80;
  static const int maxTomorrowActionLength = 80;
  
  // 72小时挑战
  static const int challengeHours = 72;
  static const int maxChallengeTitle = 40;
  static const int maxMinimalAction = 80;
  static const int maxActiveChallenges = 3;
  static const int maxCompletionEvidence = 80;
  static const int maxReflection = 80;
  
  // 梦想
  static const int maxDreamTitle = 20;
  static const int maxDreamReason = 120;
  static const int maxDepositNote = 50;
  
  // 快捷金额
  static const List<double> quickAmounts = [10, 20, 50, 100];
  
  // 标签
  static const List<String> journalTags = [
    '工作',
    '学习',
    '交易',
    '健康',
    '社交',
    '生活',
  ];
  
  // 挑战模板
  static const List<Map<String, String>> challengeTemplates = [
    {
      'title': '发一条消息',
      'action': '给某人发一条消息，开始沟通',
    },
    {
      'title': '查资料做笔记',
      'action': '查3篇资料并写5行笔记',
    },
    {
      'title': '存入梦想罐',
      'action': '存10元到梦想储蓄罐',
    },
    {
      'title': '运动打卡',
      'action': '完成15分钟运动',
    },
    {
      'title': '学习进步',
      'action': '写100字/做一个小提交/写一个函数',
    },
    {
      'title': '阅读积累',
      'action': '阅读10页书并记录3个要点',
    },
  ];
  
  // 成功日记示例
  static const List<String> journalExamples = [
    '今天按时起床了',
    '完成了一个小任务',
    '学习了新知识',
    '坚持运动了',
    '控制住了冲动消费',
    '主动和朋友联系',
    '整理了房间',
    '准时完成工作',
  ];
  
  // 鼓励文案
  static const List<String> encouragementMessages = [
    '小事也算，你已经在变好了！',
    '每一步都是进步！',
    '坚持下去，你会看到改变！',
    '今天的你比昨天更好！',
    '继续加油，你做得很棒！',
    '相信自己，你可以的！',
  ];
  
  // 完成挑战后的祝贺文案
  static const List<String> congratulationMessages = [
    '太棒了！你完成了这个挑战！',
    '做得好！又向目标迈进了一步！',
    '厉害！你证明了自己的行动力！',
    '完美！继续保持这个势头！',
    '真棒！你的坚持会带来改变！',
  ];
  
  // 提醒时间
  static const int defaultReminderHour = 21;
  static const int defaultReminderMinute = 0;
  
  // 数据库
  static const String dbName = 'golden_goose.db';
  static const int dbVersion = 1;
  
  // SharedPreferences Keys
  static const String keyFirstLaunch = 'first_launch';
  static const String keyDailyReminderEnabled = 'daily_reminder_enabled';
  static const String keyReminderHour = 'reminder_hour';
  static const String keyReminderMinute = 'reminder_minute';
  static const String keyThemeMode = 'theme_mode';
  
  // 动画时长
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);
}
