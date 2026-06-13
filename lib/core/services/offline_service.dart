import 'package:hive_flutter/hive_flutter.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:convert';

import '../../models/report_model.dart';

class OfflineService {
  static const String _reportsBox = 'offline_reports';
  static const String _settingsBox = 'app_settings';
  
  static Box<dynamic>? _reportsBoxInstance;
  static Box<dynamic>? _settingsBoxInstance;
  static bool _isOnline = true;

  static Future<void> initialize() async {
    _reportsBoxInstance = await Hive.openBox(_reportsBox);
    _settingsBoxInstance = await Hive.openBox(_settingsBox);
    
    // Listen to connectivity changes
    Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) {
  _isOnline = results.isNotEmpty && !results.contains(ConnectivityResult.none);
  if (_isOnline) {
    _syncOfflineReports();
  }
});
  }

  static bool get isOnline => _isOnline;

  // Save report for offline sync
  static Future<void> saveOfflineReport(ReportModel report) async {
    if (_reportsBoxInstance == null) return;
    
    final reportJson = report.toJson();
    await _reportsBoxInstance!.put(report.id, reportJson);
  }

  // Get all offline reports
  static List<ReportModel> getOfflineReports() {
    if (_reportsBoxInstance == null) return [];
    
    final reports = <ReportModel>[];
    for (final key in _reportsBoxInstance!.keys) {
      try {
        final reportData = _reportsBoxInstance!.get(key);
        if (reportData != null) {
          final report = ReportModel.fromJson(jsonDecode(reportData));
          reports.add(report);
        }
      } catch (e) {
        // Skip invalid reports
        continue;
      }
    }
    return reports;
  }

  // Remove report after successful sync
  static Future<void> removeOfflineReport(String reportId) async {
    if (_reportsBoxInstance == null) return;
    await _reportsBoxInstance!.delete(reportId);
  }

  // Sync offline reports when online
  static Future<void> _syncOfflineReports() async {
    if (!_isOnline) return;
    
    final offlineReports = getOfflineReports();
    for (final report in offlineReports) {
      try {
        // TODO: Implement API call to sync report
        // await ApiService.submitReport(report);
        await removeOfflineReport(report.id);
      } catch (e) {
        // Keep report for next sync attempt
        continue;
      }
    }
  }

  // Save app settings
  static Future<void> saveSetting(String key, dynamic value) async {
    if (_settingsBoxInstance == null) return;
    await _settingsBoxInstance!.put(key, value);
  }

  // Get app setting
  static T? getSetting<T>(String key, {T? defaultValue}) {
    if (_settingsBoxInstance == null) return defaultValue;
    return _settingsBoxInstance!.get(key, defaultValue: defaultValue) as T?;
  }

  // Clear all offline data
  static Future<void> clearOfflineData() async {
    if (_reportsBoxInstance != null) {
      await _reportsBoxInstance!.clear();
    }
    if (_settingsBoxInstance != null) {
      await _settingsBoxInstance!.clear();
    }
  }
}
