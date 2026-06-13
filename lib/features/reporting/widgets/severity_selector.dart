import 'package:flutter/material.dart';

import '../../../models/report_model.dart';
import '../../../core/theme/app_theme.dart';

class SeveritySelector extends StatelessWidget {
  final ReportSeverity selectedSeverity;
  final ValueChanged<ReportSeverity> onChanged;

  const SeveritySelector({
    super.key,
    required this.selectedSeverity,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: ReportSeverity.values.map((severity) {
        final isSelected = selectedSeverity == severity;
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          child: InkWell(
            onTap: () => onChanged(severity),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isSelected 
                    ? _getSeverityColor(severity).withOpacity(0.1)
                    : Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected 
                      ? _getSeverityColor(severity)
                      : Colors.grey[300]!,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: isSelected 
                          ? _getSeverityColor(severity)
                          : Colors.grey[400],
                      shape: BoxShape.circle,
                    ),
                    child: isSelected
                        ? const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 16,
                          )
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    _getSeverityIcon(severity),
                    color: _getSeverityColor(severity),
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getSeverityDisplayName(severity),
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: _getSeverityColor(severity),
                          ),
                        ),
                        Text(
                          _getSeverityDescription(severity),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  String _getSeverityDisplayName(ReportSeverity severity) {
    switch (severity) {
      case ReportSeverity.low:
        return 'Low';
      case ReportSeverity.medium:
        return 'Medium';
      case ReportSeverity.high:
        return 'High';
      case ReportSeverity.critical:
        return 'Critical';
    }
  }

  String _getSeverityDescription(ReportSeverity severity) {
    switch (severity) {
      case ReportSeverity.low:
        return 'Minor impact, no immediate danger';
      case ReportSeverity.medium:
        return 'Moderate impact, caution advised';
      case ReportSeverity.high:
        return 'Significant impact, avoid area if possible';
      case ReportSeverity.critical:
        return 'Extreme danger, immediate evacuation recommended';
    }
  }

  IconData _getSeverityIcon(ReportSeverity severity) {
    switch (severity) {
      case ReportSeverity.low:
        return Icons.info_outline;
      case ReportSeverity.medium:
        return Icons.warning_outlined;
      case ReportSeverity.high:
        return Icons.warning;
      case ReportSeverity.critical:
        return Icons.dangerous;
    }
  }

  Color _getSeverityColor(ReportSeverity severity) {
    switch (severity) {
      case ReportSeverity.low:
        return AppTheme.successColor;
      case ReportSeverity.medium:
        return AppTheme.warningColor;
      case ReportSeverity.high:
        return AppTheme.dangerColor;
      case ReportSeverity.critical:
        return Colors.red[900]!;
    }
  }
}
