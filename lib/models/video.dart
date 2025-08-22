// lib/models/video.dart
class Video {
  final int id;
  final String userId;
  final String title;
  final String? url;
  final String? category;
  final String status;
  final DateTime createdAt;

  Video({
    required this.id,
    required this.userId,
    required this.title,
    this.url,
    this.category,
    required this.status,
    required this.createdAt,
  });

  factory Video.fromJson(Map<String, dynamic> json) {
    return Video(
      id: json['id'],
      userId: json['user_id'],
      title: json['title'],
      url: json['url'],
      category: json['category'],
      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
