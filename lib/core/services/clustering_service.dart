import 'dart:math' as math;
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../models/report_model.dart';
import 'custom_marker_service.dart';

class ClusteringService {
  static Function(Set<Marker>)? _updateMarkers;

  /// Initializes clustering (no-op fallback). Immediately renders normal markers.
  static void initialize(
    List<ReportModel> reports,
    Function(Set<Marker>) updateMarkers,
  ) {
    _updateMarkers = updateMarkers;
    _renderSimpleMarkers(reports);
  }

  static Future<void> _renderSimpleMarkers(List<ReportModel> reports) async {
    final Set<Marker> markers = {};
    for (final r in reports) {
      final icon = await CustomMarkerService.createCustomMarker(r.hazardType, r.severity);
      markers.add(
        Marker(
          markerId: MarkerId(r.id),
          position: LatLng(r.latitude, r.longitude),
          icon: icon,
          infoWindow: InfoWindow(title: r.title, snippet: '${r.hazardTypeDisplayName} - ${r.severityDisplayName}'),
        ),
      );
    }
    _updateMarkers?.call(markers);
  }

  /// Updates clustering with new reports (no-op fallback: render markers)
  static void updateReports(List<ReportModel> reports) {
    _renderSimpleMarkers(reports);
  }

  /// Updates clusters based on camera position (no-op)
  static void onCameraMove(CameraPosition position) {}

  /// Updates clusters when camera movement ends (no-op)
  static void onCameraIdle() {}

  // Cluster marker builder removed in fallback implementation

  // Helper removed in fallback

  /// Generates density-based clusters without using the cluster manager
  static List<ReportCluster> generateDensityClusters(
    List<ReportModel> reports, {
    double clusterRadius = 2000, // 2km in meters
    int minReportsForCluster = 2,
  }) {
    final List<ReportCluster> clusters = [];
    final List<ReportModel> unprocessedReports = List.from(reports);

    while (unprocessedReports.isNotEmpty) {
      final ReportModel seedReport = unprocessedReports.removeAt(0);
      final List<ReportModel> clusterReports = [seedReport];

      // Find nearby reports
      unprocessedReports.removeWhere((report) {
        final double distance = _calculateDistance(
          seedReport.latitude,
          seedReport.longitude,
          report.latitude,
          report.longitude,
        );

        if (distance <= clusterRadius) {
          clusterReports.add(report);
          return true;
        }
        return false;
      });

      // Create cluster
      if (clusterReports.length >= minReportsForCluster) {
        clusters.add(ReportCluster(
          id: 'cluster_${clusters.length}',
          reports: clusterReports,
          center: _calculateCentroid(clusterReports),
          radius: _calculateClusterRadius(clusterReports),
        ));
      } else {
        // Single report, create individual cluster
        clusters.add(ReportCluster(
          id: 'single_${seedReport.id}',
          reports: [seedReport],
          center: LatLng(seedReport.latitude, seedReport.longitude),
          radius: 100, // Small radius for individual reports
        ));
      }
    }

    return clusters;
  }

  /// Calculates distance between two coordinates in meters
  static double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371000; // Earth's radius in meters
    final double dLat = _degreesToRadians(lat2 - lat1);
    final double dLon = _degreesToRadians(lon2 - lon1);

    final double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_degreesToRadians(lat1)) *
            math.cos(_degreesToRadians(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);

    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadius * c;
  }

  /// Converts degrees to radians
  static double _degreesToRadians(double degrees) {
    return degrees * (math.pi / 180);
  }

  /// Calculates the centroid of a group of reports
  static LatLng _calculateCentroid(List<ReportModel> reports) {
    double totalLat = 0;
    double totalLng = 0;

    for (final report in reports) {
      totalLat += report.latitude;
      totalLng += report.longitude;
    }

    return LatLng(
      totalLat / reports.length,
      totalLng / reports.length,
    );
  }

  /// Calculates the radius of a cluster
  static double _calculateClusterRadius(List<ReportModel> reports) {
    if (reports.length == 1) return 100;

    final LatLng center = _calculateCentroid(reports);
    double maxDistance = 0;

    for (final report in reports) {
      final double distance = _calculateDistance(
        center.latitude,
        center.longitude,
        report.latitude,
        report.longitude,
      );
      maxDistance = math.max(maxDistance, distance);
    }

    return math.max(maxDistance * 1.5, 200); // Add 50% buffer, minimum 200m
  }

  /// Disposes the clustering service
  static void dispose() {
    _updateMarkers = null;
  }
}

// Removed: ReportClusterItem and gmcm dependency

/// Represents a cluster of reports
class ReportCluster {
  final String id;
  final List<ReportModel> reports;
  final LatLng center;
  final double radius;

  const ReportCluster({
    required this.id,
    required this.reports,
    required this.center,
    required this.radius,
  });

  /// Gets the count of reports in the cluster
  int get count => reports.length;

  /// Checks if this is a multi-report cluster
  bool get isMultiple => reports.length > 1;

  /// Gets the maximum severity in the cluster
  ReportSeverity get maxSeverity {
    ReportSeverity maxSev = ReportSeverity.low;
    for (final report in reports) {
      if (report.severity.index > maxSev.index) {
        maxSev = report.severity;
      }
    }
    return maxSev;
  }

  /// Gets the most recent report in the cluster
  ReportModel get mostRecentReport {
    ReportModel mostRecent = reports.first;
    for (final report in reports) {
      if (report.createdAt.isAfter(mostRecent.createdAt)) {
        mostRecent = report;
      }
    }
    return mostRecent;
  }

  /// Gets the dominant hazard type in the cluster
  HazardType get dominantHazardType {
    final Map<HazardType, int> typeCounts = {};
    
    for (final report in reports) {
      typeCounts[report.hazardType] = (typeCounts[report.hazardType] ?? 0) + 1;
    }

    HazardType dominantType = HazardType.other;
    int maxCount = 0;

    typeCounts.forEach((type, count) {
      if (count > maxCount) {
        maxCount = count;
        dominantType = type;
      }
    });

    return dominantType;
  }
}
