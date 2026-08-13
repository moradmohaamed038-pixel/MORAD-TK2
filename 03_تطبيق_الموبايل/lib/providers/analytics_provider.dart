/// providers/analytics_provider.dart
library;

import 'package:flutter/material.dart';
import '../models/analytics_model.dart';
import '../services/analytics_service.dart';

class AnalyticsProvider extends ChangeNotifier {
  final _analyticsService = AnalyticsService();

  DailyReport? _dailyReport;
  PerformanceSummary? _performanceSummary;
  DeviceAnalytics? _latestAnalytics;
  bool _isLoading = false;
  String? _error;

  // Getters
  DailyReport? get dailyReport => _dailyReport;
  PerformanceSummary? get performanceSummary => _performanceSummary;
  DeviceAnalytics? get latestAnalytics => _latestAnalytics;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// تحميل تقرير اليوم
  Future<void> loadDailyReport(String deviceId, DateTime date) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _dailyReport = await _analyticsService.getDailyReport(deviceId, date);
    } catch (e) {
      _error = 'خطأ في تحميل تقرير اليوم: $e';
      print(_error);
    }

    _isLoading = false;
    notifyListeners();
  }

  /// تحميل ملخص الأداء
  Future<void> loadPerformanceSummary(List<String> deviceIds) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _performanceSummary = await _analyticsService.getPerformanceSummary(deviceIds);
    } catch (e) {
      _error = 'خطأ في تحميل ملخص الأداء: $e';
      print(_error);
    }

    _isLoading = false;
    notifyListeners();
  }

  /// تحميل أحدث التحليلات
  Future<void> loadLatestAnalytics(String deviceId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _latestAnalytics = await _analyticsService.getLatestAnalytics(deviceId);
    } catch (e) {
      _error = 'خطأ في تحميل التحليلات: $e';
      print(_error);
    }

    _isLoading = false;
    notifyListeners();
  }

  /// تسجيل أمر جديد
  Future<void> recordCommand(String deviceId, bool isSuccessful) async {
    try {
      await _analyticsService.recordCommand(
        deviceId: deviceId,
        isSuccessful: isSuccessful,
      );
      // إعادة تحميل أحدث التحليلات
      await loadLatestAnalytics(deviceId);
    } catch (e) {
      _error = 'خطأ في تسجيل الأمر: $e';
      print(_error);
    }
  }

  /// تسجيل حالة الاتصال
  Future<void> recordConnectionStatus(String deviceId, double quality) async {
    try {
      await _analyticsService.recordConnectionStatus(
        deviceId: deviceId,
        quality: quality,
      );
    } catch (e) {
      _error = 'خطأ في تسجيل حالة الاتصال: $e';
      print(_error);
    }
  }

  /// الاستماع لتحليلات الجهاز
  Stream<DeviceAnalytics?> getAnalyticsStream(String deviceId) {
    return _analyticsService.getAnalyticsStream(deviceId);
  }
}
