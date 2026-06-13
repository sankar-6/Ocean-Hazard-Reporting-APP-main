import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/report_model.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/providers/reports_provider.dart';

class RecentReportsList extends ConsumerWidget {
  const RecentReportsList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportsAsync = ref.watch(verifiedReportsProvider);

    return reportsAsync.when(
      data: (reports) {
        // Get the 5 most recent reports
        final recentReports = reports
            .where((report) => report.status == ReportStatus.verified)
            .toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
        
        final limitedReports = recentReports.take(5).toList();

        if (limitedReports.isEmpty) {
          return const Center(
            child: Text('No recent reports available'),
          );
        }

        return Column(
          children: limitedReports.map((report) => _buildReportCard(context, report)).toList(),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text('Failed to load reports: $error'),
      ),
    );
  }

  Widget _buildReportCard(BuildContext context, ReportModel report) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          // TODO: Navigate to report details
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getHazardTypeColor(report.hazardType).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      report.hazardTypeDisplayName,
                      style: TextStyle(
                        color: _getHazardTypeColor(report.hazardType),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(report.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      report.statusDisplayName,
                      style: TextStyle(
                        color: _getStatusColor(report.status),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                report.title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Text(
                report.description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      report.address ?? 'Unknown location',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatTimeAgo(report.createdAt),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getHazardTypeColor(HazardType type) {
    switch (type) {
      case HazardType.tsunami:
        return AppTheme.dangerColor;
      case HazardType.stormSurge:
        return AppTheme.warningColor;
      case HazardType.highWaves:
        return AppTheme.primaryColor;
      case HazardType.coastalFlooding:
        return AppTheme.oceanBlue;
      case HazardType.abnormalTides:
        return AppTheme.secondaryColor;
      case HazardType.coastalErosion:
        return Colors.brown;
      case HazardType.other:
        return Colors.grey;
    }
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

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
