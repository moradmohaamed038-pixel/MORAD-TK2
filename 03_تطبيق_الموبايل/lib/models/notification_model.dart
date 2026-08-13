/// models/notification_model.dart
library;

enum NotificationType { alert, warning, info, error, success }
enum NotificationSeverity { low, medium, high, critical }

class NotificationModel {
  final String id;
  final String userId;
  final String deviceId;
  final String title;
  final String message;
  final NotificationType type;
  final NotificationSeverity severity;
  final DateTime createdAt;
  final DateTime? readAt;
  final Map<String, dynamic> data; // بيانات إضافية

  NotificationModel({
    required this.id,
    required this.userId,
    required this.deviceId,
    required this.title,
    required this.message,
    required this.type,
    required this.severity,
    required this.createdAt,
    this.readAt,
    this.data = const {},
  });

  bool get isRead => readAt != null;

  /// تحويل من JSON
  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      deviceId: json['deviceId'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      type: _typeFromString(json['type'] as String? ?? 'info'),
      severity: _severityFromString(json['severity'] as String? ?? 'medium'),
      createdAt: DateTime.parse(json['createdAt'] as String),
      readAt: json['readAt'] != null ? DateTime.parse(json['readAt'] as String) : null,
      data: Map<String, dynamic>.from(json['data'] as Map? ?? {}),
    );
  }

  /// تحويل إلى JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'deviceId': deviceId,
      'title': title,
      'message': message,
      'type': _typeToString(type),
      'severity': _severityToString(severity),
      'createdAt': createdAt.toIso8601String(),
      'readAt': readAt?.toIso8601String(),
      'data': data,
    };
  }

  /// اللون حسب الخطورة
  int get colorValue {
    switch (severity) {
      case NotificationSeverity.low:
        return 0xFF2196F3; // أزرق
      case NotificationSeverity.medium:
        return 0xFFFFC107; // أصفر
      case NotificationSeverity.high:
        return 0xFFFF9800; // برتقالي
      case NotificationSeverity.critical:
        return 0xFFE53935; // أحمر
    }
  }

  /// الأيقونة حسب النوع
  String get iconData {
    switch (type) {
      case NotificationType.alert:
        return '⚠️';
      case NotificationType.warning:
        return '🔔';
      case NotificationType.info:
        return 'ℹ️';
      case NotificationType.error:
        return '❌';
      case NotificationType.success:
        return '✅';
    }
  }

  static NotificationType _typeFromString(String type) {
    switch (type.toLowerCase()) {
      case 'alert':
        return NotificationType.alert;
      case 'warning':
        return NotificationType.warning;
      case 'error':
        return NotificationType.error;
      case 'success':
        return NotificationType.success;
      case 'info':
      default:
        return NotificationType.info;
    }
  }

  static String _typeToString(NotificationType type) {
    switch (type) {
      case NotificationType.alert:
        return 'alert';
      case NotificationType.warning:
        return 'warning';
      case NotificationType.info:
        return 'info';
      case NotificationType.error:
        return 'error';
      case NotificationType.success:
        return 'success';
    }
  }

  static NotificationSeverity _severityFromString(String severity) {
    switch (severity.toLowerCase()) {
      case 'low':
        return NotificationSeverity.low;
      case 'high':
        return NotificationSeverity.high;
      case 'critical':
        return NotificationSeverity.critical;
      case 'medium':
      default:
        return NotificationSeverity.medium;
    }
  }

  static String _severityToString(NotificationSeverity severity) {
    switch (severity) {
      case NotificationSeverity.low:
        return 'low';
      case NotificationSeverity.medium:
        return 'medium';
      case NotificationSeverity.high:
        return 'high';
      case NotificationSeverity.critical:
        return 'critical';
    }
  }
}
