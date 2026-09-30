class FocusLog {
  final String id;
  final String note;
  final int? minutes;
  final String? questTitle;
  final DateTime loggedAt;

  const FocusLog({
    required this.id,
    required this.note,
    this.minutes,
    this.questTitle,
    required this.loggedAt,
  });

  factory FocusLog.fromJson(Map<String, dynamic> json) {
    return FocusLog(
      id: json['id'] as String,
      note: json['note'] as String,
      minutes: json['minutes'] as int?,
      questTitle: json['quest_title'] as String?,
      loggedAt: DateTime.parse(json['logged_at'] as String).toLocal(),
    );
  }

  Map<String, dynamic> toInsertJson(String userId) {
    return {
      'user_id': userId,
      'note': note,
      'minutes': minutes,
      'quest_title': questTitle,
      'logged_at': loggedAt.toUtc().toIso8601String(),
    };
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      'note': note,
      'minutes': minutes,
      'quest_title': questTitle,
      'logged_at': loggedAt.toUtc().toIso8601String(),
    };
  }
}