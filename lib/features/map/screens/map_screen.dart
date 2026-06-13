import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/widgets/adaptive_back_scope.dart';
import '../../../core/services/custom_marker_service.dart';
import '../../../core/services/heatmap_service.dart';
import '../../../core/services/clustering_service.dart';
import '../../../models/report_model.dart';
import '../../../core/providers/reports_provider.dart';
import '../widgets/map_controls.dart';
import '../widgets/report_info_window.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  Set<Circle> _hotspotCircles = {};
  Set<Circle> _heatmapCircles = {};
  ReportModel? _selectedReport;
  bool _showHeatmap = false;
  bool _showVerifiedOnly = false;
  bool _showClustering = true;
  bool _showHotspots = false;
  bool _hasError = false;
  String? _errorMessage;
  List<HotspotArea> _hotspots = [];
  List<ReportModel> _reports = [];

  @override
  void initState() {
    super.initState();
    _initializeMap();
    _checkConnectivity();
    _setupMapFeatures();
  }

  @override
  void dispose() {
    ClusteringService.dispose();
    super.dispose();
  }

  Future<void> _initializeMap() async {
    try {
      // Check if Google Maps is available
      await Future.delayed(const Duration(milliseconds: 1000));

      // Additional check for web platform
      if (kIsWeb) {
        // Wait for Google Maps API to load
        await Future.delayed(const Duration(milliseconds: 500));
      }

      if (mounted) {
        setState(() {
          _hasError = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = 'Failed to initialize map: $e';
        });
      }
    }
  }

  Future<void> _updateMapMarkers() async {
    if (_mapController == null || _reports.isEmpty) return;

    final filteredReports = _reports
        .where((report) =>
            !_showVerifiedOnly || report.status == ReportStatus.verified)
        .toList();

    final Set<Marker> markers = {};
    
    for (final report in filteredReports) {
      final customIcon = await CustomMarkerService.createCustomMarker(
        report.hazardType,
        report.severity,
      );
      
      markers.add(
        Marker(
          markerId: MarkerId(report.id),
          position: LatLng(report.latitude, report.longitude),
          icon: customIcon,
          onTap: () => _onMarkerTapped(report),
          infoWindow: InfoWindow(
            title: report.title,
            snippet: '${report.hazardTypeDisplayName} - ${report.severityDisplayName}',
          ),
        ),
      );
    }

    if (mounted) {
      setState(() {
        _markers = markers;
      });
    }
  }

  Future<void> _checkConnectivity() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult.contains(ConnectivityResult.none)) {
      setState(() {
        _hasError = true;
        _errorMessage = 'No internet connection. Maps require internet access.';
      });
    }
  }

  Future<void> _setupMapFeatures() async {
    await _updateMapMarkers();
    _generateHotspots();
    if (_showHeatmap) {
      await _createHeatmapOverlay();
    }
    if (_showClustering) {
      _initializeClustering();
    }
  }

  Future<void> _createCustomMarkers() async {
    final filteredReports = _reports
        .where((report) =>
            !_showVerifiedOnly || report.status == ReportStatus.verified)
        .toList();

    final Set<Marker> newMarkers = {};
    
    for (final report in filteredReports) {
      final BitmapDescriptor icon = await CustomMarkerService.createCustomMarker(
        report.hazardType,
        report.severity,
      );
      
      newMarkers.add(
        Marker(
          markerId: MarkerId(report.id),
          position: LatLng(report.latitude, report.longitude),
          icon: icon,
          onTap: () => _onMarkerTapped(report),
          infoWindow: InfoWindow(
            title: report.title,
            snippet: '${report.hazardTypeDisplayName} - ${report.severityDisplayName}',
          ),
        ),
      );
    }
    
    if (mounted) {
      setState(() {
        _markers = newMarkers;
      });
    }
  }

  void _initializeClustering() {
    final filteredReports = _reports
        .where((report) =>
            !_showVerifiedOnly || report.status == ReportStatus.verified)
        .toList();
    
    ClusteringService.initialize(filteredReports, _updateMarkersFromClustering);
  }

  void _updateMarkersFromClustering(Set<Marker> markers) {
    if (mounted) {
      setState(() {
        _markers = markers;
      });
    }
  }

  void _generateHotspots() {
    final filteredReports = _reports
        .where((report) =>
            !_showVerifiedOnly || report.status == ReportStatus.verified)
        .toList();
    
    _hotspots = HeatmapService.generateHotspots(filteredReports);
    _updateHotspotCircles();
  }

  void _updateHotspotCircles() {
    if (!_showHotspots) {
      setState(() {
        _hotspotCircles = {};
      });
      return;
    }

    final Set<Circle> circles = {};
    
    for (int i = 0; i < _hotspots.length; i++) {
      final hotspot = _hotspots[i];
      circles.add(
        Circle(
          circleId: CircleId('hotspot_$i'),
          center: hotspot.center,
          radius: hotspot.radius,
          fillColor: hotspot.color,
          strokeColor: hotspot.color.withOpacity(0.8),
          strokeWidth: 2,
          onTap: () => _onHotspotTapped(hotspot),
        ),
      );
    }
    
    setState(() {
      _hotspotCircles = circles;
    });
  }

  Future<void> _createHeatmapOverlay() async {
    if (!_showHeatmap || _mapController == null) return;

    final filteredReports = _reports
        .where((report) =>
            !_showVerifiedOnly || report.status == ReportStatus.verified)
        .toList();
    
    final Set<Circle> heatmapCircles = HeatmapService.createHeatmapCircles(
      filteredReports,
    );
    
    if (mounted) {
      setState(() {
        _heatmapCircles = heatmapCircles;
      });
    }
  }

  // Removed - now using CustomMarkerService

  void _onMarkerTapped(ReportModel report) {
    setState(() {
      _selectedReport = report;
    });
  }

  void _onHotspotTapped(HotspotArea hotspot) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Hotspot Area'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Reports: ${hotspot.reports.length}'),
            Text('Max Severity: ${hotspot.maxSeverity.name}'),
            Text('Intensity: ${(hotspot.intensity * 100).toStringAsFixed(1)}%'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _centerOnLocation(hotspot.center);
            },
            child: const Text('View Details'),
          ),
        ],
      ),
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    print('Google Maps initialized successfully');
    setState(() {
      _hasError = false;
    });
    
    // Initialize features that require map controller
    _setupMapFeatures();
  }

  void _onCameraMove(CameraPosition position) {
    if (_showClustering) {
      ClusteringService.onCameraMove(position);
    }
  }

  void _onCameraIdle() {
    if (_showClustering) {
      ClusteringService.onCameraIdle();
    }
    
    // Update heatmap for new visible region
    if (_showHeatmap) {
      _createHeatmapOverlay();
    }
  }

  void _toggleHeatmap() {
    setState(() {
      _showHeatmap = !_showHeatmap;
      if (!_showHeatmap) {
        _heatmapCircles = {};
      }
    });
    
    if (_showHeatmap) {
      _createHeatmapOverlay();
    }
  }

  void _toggleClustering() {
    setState(() {
      _showClustering = !_showClustering;
    });
    
    if (_showClustering) {
      _initializeClustering();
    } else {
      _createCustomMarkers();
    }
  }

  void _toggleHotspots() {
    setState(() {
      _showHotspots = !_showHotspots;
    });
    _updateHotspotCircles();
  }

  void _toggleVerifiedOnly() {
    setState(() {
      _showVerifiedOnly = !_showVerifiedOnly;
    });
    _setupMapFeatures();
  }

  void _centerOnReports() {
    if (_reports.isEmpty) return;

    double minLat = _reports.first.latitude;
    double maxLat = _reports.first.latitude;
    double minLng = _reports.first.longitude;
    double maxLng = _reports.first.longitude;

    for (final report in _reports) {
      minLat = minLat < report.latitude ? minLat : report.latitude;
      maxLat = maxLat > report.latitude ? maxLat : report.latitude;
      minLng = minLng < report.longitude ? minLng : report.longitude;
      maxLng = maxLng > report.longitude ? maxLng : report.longitude;
    }

    _mapController?.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(minLat, minLng),
          northeast: LatLng(maxLat, maxLng),
        ),
        100,
      ),
    );
  }

  void _centerOnLocation(LatLng location) {
    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(location, 15),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Listen to reports provider and update state when data changes
    ref.listen<AsyncValue<List<ReportModel>>>(
      reportsProvider,
      (previous, next) {
        next.whenOrNull(
          data: (data) {
            if (_reports != data) {
              setState(() {
                _reports = data;
              });
              _setupMapFeatures();
            }
          },
        );
      },
    );

    // Get current reports state
    final reportsAsync = ref.watch(reportsProvider);

    return reportsAsync.when(
      data: (reports) {
        // Ensure _reports is up to date
        if (_reports != reports) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            setState(() {
              _reports = reports;
            });
            _setupMapFeatures();
          });
        }
        return _buildMapScaffold();
      },
      loading: () => Scaffold(
        appBar: DetailAppBar(title: 'Ocean Hazard Map'),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        appBar: DetailAppBar(title: 'Ocean Hazard Map'),
        body: Center(
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
    );
  }

  Widget _buildMapScaffold() {
    return AdaptiveBackScope(
      popRoute: '/dashboard',
      child: Scaffold(
      appBar: DetailAppBar(
        title: 'Ocean Hazard Map',
        actions: [
          IconButton(
            icon: Icon(_showHeatmap ? Icons.layers : Icons.layers_outlined),
            onPressed: _toggleHeatmap,
            tooltip: 'Toggle Heatmap',
          ),
          IconButton(
            icon: Icon(
              _showVerifiedOnly ? Icons.verified : Icons.verified_outlined,
            ),
            onPressed: _toggleVerifiedOnly,
            tooltip: 'Show Verified Only',
          ),
        ],
      ),
      body: _hasError
          ? _buildErrorWidget()
          : Stack(
              children: [
                GoogleMap(
                  onMapCreated: _onMapCreated,
                  onCameraMove: _onCameraMove,
                  onCameraIdle: _onCameraIdle,
                  initialCameraPosition: const CameraPosition(
                    target: LatLng(20.5937, 78.9629), // Center of India
                    zoom: 6,
                  ),
                  markers: _markers,
                  circles: {..._hotspotCircles, ..._heatmapCircles},
                  mapType: MapType.normal,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  zoomControlsEnabled: false,
                  mapToolbarEnabled: false,
                  onTap: (LatLng position) {
                    // Close info window when tapping on map
                    setState(() {
                      _selectedReport = null;
                    });
                  },
                ),

                // Map Controls
                Positioned(
                  top: 16,
                  right: 16,
                  child: MapControls(
                    onCenterOnReports: _centerOnReports,
                    onToggleHeatmap: _toggleHeatmap,
                    onToggleVerifiedOnly: _toggleVerifiedOnly,
                    onToggleClustering: _toggleClustering,
                    onToggleHotspots: _toggleHotspots,
                    showHeatmap: _showHeatmap,
                    showVerifiedOnly: _showVerifiedOnly,
                    showClustering: _showClustering,
                    showHotspots: _showHotspots,
                  ),
                ),

                // Report Info Window
                if (_selectedReport != null)
                  Positioned(
                    bottom: 16,
                    left: 16,
                    right: 16,
                    child: ReportInfoWindow(
                      report: _selectedReport!,
                      onClose: () => setState(() => _selectedReport = null),
                      onViewDetails: () {
                        context.push('/report/${_selectedReport!.id}');
                      },
                    ),
                  ),

                // Legend
                Positioned(
                  bottom: _selectedReport != null ? 200 : 16,
                  left: 16,
                  child: _buildLegend(),
                ),

                // Debug Info
                Positioned(top: 16, left: 16, child: _buildDebugInfo()),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        heroTag: "map_report_fab", // Unique hero tag
        onPressed: () {
          context.push('/report/create');
        },
        backgroundColor: AppTheme.dangerColor,
        child: const Icon(Icons.add),
      ),
      ),
    );
  }

  Widget _buildLegend() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hazard Types',
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ...HazardType.values.map((type) => _buildLegendItem(type)),
        ],
      ),
    );
  }

  Widget _buildLegendItem(HazardType type) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: _getHazardTypeColor(type),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            _getHazardTypeDisplayName(type),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  String _getHazardTypeDisplayName(HazardType type) {
    switch (type) {
      case HazardType.tsunami:
        return 'Tsunami';
      case HazardType.stormSurge:
        return 'Storm Surge';
      case HazardType.highWaves:
        return 'High Waves';
      case HazardType.coastalFlooding:
        return 'Coastal Flooding';
      case HazardType.abnormalTides:
        return 'Abnormal Tides';
      case HazardType.coastalErosion:
        return 'Coastal Erosion';
      case HazardType.other:
        return 'Other';
    }
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

  Widget _buildDebugInfo() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Debug Info:',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          Text(
            'Markers: ${_markers.length}',
            style: TextStyle(color: Colors.white, fontSize: 12),
          ),
          Text(
            'Reports: ${_reports.length}',
            style: TextStyle(color: Colors.white, fontSize: 12),
          ),
          Text(
            'Error: $_hasError',
            style: TextStyle(color: Colors.white, fontSize: 12),
          ),
          if (_errorMessage != null)
            Text(
              'Msg: ${_errorMessage!.substring(0, 20)}...',
              style: TextStyle(color: Colors.white, fontSize: 12),
            ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: AppTheme.dangerColor),
            const SizedBox(height: 16),
            Text(
              'Map Error',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppTheme.dangerColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? 'An error occurred while loading the map.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _hasError = false;
                  _errorMessage = null;
                });
                _checkConnectivity();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Make sure you have:',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              '• Internet connection\n• Valid Google Maps API key\n• Location permissions enabled',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
