import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole {
  citizen,
  volunteer,
  official,
  analyst,
  admin,
}

class UserModel {
  final String id;
  final String email;
  final String? fullName;
  final String? photoUrl;
  final UserRole role;
  final DateTime createdAt;
  final DateTime? lastLoginAt;
  final bool isVerified;
  final String? phoneNumber;
  final String? organization;
  final bool isActive;
  final DateTime? updatedAt;

  UserModel({
    required this.id,
    required this.email,
    this.fullName,
    this.photoUrl,
    this.role = UserRole.citizen,
    required this.createdAt,
    this.lastLoginAt,
    this.isVerified = false,
    this.phoneNumber,
    this.organization,
    this.isActive = true,
    this.updatedAt,
  });

  factory UserModel.fromFirebaseUser(User user) {
    return UserModel(
      id: user.uid,
      email: user.email ?? '',
      fullName: user.displayName,
      photoUrl: user.photoURL,
      createdAt: user.metadata.creationTime ?? DateTime.now(),
      lastLoginAt: user.metadata.lastSignInTime,
      isVerified: user.emailVerified,
    );
  }

  factory UserModel.fromFirestore(Map<String, dynamic> data) {
    return UserModel(
      id: data['id'] as String,
      email: data['email'] as String,
      fullName: data['fullName'] as String?,
      photoUrl: data['photoUrl'] as String?,
      role: UserRole.values.firstWhere(
        (e) => e.toString() == 'UserRole.${data['role']}',
        orElse: () => UserRole.citizen,
      ),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastLoginAt: (data['lastLoginAt'] as Timestamp?)?.toDate(),
      isVerified: data['isVerified'] as bool? ?? false,
      phoneNumber: data['phoneNumber'] as String?,
      organization: data['organization'] as String?,
      isActive: data['isActive'] as bool? ?? true,
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      fullName: json['fullName'] as String?,
      photoUrl: json['photoUrl'] as String?,
      role: UserRole.values.firstWhere(
        (e) => e.toString() == 'UserRole.${json['role']}',
        orElse: () => UserRole.citizen,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastLoginAt: json['lastLoginAt'] != null
          ? DateTime.parse(json['lastLoginAt'] as String)
          : null,
      isVerified: json['isVerified'] as bool? ?? false,
      phoneNumber: json['phoneNumber'] as String?,
      organization: json['organization'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'fullName': fullName,
      'photoUrl': photoUrl,
      'role': role.toString().split('.').last,
      'createdAt': createdAt.toIso8601String(),
      'lastLoginAt': lastLoginAt?.toIso8601String(),
      'isVerified': isVerified,
      'phoneNumber': phoneNumber,
      'organization': organization,
      'isActive': isActive,
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? fullName,
    String? photoUrl,
    UserRole? role,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    bool? isVerified,
    String? phoneNumber,
    String? organization,
    bool? isActive,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      photoUrl: photoUrl ?? this.photoUrl,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      isVerified: isVerified ?? this.isVerified,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      organization: organization ?? this.organization,
      isActive: isActive ?? this.isActive,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isOfficial => role == UserRole.official || role == UserRole.admin;
  bool get isAnalyst => role == UserRole.analyst || role == UserRole.admin;
  bool get isAdmin => role == UserRole.admin;
  bool get isVolunteer => role == UserRole.volunteer || role == UserRole.admin;
  bool get canModerate => role == UserRole.volunteer || role == UserRole.official || role == UserRole.admin;
  bool get canVerify => role == UserRole.official || role == UserRole.admin;
  bool get canViewAnalytics => role == UserRole.analyst || role == UserRole.admin;
}
