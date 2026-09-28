import 'package:supabase_flutter/supabase_flutter.dart';

/// Best available display name for a user. Google sign-in supplies a real
/// name in the user metadata; email sign-up doesn't, so it falls back to
/// the part of the email before the @.
String displayNameForUser(User? user, {bool firstNameOnly = false}) {
  final meta = user?.userMetadata;
  final fullName = (meta?['full_name'] ?? meta?['name']) as String?;

  if (fullName != null && fullName.trim().isNotEmpty) {
    final trimmed = fullName.trim();
    return firstNameOnly ? trimmed.split(' ').first : trimmed;
  }

  return displayNameFromEmail(user?.email);
}

/// Derives a simple, human-friendly display name from a user's email
/// address, used when no real name is available.
String displayNameFromEmail(String? email) {
  if (email == null || email.isEmpty) return 'there';
  final localPart = email.split('@').first;
  if (localPart.isEmpty) return 'there';
  return localPart[0].toUpperCase() + localPart.substring(1);
}

/// "Joined X days ago" style label from the account's creation timestamp.
String joinedLabel(DateTime? createdAt) {
  if (createdAt == null) return '';
  final days = DateTime.now().difference(createdAt).inDays;
  if (days <= 0) return 'Joined today';
  if (days == 1) return 'Joined yesterday';
  return 'Joined $days days ago';
}

/// A time-of-day-appropriate greeting prefix ("Good morning, ", etc.).
String greetingPrefix() {
  final hour = DateTime.now().hour;
  if (hour < 12) return 'Good morning, ';
  if (hour < 17) return 'Good afternoon, ';
  return 'Good evening, ';
}