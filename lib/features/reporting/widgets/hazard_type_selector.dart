import 'package:flutter/material.dart';

import '../../../models/report_model.dart';
import '../../../core/theme/app_theme.dart';

class HazardTypeSelector extends StatelessWidget {
  final HazardType selectedType;
  final ValueChanged<HazardType> onChanged;

  const HazardTypeSelector({
    super.key,
    required this.selectedType,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: HazardType.values.map((type) {
        final isSelected = selectedType == type;
        return GestureDetector(
          onTap: () => onChanged(type),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected 
                  ? _getHazardTypeColor(type)
                  : _getHazardTypeColor(type).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _getHazardTypeColor(type),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _getHazardTypeIcon(type),
                  size: 20,
                  color: isSelected ? Colors.white : _getHazardTypeColor(type),
                ),
                const SizedBox(width: 8),
                Text(
                  _getHazardTypeDisplayName(type),
                  style: TextStyle(
                    color: isSelected ? Colors.white : _getHazardTypeColor(type),
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
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
}
