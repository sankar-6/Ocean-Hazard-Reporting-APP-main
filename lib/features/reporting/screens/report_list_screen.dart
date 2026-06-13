import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/widgets/adaptive_back_scope.dart';
import '../../../core/providers/reports_provider.dart';
import '../../../models/report_model.dart';
import '../widgets/report_card.dart';
import '../widgets/report_filters.dart';

class ReportListScreen extends ConsumerStatefulWidget {
  const ReportListScreen({super.key});

  @override
  ConsumerState<ReportListScreen> createState() => _ReportListScreenState();
}

class _ReportListScreenState extends ConsumerState<ReportListScreen> {
  String _selectedFilter = 'all';
  String _selectedSort = 'newest';
  bool _showVerifiedOnly = false;

  List<ReportModel> _getFilteredReports(List<ReportModel> reports) {
    var filtered = reports.where((report) {
      if (_showVerifiedOnly && report.status != ReportStatus.verified) {
        return false;
      }
      
      if (_selectedFilter == 'all') return true;
      
      return report.hazardType.toString().split('.').last == _selectedFilter;
    }).toList();

    // Sort reports
    filtered.sort((a, b) {
      switch (_selectedSort) {
        case 'newest':
          return b.createdAt.compareTo(a.createdAt);
        case 'oldest':
          return a.createdAt.compareTo(b.createdAt);
        case 'severity':
          return b.severity.index.compareTo(a.severity.index);
        case 'verified':
          return b.status.index.compareTo(a.status.index);
        default:
          return b.createdAt.compareTo(a.createdAt);
      }
    });

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final reportsAsync = ref.watch(reportsProvider);

    return AdaptiveBackScope(
      popRoute: '/dashboard',
      child: Scaffold(
      appBar: DetailAppBar(
        title: 'All Reports',
        actions: [
          IconButton(
            icon: Icon(_showVerifiedOnly ? Icons.verified : Icons.verified_outlined),
            onPressed: () {
              setState(() => _showVerifiedOnly = !_showVerifiedOnly);
            },
            tooltip: 'Show Verified Only',
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() => _selectedSort = value);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'newest',
                child: Text('Newest First'),
              ),
              const PopupMenuItem(
                value: 'oldest',
                child: Text('Oldest First'),
              ),
              const PopupMenuItem(
                value: 'severity',
                child: Text('By Severity'),
              ),
            ],
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.sort, size: 20),
                  const SizedBox(width: 4),
                  Text(
                    _selectedSort == 'newest' ? 'Newest' :
                    _selectedSort == 'oldest' ? 'Oldest' : 'Severity',
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: reportsAsync.when(
        data: (reports) {
          final filteredReports = _getFilteredReports(reports);
          
          return Column(
            children: [
              // Filters
              ReportFilters(
                selectedFilter: _selectedFilter,
                onFilterChanged: (filter) {
                  setState(() => _selectedFilter = filter);
                },
              ),
              
              // Reports List
              Expanded(
                child: filteredReports.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredReports.length,
                        itemBuilder: (context, index) {
                          final report = filteredReports[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: ReportCard(
                              report: report,
                              onTap: () {
                                // TODO: Navigate to report details
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Report details: ${report.title}'),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error, size: 64, color: AppTheme.dangerColor),
              const SizedBox(height: 16),
              Text('Failed to load reports'),
              const SizedBox(height: 8),
              Text(error.toString()),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.refresh(reportsProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Navigate to report screen
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Report screen coming soon'),
            ),
          );
        },
        backgroundColor: AppTheme.dangerColor,
        child: const Icon(Icons.add),
      ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.report_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No reports found',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your filters or check back later',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
