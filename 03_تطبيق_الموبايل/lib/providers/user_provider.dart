/// providers/user_provider.dart
library;

import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/user_service.dart';

class UserProvider extends ChangeNotifier {
  final _userService = UserService();

  UserModel? _currentUser;
  List<UserModel> _companyUsers = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  UserModel? get currentUser => _currentUser;
  List<UserModel> get companyUsers => _companyUsers;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// تحميل بيانات المستخدم الحالي
  Future<void> loadCurrentUser() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentUser = await _userService.getCurrentUser();
    } catch (e) {
      _error = 'خطأ في تحميل بيانات المستخدم: $e';
      print(_error);
    }

    _isLoading = false;
    notifyListeners();
  }

  /// تحميل جميع مستخدمي الشركة
  Future<void> loadCompanyUsers() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _companyUsers = await _userService.getCompanyUsers();
    } catch (e) {
      _error = 'خطأ في تحميل مستخدمي الشركة: $e';
      print(_error);
    }

    _isLoading = false;
    notifyListeners();
  }

  /// إنشاء مستخدم جديد
  Future<bool> createNewUser({
    required String email,
    required String password,
    required String displayName,
    String? phoneNumber,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _userService.createUser(
        email: email,
        password: password,
        displayName: displayName,
        phoneNumber: phoneNumber,
      );

      if (success) {
        await loadCompanyUsers();
      }

      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _error = 'خطأ في إنشاء مستخدم جديد: $e';
      print(_error);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// تحديث بيانات المستخدم
  Future<bool> updateCurrentUser({
    String? displayName,
    String? photoUrl,
    String? phoneNumber,
  }) async {
    if (_currentUser == null) return false;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updated = _currentUser!.copyWith(
        displayName: displayName,
        photoUrl: photoUrl,
        phoneNumber: phoneNumber,
      );

      final success = await _userService.updateUser(updated);
      if (success) {
        _currentUser = updated;
      }

      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _error = 'خطأ في تحديث بيانات المستخدم: $e';
      print(_error);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// تحديث دور المستخدم
  Future<bool> updateUserRole(String userId, UserRole role) async {
    _error = null;

    try {
      return await _userService.updateUserRole(userId, role);
    } catch (e) {
      _error = 'خطأ في تحديث دور المستخدم: $e';
      print(_error);
      return false;
    }
  }

  /// إضافة جهاز للمستخدم
  Future<bool> addDeviceToUser(String userId, String deviceId) async {
    _error = null;

    try {
      return await _userService.addDeviceToUser(userId, deviceId);
    } catch (e) {
      _error = 'خطأ في إضافة جهاز: $e';
      print(_error);
      return false;
    }
  }

  /// إزالة جهاز من المستخدم
  Future<bool> removeDeviceFromUser(String userId, String deviceId) async {
    _error = null;

    try {
      return await _userService.removeDeviceFromUser(userId, deviceId);
    } catch (e) {
      _error = 'خطأ في إزالة الجهاز: $e';
      print(_error);
      return false;
    }
  }

  /// حذف مستخدم
  Future<bool> deleteUser(String userId) async {
    _error = null;

    try {
      final success = await _userService.deleteUser(userId);
      if (success) {
        await loadCompanyUsers();
      }
      return success;
    } catch (e) {
      _error = 'خطأ في حذف المستخدم: $e';
      print(_error);
      return false;
    }
  }

  /// الاستماع لتحديثات المستخدم الحالي
  Stream<UserModel?> getCurrentUserStream() {
    return _userService.getCurrentUserStream();
  }

  /// الاستماع لجميع المستخدمين
  Stream<List<UserModel>> getCompanyUsersStream() {
    return _userService.getCompanyUsersStream();
  }

  /// التحقق من صلاحية المستخدم الحالي
  bool canManageUsers() => _currentUser?.canManageUsers() ?? false;
  bool canManageDevices() => _currentUser?.canManageDevices() ?? false;
  bool canViewAnalytics() => _currentUser?.canViewAnalytics() ?? false;
  bool canEditSettings() => _currentUser?.canEditSettings() ?? false;
}
