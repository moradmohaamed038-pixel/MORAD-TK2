/// services/analytics_service.dart
library;

import 'package:firebase_database/firebase_database.dart';
import '../models/analytics_model.dart';

class AnalyticsService {
  final _db = FirebaseDatabase.instance;

  /// تسجيل أمر جديد
  Future<void> recordCommand({
    required String deviceId,
    required bool isSuccessful,
  }) async {
    try {
      final now = DateTime.now();
      final dayKey = '${now.year}-${now.month}-${now.day}';
      final hourKey = now.hour;

      final analyticsRef = _db.ref('analytics/$deviceId/$dayKey/hours/$hourKey');
      final snapshot = await analyticsRef.get();

      int totalCommands = 0;
      int successfulCommands = 0;

      if (snapshot.exists) {
        final data = snapshot.value as Map;
        totalCommands = (data['totalCommands'] as int?) ?? 0;
        successfulCommands = (data['successfulCommands'] as int?) ?? 0;
      }

      totalCommands++;
      if (isSuccessful) successfulCommands++;

      await analyticsRef.update({
        'totalCommands': totalCommands,
        'successfulCommands': successfulCommands,
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('خطأ في تسجيل الأمر: $e');
    }
  }

  /// تسجيل حالة الاتصال
  Future<void> recordConnectionStatus({
    required String deviceId,
    required double quality,
  }) async {
    try {
      final now = DateTime.now();
      final dayKey = '${now.year}-${now.month}-${now.day}';
      final hourKey = now.hour;

      await _db.ref('analytics/$deviceId/$dayKey/hours/$hourKey/connectionQuality').set(quality);
    } catch (e) {
      print('خطأ في تسجيل حالة الاتصال: $e');
    }
  }

  /// الحصول على تحليلات اليوم
  Future<DailyReport?> getDailyReport(String deviceId, DateTime date) async {
    try {
      final dayKey = '${date.year}-${date.month}-${date.day}';
      final snapshot = await _db.ref('analytics/$deviceId/$dayKey').get();

      if (!snapshot.exists) return null;

      final data = snapshot.value as Map;
      final hoursData = data['hours'] as Map? ?? {};

      int totalCommands = 0;
      int successfulCommands = 0;
      double totalQuality = 0;
      int hourCount = 0;
      final hourlyDataList = <DeviceAnalytics>[];

      for (var entry in hoursData.entries) {
        final hourData = entry.value as Map;
        final commands = (hourData['totalCommands'] as int?) ?? 0;
        final successful = (hourData['successfulCommands'] as int?) ?? 0;
        final quality = (hourData['connectionQuality'] as num?)?.toDouble() ?? 100;

        totalCommands += commands;
        successfulCommands += successful;
        totalQuality += quality;
        hourCount++;

        hourlyDataList.add(DeviceAnalytics(
          deviceId: deviceId,
          timestamp: DateTime.now(),
          totalCommands: commands,
          successfulCommands: successful,
          failedCommands: commands - successful,
          uptime: 100,
          connectionQuality: quality,
        ));
      }

      return DailyReport(
        deviceId: deviceId,
        date: date,
        totalCommands: totalCommands,
        successfulCommands: successfulCommands,
        averageUptime: 100,
        averageConnectionQuality: hourCount > 0 ? totalQuality / hourCount : 100,
        hourlyData: hourlyDataList,
      );
    } catch (e) {
      print('خطأ في جلب تقرير اليوم: $e');
      return null;
    }
  }

  /// الحصول على ملخص الأداء
  Future<PerformanceSummary?> getPerformanceSummary(List<String> deviceIds) async {
    try {
      int totalCommands = 0;
      int successfulCommands = 0;
      int activeDevices = 0;

      for (final deviceId in deviceIds) {
        final snapshot = await _db.ref('devices/$deviceId/status').get();
        if (snapshot.exists && snapshot.value == 'connected') {
          activeDevices++;
        }

        // جلب الأوامر من آخر 24 ساعة
        final now = DateTime.now();
        for (int i = 0; i < 24; i++) {
          final checkDate = now.subtract(Duration(hours: i));
          final dayKey = '${checkDate.year}-${checkDate.month}-${checkDate.day}';

          final analyticsSnapshot = await _db.ref('analytics/$deviceId/$dayKey').get();
          if (analyticsSnapshot.exists) {
            final data = analyticsSnapshot.value as Map;
            final hours = data['hours'] as Map? ?? {};

            for (var hour in hours.values) {
              final hourData = hour as Map;
              totalCommands += (hourData['totalCommands'] as int?) ?? 0;
              successfulCommands += (hourData['successfulCommands'] as int?) ?? 0;
            }
          }
        }
      }

      final successRate = totalCommands > 0 ? (successfulCommands / totalCommands) * 100 : 100;

      return PerformanceSummary(
        totalDevices: deviceIds.length,
        activeDevices: activeDevices,
        inactiveDevices: deviceIds.length - activeDevices,
        averageUptime: 100,
        totalCommands: totalCommands,
        successRate: successRate,
        alertsCount: 0,
      );
    } catch (e) {
      print('خطأ في جلب ملخص الأداء: $e');
      return null;
    }
  }

  /// الحصول على أحدث التحليلات لجهاز
  Future<DeviceAnalytics?> getLatestAnalytics(String deviceId) async {
    try {
      final now = DateTime.now();
      final dayKey = '${now.year}-${now.month}-${now.day}';
      final hourKey = now.hour;

      final snapshot = await _db.ref('analytics/$deviceId/$dayKey/hours/$hourKey').get();

      if (!snapshot.exists) return null;

      final data = snapshot.value as Map;
      return DeviceAnalytics(
        deviceId: deviceId,
        timestamp: DateTime.now(),
        totalCommands: (data['totalCommands'] as int?) ?? 0,
        successfulCommands: (data['successfulCommands'] as int?) ?? 0,
        failedCommands: ((data['totalCommands'] as int?) ?? 0) - ((data['successfulCommands'] as int?) ?? 0),
        uptime: 100,
        connectionQuality: (data['connectionQuality'] as num?)?.toDouble() ?? 100,
      );
    } catch (e) {
      print('خطأ في جلب أحدث التحليلات: $e');
      return null;
    }
  }

  /// الاستماع لتحليلات الجهاز في الوقت الفعلي
  Stream<DeviceAnalytics?> getAnalyticsStream(String deviceId) {
    final now = DateTime.now();
    final dayKey = '${now.year}-${now.month}-${now.day}';
    final hourKey = now.hour;

    return _db.ref('analytics/$deviceId/$dayKey/hours/$hourKey').onValue.map((event) {
      if (!event.snapshot.exists) return null;

      final data = event.snapshot.value as Map;
      return DeviceAnalytics(
        deviceId: deviceId,
        timestamp: DateTime.now(),
        totalCommands: (data['totalCommands'] as int?) ?? 0,
        successfulCommands: (data['successfulCommands'] as int?) ?? 0,
        failedCommands: ((data['totalCommands'] as int?) ?? 0) - ((data['successfulCommands'] as int?) ?? 0),
        uptime: 100,
        connectionQuality: (data['connectionQuality'] as num?)?.toDouble() ?? 100,
      );
    });
  }
}
