class UserModel {
  static const Object _unset = Object();

  final String id;
  final String fullName;
  final String firstName;
  final String lastName;
  final String email;
  final String password;
  final String? role;
  final String? schoolId;
  final String? schoolName;
  final DateTime createdAt;
  final String category;
  final String level;
  final String modality;
  final String? photoUrl;
  final DateTime? birthDate;
  final int participationsCount;
  final int goldMedals;
  final int silverMedals;
  final int bronzeMedals;

  const UserModel({
    required this.id,
    required this.fullName,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
    required this.createdAt,
    this.role,
    this.schoolId,
    this.schoolName,
    this.category = 'Prejuvenil',
    this.level = 'Principiante',
    this.modality = 'Velocidad',
    this.photoUrl,
    this.birthDate,
    this.participationsCount = 0,
    this.goldMedals = 0,
    this.silverMedals = 0,
    this.bronzeMedals = 0,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final fullName = (json['fullName'] as String? ?? '').trim();
    final nameParts = fullName.isEmpty
        ? const <String>[]
        : fullName.split(RegExp(r'\s+'));
    final firstName =
        json['firstName'] as String? ??
        (nameParts.isNotEmpty ? nameParts.first : '');
    final lastName =
        json['lastName'] as String? ??
        (nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '');

    return UserModel(
      id: json['id'] as String? ?? '',
      fullName: fullName.isNotEmpty ? fullName : '$firstName $lastName'.trim(),
      firstName: firstName,
      lastName: lastName,
      email: json['email'] as String? ?? '',
      password: json['password'] as String? ?? '',
      role: json['role'] as String?,
      schoolId: json['schoolId'] as String?,
      schoolName: json['schoolName'] as String?,
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      category: json['category'] as String? ?? 'Prejuvenil',
      level: json['level'] as String? ?? 'Principiante',
      modality: json['modality'] as String? ?? 'Velocidad',
      photoUrl: json['photoUrl'] as String?,
      birthDate: DateTime.tryParse(json['birthDate'] as String? ?? ''),
      participationsCount: json['participationsCount'] as int? ?? 0,
      goldMedals: json['goldMedals'] as int? ?? 0,
      silverMedals: json['silverMedals'] as int? ?? 0,
      bronzeMedals: json['bronzeMedals'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'password': password,
      'role': role,
      'schoolId': schoolId,
      'schoolName': schoolName,
      'createdAt': createdAt.toIso8601String(),
      'category': category,
      'level': level,
      'modality': modality,
      'photoUrl': photoUrl,
      'birthDate': birthDate?.toIso8601String(),
      'participationsCount': participationsCount,
      'goldMedals': goldMedals,
      'silverMedals': silverMedals,
      'bronzeMedals': bronzeMedals,
    };
  }

  UserModel copyWith({
    String? id,
    String? fullName,
    String? firstName,
    String? lastName,
    String? email,
    String? password,
    Object? role = _unset,
    Object? schoolId = _unset,
    Object? schoolName = _unset,
    DateTime? createdAt,
    String? category,
    String? level,
    String? modality,
    Object? photoUrl = _unset,
    Object? birthDate = _unset,
    int? participationsCount,
    int? goldMedals,
    int? silverMedals,
    int? bronzeMedals,
  }) {
    return UserModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      password: password ?? this.password,
      role: identical(role, _unset) ? this.role : role as String?,
      schoolId: identical(schoolId, _unset)
          ? this.schoolId
          : schoolId as String?,
      schoolName: identical(schoolName, _unset)
          ? this.schoolName
          : schoolName as String?,
      createdAt: createdAt ?? this.createdAt,
      category: category ?? this.category,
      level: level ?? this.level,
      modality: modality ?? this.modality,
      photoUrl: identical(photoUrl, _unset)
          ? this.photoUrl
          : photoUrl as String?,
      birthDate: identical(birthDate, _unset)
          ? this.birthDate
          : birthDate as DateTime?,
      participationsCount: participationsCount ?? this.participationsCount,
      goldMedals: goldMedals ?? this.goldMedals,
      silverMedals: silverMedals ?? this.silverMedals,
      bronzeMedals: bronzeMedals ?? this.bronzeMedals,
    );
  }
}
