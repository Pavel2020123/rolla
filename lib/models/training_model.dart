class TrainingModel {
  final String id;
  final String schoolId;
  final String coachId;
  final String title;
  final String? description;
  final DateTime date;
  final String? time;
  final String location;
  final String? category; // Para qué categoría (opcional)
  final DateTime createdAt;
  final List<String> confirmedAthletes; // IDs de deportistas que confirmaron
  final List<String> declinedAthletes;  // IDs que dijeron que no van

  TrainingModel({
    required this.id,
    required this.schoolId,
    required this.coachId,
    required this.title,
    this.description,
    required this.date,
    this.time,
    required this.location,
    this.category,
    required this.createdAt,
    this.confirmedAthletes = const [],
    this.declinedAthletes = const [],
  });

  bool isConfirmed(String athleteId) => confirmedAthletes.contains(athleteId);
  bool isDeclined(String athleteId) => declinedAthletes.contains(athleteId);

  int get confirmedCount => confirmedAthletes.length;
  int get declinedCount => declinedAthletes.length;
  int get pendingCount => 0; // Se calcula externamente contra total deportistas

  factory TrainingModel.fromJson(Map<String, dynamic> json) {
    return TrainingModel(
      id: json['id'],
      schoolId: json['schoolId'],
      coachId: json['coachId'],
      title: json['title'],
      description: json['description'],
      date: DateTime.parse(json['date']),
      time: json['time'],
      location: json['location'],
      category: json['category'],
      createdAt: DateTime.parse(json['createdAt']),
      confirmedAthletes: List<String>.from(json['confirmedAthletes'] ?? []),
      declinedAthletes: List<String>.from(json['declinedAthletes'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'schoolId': schoolId,
      'coachId': coachId,
      'title': title,
      'description': description,
      'date': date.toIso8601String(),
      'time': time,
      'location': location,
      'category': category,
      'createdAt': createdAt.toIso8601String(),
      'confirmedAthletes': confirmedAthletes,
      'declinedAthletes': declinedAthletes,
    };
  }

  TrainingModel copyWith({
    String? id,
    String? schoolId,
    String? coachId,
    String? title,
    String? description,
    DateTime? date,
    String? time,
    String? location,
    String? category,
    DateTime? createdAt,
    List<String>? confirmedAthletes,
    List<String>? declinedAthletes,
  }) {
    return TrainingModel(
      id: id ?? this.id,
      schoolId: schoolId ?? this.schoolId,
      coachId: coachId ?? this.coachId,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      time: time ?? this.time,
      location: location ?? this.location,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
      confirmedAthletes: confirmedAthletes ?? this.confirmedAthletes,
      declinedAthletes: declinedAthletes ?? this.declinedAthletes,
    );
  }
}