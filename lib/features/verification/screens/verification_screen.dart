import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/widgets/adaptive_back_scope.dart';
import '../../../core/providers/reports_provider.dart';
import '../../../models/report_model.dart';

class VerificationScreen extends ConsumerWidget {
  const VerificationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportsAsync = ref.watch(reportsProvider);

    return AdaptiveBackScope(
      popRoute: '/dashboard',
      child: Scaffold(
      appBar: DetailAppBar(
        title: 'Report Verification',
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // TODO: Implement filter dialog
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'profile':
                  context.push('/profile');
                  break;
                case 'settings':
                  context.push('/settings');
                  break;
                case 'logout':
                  // TODO: Implement logout
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Logout functionality coming soon')),
                  );
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'profile',
                child: Row(
                  children: [
                    Icon(Icons.person_outline),
                    SizedBox(width: 8),
                    Text('Profile'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings_outlined),
                    SizedBox(width: 8),
                    Text('Settings'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Logout', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: reportsAsync.when(
        data: (reports) {
          // Filter reports that need verification (pending or under review)
          final pendingReports = reports
              .where((report) => 
                  report.status == ReportStatus.pending || 
                  report.status == ReportStatus.underReview)
              .toList();

          final verifiedTodayCount = reports
              .where((report) => 
                  report.status == ReportStatus.verified &&
                  report.verifiedAt != null &&
                  DateTime.now().difference(report.verifiedAt!).inDays == 0)
              .length;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome Section
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppTheme.warningColor, AppTheme.primaryColor],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Report Verification',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Review and verify hazard reports from citizens',
                        style: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Statistics
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        context,
                        'Pending',
                        '${pendingReports.length}',
                        Icons.pending,
                        AppTheme.warningColor,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatCard(
                        context,
                        'Verified Today',
                        '$verifiedTodayCount',
                        Icons.verified,
                        AppTheme.successColor,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Filter Options
                Text(
                  'Filter Reports',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),

                Wrap(
                  spacing: 8,
                  children: [
                    _buildFilterChip(context, 'All', true),
                    _buildFilterChip(context, 'High Priority', false),
                    _buildFilterChip(context, 'Recent', false),
                    _buildFilterChip(context, 'By Type', false),
                  ],
                ),

                const SizedBox(height: 24),

                // Reports List
                Text(
                  'Reports to Verify',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                // Dynamic reports list
                if (pendingReports.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Text(
                        'No reports pending verification',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ),
                  )
                else
                  ...pendingReports.take(10).map((report) => _buildReportCard(context, report)),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(BuildContext context, String label, bool isSelected) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        // TODO: Implement filter logic
      },
      selectedColor: AppTheme.primaryColor.withOpacity(0.2),
      checkmarkColor: AppTheme.primaryColor,
    );
  }

  Widget _buildReportCard(BuildContext context, ReportModel report) {

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    report.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getSeverityColor(report.severity).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    report.severityDisplayName,
                    style: TextStyle(
                      color: _getSeverityColor(report.severity),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Type: ${report.hazardTypeDisplayName} • Location: ${report.address ?? 'Unknown'}',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 4),
            Text(
              'Reported by ${report.userName} • ${_formatTimeAgo(report.createdAt)}',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey[500]),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // TODO: Implement view details
                    },
                    icon: const Icon(Icons.visibility),
                    label: const Text('View Details'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // TODO: Implement verify action
                    },
                    icon: const Icon(Icons.verified),
                    label: const Text('Verify'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.successColor,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // TODO: Implement reject action
                    },
                    icon: const Icon(Icons.close),
                    label: const Text('Reject'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.dangerColor,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getSeverityColor(ReportSeverity severity) {
    switch (severity) {
      case ReportSeverity.low:
        return AppTheme.successColor;
      case ReportSeverity.medium:
        return AppTheme.warningColor;
      case ReportSeverity.high:
        return AppTheme.primaryColor;
      case ReportSeverity.critical:
        return AppTheme.dangerColor;
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
