import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/role_provider.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/custom_app_bar.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userWithRole = ref.watch(currentUserWithRoleProvider);
    final allUsers = ref.watch(allUsersProvider);

    return Scaffold(
      appBar: MainAppBar(
        title: 'Admin Dashboard',
        actions: [
          IconButton(
            icon: const Icon(Icons.people),
            onPressed: () => context.go('/admin/users'),
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
      body: userWithRole.when(
        data: (user) {
          if (user == null || !user.isAdmin) {
            return const Center(
              child: Text('Unauthorized: Admin access required'),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome Section
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppTheme.dangerColor, AppTheme.warningColor],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Admin Panel',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Manage users, roles, and system settings',
                        style: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Quick Actions
                Text(
                  'Quick Actions',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: _buildActionCard(
                        context,
                        icon: Icons.people,
                        title: 'User Management',
                        subtitle: 'Manage user roles and permissions',
                        onTap: () => context.go('/admin/users'),
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildActionCard(
                        context,
                        icon: Icons.analytics,
                        title: 'System Analytics',
                        subtitle: 'View system performance metrics',
                        onTap: () => context.go('/analytics'),
                        color: AppTheme.successColor,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: _buildActionCard(
                        context,
                        icon: Icons.verified_user,
                        title: 'Report Verification',
                        subtitle: 'Verify and moderate reports',
                        onTap: () => context.go('/verification'),
                        color: AppTheme.warningColor,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildActionCard(
                        context,
                        icon: Icons.settings,
                        title: 'System Settings',
                        subtitle: 'Configure system parameters',
                        onTap: () => context.go('/settings'),
                        color: AppTheme.oceanBlue,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // User Statistics
                Text(
                  'User Statistics',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                allUsers.when(
                  data: (users) => _buildUserStats(context, users),
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, _) => Text('Error: $error'),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required Color color,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, size: 32, color: color),
              const SizedBox(height: 8),
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserStats(BuildContext context, List<dynamic> users) {
    final roleCounts = <String, int>{};
    for (final user in users) {
      final role = user.role.toString().split('.').last;
      roleCounts[role] = (roleCounts[role] ?? 0) + 1;
    }

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            context,
            'Total Users',
            users.length.toString(),
            Icons.people,
            AppTheme.primaryColor,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            context,
            'Citizens',
            roleCounts['citizen']?.toString() ?? '0',
            Icons.person,
            AppTheme.successColor,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            context,
            'Officials',
            roleCounts['official']?.toString() ?? '0',
            Icons.badge,
            AppTheme.warningColor,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
