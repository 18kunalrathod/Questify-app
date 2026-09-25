/// Derives a simple, human-friendly display name from a user's email
/// address, since sign-up only collects an email and password — there is
/// no separate "name" field stored anywhere. Used anywhere the UI wants to
/// greet the user by something more personal than their raw email.
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