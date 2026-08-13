/// models/user_model.dart
library;

enum UserRole { owner, admin, operator, viewer }

class UserModel {
  final String uid;
  final String email;
  final String displayName;
  final String? photoUrl;
  final DateTime createdAt;
  final DateTime? lastLoginAt;
  final UserRole role;
  final List<String> deviceIds; // الأجهزة المسموح الوصول إليها
  final bool isActive;
  final String? phoneNumber;

  UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    this.photoUrl,
    required this.createdAt,
    this.lastLoginAt,
    this.role = UserRole.viewer,
    this.deviceIds = const [],
    this.isActive = true,
    this.phoneNumber,
  });

  /// تحويل من JSON (Firebase)
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] as String,
      email: json['email'] as String,
      displayName: json['displayName'] as String? ?? 'مستخدم',
      photoUrl: json['photoUrl'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String? ?? DateTime.now().toIso8601String()),
      lastLoginAt: json['lastLoginAt'] != null ? DateTime.parse(json['lastLoginAt'] as String) : null,
      role: _roleFromString(json['role'] as String? ?? 'viewer'),
      deviceIds: List<String>.from(json['deviceIds'] as List? ?? []),
      isActive: json['isActive'] as bool? ?? true,
      phoneNumber: json['phoneNumber'] as String?,
    );
  }

  /// تحويل إلى JSON
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'createdAt': createdAt.toIso8601String(),
      'lastLoginAt': lastLoginAt?.toIso8601String(),
      'role': _roleToString(role),
      'deviceIds': deviceIds,
      'isActive': isActive,
      'phoneNumber': phoneNumber,
    };
  }

  /// نسخة محدّثة من المستخدم
  UserModel copyWith({
    String? displayName,
    String? photoUrl,
    UserRole? role,
    List<String>? deviceIds,
    bool? isActive,
    String? phoneNumber,
  }) {
    return UserModel(
      uid: uid,
      email: email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt,
      lastLoginAt: lastLoginAt,
      role: role ?? this.role,
      deviceIds: deviceIds ?? this.deviceIds,
      isActive: isActive ?? this.isActive,
      phoneNumber: phoneNumber ?? this.phoneNumber,
    );
  }

  /// الحصول على اسم الدور بالعربية
  String get roleDisplayName {
    switch (role) {
      case UserRole.owner:
        return 'مالك';
      case UserRole.admin:
        return 'مدير';
      case UserRole.operator:
        return 'مشغّل';
      case UserRole.viewer:
        return 'عارض فقط';
    }
  }

  /// التحقق من الصلاحيات
  bool canManageUsers() => role == UserRole.owner || role == UserRole.admin;
  bool canManageDevices() => role == UserRole.owner || role == UserRole.admin || role == UserRole.operator;
  bool canViewAnalytics() => role != UserRole.viewer;
  bool canEditSettings() => role == UserRole.owner || role == UserRole.admin;

  static UserRole _roleFromString(String role) {
    switch (role.toLowerCase()) {
      case 'owner':
        return UserRole.owner;
      case 'admin':
        return UserRole.admin;
      case 'operator':
        return UserRole.operator;
      case 'viewer':
      default:
        return UserRole.viewer;
    }
  }

  static String _roleToString(UserRole role) {
    switch (role) {
      case UserRole.owner:
        return 'owner';
      case UserRole.admin:
        return 'admin';
      case UserRole.operator:
        return 'operator';
      case UserRole.viewer:
        return 'viewer';
    }
  }
}
