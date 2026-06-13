import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../models/report_model.dart';

class HeatmapService {
  static const double _defaultRadius = 50.0;
  static const double _defaultIntensity = 1.0;

  /// Generates heatmap data points from reports
  static List<WeightedLatLng> generateHeatmapData(
    List<ReportModel> reports, {
    double radiusMultiplier = 1.0,
  }) {
    return reports.map((report) {
      final double intensity = _calculateIntensity(report);
      return WeightedLatLng(
        point: LatLng(report.latitude, report.longitude),
        intensity: intensity * radiusMultiplier,
      );
    }).toList();
  }

  /// Creates heatmap circles as map markers
  static Set<Circle> createHeatmapCircles(
    List<ReportModel> reports, {
    double radius = _defaultRadius,
  }) {
    if (reports.isEmpty) return {};

    return reports.map((report) {
      final double intensity = _calculateIntensity(report);
      final Color color = _getHeatmapColor(intensity);
      
      return Circle(
        circleId: CircleId('heatmap_${report.id}'),
        center: LatLng(report.latitude, report.longitude),
        radius: radius * (0.5 + intensity * 0.5), // Scale radius by intensity
        fillColor: color.withOpacity(0.3),
        strokeColor: color.withOpacity(0.6),
        strokeWidth: 2,
      );
    }).toSet();
  }

