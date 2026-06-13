import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/role_provider.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/services/firestore_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../models/user_model.dart';

class UserManagementScreen extends ConsumerWidget {
  const UserManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allUsers = ref.watch(allUsersProvider);

    return Scaffold(
      appBar: DetailAppBar(
        title: 'User Management',
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.refresh(allUsersProvider),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'profile':
                  context.go('/profile');
                  break;
                case 'settings':
                  context.go('/settings');
                  break;
                case 'logout':
                  ref.read(authServiceProvider).signOut();
                  context.go('/login');
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'profile',
                child: Row(
                  children: [
                    Icon(Icons.person_outline),
                    SizedBox(width: 8),
                    Text('Profile'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings_outlined),
                    SizedBox(width: 8),
                    Text('Settings'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Logout', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: allUsers.when(
        data: (users) => _buildUsersList(context, ref, users),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error, size: 64, color: AppTheme.dangerColor),
              const SizedBox(height: 16),
              Text('Error: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.refresh(allUsersProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUsersList(
    BuildContext context,
    WidgetRef ref,
    List<UserModel> users,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _getRoleColor(user.role),
              child: Text(
                user.fullName?.isNotEmpty == true
                    ? user.fullName![0].toUpperCase()
                    : 'U',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(user.fullName ?? 'Unknown'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user.email),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: _getRoleColor(user.role).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        user.role.toString().split('.').last.toUpperCase(),
                        style: TextStyle(
                          color: _getRoleColor(user.role),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (user.organization != null)
                      Text(
                        user.organization!,
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                  ],
                ),
              ],
            ),
            trailing: PopupMenuButton<String>(
              onSelected: (value) =>
                  _handleUserAction(context, ref, user, value),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'change_role',
                  child: Row(
                    children: [
                      Icon(Icons.edit),
                      SizedBox(width: 8),
                      Text('Change Role'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'view_details',
                  child: Row(
                    children: [
                      Icon(Icons.info),
                      SizedBox(width: 8),
                      Text('View Details'),
                    ],
                  ),
                ),
                if (user.isActive)
                  const PopupMenuItem(
                    value: 'deactivate',
                    child: Row(
                      children: [
                        Icon(Icons.block, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Deactivate', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  )
                else
                  const PopupMenuItem(
                    value: 'activate',
                    child: Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green),
                        SizedBox(width: 8),
                        Text('Activate', style: TextStyle(color: Colors.green)),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _getRoleColor(UserRole role) {
    switch (role) {
      case UserRole.citizen:
        return AppTheme.successColor;
      case UserRole.volunteer:
        return AppTheme.primaryColor;
      case UserRole.official:
        return AppTheme.warningColor;
      case UserRole.analyst:
        return AppTheme.oceanBlue;
      case UserRole.admin:
        return AppTheme.dangerColor;
    }
  }

  void _handleUserAction(
    BuildContext context,
    WidgetRef ref,
    UserModel user,
    String action,
  ) {
    switch (action) {
      case 'change_role':
        _showRoleChangeDialog(context, ref, user);
        break;
      case 'view_details':
        _showUserDetailsDialog(context, user);
        break;
      case 'activate':
      case 'deactivate':
        _toggleUserStatus(context, ref, user);
        break;
    }
  }

  void _showRoleChangeDialog(
    BuildContext context,
    WidgetRef ref,
    UserModel user,
  ) {
    UserRole selectedRole = user.role;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Change Role for ${user.fullName}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: UserRole.values
                .map(
                  (role) => RadioListTile<UserRole>(
                    title: Text(role.toString().split('.').last.toUpperCase()),
                    subtitle: Text(_getRoleDescription(role)),
                    value: role,
                    groupValue: selectedRole,
                    onChanged: (value) => setState(() => selectedRole = value!),
                  ),
                )
                .toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  await FirestoreService.updateUserRole(user.id, selectedRole);
                  if (context.mounted) {
                    Navigator.pop(context);
                    ref.invalidate(allUsersProvider);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('User role updated successfully'),
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text('Error: $e')));
                  }
                }
              },
              child: const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }

  void _showUserDetailsDialog(BuildContext context, UserModel user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('User Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Name', user.fullName ?? 'N/A'),
            _buildDetailRow('Email', user.email),
            _buildDetailRow(
              'Role',
              user.role.toString().split('.').last.toUpperCase(),
            ),
            _buildDetailRow('Phone', user.phoneNumber ?? 'N/A'),
            _buildDetailRow('Organization', user.organization ?? 'N/A'),
            _buildDetailRow('Status', user.isActive ? 'Active' : 'Inactive'),
            _buildDetailRow('Created', user.createdAt.toString().split(' ')[0]),
            _buildDetailRow(
              'Last Login',
              user.lastLoginAt?.toString().split(' ')[0] ?? 'Never',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _toggleUserStatus(
    BuildContext context,
    WidgetRef ref,
    UserModel user,
  ) async {
    try {
      await FirestoreService.updateUserProfile(user.id, {
        'isActive': !user.isActive,
      });
      ref.invalidate(allUsersProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            user.isActive
                ? 'User deactivated successfully'
                : 'User activated successfully',
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  String _getRoleDescription(UserRole role) {
    switch (role) {
      case UserRole.citizen:
        return 'Can submit hazard reports';
      case UserRole.volunteer:
        return 'Can submit and moderate reports';
      case UserRole.official:
        return 'Can verify reports and view dashboard';
      case UserRole.analyst:
        return 'Can view analytics and hotspot trends';
      case UserRole.admin:
        return 'Full system access and user management';
    }
  }
}
