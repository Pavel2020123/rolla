class SchoolRequestModel {
  final String id;
  final String athleteId;
  final String athleteName;
  final String schoolId;
  final String schoolName;
  final String status; // 'pending', 'accepted', 'rejected'
  final DateTime createdAt;
  final DateTime? respondedAt;

  SchoolRequestModel({
    required this.id,
    required this.athleteId,
    required this.athleteName,
    required this.schoolId,
    required this.schoolName,
    this.status = 'pending',
    required this.createdAt,
    this.respondedAt,
  });

  factory SchoolRequestModel.fromJson(Map<String, dynamic> json) {
    return SchoolRequestModel(
      id: json['id'],
      athleteId: json['athleteId'],
      athleteName: json['athleteName'],
      schoolId: json['schoolId'],
      schoolName: json['schoolName'],
      status: json['status'],
      createdAt: DateTime.parse(json['createdAt']),
      respondedAt: json['respondedAt'] != null
          ? DateTime.parse(json['respondedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'athleteId': athleteId,
      'athleteName': athleteName,
      'schoolId': schoolId,
      'schoolName': schoolName,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'respondedAt': respondedAt?.toIso8601String(),
    };
  }
}