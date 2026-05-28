class AdminUser {
  final String id;
  final String? authUid;
  final String email;
  final String? fullName;
  final String role; // masjid_admin, super_admin
  final bool isActive;
  final DateTime createdAt;

  AdminUser({
    required this.id,
    this.authUid,
    required this.email,
    this.fullName,
    required this.role,
    required this.isActive,
    required this.createdAt,
  });

  bool get isSuperAdmin => role == 'super_admin';

  factory AdminUser.fromJson(Map<String, dynamic> json) {
    return AdminUser(
      id: json['id'] as String,
      authUid: json['auth_uid'] as String?,
      email: json['email'] as String,
      fullName: json['full_name'] as String?,
      role: json['role'] as String,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'auth_uid': authUid,
      'email': email,
      'full_name': fullName,
      'role': role,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
