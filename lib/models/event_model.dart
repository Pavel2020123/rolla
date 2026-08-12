class EventModel {
  final String id;
  final String schoolId;      // A qué escuela pertenece
  final String creatorId;     // Quién lo creó
  final String title;
  final String description;
  final DateTime date;
  final String? time;
  final String location;
  final String category;
  final String modality;
  final double price;
  final DateTime? deadline;
  final int? maxSlots;
  final String status;        // 'draft', 'pending', 'approved', 'published', 'cancelled', 'finished'
  final List<String> enabledAthletes; // IDs de deportistas habilitados
  final bool isRegistered;    // Para el deportista actual

  EventModel({
    required this.id,
    required this.schoolId,
    required this.creatorId,
    required this.title,
    required this.description,
    required this.date,
    this.time,
    required this.location,
    required this.category,
    required this.modality,
    required this.price,
    this.deadline,
    this.maxSlots,
    this.status = 'draft',
    this.enabledAthletes = const [],
    this.isRegistered = false,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id'],
      schoolId: json['schoolId'],
      creatorId: json['creatorId'],
      title: json['title'],
      description: json['description'],
      date: DateTime.parse(json['date']),
      time: json['time'],
      location: json['location'],
      category: json['category'],
      modality: json['modality'],
      price: (json['price'] as num).toDouble(),
      deadline: json['deadline'] != null ? DateTime.parse(json['deadline']) : null,
      maxSlots: json['maxSlots'],
      status: json['status'] ?? 'draft',
      enabledAthletes: List<String>.from(json['enabledAthletes'] ?? []),
      isRegistered: json['isRegistered'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'schoolId': schoolId,
      'creatorId': creatorId,
      'title': title,
      'description': description,
      'date': date.toIso8601String(),
      'time': time,
      'location': location,
      'category': category,
      'modality': modality,
      'price': price,
      'deadline': deadline?.toIso8601String(),
      'maxSlots': maxSlots,
      'status': status,
      'enabledAthletes': enabledAthletes,
      'isRegistered': isRegistered,
    };
  }

  EventModel copyWith({
    String? id,
    String? schoolId,
    String? creatorId,
    String? title,
    String? description,
    DateTime? date,
    String? time,
    String? location,
    String? category,
    String? modality,
    double? price,
    DateTime? deadline,
    int? maxSlots,
    String? status,
    List<String>? enabledAthletes,
    bool? isRegistered,
  }) {
    return EventModel(
      id: id ?? this.id,
      schoolId: schoolId ?? this.schoolId,
      creatorId: creatorId ?? this.creatorId,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      time: time ?? this.time,
      location: location ?? this.location,
      category: category ?? this.category,
      modality: modality ?? this.modality,
      price: price ?? this.price,
      deadline: deadline ?? this.deadline,
      maxSlots: maxSlots ?? this.maxSlots,
      status: status ?? this.status,
      enabledAthletes: enabledAthletes ?? this.enabledAthletes,
      isRegistered: isRegistered ?? this.isRegistered,
    );
  }
}