  /// Creates a custom heatmap overlay using Canvas (returns BitmapDescriptor for custom markers)
  static Future<BitmapDescriptor?> createCustomHeatmapMarker(
    List<ReportModel> reports,
    LatLngBounds bounds, {
    double radius = _defaultRadius,
    int resolution = 256,
  }) async {
    if (reports.isEmpty) return null;

    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(recorder);
    final Size size = Size(resolution.toDouble(), resolution.toDouble());

    // Create transparent background
    final Paint backgroundPaint = Paint()
      ..color = Colors.transparent
      ..style = PaintingStyle.fill;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), backgroundPaint);

    // Calculate pixel coordinates for each report
    for (final report in reports) {
      final Offset pixelPosition = _latLngToPixel(
        LatLng(report.latitude, report.longitude),
        bounds,
        size,
      );

      final double intensity = _calculateIntensity(report);
      _drawHeatPoint(canvas, pixelPosition, radius * 0.3, intensity);
    }

    // Convert to image
    final ui.Picture picture = recorder.endRecording();
    final ui.Image image = await picture.toImage(resolution, resolution);
    final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);

    if (byteData == null) return null;

    return BitmapDescriptor.bytes(byteData.buffer.asUint8List());
  }

  /// Draws a heat point on the canvas
  static void _drawHeatPoint(
    Canvas canvas,
    Offset center,
    double radius,
    double intensity,
  ) {
    final Paint paint = Paint()
      ..shader = RadialGradient(
        colors: _getHeatmapColors(intensity),
        stops: const [0.0, 0.3, 0.6, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawCircle(center, radius, paint);
  }

  /// Gets a single heatmap color based on intensity
  static Color _getHeatmapColor(double intensity) {
    if (intensity >= 0.8) {
      return Colors.red;
    } else if (intensity >= 0.6) {
      return Colors.orange;
    } else if (intensity >= 0.4) {
      return Colors.yellow;
    } else {
      return Colors.green;
    }
  }

  /// Gets heatmap colors based on intensity
  static List<Color> _getHeatmapColors(double intensity) {
    if (intensity >= 0.8) {
      // Critical - Red gradient
      return [
        Colors.red.withOpacity(0.8),
        Colors.red.withOpacity(0.6),
        Colors.orange.withOpacity(0.4),
        Colors.transparent,
      ];
    } else if (intensity >= 0.6) {
      // High - Orange gradient
      return [
        Colors.orange.withOpacity(0.7),
        Colors.orange.withOpacity(0.5),
        Colors.yellow.withOpacity(0.3),
        Colors.transparent,
      ];
    } else if (intensity >= 0.4) {
      // Medium - Yellow gradient
      return [
        Colors.yellow.withOpacity(0.6),
        Colors.yellow.withOpacity(0.4),
        Colors.green.withOpacity(0.2),
        Colors.transparent,
      ];
    } else {
      // Low - Green gradient
      return [
        Colors.green.withOpacity(0.5),
        Colors.green.withOpacity(0.3),
        Colors.blue.withOpacity(0.2),
        Colors.transparent,
      ];
    }
  }

  /// Converts LatLng to pixel coordinates
  static Offset _latLngToPixel(LatLng latLng, LatLngBounds bounds, Size size) {
    final double latRange = bounds.northeast.latitude - bounds.southwest.latitude;
    final double lngRange = bounds.northeast.longitude - bounds.southwest.longitude;

    final double x = ((latLng.longitude - bounds.southwest.longitude) / lngRange) * size.width;
    final double y = ((bounds.northeast.latitude - latLng.latitude) / latRange) * size.height;

    return Offset(x, y);
  }

  /// Calculates intensity based on report severity and verification status
  static double _calculateIntensity(ReportModel report) {
    double baseIntensity = _defaultIntensity;

    // Severity multiplier
    switch (report.severity) {
      case ReportSeverity.low:
        baseIntensity *= 0.3;
        break;
      case ReportSeverity.medium:
        baseIntensity *= 0.6;
        break;
      case ReportSeverity.high:
        baseIntensity *= 0.8;
        break;
      case ReportSeverity.critical:
        baseIntensity *= 1.0;
        break;
    }

    // Status multiplier (verified reports have higher intensity)
    switch (report.status) {
      case ReportStatus.verified:
        baseIntensity *= 1.2;
        break;
      case ReportStatus.underReview:
        baseIntensity *= 0.8;
        break;
      case ReportStatus.pending:
        baseIntensity *= 0.6;
        break;
      case ReportStatus.rejected:
        baseIntensity *= 0.2;
        break;
    }

    // Time decay (newer reports have higher intensity)
    final DateTime now = DateTime.now();
    final Duration timeDiff = now.difference(report.createdAt);
    final double daysSinceReport = timeDiff.inDays.toDouble();
    
    if (daysSinceReport <= 1) {
      baseIntensity *= 1.0; // Full intensity for reports within 24 hours
    } else if (daysSinceReport <= 7) {
      baseIntensity *= 0.8; // 80% intensity for reports within a week
    } else if (daysSinceReport <= 30) {
      baseIntensity *= 0.5; // 50% intensity for reports within a month
    } else {
      baseIntensity *= 0.2; // 20% intensity for older reports
    }

    return math.min(baseIntensity, 1.0); // Cap at 1.0
  }

  /// Generates hotspot areas based on report density
  static List<HotspotArea> generateHotspots(
    List<ReportModel> reports, {
    double clusterRadius = 5000, // 5km in meters
    int minReportsForHotspot = 3,
  }) {
    final List<HotspotArea> hotspots = [];
    final List<ReportModel> processedReports = List.from(reports);

    while (processedReports.isNotEmpty) {
      final ReportModel centerReport = processedReports.removeAt(0);
      final List<ReportModel> nearbyReports = [centerReport];

      // Find nearby reports
      processedReports.removeWhere((report) {
        final double distance = _calculateDistance(
          centerReport.latitude,
          centerReport.longitude,
          report.latitude,
          report.longitude,
        );

        if (distance <= clusterRadius) {
          nearbyReports.add(report);
          return true;
        }
        return false;
      });

      // Create hotspot if enough reports
      if (nearbyReports.length >= minReportsForHotspot) {
        hotspots.add(HotspotArea(
          center: _calculateCentroid(nearbyReports),
          reports: nearbyReports,
          radius: _calculateOptimalRadius(nearbyReports),
          intensity: _calculateHotspotIntensity(nearbyReports),
        ));
      }
    }

    return hotspots;
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

  /// Calculates optimal radius for a hotspot
  static double _calculateOptimalRadius(List<ReportModel> reports) {
    if (reports.length == 1) return 1000; // 1km for single report

    double maxDistance = 0;
    final LatLng center = _calculateCentroid(reports);

    for (final report in reports) {
      final double distance = _calculateDistance(
        center.latitude,
        center.longitude,
        report.latitude,
        report.longitude,
      );
      maxDistance = math.max(maxDistance, distance);
    }

    return math.max(maxDistance * 1.2, 500); // Add 20% buffer, minimum 500m
  }

  /// Calculates hotspot intensity based on reports
  static double _calculateHotspotIntensity(List<ReportModel> reports) {
    double totalIntensity = 0;

    for (final report in reports) {
      totalIntensity += _calculateIntensity(report);
    }

    return math.min(totalIntensity / reports.length, 1.0);
  }
}

/// Represents a hotspot area
class HotspotArea {
  final LatLng center;
  final List<ReportModel> reports;
  final double radius;
  final double intensity;

  const HotspotArea({
    required this.center,
    required this.reports,
    required this.radius,
    required this.intensity,
  });

  /// Gets the severity level of the hotspot
  ReportSeverity get maxSeverity {
    ReportSeverity maxSev = ReportSeverity.low;
    for (final report in reports) {
      if (report.severity.index > maxSev.index) {
        maxSev = report.severity;
      }
    }
    return maxSev;
  }

  /// Gets the color for the hotspot
  Color get color {
    if (intensity >= 0.8) return Colors.red.withOpacity(0.3);
    if (intensity >= 0.6) return Colors.orange.withOpacity(0.3);
    if (intensity >= 0.4) return Colors.yellow.withOpacity(0.3);
    return Colors.green.withOpacity(0.3);
  }
}

/// Weighted LatLng for heatmap data
class WeightedLatLng {
  final LatLng point;
  final double intensity;

  const WeightedLatLng({
    required this.point,
    required this.intensity,
  });
}
