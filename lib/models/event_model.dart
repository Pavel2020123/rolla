class EventModel {
  final String id;
  final String title;
  final DateTime date;
  final String location;
  final String category;
  final String status;
  final bool isRegistered;

  EventModel({
    required this.id,
    required this.title,
    required this.date,
    required this.location,
    required this.category,
    required this.status,
    required this.isRegistered,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id'] as String,
      title: json['title'] as String,
      date: DateTime.parse(json['date'] as String),
      location: json['location'] as String,
      category: json['category'] as String,
      status: json['status'] as String,
      isRegistered: json['is_registered'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'date': date.toIso8601String(),
      'location': location,
      'category': category,
      'status': status,
      'is_registered': isRegistered,
    };
  }
}