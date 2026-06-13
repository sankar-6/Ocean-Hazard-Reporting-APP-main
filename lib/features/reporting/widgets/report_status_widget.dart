import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/report_model.dart';

class ReportStatusWidget extends StatelessWidget {
  final ReportModel report;

  const ReportStatusWidget({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _getStatusColor(report.status).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getStatusColor(report.status).withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _getStatusColor(report.status),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getStatusIcon(report.status),
                  color: Colors.white,
                  size: 16,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Report Status',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      report.statusDisplayName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: _getStatusColor(report.status),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _getSeverityColor(report.severity),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getSeverityIcon(report.severity),
                      color: Colors.white,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      report.severityDisplayName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Text(
            _getStatusDescription(report.status),
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
          ),

          if (report.status == ReportStatus.verified) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.verified_user,
                  color: AppTheme.successColor,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  'Verified by authorities',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.successColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],

          if (report.status == ReportStatus.underReview) ...[
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: 0.6, // Mock progress
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                _getStatusColor(report.status),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Review in progress...',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
            ),
          ],
        ],
      ),
    );
  }

  Color _getStatusColor(ReportStatus status) {
    switch (status) {
      case ReportStatus.pending:
        return AppTheme.warningColor;
      case ReportStatus.verified:
        return AppTheme.successColor;
      case ReportStatus.rejected:
        return AppTheme.dangerColor;
      case ReportStatus.underReview:
        return AppTheme.primaryColor;
    }
  }

  IconData _getStatusIcon(ReportStatus status) {
    switch (status) {
      case ReportStatus.pending:
        return Icons.schedule;
      case ReportStatus.verified:
        return Icons.verified;
      case ReportStatus.rejected:
        return Icons.cancel;
      case ReportStatus.underReview:
        return Icons.rate_review;
    }
  }

  String _getStatusDescription(ReportStatus status) {
    switch (status) {
      case ReportStatus.pending:
        return 'This report is waiting for review by our team. We typically review reports within 24 hours.';
      case ReportStatus.verified:
        return 'This report has been verified by our team and confirmed as accurate. It will be used for hazard monitoring.';
      case ReportStatus.rejected:
        return 'This report was reviewed and could not be verified. It may contain inaccurate information.';
      case ReportStatus.underReview:
        return 'Our team is currently reviewing this report. This process may take a few hours.';
    }
  }

  Color _getSeverityColor(ReportSeverity severity) {
    switch (severity) {
      case ReportSeverity.low:
        return AppTheme.successColor;
      case ReportSeverity.medium:
        return AppTheme.warningColor;
      case ReportSeverity.high:
        return AppTheme.dangerColor;
      case ReportSeverity.critical:
        return const Color(0xFFB71C1C); // Dark red
    }
  }

  IconData _getSeverityIcon(ReportSeverity severity) {
    switch (severity) {
      case ReportSeverity.low:
        return Icons.info;
      case ReportSeverity.medium:
        return Icons.warning;
      case ReportSeverity.high:
        return Icons.warning;
      case ReportSeverity.critical:
        return Icons.dangerous;
    }
  }
}
