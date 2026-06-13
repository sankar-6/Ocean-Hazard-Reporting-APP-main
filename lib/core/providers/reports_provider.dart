import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';
import 'package:flutter/services.dart';

import '../../models/report_model.dart';
import '../repositories/local_json_report_repository.dart';
import '../repositories/report_repository.dart';

/// Provider for repository implementation (easy to swap in tests)
final reportRepositoryProvider = Provider<ReportRepository>((ref) {
  return LocalJsonReportRepository();
});

/// Cached reports to avoid reloading
List<ReportModel>? _cachedReports;

// Provider for loading all reports from JSON (cached)
final allReportsProvider = FutureProvider<List<ReportModel>>((ref) async {
  if (_cachedReports != null) {
    return _cachedReports!;
  }
  
  try {
    final String response = await rootBundle.loadString('assets/data/reports_india.json');
    final List<dynamic> data = json.decode(response);
    
    _cachedReports = data.map((json) => ReportModel.fromJson(json)).toList();
    return _cachedReports!;
  } catch (e) {
    throw Exception('Failed to load reports: $e');
  }
});

// Paginated reports provider for better performance
final paginatedReportsProvider = FutureProvider.family<List<ReportModel>, PaginationParams>((ref, params) async {
  final allReports = await ref.watch(allReportsProvider.future);
  
  final startIndex = params.page * params.limit;
  final endIndex = (startIndex + params.limit).clamp(0, allReports.length);
  
  if (startIndex >= allReports.length) {
    return [];
  }
  
  return allReports.sublist(startIndex, endIndex);
});

// Default reports provider (first 100 for performance)
final reportsProvider = FutureProvider<List<ReportModel>>((ref) async {
  return ref.watch(paginatedReportsProvider(const PaginationParams(page: 0, limit: 100)).future);
});

// Map-specific reports provider (clustered for performance)
final mapReportsProvider = FutureProvider<List<ReportModel>>((ref) async {
  final allReports = await ref.watch(allReportsProvider.future);
  
  // For map, limit to 200 most recent reports to avoid performance issues
  final sortedReports = List<ReportModel>.from(allReports)
    ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    
  return sortedReports.take(200).toList();
});

// Verified reports provider for dashboard
final verifiedReportsProvider = FutureProvider<List<ReportModel>>((ref) async {
  final allReports = await ref.watch(allReportsProvider.future);
  
  return allReports
      .where((report) => report.status == ReportStatus.verified)
      .take(50) // Limit for performance
      .toList();
});

class PaginationParams {
  final int page;
  final int limit;
  
  const PaginationParams({required this.page, required this.limit});
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PaginationParams && other.page == page && other.limit == limit;
  }
  
  @override
  int get hashCode => page.hashCode ^ limit.hashCode;
}
