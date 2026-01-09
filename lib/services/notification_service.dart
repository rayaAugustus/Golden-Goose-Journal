import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../models/challenge.dart';

class NotificationService {
  static final NotificationService instance = NotificationService._init();
  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  NotificationService._init();

  Future<void> initialize() async {
    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
  }

  void _onNotificationTapped(NotificationResponse response) {
    // 处理通知点击事件
    // 可以在这里导航到相应的页面
  }

  Future<bool> requestPermissions() async {
    final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    final iosPlugin = _notifications.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();

    bool? androidGranted;
    bool? iosGranted;

    if (androidPlugin != null) {
      androidGranted = await androidPlugin.requestNotificationsPermission();
    }

    if (iosPlugin != null) {
      iosGranted = await iosPlugin.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
    }

    return androidGranted ?? iosGranted ?? false;
  }

  // 为挑战设置提醒
  Future<void> scheduleChallengeReminders(Challenge challenge) async {
    await cancelChallengeReminders(challenge.id);

    final now = DateTime.now();
    final deadline = challenge.deadline;

    // 24小时提醒
    final reminder24h = deadline.subtract(const Duration(hours: 24));
    if (reminder24h.isAfter(now)) {
      await _scheduleNotification(
        id: '${challenge.id}_24h'.hashCode,
        title: '⏰ 挑战提醒',
        body: '还有24小时！"${challenge.title}"即将到期',
        scheduledDate: reminder24h,
        payload: 'challenge_${challenge.id}',
      );
    }

    // 1小时提醒
    final reminder1h = deadline.subtract(const Duration(hours: 1));
    if (reminder1h.isAfter(now)) {
      await _scheduleNotification(
        id: '${challenge.id}_1h'.hashCode,
        title: '🔥 最后1小时！',
        body: '"${challenge.title}"马上就要到期了，快去完成吧！',
        scheduledDate: reminder1h,
        payload: 'challenge_${challenge.id}',
      );
    }
  }

  // 取消挑战提醒
  Future<void> cancelChallengeReminders(String challengeId) async {
    await _notifications.cancel('${challengeId}_24h'.hashCode);
    await _notifications.cancel('${challengeId}_1h'.hashCode);
  }

  // 每日日记提醒
  Future<void> scheduleDailyJournalReminder({
    int hour = 21,
    int minute = 0,
  }) async {
    await _notifications.zonedSchedule(
      0, // 固定ID用于每日提醒
      '✨ 今天的成功日记',
      '记录今天的3个成功，让自己看到进步！',
      _nextInstanceOfTime(hour, minute),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_journal',
          '每日日记提醒',
          channelDescription: '提醒您每天写成功日记',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: 'daily_journal',
    );
  }

  // 取消每日日记提醒
  Future<void> cancelDailyJournalReminder() async {
    await _notifications.cancel(0);
  }

  // 通用的计划通知方法
  Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'challenge_reminders',
          '挑战提醒',
          channelDescription: '72小时挑战的提醒通知',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
    );
  }

  // 立即显示通知
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    await _notifications.show(
      id,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'general',
          '通用通知',
          channelDescription: '应用的通用通知',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      payload: payload,
    );
  }

  // 取消所有通知
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  // 获取下一个指定时间的实例
  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    return scheduledDate;
  }
}
