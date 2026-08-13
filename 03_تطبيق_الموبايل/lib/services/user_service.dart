/// services/user_service.dart
library;

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';

class UserService {
  final _db = FirebaseDatabase.instance;
  final _auth = FirebaseAuth.instance;

  /// الحصول على بيانات المستخدم الحالي
  Future<UserModel?> getCurrentUser() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return null;

    try {
      final snapshot = await _db.ref('users/$userId').get();
      if (!snapshot.exists) return null;
      return UserModel.fromJson(Map<String, dynamic>.from(snapshot.value as Map));
    } catch (e) {
      print('خطأ في جلب بيانات المستخدم: $e');
      return null;
    }
  }

  /// الحصول على جميع مستخدمي الشركة
  Future<List<UserModel>> getCompanyUsers() async {
    try {
      final snapshot = await _db.ref('users').get();
      if (!snapshot.exists) return [];

      final users = <UserModel>[];
      for (var child in snapshot.children) {
        users.add(UserModel.fromJson(Map<String, dynamic>.from(child.value as Map)));
      }
      return users;
    } catch (e) {
      print('خطأ في جلب مستخدمي الشركة: $e');
      return [];
    }
  }

  /// إنشاء مستخدم جديد
  Future<bool> createUser({
    required String email,
    required String password,
    required String displayName,
    String? phoneNumber,
  }) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = UserModel(
        uid: userCredential.user!.uid,
        email: email,
        displayName: displayName,
        createdAt: DateTime.now(),
        role: UserRole.viewer, // الدور الافتراضي
        phoneNumber: phoneNumber,
      );

      await _db.ref('users/${user.uid}').set(user.toJson());
      return true;
    } catch (e) {
      print('خطأ في إنشاء مستخدم جديد: $e');
      return false;
    }
  }

  /// تحديث بيانات المستخدم
  Future<bool> updateUser(UserModel user) async {
    try {
      await _db.ref('users/${user.uid}').set(user.toJson());
      return true;
    } catch (e) {
      print('خطأ في تحديث بيانات المستخدم: $e');
      return false;
    }
  }

  /// تحديث دور المستخدم
  Future<bool> updateUserRole(String userId, UserRole role) async {
    try {
      await _db.ref('users/$userId/role').set(_roleToString(role));
      return true;
    } catch (e) {
      print('خطأ في تحديث دور المستخدم: $e');
      return false;
    }
  }

  /// إضافة جهاز لمستخدم
  Future<bool> addDeviceToUser(String userId, String deviceId) async {
    try {
      final userRef = _db.ref('users/$userId/deviceIds');
      final snapshot = await userRef.get();
      final deviceIds = List<String>.from(snapshot.value as List? ?? []);

      if (!deviceIds.contains(deviceId)) {
        deviceIds.add(deviceId);
        await userRef.set(deviceIds);
      }
      return true;
    } catch (e) {
      print('خطأ في إضافة جهاز للمستخدم: $e');
      return false;
    }
  }

  /// إزالة جهاز من مستخدم
  Future<bool> removeDeviceFromUser(String userId, String deviceId) async {
    try {
      final userRef = _db.ref('users/$userId/deviceIds');
      final snapshot = await userRef.get();
      var deviceIds = List<String>.from(snapshot.value as List? ?? []);

      deviceIds.removeWhere((id) => id == deviceId);
      await userRef.set(deviceIds);
      return true;
    } catch (e) {
      print('خطأ في إزالة جهاز من المستخدم: $e');
      return false;
    }
  }

  /// حذف مستخدم
  Future<bool> deleteUser(String userId) async {
    try {
      await _db.ref('users/$userId').remove();
      return true;
    } catch (e) {
      print('خطأ في حذف المستخدم: $e');
      return false;
    }
  }

  /// تحديث آخر تسجيل دخول
  Future<void> updateLastLogin(String userId) async {
    try {
      await _db.ref('users/$userId/lastLoginAt').set(DateTime.now().toIso8601String());
    } catch (e) {
      print('خطأ في تحديث آخر تسجيل دخول: $e');
    }
  }

  /// الاستماع لتحديثات المستخدم الحالي
  Stream<UserModel?> getCurrentUserStream() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      return Stream.value(null);
    }

    return _db.ref('users/$userId').onValue.map((event) {
      if (!event.snapshot.exists) return null;
      return UserModel.fromJson(Map<String, dynamic>.from(event.snapshot.value as Map));
    });
  }

  /// الاستماع لجميع المستخدمين
  Stream<List<UserModel>> getCompanyUsersStream() {
    return _db.ref('users').onValue.map((event) {
      if (!event.snapshot.exists) return [];

      final users = <UserModel>[];
      for (var child in event.snapshot.children) {
        users.add(UserModel.fromJson(Map<String, dynamic>.from(child.value as Map)));
      }
      return users;
    });
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
