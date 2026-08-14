class TransferRequestModel {
  final String id;
  final String athleteId;
  final String athleteName;
  final String athleteEmail;
  final String currentSchoolId;
  final String currentSchoolName;
  final String? targetSchoolId; // null si quiere quedar libre
  final String? targetSchoolName;
  final String type; // 'transfer' o 'free_agent'
  final String status; // 'pending', 'accepted_by_current', 'accepted_by_target', 'completed', 'rejected', 'cancelled'
  final DateTime createdAt;
  final DateTime? respondedAt;

  TransferRequestModel({
    required this.id,
    required this.athleteId,
    required this.athleteName,
    required this.athleteEmail,
    required this.currentSchoolId,
    required this.currentSchoolName,
    this.targetSchoolId,
    this.targetSchoolName,
    required this.type,
    this.status = 'pending',
    required this.createdAt,
    this.respondedAt,
  });

  factory TransferRequestModel.fromJson(Map<String, dynamic> json) {
    return TransferRequestModel(
      id: json['id'],
      athleteId: json['athleteId'],
      athleteName: json['athleteName'],
      athleteEmail: json['athleteEmail'],
      currentSchoolId: json['currentSchoolId'],
      currentSchoolName: json['currentSchoolName'],
      targetSchoolId: json['targetSchoolId'],
      targetSchoolName: json['targetSchoolName'],
      type: json['type'],
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
      'athleteEmail': athleteEmail,
      'currentSchoolId': currentSchoolId,
      'currentSchoolName': currentSchoolName,
      'targetSchoolId': targetSchoolId,
      'targetSchoolName': targetSchoolName,
      'type': type,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'respondedAt': respondedAt?.toIso8601String(),
    };
  }
}