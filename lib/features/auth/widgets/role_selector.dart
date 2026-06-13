import 'package:flutter/material.dart';
import '../../../models/user_model.dart';

class RoleSelector extends StatelessWidget {
  final UserRole selectedRole;
  final ValueChanged<UserRole> onChanged;
  final bool enabled;

  const RoleSelector({
    super.key,
    required this.selectedRole,
    required this.onChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Account Type',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...UserRole.values.map((role) => _buildRoleOption(context, role)),
      ],
    );
  }

  Widget _buildRoleOption(BuildContext context, UserRole role) {
    final isSelected = selectedRole == role;
    final roleInfo = _getRoleInfo(role);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: enabled ? () => onChanged(role) : null,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected
                  ? Theme.of(context).primaryColor
                  : Colors.grey[300]!,
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(8),
            color: isSelected
                ? Theme.of(context).primaryColor.withOpacity(0.1)
                : Colors.grey[50],
          ),
          child: Row(
            children: [
              Radio<UserRole>(
                value: role,
                groupValue: selectedRole,
                onChanged: enabled ? (value) => onChanged(value!) : null,
                activeColor: Theme.of(context).primaryColor,
              ),
              const SizedBox(width: 12),
              Icon(
                roleInfo.icon,
                color: isSelected
                    ? Theme.of(context).primaryColor
                    : Colors.grey[600],
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      roleInfo.title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isSelected
                            ? Theme.of(context).primaryColor
                            : Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      roleInfo.description,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  RoleInfo _getRoleInfo(UserRole role) {
    switch (role) {
      case UserRole.citizen:
        return RoleInfo(
          title: 'Citizen',
          description: 'Report ocean hazards and view public information',
          icon: Icons.person,
        );
      case UserRole.volunteer:
        return RoleInfo(
          title: 'Volunteer',
          description: 'Report hazards and help moderate community reports',
          icon: Icons.volunteer_activism,
        );
      case UserRole.official:
        return RoleInfo(
          title: 'Official',
          description: 'Verify reports and access official dashboard',
          icon: Icons.badge,
        );
      case UserRole.analyst:
        return RoleInfo(
          title: 'Analyst',
          description: 'View analytics and hotspot trends',
          icon: Icons.analytics,
        );
      case UserRole.admin:
        return RoleInfo(
          title: 'Administrator',
          description: 'Full system access and user management',
          icon: Icons.admin_panel_settings,
        );
    }
  }
}

class RoleInfo {
  final String title;
  final String description;
  final IconData icon;

  RoleInfo({
    required this.title,
    required this.description,
    required this.icon,
  });
}
