import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String id;
  final String name;
  final String email;
  final UserRole role;
  final DateTime createdAt;

  // Hashed password for authentication
  final String? password;

  // Permanent badge ID for QR code login (reusable)
  final String? badgeId;

  AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.createdAt,
    this.password,
    this.badgeId,
  });

  factory AppUser.fromJson(Map<String, dynamic> json, String id) {
    return AppUser(
      id: id,
      name: json['name'] as String,
      email: json['email'] as String,
      role: UserRole.values.firstWhere(
        (e) => e.toString().split('.').last == json['role'],
      ),
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      password: json['password'] as String?,
      badgeId: json['badgeId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'role': role.toString().split('.').last,
      'createdAt': Timestamp.fromDate(createdAt),
      'password': password,
      'badgeId': badgeId,
    };
  }
}

enum UserRole { admin, cashier, stockManager }
