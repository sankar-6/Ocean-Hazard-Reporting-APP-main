import 'dart:ui' as ui;
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../models/report_model.dart';
import '../theme/app_theme.dart';

class CustomMarkerService {
  static final Map<String, BitmapDescriptor> _markerCache = {};

  /// Creates a custom marker icon based on hazard type and severity
  static Future<BitmapDescriptor> createCustomMarker(
    HazardType hazardType,
    ReportSeverity severity, {
    bool isCluster = false,
    int? clusterCount,
  }) async {
    final String cacheKey = '${hazardType.name}_${severity.name}_${isCluster}_$clusterCount';
    
    if (_markerCache.containsKey(cacheKey)) {
      return _markerCache[cacheKey]!;
    }

    final BitmapDescriptor marker = isCluster
        ? await _createClusterMarker(clusterCount!, severity)
        : await _createHazardMarker(hazardType, severity);

    _markerCache[cacheKey] = marker;
    return marker;
  }

  /// Creates a marker for individual hazard reports
  static Future<BitmapDescriptor> _createHazardMarker(
    HazardType hazardType,
    ReportSeverity severity,
  ) async {
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    const double size = 120.0;

    // Background circle with severity color
    final Paint backgroundPaint = Paint()
      ..color = _getSeverityColor(severity)
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(
      const Offset(size / 2, size / 2),
      size / 2 - 10,
      backgroundPaint,
    );

    // White inner circle
    final Paint innerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(
      const Offset(size / 2, size / 2),
      size / 2 - 20,
      innerPaint,
    );

    // Hazard type icon
    final IconData iconData = _getHazardTypeIcon(hazardType);
    final TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(iconData.codePoint),
        style: TextStyle(
          fontSize: 40,
          fontFamily: iconData.fontFamily,
          color: _getSeverityColor(severity),
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        (size - textPainter.width) / 2,
        (size - textPainter.height) / 2,
      ),
    );

    // Severity indicator (small circle)
    final Paint severityPaint = Paint()
      ..color = _getSeverityColor(severity)
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(
      Offset(size - 15, 15),
      8,
      severityPaint,
    );

    final ui.Picture picture = pictureRecorder.endRecording();
    final ui.Image image = await picture.toImage(size.toInt(), size.toInt());
    final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);

    return BitmapDescriptor.bytes(byteData!.buffer.asUint8List());
  }

  /// Creates a marker for clustered reports
  static Future<BitmapDescriptor> _createClusterMarker(
    int count,
    ReportSeverity maxSeverity,
  ) async {
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    const double size = 140.0;

    // Background circle with gradient
    final Paint backgroundPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          _getSeverityColor(maxSeverity).withOpacity(0.8),
          _getSeverityColor(maxSeverity),
        ],
      ).createShader(Rect.fromCircle(
        center: const Offset(size / 2, size / 2),
        radius: size / 2 - 10,
      ));
    
    canvas.drawCircle(
      const Offset(size / 2, size / 2),
      size / 2 - 10,
      backgroundPaint,
    );

    // White inner circle
    final Paint innerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(
      const Offset(size / 2, size / 2),
      size / 2 - 25,
      innerPaint,
    );

    // Cluster count text
    final TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: count.toString(),
        style: TextStyle(
          fontSize: count > 99 ? 28 : 36,
          fontWeight: FontWeight.bold,
          color: _getSeverityColor(maxSeverity),
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        (size - textPainter.width) / 2,
        (size - textPainter.height) / 2,
      ),
    );

    // Cluster indicator (small circles around the edge)
    for (int i = 0; i < 8; i++) {
      final double angle = (i * 45) * (3.14159 / 180);
      final double x = (size / 2) + (size / 2 - 15) * 0.8 * cos(angle);
      final double y = (size / 2) + (size / 2 - 15) * 0.8 * sin(angle);
      
      final Paint dotPaint = Paint()
        ..color = _getSeverityColor(maxSeverity).withOpacity(0.6)
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(Offset(x, y), 4, dotPaint);
    }

    final ui.Picture picture = pictureRecorder.endRecording();
    final ui.Image image = await picture.toImage(size.toInt(), size.toInt());
    final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);

    return BitmapDescriptor.fromBytes(byteData!.buffer.asUint8List());
  }

  /// Gets the appropriate icon for each hazard type
  static IconData _getHazardTypeIcon(HazardType type) {
    switch (type) {
      case HazardType.tsunami:
        return Icons.waves;
      case HazardType.stormSurge:
        return Icons.storm;
      case HazardType.highWaves:
        return Icons.water;
      case HazardType.coastalFlooding:
        return Icons.flood;
      case HazardType.abnormalTides:
        return Icons.trending_up;
      case HazardType.coastalErosion:
        return Icons.landscape;
      case HazardType.other:
        return Icons.warning;
    }
  }

  /// Gets the color based on severity level
  static Color _getSeverityColor(ReportSeverity severity) {
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

  /// Clears the marker cache
  static void clearCache() {
    _markerCache.clear();
  }
}

// Helper function for cos calculation
double cos(double radians) => math.cos(radians);

// Helper function for sin calculation  
double sin(double radians) => math.sin(radians);
