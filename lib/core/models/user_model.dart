/// User Model
/// Represents a user in the system
class UserModel {
  final String id;
  final String email;
  final String username;
  final String? fullName;
  final String? phone;
  final String? location;
  final String role;
  final bool enabled;
  final String? emergencyContactName;
  final String? emergencyContactPhone;
  final String? avatarUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserModel({
    required this.id,
    required this.email,
    required this.username,
    this.fullName,
    this.phone,
    this.location,
    required this.role,
    required this.enabled,
    this.emergencyContactName,
    this.emergencyContactPhone,
    this.avatarUrl,
    this.createdAt,
    this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      email: json['email'] ?? '',
      username: json['username'] ?? '',
      fullName: json['fullName'],
      phone: json['phone'],
      location: json['location'],
      role: json['role'] ?? 'CIVILIAN',
      enabled: json['enabled'] ?? true,
      emergencyContactName: json['emergencyContactName'],
      emergencyContactPhone: json['emergencyContactPhone'],
      avatarUrl: json['avatarUrl'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'fullName': fullName,
      'phone': phone,
      'location': location,
      'role': role,
      'enabled': enabled,
      'emergencyContactName': emergencyContactName,
      'emergencyContactPhone': emergencyContactPhone,
      'avatarUrl': avatarUrl,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}

