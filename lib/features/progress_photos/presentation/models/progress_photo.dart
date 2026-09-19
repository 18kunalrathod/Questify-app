class ProgressPhoto {
  final String id;
  final String userId;
  final String storagePath;
  final int fileSizeBytes;
  final DateTime takenAt;
  final DateTime createdAt;

  ProgressPhoto({
    required this.id,
    required this.userId,
    required this.storagePath,
    required this.fileSizeBytes,
    required this.takenAt,
    required this.createdAt,
  });

  factory ProgressPhoto.fromJson(Map<String, dynamic> json) {
    return ProgressPhoto(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      storagePath: json['storage_path'] as String,
      fileSizeBytes: json['file_size_bytes'] as int,
      takenAt: DateTime.parse(json['taken_at'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toInsertJson(String userId) {
    return {
      'user_id': userId,
      'storage_path': storagePath,
      'file_size_bytes': fileSizeBytes,
      'taken_at': takenAt.toIso8601String().split('T').first,
    };
  }

  int get daysAgo => DateTime.now().difference(takenAt).inDays;
}