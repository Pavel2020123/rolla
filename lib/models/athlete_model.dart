class AthleteModel {
  final String id;
  final String firstName;
  final String lastName;
  final String role;
  final String schoolName;
  final String category;
  final String level;
  final String? modality;        // NUEVO: Velocidad, Figuras, etc.
  final String? photoUrl;        // NUEVO: ruta local de la foto
  final DateTime? birthDate;       // NUEVO
  final String? email;             // NUEVO: para conectar con usuario
  final int participationsCount;
  final int goldMedals;
  final int silverMedals;
  final int bronzeMedals;

  AthleteModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.role,
    required this.schoolName,
    required this.category,
    required this.level,
    this.modality,
    this.photoUrl,
    this.birthDate,
    this.email,
    required this.participationsCount,
    required this.goldMedals,
    required this.silverMedals,
    required this.bronzeMedals,
  });

  String get fullName => '$firstName $lastName';

  String get initials {
    final f = firstName.isNotEmpty ? firstName[0] : '';
    final l = lastName.isNotEmpty ? lastName[0] : '';
    return '$f$l'.toUpperCase();
  }

  int get totalMedals => goldMedals + silverMedals + bronzeMedals;

  factory AthleteModel.fromJson(Map<String, dynamic> json) {
    return AthleteModel(
      id: json['id'] as String,
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      role: json['role'] as String? ?? 'Deportista',
      schoolName: json['school_name'] as String,
      category: json['category'] as String,
      level: json['level'] as String,
      modality: json['modality'] as String?,
      photoUrl: json['photo_url'] as String?,
      birthDate: json['birth_date'] != null ? DateTime.parse(json['birth_date']) : null,
      email: json['email'] as String?,
      participationsCount: json['participations_count'] as int? ?? 0,
      goldMedals: json['gold_medals'] as int? ?? 0,
      silverMedals: json['silver_medals'] as int? ?? 0,
      bronzeMedals: json['bronze_medals'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'role': role,
      'school_name': schoolName,
      'category': category,
      'level': level,
      'modality': modality,
      'photo_url': photoUrl,
      'birth_date': birthDate?.toIso8601String(),
      'email': email,
      'participations_count': participationsCount,
      'gold_medals': goldMedals,
      'silver_medals': silverMedals,
      'bronze_medals': bronzeMedals,
    };
  }

  AthleteModel copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? role,
    String? schoolName,
    String? category,
    String? level,
    String? modality,
    String? photoUrl,
    DateTime? birthDate,
    String? email,
    int? participationsCount,
    int? goldMedals,
    int? silverMedals,
    int? bronzeMedals,
  }) {
    return AthleteModel(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      role: role ?? this.role,
      schoolName: schoolName ?? this.schoolName,
      category: category ?? this.category,
      level: level ?? this.level,
      modality: modality ?? this.modality,
      photoUrl: photoUrl ?? this.photoUrl,
      birthDate: birthDate ?? this.birthDate,
      email: email ?? this.email,
      participationsCount: participationsCount ?? this.participationsCount,
      goldMedals: goldMedals ?? this.goldMedals,
      silverMedals: silverMedals ?? this.silverMedals,
      bronzeMedals: bronzeMedals ?? this.bronzeMedals,
    );
  }
}