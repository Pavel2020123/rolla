class SchoolHistoryModel {
  final String id;
  final String schoolId;
  final String schoolName;
  final DateTime joinedAt;
  final DateTime? leftAt;
  final String? reason; // 'transfer', 'free_agent', 'removed'

  SchoolHistoryModel({
    required this.id,
    required this.schoolId,
    required this.schoolName,
    required this.joinedAt,
    this.leftAt,
    this.reason,
  });

  bool get isCurrent => leftAt == null;

  factory SchoolHistoryModel.fromJson(Map<String, dynamic> json) {
    return SchoolHistoryModel(
      id: json['id'] as String,
      schoolId: json['schoolId'] as String,
      schoolName: json['schoolName'] as String,
      joinedAt: DateTime.parse(json['joinedAt'] as String),
      leftAt: json['leftAt'] != null ? DateTime.parse(json['leftAt'] as String) : null,
      reason: json['reason'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'schoolId': schoolId,
      'schoolName': schoolName,
      'joinedAt': joinedAt.toIso8601String(),
      'leftAt': leftAt?.toIso8601String(),
      'reason': reason,
    };
  }

  SchoolHistoryModel copyWith({
    String? id,
    String? schoolId,
    String? schoolName,
    DateTime? joinedAt,
    DateTime? leftAt,
    String? reason,
  }) {
    return SchoolHistoryModel(
      id: id ?? this.id,
      schoolId: schoolId ?? this.schoolId,
      schoolName: schoolName ?? this.schoolName,
      joinedAt: joinedAt ?? this.joinedAt,
      leftAt: leftAt ?? this.leftAt,
      reason: reason ?? this.reason,
    );
  }
}