import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

class MapControls extends StatelessWidget {
  final VoidCallback onCenterOnReports;
  final VoidCallback onToggleHeatmap;
  final VoidCallback onToggleVerifiedOnly;
  final VoidCallback onToggleClustering;
  final VoidCallback onToggleHotspots;
  final bool showHeatmap;
  final bool showVerifiedOnly;
  final bool showClustering;
  final bool showHotspots;

  const MapControls({
    super.key,
    required this.onCenterOnReports,
    required this.onToggleHeatmap,
    required this.onToggleVerifiedOnly,
    required this.onToggleClustering,
    required this.onToggleHotspots,
    required this.showHeatmap,
    required this.showVerifiedOnly,
    required this.showClustering,
    required this.showHotspots,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Center on Reports Button
        FloatingActionButton.small(
          heroTag: "map_center_fab",
          onPressed: onCenterOnReports,
          backgroundColor: Colors.white,
          child: const Icon(
            Icons.center_focus_strong,
            color: AppTheme.primaryColor,
          ),
        ),
        const SizedBox(height: 8),

        // Heatmap Toggle
        FloatingActionButton.small(
          heroTag: "map_heatmap_fab",
          onPressed: onToggleHeatmap,
          backgroundColor: showHeatmap ? AppTheme.primaryColor : Colors.white,
          child: Icon(
            Icons.layers,
            color: showHeatmap ? Colors.white : AppTheme.primaryColor,
          ),
        ),
        const SizedBox(height: 8),

        // Verified Only Toggle
        FloatingActionButton.small(
          heroTag: "map_verified_fab",
          onPressed: onToggleVerifiedOnly,
          backgroundColor: showVerifiedOnly
              ? AppTheme.successColor
              : Colors.white,
          child: Icon(
            Icons.verified,
            color: showVerifiedOnly ? Colors.white : AppTheme.primaryColor,
          ),
        ),
        const SizedBox(height: 8),

        // Clustering Toggle
        FloatingActionButton.small(
          heroTag: "map_clustering_fab",
          onPressed: onToggleClustering,
          backgroundColor: showClustering ? AppTheme.primaryColor : Colors.white,
          child: Icon(
            Icons.scatter_plot,
            color: showClustering ? Colors.white : AppTheme.primaryColor,
          ),
        ),
        const SizedBox(height: 8),

        // Hotspots Toggle
        FloatingActionButton.small(
          heroTag: "map_hotspots_fab",
          onPressed: onToggleHotspots,
          backgroundColor: showHotspots ? AppTheme.warningColor : Colors.white,
          child: Icon(
            Icons.local_fire_department,
            color: showHotspots ? Colors.white : AppTheme.primaryColor,
          ),
        ),
      ],
    );
  }
}
