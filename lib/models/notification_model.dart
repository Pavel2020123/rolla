class NotificationModel {
  final String id;
  final String userId;      // A quién va dirigida
  final String title;
  final String message;
  final String type;        // 'request', 'event', 'registration', 'payment', 'transfer', 'info'
  final bool read;
  final DateTime date;
  final String? relatedId;  // ID relacionado (solicitud, evento, etc.)

  NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.type,
    this.read = false,
    required this.date,
    this.relatedId,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      userId: json['userId'],
      title: json['title'],
      message: json['message'],
      type: json['type'],
      read: json['read'] ?? false,
      date: DateTime.parse(json['date']),
      relatedId: json['relatedId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'message': message,
      'type': type,
      'read': read,
      'date': date.toIso8601String(),
      'relatedId': relatedId,
    };
  }
}