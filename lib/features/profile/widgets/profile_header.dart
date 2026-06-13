import 'package:flutter/material.dart';

import '../../../models/user_model.dart';
import '../../../core/theme/app_theme.dart';

class ProfileHeader extends StatelessWidget {
  final UserModel? user;

  const ProfileHeader({
    super.key,
    this.user,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryColor,
            AppTheme.oceanBlue,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // Avatar
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white,
                width: 4,
              ),
            ),
            child: CircleAvatar(
              radius: 48,
              backgroundColor: Colors.white,
              backgroundImage: user?.photoUrl != null
                  ? NetworkImage(user!.photoUrl!)
                  : null,
              child: user?.photoUrl == null
                  ? Text(
                      user?.fullName?.substring(0, 1).toUpperCase() ?? 'U',
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    )
                  : null,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Name
          Text(
            user?.fullName ?? 'User',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 4),
          
          // Email
          Text(
            user?.email ?? 'user@example.com',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white70,
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Role Badge
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _getRoleIcon(user?.role),
                  size: 16,
                  color: Colors.white,
                ),
                const SizedBox(width: 4),
                Text(
                  _getRoleDisplayName(user?.role),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          
          if (user?.organization != null) ...[
            const SizedBox(height: 8),
            Text(
              user!.organization!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white70,
              ),
            ),
          ],
        ],
      ),
    );
  }

  IconData _getRoleIcon(UserRole? role) {
    switch (role) {
      case UserRole.citizen:
        return Icons.person;
      case UserRole.official:
        return Icons.badge;
      case UserRole.analyst:
        return Icons.analytics;
      case UserRole.admin:
        return Icons.admin_panel_settings;
      default:
        return Icons.person;
    }
  }

  String _getRoleDisplayName(UserRole? role) {
    switch (role) {
      case UserRole.citizen:
        return 'Citizen Reporter';
      case UserRole.official:
        return 'Official';
      case UserRole.analyst:
        return 'Analyst';
      case UserRole.admin:
        return 'Administrator';
      default:
        return 'User';
    }
  }
}
