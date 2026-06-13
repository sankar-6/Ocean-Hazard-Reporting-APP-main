import 'package:flutter/material.dart';

import '../../../models/report_model.dart';

class ReportFilters extends StatelessWidget {
  final String selectedFilter;
  final ValueChanged<String> onFilterChanged;

  const ReportFilters({
    super.key,
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip(context, 'all', 'All', Icons.list),
            const SizedBox(width: 8),
            ...HazardType.values.map((type) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _buildFilterChip(
                context,
                type.toString().split('.').last,
                _getHazardTypeDisplayName(type),
                _getHazardTypeIcon(type),
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(BuildContext context, String value, String label, IconData icon) {
    final isSelected = selectedFilter == value;
    
    return FilterChip(
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          onFilterChanged(value);
        }
      },
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: isSelected ? Colors.white : Colors.grey[600],
          ),
          const SizedBox(width: 4),
          Text(label),
        ],
      ),
      selectedColor: Theme.of(context).primaryColor,
      checkmarkColor: Colors.white,
      backgroundColor: Colors.grey[100],
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

  IconData _getHazardTypeIcon(HazardType type) {
    switch (type) {
      case HazardType.tsunami:
        return Icons.waves;
      case HazardType.stormSurge:
        return Icons.thunderstorm;
      case HazardType.highWaves:
        return Icons.water;
      case HazardType.coastalFlooding:
        return Icons.flood;
      case HazardType.abnormalTides:
        return Icons.trending_up;
      case HazardType.coastalErosion:
        return Icons.terrain;
      case HazardType.other:
        return Icons.warning;
    }
  }
}
