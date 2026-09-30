import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;
import '../models/quest.dart';
import '../utils/quest_stats.dart';

/// Schedules the two on-device reminders: a daily "your quests are ready"
/// nudge and an evening streak warning. Everything runs locally on the
/// phone, so there is no server and no cost.
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  static const _dailyKey = 'notif_daily_enabled';
  static const _streakKey = 'notif_streak_enabled';

  static const _dailyId = 1;
  static const _streakId = 2;
  static const _confirmId = 3;

  // Change these to test quickly (e.g. two minutes from now), then put them back.
  static const dailyHour = 9;
  static const dailyMinute = 0;
  static const streakHour = 20;
  static const streakMinute = 0;

  static const _details = NotificationDetails(
    android: AndroidNotificationDetails(
      'questify_reminders',
      'Reminders',
      channelDescription: 'Daily quest reminders and streak warnings',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    ),
  );

  Future<void> _ensureInitialized() async {
    if (_initialized) return;
    tz_data.initializeTimeZones();
    final info = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(info.identifier));
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@drawable/ic_launcher_monochrome'),
      ),
    );
    _initialized = true;
  }

  Future<bool> isDailyEnabled() async =>
      (await SharedPreferences.getInstance()).getBool(_dailyKey) ?? false;

  Future<bool> isStreakEnabled() async =>
      (await SharedPreferences.getInstance()).getBool(_streakKey) ?? false;

  Future<bool> _ensurePermission() async {
    await _ensureInitialized();
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (await android?.areNotificationsEnabled() == true) return true;
    final granted = await android?.requestNotificationsPermission();
    return granted ?? false;
  }

  tz.TZDateTime _nextInstanceOf(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (!scheduled.isAfter(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  Future<void> _scheduleDaily() async {
    await _plugin.zonedSchedule(
      id: _dailyId,
      title: 'Your quests are ready',
      body: 'Open Questify and pick your first one for today.',
      scheduledDate: _nextInstanceOf(dailyHour, dailyMinute),
      notificationDetails: _details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  /// Schedules a single streak warning. If a quest is already done today it
  /// goes to tomorrow evening; if there is no streak to lose, nothing is set.
  Future<void> _scheduleStreakWarning(List<Quest> quests) async {
    await _plugin.cancel(id: _streakId);

    final streak = QuestStats.currentStreak(quests);
    if (streak == 0) return;

    final now = DateTime.now();
    final doneToday = quests.any(
      (q) => q.completed && q.completedAt != null && _sameDay(q.completedAt!, now),
    );

    var target = _nextInstanceOf(streakHour, streakMinute);
    final tzNow = tz.TZDateTime.now(tz.local);
    if (doneToday) {
      // Today is safe, so warn tomorrow evening instead.
      if (_sameDay(target, tzNow)) target = target.add(const Duration(days: 1));
    } else if (!_sameDay(target, tzNow)) {
      // Tonight's warning time already passed and nothing was done.
      return;
    }

    await _plugin.zonedSchedule(
      id: _streakId,
      title: 'Your $streak-day streak is at risk',
      body: 'Finish one quest before midnight to keep it alive.',
      scheduledDate: target,
      notificationDetails: _details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  Future<void> _showConfirmation(String title, String body) async {
    await _plugin.show(
      id: _confirmId,
      title: title,
      body: body,
      notificationDetails: _details,
    );
  }

  /// Returns false if the user has notifications blocked.
  Future<bool> setDailyEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    if (enabled) {
      if (!await _ensurePermission()) return false;
      await _scheduleDaily();
      await prefs.setBool(_dailyKey, true);
      await _showConfirmation('Daily reminder on', "We'll nudge you every morning at 9:00 AM.");
    } else {
      await prefs.setBool(_dailyKey, false);
      await _ensureInitialized();
      await _plugin.cancel(id: _dailyId);
    }
    return true;
  }

  /// Returns false if the user has notifications blocked.
  Future<bool> setStreakEnabled(bool enabled, List<Quest> quests) async {
    final prefs = await SharedPreferences.getInstance();
    if (enabled) {
      if (!await _ensurePermission()) return false;
      await prefs.setBool(_streakKey, true);
      await _scheduleStreakWarning(quests);
      await _showConfirmation(
        'Streak warnings on',
        "We'll warn you in the evening if your streak is about to break.",
      );
    } else {
      await prefs.setBool(_streakKey, false);
      await _ensureInitialized();
      await _plugin.cancel(id: _streakId);
    }
    return true;
  }

  /// Re-applies whatever is switched on. Called whenever quests load or
  /// change, so the streak warning always reflects today's progress.
  Future<void> syncAll(List<Quest> quests) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final daily = prefs.getBool(_dailyKey) ?? false;
      final streak = prefs.getBool(_streakKey) ?? false;
      if (!daily && !streak) return;

      await _ensureInitialized();
      if (daily) await _scheduleDaily();
      if (streak) await _scheduleStreakWarning(quests);
    } catch (e) {
      debugPrint('Could not sync reminders: $e');
    }
  }

  /// Clears every reminder and switches both off, used when signing out.
  Future<void> resetForSignOut() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_dailyKey, false);
      await prefs.setBool(_streakKey, false);
      await _ensureInitialized();
      await _plugin.cancelAll();
    } catch (e) {
      debugPrint('Could not clear reminders: $e');
    }
  }
}