import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart' as intl;

import '../../../core/providers/role_provider.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/reports_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/widgets/adaptive_back_scope.dart';
import '../../../models/report_model.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userWithRole = ref.watch(currentUserWithRoleProvider);

    return AdaptiveBackScope(
      popRoute: '/dashboard',
      child: Scaffold(
      appBar: DetailAppBar(
        title: 'Analytics Dashboard',
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // TODO: Implement refresh analytics
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'profile':
                  context.go('/profile');
                  break;
                case 'settings':
                  context.go('/settings');
                  break;
                case 'logout':
                  ref.read(authServiceProvider).signOut();
                  context.go('/login');
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
      body: userWithRole.when(
        data: (user) {
          if (user == null || !user.canViewAnalytics) {
            return const Center(
              child: Text('Unauthorized: Analyst access required'),
            );
          }

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
                      colors: [AppTheme.oceanBlue, AppTheme.primaryColor],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Analytics Dashboard',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Monitor trends and analyze ocean hazard patterns',
                        style: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Key Metrics
                Text(
                  'Key Metrics',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: _buildMetricCard(
                        context,
                        'Total Reports',
                        '1,247',
                        '+12%',
                        Icons.report,
                        AppTheme.primaryColor,
                        true,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildMetricCard(
                        context,
                        'Verified Today',
                        '23',
                        '+8%',
                        Icons.verified,
                        AppTheme.successColor,
                        true,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: _buildMetricCard(
                        context,
                        'Active Alerts',
                        '15',
                        '-3%',
                        Icons.warning,
                        AppTheme.warningColor,
                        false,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildMetricCard(
                        context,
                        'Social Posts',
                        '156',
                        '+25%',
                        Icons.social_distance,
                        AppTheme.oceanBlue,
                        true,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // Charts Section
                Text(
                  'Hazard Type Distribution',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: SizedBox(
                      height: 300,
                      child: Consumer(
                        builder: (context, ref, child) {
                          final reportsAsync = ref.watch(allReportsProvider);
                          
                          return reportsAsync.when(
                            data: (reports) => _buildHazardTypePieChart(reports),
                            loading: () => const Center(child: CircularProgressIndicator()),
                            error: (error, stack) => Center(child: Text('Error: $error')),
                          );
                        },
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Hotspot Analysis
                Text(
                  'Hotspot Analysis',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _buildHotspotItem(
                          context,
                          'Chennai Coast',
                          'High Activity',
                          25,
                        ),
                        _buildHotspotItem(
                          context,
                          'Mumbai Bay',
                          'Medium Activity',
                          18,
                        ),
                        _buildHotspotItem(
                          context,
                          'Kochi Harbor',
                          'Low Activity',
                          8,
                        ),
                        _buildHotspotItem(
                          context,
                          'Goa Beaches',
                          'Medium Activity',
                          12,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Time Series Analysis
                Text(
                  'Report Trends (Last 7 Days)',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: SizedBox(
                      height: 300,
                      child: Consumer(
                        builder: (context, ref, child) {
                          final reportsAsync = ref.watch(allReportsProvider);
                          
                          return reportsAsync.when(
                            data: (reports) => _buildTimeSeriesChart(reports),
                            loading: () => const Center(child: CircularProgressIndicator()),
                            error: (error, stack) => Center(child: Text('Error: $error')),
                          );
                        },
                      ),
                    ),
                  ),
                ),
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

  Widget _buildMetricCard(
    BuildContext context,
    String title,
    String value,
    String change,
    IconData icon,
    Color color,
    bool isPositive,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const Spacer(),
                Text(
                  change,
                  style: TextStyle(
                    color: isPositive
                        ? AppTheme.successColor
                        : AppTheme.dangerColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
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


  Widget _buildHotspotItem(
    BuildContext context,
    String location,
    String activity,
    int reports,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(Icons.location_on, color: AppTheme.primaryColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  location,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  activity,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Text(
            '$reports reports',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHazardTypePieChart(List<ReportModel> reports) {
    // Calculate hazard type distribution
    final hazardCounts = <String, int>{};
    for (final report in reports) {
      final hazardType = report.hazardTypeDisplayName;
      hazardCounts[hazardType] = (hazardCounts[hazardType] ?? 0) + 1;
    }

    final chartData = hazardCounts.entries.map((entry) => 
      HazardTypeData(entry.key, entry.value, _getHazardTypeColor(entry.key))
    ).toList();

    return SfCircularChart(
      title: ChartTitle(text: 'Hazard Type Distribution'),
      legend: Legend(isVisible: true, position: LegendPosition.bottom),
      series: <PieSeries<HazardTypeData, String>>[
        PieSeries<HazardTypeData, String>(
          dataSource: chartData,
          xValueMapper: (HazardTypeData data, _) => data.hazardType,
          yValueMapper: (HazardTypeData data, _) => data.count,
          pointColorMapper: (HazardTypeData data, _) => data.color,
          dataLabelSettings: const DataLabelSettings(isVisible: true),
          enableTooltip: true,
        )
      ],
    );
  }

  Widget _buildTimeSeriesChart(List<ReportModel> reports) {
    // Get reports from last 7 days
    final now = DateTime.now();
    final sevenDaysAgo = now.subtract(const Duration(days: 7));
    
    final recentReports = reports.where((report) => 
      report.createdAt.isAfter(sevenDaysAgo)
    ).toList();

    // Group by day
    final dailyCounts = <DateTime, int>{};
    for (int i = 0; i < 7; i++) {
      final day = DateTime(now.year, now.month, now.day - i);
      dailyCounts[day] = 0;
    }

    for (final report in recentReports) {
      final day = DateTime(report.createdAt.year, report.createdAt.month, report.createdAt.day);
      if (dailyCounts.containsKey(day)) {
        dailyCounts[day] = dailyCounts[day]! + 1;
      }
    }

    final chartData = dailyCounts.entries.map((entry) => 
      DailyReportData(entry.key, entry.value)
    ).toList()..sort((a, b) => a.date.compareTo(b.date));

    return SfCartesianChart(
      title: ChartTitle(text: 'Reports Trend (Last 7 Days)'),
      primaryXAxis: DateTimeAxis(
        dateFormat: intl.DateFormat('MMM dd'),
        intervalType: DateTimeIntervalType.days,
      ),
      primaryYAxis: NumericAxis(
        title: AxisTitle(text: 'Number of Reports'),
      ),
      series: <CartesianSeries<DailyReportData, DateTime>>[
        LineSeries<DailyReportData, DateTime>(
          dataSource: chartData,
          xValueMapper: (DailyReportData data, _) => data.date,
          yValueMapper: (DailyReportData data, _) => data.count,
          color: AppTheme.primaryColor,
          markerSettings: const MarkerSettings(isVisible: true),
          dataLabelSettings: const DataLabelSettings(isVisible: true),
        )
      ],
      tooltipBehavior: TooltipBehavior(enable: true),
    );
  }

  Color _getHazardTypeColor(String hazardType) {
    switch (hazardType.toLowerCase()) {
      case 'high waves':
        return AppTheme.primaryColor;
      case 'coastal flooding':
        return AppTheme.oceanBlue;
      case 'storm surge':
        return AppTheme.warningColor;
      case 'tsunami':
        return AppTheme.dangerColor;
      case 'coastal erosion':
        return Colors.orange;
      case 'abnormal tides':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
}

class HazardTypeData {
  final String hazardType;
  final int count;
  final Color color;

  HazardTypeData(this.hazardType, this.count, this.color);
}

class DailyReportData {
  final DateTime date;
  final int count;

  DailyReportData(this.date, this.count);
}
