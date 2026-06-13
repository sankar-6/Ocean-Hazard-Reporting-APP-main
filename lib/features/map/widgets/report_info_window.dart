import 'package:flutter/material.dart';

import '../../../models/report_model.dart';
import '../../../core/theme/app_theme.dart';

class ReportInfoWindow extends StatelessWidget {
  final ReportModel report;
  final VoidCallback onClose;
  final VoidCallback onViewDetails;

  const ReportInfoWindow({
    super.key,
    required this.report,
    required this.onClose,
    required this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
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
                const SizedBox(width: 8),
                IconButton(
                  onPressed: onClose,
                  icon: const Icon(Icons.close),
                  iconSize: 20,
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Title
            Text(
              report.title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            
            const SizedBox(height: 8),
            
            // Description
            Text(
              report.description,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            
            const SizedBox(height: 12),
            
            // Details Row
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
                const SizedBox(width: 16),
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
            
            const SizedBox(height: 12),
            
            // Severity and Reporter
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getSeverityColor(report.severity).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getSeverityIcon(report.severity),
                        size: 14,
                        color: _getSeverityColor(report.severity),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        report.severityDisplayName,
                        style: TextStyle(
                          color: _getSeverityColor(report.severity),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Text(
                  'by ${report.userName}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Action Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onViewDetails,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('View Details'),
              ),
            ),
          ],
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

  Color _getSeverityColor(ReportSeverity severity) {
    switch (severity) {
      case ReportSeverity.low:
        return AppTheme.successColor;
      case ReportSeverity.medium:
        return AppTheme.warningColor;
      case ReportSeverity.high:
        return AppTheme.dangerColor;
      case ReportSeverity.critical:
        return Colors.red[900]!;
    }
  }

  IconData _getSeverityIcon(ReportSeverity severity) {
    switch (severity) {
      case ReportSeverity.low:
        return Icons.info_outline;
      case ReportSeverity.medium:
        return Icons.warning_outlined;
      case ReportSeverity.high:
        return Icons.warning;
      case ReportSeverity.critical:
        return Icons.dangerous;
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
