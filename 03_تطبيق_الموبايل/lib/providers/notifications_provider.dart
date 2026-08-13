/// providers/notifications_provider.dart
library;

import 'package:flutter/material.dart';
import '../models/notification_model.dart';
import '../services/notifications_service.dart';

class NotificationsProvider extends ChangeNotifier {
  final _notificationsService = NotificationsService();

  List<NotificationModel> _notifications = [];
  List<NotificationModel> _unreadNotifications = [];
  int _unreadCount = 0;
  bool _isLoading = false;
  String? _error;

  // Getters
  List<NotificationModel> get notifications => _notifications;
  List<NotificationModel> get unreadNotifications => _unreadNotifications;
  int get unreadCount => _unreadCount;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// تحميل إشعارات المستخدم
  Future<void> loadNotifications({int limit = 50}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _notifications = await _notificationsService.getUserNotifications(limit: limit);
      _unreadNotifications = _notifications.where((n) => !n.isRead).toList();
      _unreadCount = _unreadNotifications.length;
    } catch (e) {
      _error = 'خطأ في تحميل الإشعارات: $e';
      print(_error);
    }

    _isLoading = false;
    notifyListeners();
  }

  /// إنشاء إشعار جديد
  Future<bool> createNotification({
    required String deviceId,
    required String title,
    required String message,
    required NotificationType type,
    required NotificationSeverity severity,
    Map<String, dynamic>? data,
  }) async {
    _error = null;

    try {
      final success = await _notificationsService.createNotification(
        deviceId: deviceId,
        title: title,
        message: message,
        type: type,
        severity: severity,
        data: data,
      );

      if (success) {
        await loadNotifications();
      }

      return success;
    } catch (e) {
      _error = 'خطأ في إنشاء إشعار: $e';
      print(_error);
      return false;
    }
  }

  /// وضع علامة قراءة على إشعار
  Future<bool> markAsRead(String notificationId) async {
    _error = null;

    try {
      final success = await _notificationsService.markAsRead(notificationId);
      if (success) {
        await loadNotifications();
      }
      return success;
    } catch (e) {
      _error = 'خطأ في وضع علامة القراءة: $e';
      print(_error);
      return false;
    }
  }

  /// وضع علامة قراءة على جميع الإشعارات
  Future<bool> markAllAsRead() async {
    _error = null;

    try {
      final success = await _notificationsService.markAllAsRead();
      if (success) {
        await loadNotifications();
      }
      return success;
    } catch (e) {
      _error = 'خطأ: $e';
      print(_error);
      return false;
    }
  }

  /// حذف إشعار
  Future<bool> deleteNotification(String notificationId) async {
    _error = null;

    try {
      final success = await _notificationsService.deleteNotification(notificationId);
      if (success) {
        await loadNotifications();
      }
      return success;
    } catch (e) {
      _error = 'خطأ في حذف الإشعار: $e';
      print(_error);
      return false;
    }
  }

  /// حذف جميع الإشعارات المقروءة
  Future<bool> deleteReadNotifications() async {
    _error = null;

    try {
      final success = await _notificationsService.deleteReadNotifications();
      if (success) {
        await loadNotifications();
      }
      return success;
    } catch (e) {
      _error = 'خطأ: $e';
      print(_error);
      return false;
    }
  }

  /// الاستماع لإشعارات جديدة
  Stream<List<NotificationModel>> getNotificationsStream() {
    return _notificationsService.getUserNotificationsStream();
  }

  /// الاستماع لعدد الإشعارات غير المقروءة
  Stream<int> getUnreadCountStream() {
    return _notificationsService.getUnreadCountStream();
  }
}
