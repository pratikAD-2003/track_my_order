class UserModel {
  final String uid;
  final String name;
  final String phone;
  final String email;
  final String role; // 'customer' | 'partner'
  final DateTime createdAt;
  final bool isActive;

  // Partner-only optional fields
  final String? vehicleNumber;
  final double? rating;

  const UserModel({
    required this.uid,
    required this.name,
    required this.phone,
    required this.email,
    required this.role,
    required this.createdAt,
    required this.isActive,
    this.vehicleNumber,
    this.rating,
  });

  bool get isCustomer => role == 'customer';
  bool get isPartner => role == 'partner';

  // ── Serialisation ────────────────────────────────────────────────────────
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'phone': phone,
      'email': email,
      'role': role,
      'createdAt': createdAt.toIso8601String(),
      'isActive': isActive,
      if (vehicleNumber != null) 'vehicleNumber': vehicleNumber,
      if (rating != null) 'rating': rating,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map, String docId) {
    return UserModel(
      uid: docId,
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      email: map['email'] ?? '',
      role: map['role'] ?? 'customer',
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt']) ?? DateTime.now()
          : DateTime.now(),
      isActive: map['isActive'] ?? true,
      vehicleNumber: map['vehicleNumber'],
      rating: (map['rating'] as num?)?.toDouble(),
    );
  }

  UserModel copyWith({
    String? uid,
    String? name,
    String? phone,
    String? email,
    String? role,
    DateTime? createdAt,
    bool? isActive,
    String? vehicleNumber,
    double? rating,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
      vehicleNumber: vehicleNumber ?? this.vehicleNumber,
      rating: rating ?? this.rating,
    );
  }

  @override
  String toString() =>
      'UserModel(uid: $uid, name: $name, role: $role, email: $email)';
}
