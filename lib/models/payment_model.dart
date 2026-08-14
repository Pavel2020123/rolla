class PaymentModel {
  final String id;
  final String eventId;
  final String eventTitle;
  final String athleteId;
  final String athleteName;
  final String athleteEmail;
  final String schoolId;
  final double amount;
  final String status; // 'pending', 'completed', 'failed', 'refunded'
  final DateTime createdAt;
  final DateTime? paidAt;
  final String? reference; // referencia de Wompi
  final String? paymentMethod; // 'card', 'pse', 'transfer', etc.

  PaymentModel({
    required this.id,
    required this.eventId,
    required this.eventTitle,
    required this.athleteId,
    required this.athleteName,
    required this.athleteEmail,
    required this.schoolId,
    required this.amount,
    this.status = 'pending',
    required this.createdAt,
    this.paidAt,
    this.reference,
    this.paymentMethod,
  });

  bool get isPaid => status == 'completed';

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id'],
      eventId: json['eventId'],
      eventTitle: json['eventTitle'],
      athleteId: json['athleteId'],
      athleteName: json['athleteName'],
      athleteEmail: json['athleteEmail'],
      schoolId: json['schoolId'],
      amount: (json['amount'] as num).toDouble(),
      status: json['status'],
      createdAt: DateTime.parse(json['createdAt']),
      paidAt: json['paidAt'] != null ? DateTime.parse(json['paidAt']) : null,
      reference: json['reference'],
      paymentMethod: json['paymentMethod'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'eventId': eventId,
      'eventTitle': eventTitle,
      'athleteId': athleteId,
      'athleteName': athleteName,
      'athleteEmail': athleteEmail,
      'schoolId': schoolId,
      'amount': amount,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'paidAt': paidAt?.toIso8601String(),
      'reference': reference,
      'paymentMethod': paymentMethod,
    };
  }

  PaymentModel copyWith({
    String? id,
    String? eventId,
    String? eventTitle,
    String? athleteId,
    String? athleteName,
    String? athleteEmail,
    String? schoolId,
    double? amount,
    String? status,
    DateTime? createdAt,
    DateTime? paidAt,
    String? reference,
    String? paymentMethod,
  }) {
    return PaymentModel(
      id: id ?? this.id,
      eventId: eventId ?? this.eventId,
      eventTitle: eventTitle ?? this.eventTitle,
      athleteId: athleteId ?? this.athleteId,
      athleteName: athleteName ?? this.athleteName,
      athleteEmail: athleteEmail ?? this.athleteEmail,
      schoolId: schoolId ?? this.schoolId,
      amount: amount ?? this.amount,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      paidAt: paidAt ?? this.paidAt,
      reference: reference ?? this.reference,
      paymentMethod: paymentMethod ?? this.paymentMethod,
    );
  }
}