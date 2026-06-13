import '../../models/report_model.dart';

/// Abstract repository to fetch reports
abstract class ReportRepository {
  Future<List<ReportModel>> fetchReports();
}
