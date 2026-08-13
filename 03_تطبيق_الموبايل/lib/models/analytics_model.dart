/// models/analytics_model.dart
library;

class DeviceAnalytics {
  final String deviceId;
  final DateTime timestamp;
  final int totalCommands; // عدد الأوامر
  final int successfulCommands; // الأوامر الناجحة
  final int failedCommands; // الأوامر الفاشلة
  final double uptime; // نسبة التشغيل (%)
  final double connectionQuality; // جودة الاتصال (0-100)
  final Map<String, dynamic> sensorData; // بيانات الحساسات

  DeviceAnalytics({
    required this.deviceId,
    required this.timestamp,
    required this.totalCommands,
    required this.successfulCommands,
    required this.failedCommands,
    required this.uptime,
    required this.connectionQuality,
    this.sensorData = const {},
  });

  /// نسبة النجاح
  double get successRate {
    if (totalCommands == 0) return 100;
    return (successfulCommands / totalCommands) * 100;
  }

  /// تحويل من JSON
  factory DeviceAnalytics.fromJson(Map<String, dynamic> json) {
    return DeviceAnalytics(
      deviceId: json['deviceId'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      totalCommands: json['totalCommands'] as int? ?? 0,
      successfulCommands: json['successfulCommands'] as int? ?? 0,
      failedCommands: json['failedCommands'] as int? ?? 0,
      uptime: (json['uptime'] as num?)?.toDouble() ?? 100,
      connectionQuality: (json['connectionQuality'] as num?)?.toDouble() ?? 100,
      sensorData: Map<String, dynamic>.from(json['sensorData'] as Map? ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'deviceId': deviceId,
      'timestamp': timestamp.toIso8601String(),
      'totalCommands': totalCommands,
      'successfulCommands': successfulCommands,
      'failedCommands': failedCommands,
      'uptime': uptime,
      'connectionQuality': connectionQuality,
      'sensorData': sensorData,
    };
  }
}

/// تقرير يومي
class DailyReport {
  final String deviceId;
  final DateTime date;
  final int totalCommands;
  final int successfulCommands;
  final double averageUptime;
  final double averageConnectionQuality;
  final List<DeviceAnalytics> hourlyData;

  DailyReport({
    required this.deviceId,
    required this.date,
    required this.totalCommands,
    required this.successfulCommands,
    required this.averageUptime,
    required this.averageConnectionQuality,
    required this.hourlyData,
  });

  double get successRate {
    if (totalCommands == 0) return 100;
    return (successfulCommands / totalCommands) * 100;
  }
}

/// ملخص الأداء
class PerformanceSummary {
  final int totalDevices;
  final int activeDevices;
  final int inactiveDevices;
  final double averageUptime;
  final int totalCommands;
  final double successRate;
  final int alertsCount;

  PerformanceSummary({
    required this.totalDevices,
    required this.activeDevices,
    required this.inactiveDevices,
    required this.averageUptime,
    required this.totalCommands,
    required this.successRate,
    required this.alertsCount,
  });

  /// نسبة الأجهزة النشطة
  double get activePercentage {
    if (totalDevices == 0) return 0;
    return (activeDevices / totalDevices) * 100;
  }
}
