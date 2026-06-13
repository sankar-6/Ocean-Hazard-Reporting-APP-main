import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/widgets/adaptive_back_scope.dart';
import '../../../models/report_model.dart';
import '../widgets/media_gallery_widget.dart';
import '../widgets/report_status_widget.dart';
import '../widgets/report_actions_widget.dart';

class ReportDetailsScreen extends ConsumerStatefulWidget {
  final String reportId;

  const ReportDetailsScreen({
    super.key,
    required this.reportId,
  });

  @override
  ConsumerState<ReportDetailsScreen> createState() => _ReportDetailsScreenState();
}

class _ReportDetailsScreenState extends ConsumerState<ReportDetailsScreen> {
  bool _isLoading = true;
  ReportModel? _report;

  @override
  void initState() {
    super.initState();
    _loadReportDetails();
  }

  Future<void> _loadReportDetails() async {
    try {
      // TODO: Replace with actual API call
      await Future.delayed(const Duration(seconds: 1)); // Simulate API call
      
      // Mock data for demonstration
      setState(() {
        _report = ReportModel(
          id: widget.reportId,
          userId: 'user123',
          userName: 'John Doe',
          hazardType: HazardType.highWaves,
          title: 'High waves observed at Marina Beach',
          description: 'Waves reaching 3-4 meters height, dangerous for swimming. Strong winds from the southeast. Local fishermen advised to avoid going out to sea.',
          latitude: 13.0475,
          longitude: 80.2837,
          address: 'Marina Beach, Chennai, Tamil Nadu, India',
          status: ReportStatus.verified,
          severity: ReportSeverity.high,
          createdAt: DateTime.now().subtract(const Duration(hours: 2)),
          mediaUrls: [
            'https://example.com/image1.jpg',
            'https://example.com/image2.jpg',
            'https://example.com/video1.mp4',
          ],
        );
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load report details: $e'),
            backgroundColor: AppTheme.dangerColor,
          ),
        );
      }
    }
  }

  // No-op map created handler; controller not needed for mini map
  void _onMapCreated(GoogleMapController controller) {}

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: DetailAppBar(title: 'Report Details'),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_report == null) {
      return Scaffold(
        appBar: DetailAppBar(title: 'Report Details'),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: AppTheme.dangerColor,
              ),
              const SizedBox(height: 16),
              Text(
                'Report not found',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                'The requested report could not be loaded.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }

    return AdaptiveBackScope(
      child: Scaffold(
      appBar: DetailAppBar(
        title: 'Report Details',
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _shareReport(),
          ),
          PopupMenuButton<String>(
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: ListTile(
                  leading: Icon(Icons.edit),
                  title: Text('Edit Report'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'flag',
                child: ListTile(
                  leading: Icon(Icons.flag),
                  title: Text('Flag Report'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: ListTile(
                  leading: Icon(Icons.delete, color: Colors.red),
                  title: Text('Delete Report', style: TextStyle(color: Colors.red)),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            _buildHeaderSection(),
            
            // Status and Actions
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ReportStatusWidget(report: _report!),
                  const SizedBox(height: 16),
                  ReportActionsWidget(report: _report!),
                ],
              ),
            ),

            // Description Section
            _buildDescriptionSection(),

            // Media Section
            if (_report!.mediaUrls.isNotEmpty)
              _buildMediaSection(),

            // Location Section
            _buildLocationSection(),

            // Timeline Section
            _buildTimelineSection(),

            // Additional Info Section
            _buildAdditionalInfoSection(),

            const SizedBox(height: 100), // Bottom padding for FAB
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToMap(),
        backgroundColor: AppTheme.primaryColor,
        icon: const Icon(Icons.map),
        label: const Text('View on Map'),
      ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _getHazardTypeColor(_report!.hazardType).withOpacity(0.1),
            _getHazardTypeColor(_report!.hazardType).withOpacity(0.05),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hazard Type Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _getHazardTypeColor(_report!.hazardType),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _report!.hazardTypeDisplayName,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Title
          Text(
            _report!.title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Reporter and Time
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: AppTheme.primaryColor,
                child: Text(
                  _report!.userName.substring(0, 1).toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Reported by ${_report!.userName}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      _formatDateTime(_report!.createdAt),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionSection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Description',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _report!.description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMediaSection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Media',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          MediaGalleryWidget(
            imageUrls: _getImageUrls(_report!.mediaUrls),
            videoUrls: _getVideoUrls(_report!.mediaUrls),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationSection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Location',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          
          // Address
          Row(
            children: [
              Icon(
                Icons.location_on,
                color: AppTheme.primaryColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _report!.address ?? 'Address not available',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          // Coordinates
          Row(
            children: [
              Icon(
                Icons.gps_fixed,
                color: Colors.grey[600],
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '${_report!.latitude.toStringAsFixed(6)}, ${_report!.longitude.toStringAsFixed(6)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontFamily: 'monospace',
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Mini Map
          Container(
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: GoogleMap(
                onMapCreated: _onMapCreated,
                initialCameraPosition: CameraPosition(
                  target: LatLng(_report!.latitude, _report!.longitude),
                  zoom: 15,
                ),
                markers: {
                  Marker(
                    markerId: MarkerId(_report!.id),
                    position: LatLng(_report!.latitude, _report!.longitude),
                    infoWindow: InfoWindow(
                      title: _report!.title,
                      snippet: _report!.hazardTypeDisplayName,
                    ),
                  ),
                },
                zoomControlsEnabled: false,
                mapToolbarEnabled: false,
                myLocationButtonEnabled: false,
                scrollGesturesEnabled: false,
                zoomGesturesEnabled: false,
                tiltGesturesEnabled: false,
                rotateGesturesEnabled: false,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineSection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Timeline',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          
          // Timeline items
          _buildTimelineItem(
            'Report Created',
            _formatDateTime(_report!.createdAt),
            Icons.add_circle,
            AppTheme.primaryColor,
            isFirst: true,
          ),
          
          if (_report!.status == ReportStatus.verified)
            _buildTimelineItem(
              'Report Verified',
              _formatDateTime(_report!.createdAt.add(const Duration(hours: 1))),
              Icons.verified,
              AppTheme.successColor,
            ),
          
          if (_report!.status == ReportStatus.underReview)
            _buildTimelineItem(
              'Under Review',
              _formatDateTime(_report!.createdAt.add(const Duration(minutes: 30))),
              Icons.rate_review,
              AppTheme.warningColor,
            ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(
    String title,
    String time,
    IconData icon,
    Color color, {
    bool isFirst = false,
    bool isLast = false,
  }) {
    return Row(
      children: [
        Column(
          children: [
            if (!isFirst)
              Container(
                width: 2,
                height: 20,
                color: Colors.grey[300],
              ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 16,
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 20,
                color: Colors.grey[300],
              ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                time,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAdditionalInfoSection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Additional Information',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          
          _buildInfoRow('Report ID', _report!.id),
          _buildInfoRow('Severity Level', _report!.severityDisplayName),
          _buildInfoRow('Status', _report!.statusDisplayName),
          _buildInfoRow('Hazard Type', _report!.hazardTypeDisplayName),
          _buildInfoRow('Reporter ID', _report!.userId),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
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

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }

  void _shareReport() {
    // TODO: Implement share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Share functionality coming soon')),
    );
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'edit':
        // TODO: Navigate to edit screen
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Edit functionality coming soon')),
        );
        break;
      case 'flag':
        // TODO: Implement flag functionality
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Flag functionality coming soon')),
        );
        break;
      case 'delete':
        _showDeleteConfirmation();
        break;
    }
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Report'),
        content: const Text('Are you sure you want to delete this report? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Implement delete functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Delete functionality coming soon')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: AppTheme.dangerColor),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _navigateToMap() {
    // TODO: Navigate to map screen with this report highlighted
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Map navigation coming soon')),
    );
  }

  List<String> _getImageUrls(List<String> mediaUrls) {
    // Filter for image URLs based on file extensions
    return mediaUrls.where((url) {
      final String lowerUrl = url.toLowerCase();
      return lowerUrl.endsWith('.jpg') ||
          lowerUrl.endsWith('.jpeg') ||
          lowerUrl.endsWith('.png') ||
          lowerUrl.endsWith('.gif') ||
          lowerUrl.endsWith('.webp') ||
          lowerUrl.endsWith('.bmp');
    }).toList();
  }

  List<String> _getVideoUrls(List<String> mediaUrls) {
    // Filter for video URLs based on file extensions
    return mediaUrls.where((url) {
      final String lowerUrl = url.toLowerCase();
      return lowerUrl.endsWith('.mp4') ||
          lowerUrl.endsWith('.avi') ||
          lowerUrl.endsWith('.mov') ||
          lowerUrl.endsWith('.wmv') ||
          lowerUrl.endsWith('.flv') ||
          lowerUrl.endsWith('.webm') ||
          lowerUrl.endsWith('.mkv');
    }).toList();
  }
}
