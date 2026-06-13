import 'package:flutter/material.dart';

import '../../../models/user_model.dart';
import '../../../core/theme/app_theme.dart';

class ProfileMenu extends StatelessWidget {
  final UserModel? user;

  const ProfileMenu({
    super.key,
    this.user,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
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
          _buildMenuItem(
            context,
            'My Reports',
            'View and manage your reports',
            Icons.report_outlined,
            () {
              // TODO: Navigate to user's reports
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('My reports coming soon'),
                ),
              );
            },
          ),
          _buildDivider(),
          _buildMenuItem(
            context,
            'Notifications',
            'Manage your notification preferences',
            Icons.notifications_outlined,
            () {
              // TODO: Navigate to notifications settings
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Notifications settings coming soon'),
                ),
              );
            },
          ),
          _buildDivider(),
          _buildMenuItem(
            context,
            'Privacy & Security',
            'Manage your privacy and security settings',
            Icons.security_outlined,
            () {
              // TODO: Navigate to privacy settings
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Privacy settings coming soon'),
                ),
              );
            },
          ),
          _buildDivider(),
          _buildMenuItem(
            context,
            'Help & Support',
            'Get help and contact support',
            Icons.help_outline,
            () {
              // TODO: Navigate to help
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Help & support coming soon'),
                ),
              );
            },
          ),
          _buildDivider(),
          _buildMenuItem(
            context,
            'About',
            'App version and information',
            Icons.info_outline,
            () {
              showAboutDialog(
                context: context,
                applicationName: 'Ocean Hazard Reporter',
                applicationVersion: '1.0.0',
                applicationIcon: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.waves,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                children: [
                  const Text('A platform for reporting and monitoring ocean hazards in real-time.'),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: AppTheme.primaryColor,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Colors.grey[600],
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right,
        color: Colors.grey,
      ),
      onTap: onTap,
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.only(left: 56),
      child: Divider(
        height: 1,
        color: Colors.grey[200],
      ),
    );
  }
}
