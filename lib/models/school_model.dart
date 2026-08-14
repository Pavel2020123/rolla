class SchoolModel {
  final String id;
  final String name;
  final String? logoUrl;
  final String description;
  final String city;
  final String address;
  final String phone;
  final String email;
  final String? info;
  final DateTime createdAt;
  final String ownerId;

  // Wompi
  final String? wompiPublicKey;
  final String? wompiPrivateKey;
  final String? wompiIntegritySecret;
  final bool wompiEnabled;

  SchoolModel({
    required this.id,
    required this.name,
    this.logoUrl,
    required this.description,
    required this.city,
    required this.address,
    required this.phone,
    required this.email,
    this.info,
    required this.createdAt,
    required this.ownerId,
    this.wompiPublicKey,
    this.wompiPrivateKey,
    this.wompiIntegritySecret,
    this.wompiEnabled = false,
  });

  factory SchoolModel.fromJson(Map<String, dynamic> json) {
    return SchoolModel(
      id: json['id'],
      name: json['name'],
      logoUrl: json['logoUrl'],
      description: json['description'],
      city: json['city'],
      address: json['address'],
      phone: json['phone'],
      email: json['email'],
      info: json['info'],
      createdAt: DateTime.parse(json['createdAt']),
      ownerId: json['ownerId'],
      wompiPublicKey: json['wompiPublicKey'],
      wompiPrivateKey: json['wompiPrivateKey'],
      wompiIntegritySecret: json['wompiIntegritySecret'],
      wompiEnabled: json['wompiEnabled'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'logoUrl': logoUrl,
      'description': description,
      'city': city,
      'address': address,
      'phone': phone,
      'email': email,
      'info': info,
      'createdAt': createdAt.toIso8601String(),
      'ownerId': ownerId,
      'wompiPublicKey': wompiPublicKey,
      'wompiPrivateKey': wompiPrivateKey,
      'wompiIntegritySecret': wompiIntegritySecret,
      'wompiEnabled': wompiEnabled,
    };
  }

  SchoolModel copyWith({
    String? id,
    String? name,
    String? logoUrl,
    String? description,
    String? city,
    String? address,
    String? phone,
    String? email,
    String? info,
    DateTime? createdAt,
    String? ownerId,
    String? wompiPublicKey,
    String? wompiPrivateKey,
    String? wompiIntegritySecret,
    bool? wompiEnabled,
  }) {
    return SchoolModel(
      id: id ?? this.id,
      name: name ?? this.name,
      logoUrl: logoUrl ?? this.logoUrl,
      description: description ?? this.description,
      city: city ?? this.city,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      info: info ?? this.info,
      createdAt: createdAt ?? this.createdAt,
      ownerId: ownerId ?? this.ownerId,
      wompiPublicKey: wompiPublicKey ?? this.wompiPublicKey,
      wompiPrivateKey: wompiPrivateKey ?? this.wompiPrivateKey,
      wompiIntegritySecret: wompiIntegritySecret ?? this.wompiIntegritySecret,
      wompiEnabled: wompiEnabled ?? this.wompiEnabled,
    );
  }
}