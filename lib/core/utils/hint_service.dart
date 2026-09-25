import 'package:shared_preferences/shared_preferences.dart';

/// Tracks which one-time onboarding hints a user has already dismissed,
/// stored locally on-device. Since this isn't tied to their account, a
/// reinstall or a different device will show hints again — an acceptable
/// tradeoff for something this low-stakes.
class HintService {
  static const _keyPrefix = 'hint_seen_';

  static Future<bool> hasSeen(String hintId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('$_keyPrefix$hintId') ?? false;
  }

  static Future<void> markSeen(String hintId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('$_keyPrefix$hintId', true);
  }
}