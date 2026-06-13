import 'package:flutter/material.dart';

import '../../../models/user_model.dart';
import '../../../core/theme/app_theme.dart';

class ProfileStats extends StatelessWidget {
  final UserModel? user;

  const ProfileStats({
    super.key,
    this.user,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              context,
              'Reports',
              '12',
              Icons.report_outlined,
              AppTheme.primaryColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              context,
              'Verified',
              '8',
              Icons.verified,
              AppTheme.successColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              context,
              'Impact Score',
              '4.8',
              Icons.star,
              AppTheme.warningColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
