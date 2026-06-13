import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

class HazardAlertsBanner extends StatelessWidget {
  const HazardAlertsBanner({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock data - replace with actual alert data from provider/API
    // In real implementation, this would come from a provider/API
    final alertCount = 3;
    final hasActiveAlerts = alertCount > 0;

    // Early return if no active alerts
    if (!hasActiveAlerts) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.dangerColor.withOpacity(0.1),
            AppTheme.warningColor.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.dangerColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.dangerColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.warning, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Active Hazard Alerts',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.dangerColor,
                      ),
                    ),
                    Text(
                      '$alertCount active alerts in your area',
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.grey[700]),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () {
                  // TODO: Navigate to alerts screen
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Alerts screen coming soon')),
                  );
                },
                child: const Text('View All'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.7),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                _buildAlertItem(
                  context,
                  'High Wave Warning',
                  'Waves up to 4m expected in Chennai coast',
                  '2 hours ago',
                  AppTheme.dangerColor,
                ),
                const SizedBox(height: 8),
                _buildAlertItem(
                  context,
                  'Storm Surge Alert',
                  'Rising sea levels in Mumbai area',
                  '4 hours ago',
                  AppTheme.warningColor,
                ),
                const SizedBox(height: 8),
                _buildAlertItem(
                  context,
                  'Coastal Flooding',
                  'Water levels rising in low-lying areas',
                  '6 hours ago',
                  AppTheme.oceanBlue,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertItem(
    BuildContext context,
    String title,
    String description,
    String time,
    Color color,
  ) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
              Text(
                description,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.grey[700]),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        Text(
          time,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
        ),
      ],
    );
  }
}
