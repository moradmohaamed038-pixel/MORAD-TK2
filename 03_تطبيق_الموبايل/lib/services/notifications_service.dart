/// services/notifications_service.dart
library;

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import '../models/notification_model.dart';

class NotificationsService {
  final _db = FirebaseDatabase.instance;
  final _auth = FirebaseAuth.instance;
  static const _uuid = Uuid();

  /// الحصول على إشعارات المستخدم الحالي
  Future<List<NotificationModel>> getUserNotifications({int limit = 50}) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return [];

    try {
      final snapshot = await _db
          .ref('notifications/$userId')
          .orderByChild('createdAt')
          .limitToLast(limit)
          .get();

      if (!snapshot.exists) return [];

      final notifications = <NotificationModel>[];
      for (var child in snapshot.children) {
        notifications.add(NotificationModel.fromJson(Map<String, dynamic>.from(child.value as Map)));
      }
      return notifications.reversed.toList();
    } catch (e) {
      print('خطأ في جلب الإشعارات: $e');
      return [];
    }
  }

  /// الحصول على الإشعارات غير المقروءة
  Future<List<NotificationModel>> getUnreadNotifications() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return [];

    try {
      final snapshot = await _db.ref('notifications/$userId').get();
      if (!snapshot.exists) return [];

      final unread = <NotificationModel>[];
      for (var child in snapshot.children) {
        final notification = NotificationModel.fromJson(Map<String, dynamic>.from(child.value as Map));
        if (!notification.isRead) {
          unread.add(notification);
        }
      }
      return unread;
    } catch (e) {
      print('خطأ في جلب الإشعارات غير المقروءة: $e');
      return [];
    }
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
    final userId = _auth.currentUser?.uid;
    if (userId == null) return false;

    try {
      final notification = NotificationModel(
        id: _uuid.v4(),
        userId: userId,
        deviceId: deviceId,
        title: title,
        message: message,
        type: type,
        severity: severity,
        createdAt: DateTime.now(),
        data: data ?? {},
      );

      await _db.ref('notifications/$userId/${notification.id}').set(notification.toJson());
      return true;
    } catch (e) {
      print('خطأ في إنشاء إشعار: $e');
      return false;
    }
  }

  /// وضع علامة قراءة على إشعار
  Future<bool> markAsRead(String notificationId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return false;

    try {
      await _db.ref('notifications/$userId/$notificationId/readAt').set(DateTime.now().toIso8601String());
      return true;
    } catch (e) {
      print('خطأ في وضع علامة قراءة: $e');
      return false;
    }
  }

  /// وضع علامة قراءة على جميع الإشعارات
  Future<bool> markAllAsRead() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return false;

    try {
      final snapshot = await _db.ref('notifications/$userId').get();
      if (!snapshot.exists) return true;

      final now = DateTime.now().toIso8601String();
      for (var child in snapshot.children) {
        await _db.ref('notifications/$userId/${child.key}/readAt').set(now);
      }
      return true;
    } catch (e) {
      print('خطأ في وضع علامة قراءة على الجميع: $e');
      return false;
    }
  }

  /// حذف إشعار
  Future<bool> deleteNotification(String notificationId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return false;

    try {
      await _db.ref('notifications/$userId/$notificationId').remove();
      return true;
    } catch (e) {
      print('خطأ في حذف الإشعار: $e');
      return false;
    }
  }

  /// حذف جميع الإشعارات المقروءة
  Future<bool> deleteReadNotifications() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return false;

    try {
      final snapshot = await _db.ref('notifications/$userId').get();
      if (!snapshot.exists) return true;

      for (var child in snapshot.children) {
        final notification = NotificationModel.fromJson(Map<String, dynamic>.from(child.value as Map));
        if (notification.isRead) {
          await _db.ref('notifications/$userId/${child.key}').remove();
        }
      }
      return true;
    } catch (e) {
      print('خطأ في حذف الإشعارات المقروءة: $e');
      return false;
    }
  }

  /// الاستماع لإشعارات المستخدم الحالي
  Stream<List<NotificationModel>> getUserNotificationsStream() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      return Stream.value([]);
    }

    return _db.ref('notifications/$userId').onValue.map((event) {
      if (!event.snapshot.exists) return [];

      final notifications = <NotificationModel>[];
      for (var child in event.snapshot.children) {
        notifications.add(NotificationModel.fromJson(Map<String, dynamic>.from(child.value as Map)));
      }
      return notifications;
    });
  }

  /// عدد الإشعارات غير المقروءة
  Stream<int> getUnreadCountStream() {
    return getUserNotificationsStream().map((notifications) {
      return notifications.where((n) => !n.isRead).length;
    });
  }
}
