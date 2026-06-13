import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../models/report_model.dart';
import '../config/app_config.dart';
import 'report_repository.dart';

class ApiReportRepository implements ReportRepository {
  final String baseUrl;
  final http.Client _client;

  ApiReportRepository({String? baseUrl, http.Client? client})
      : baseUrl = baseUrl ?? AppConfig.apiBaseUrl,
        _client = client ?? http.Client();

  @override
  Future<List<ReportModel>> fetchReports() async {
    final uri = Uri.parse('$baseUrl/api/reports');
    final resp = await _client.get(uri, headers: const {
      'Accept': 'application/json',
    });

    if (resp.statusCode != 200) {
      throw Exception('Failed to load reports: ${resp.statusCode} ${resp.body}');
    }

    final List<dynamic> data = json.decode(resp.body) as List<dynamic>;
    return data
        .map((e) => ReportModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
