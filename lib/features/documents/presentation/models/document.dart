class Document {
  final String id;
  final String userId;
  final String fileName;
  final String storagePath;
  final int fileSizeBytes;
  final DateTime createdAt;

  Document({
    required this.id,
    required this.userId,
    required this.fileName,
    required this.storagePath,
    required this.fileSizeBytes,
    required this.createdAt,
  });

  factory Document.fromJson(Map<String, dynamic> json) {
    return Document(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      fileName: json['file_name'] as String,
      storagePath: json['storage_path'] as String,
      fileSizeBytes: json['file_size_bytes'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toInsertJson(String userId) {
    return {
      'user_id': userId,
      'file_name': fileName,
      'storage_path': storagePath,
      'file_size_bytes': fileSizeBytes,
    };
  }

  String get fileExtension {
    final parts = fileName.split('.');
    return parts.length > 1 ? parts.last.toLowerCase() : '';
  }

  String get formattedSize {
    if (fileSizeBytes < 1024) return '$fileSizeBytes B';
    if (fileSizeBytes < 1024 * 1024) {
      return '${(fileSizeBytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(fileSizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}