/// Notification Model
/// Represents a user notification
class NotificationModel {
  final String id;
  final String userId;
  final String type;
  final String title;
  final String? message;
  final Map<String, dynamic>? data;
  final bool isRead;
  final String? priority;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    this.message,
    this.data,
    required this.isRead,
    this.priority,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      type: json['type'] ?? '',
      title: json['title'] ?? '',
      message: json['message'],
      data: json['data'] != null
          ? Map<String, dynamic>.from(json['data'])
          : null,
      isRead: json['isRead'] ?? false,
      priority: json['priority'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'type': type,
      'title': title,
      'message': message,
      'data': data,
      'isRead': isRead,
      'priority': priority,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

