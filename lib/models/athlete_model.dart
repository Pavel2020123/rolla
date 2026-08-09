class AthleteModel {
  final String id;
  final String firstName;
  final String lastName;
  final String role;
  final String schoolName;
  final String category;
  final String level;
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
    required this.participationsCount,
    required this.goldMedals,
    required this.silverMedals,
    required this.bronzeMedals,
  });

  // Nombre completo calculado
  String get fullName => '$firstName $lastName';

  // Iniciales automáticas para el avatar (ej: Juan Pérez -> JP)
  String get initials {
    final f = firstName.isNotEmpty ? firstName[0] : '';
    final l = lastName.isNotEmpty ? lastName[0] : '';
    return '$f$l'.toUpperCase();
  }

  // Total de medallas
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
      'participations_count': participationsCount,
      'gold_medals': goldMedals,
      'silver_medals': silverMedals,
      'bronze_medals': bronzeMedals,
    };
  }
}