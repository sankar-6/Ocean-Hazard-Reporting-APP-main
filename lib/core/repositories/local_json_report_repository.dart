import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../../models/report_model.dart';
import 'report_repository.dart';

class LocalJsonReportRepository implements ReportRepository {
  final String assetPath;

  LocalJsonReportRepository({this.assetPath = 'assets/data/reports_india.json'});

  @override
  Future<List<ReportModel>> fetchReports() async {
    final raw = await rootBundle.loadString(assetPath);
    final List<dynamic> data = json.decode(raw) as List<dynamic>;
    return data
        .map((e) => ReportModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
