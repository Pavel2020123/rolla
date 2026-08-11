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
  final String ownerId; // ID del entrenador principal

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
    };
  }
}