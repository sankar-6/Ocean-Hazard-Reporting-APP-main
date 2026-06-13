import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/role_provider.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/widgets/adaptive_back_scope.dart';
import '../../../core/widgets/language_selector.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userWithRole = ref.watch(currentUserWithRoleProvider);

    return AdaptiveBackScope(
      popRoute: '/dashboard',
      child: Scaffold(
        appBar: DetailAppBar(
          title: 'settings'.tr(),
          actions: [const CompactLanguageSelector(), const SizedBox(width: 8)],
        ),
        body: userWithRole.when(
          data: (user) {
            if (user == null) {
              return Center(child: Text('please_log_in_settings'.tr()));
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // User Info Section
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'profile'.tr(),
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 30,
                                backgroundColor: Theme.of(context).primaryColor,
                                child: Text(
                                  (user.fullName?.isNotEmpty == true ? user.fullName![0].toUpperCase() : 'U'),
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      user.fullName ?? 'user'.tr(),
                                      style: Theme.of(context).textTheme.titleMedium,
                                    ),
                                    Text(
                                      user.email,
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                                    ),
                                    const SizedBox(height: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: _getRoleColor(user.role),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        _getRoleDisplayName(user.role),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Language Settings
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'language'.tr(),
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 12),
                          const LanguageSelector(showAsListTile: true),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // App Settings
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'app_settings'.tr(),
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 12),
                          _buildSettingsTile(
                            context,
                            icon: Icons.notifications_outlined,
                            title: 'notifications'.tr(),
                            subtitle: 'notification_settings'.tr(),
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('coming_soon'.tr())),
                              );
                            },
                          ),
                          _buildSettingsTile(
                            context,
                            icon: Icons.help_outline,
                            title: 'help'.tr(),
                            subtitle: 'help_support'.tr(),
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('coming_soon'.tr())),
                              );
                            },
                          ),
                          _buildSettingsTile(
                            context,
                            icon: Icons.info_outline,
                            title: 'about'.tr(),
                            subtitle: 'app_version'.tr(),
                            onTap: () => _showAboutDialog(context),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Account Actions
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'account'.tr(),
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 12),
                          _buildSettingsTile(
                            context,
                            icon: Icons.logout,
                            title: 'logout'.tr(),
                            subtitle: 'sign_out_account'.tr(),
                            textColor: Colors.red,
                            onTap: () => _showLogoutDialog(context, ref),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text('error'.tr()),
                const SizedBox(height: 8),
                Text(error.toString()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    Color? textColor,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: textColor),
      title: Text(title, style: TextStyle(color: textColor)),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  Color _getRoleColor(dynamic role) {
    switch (role.toString()) {
      case 'UserRole.citizen':
        return Colors.blue;
      case 'UserRole.volunteer':
        return Colors.green;
      case 'UserRole.official':
        return Colors.orange;
      case 'UserRole.analyst':
        return Colors.purple;
      case 'UserRole.admin':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getRoleDisplayName(dynamic role) {
    switch (role.toString()) {
      case 'UserRole.citizen':
        return 'citizen'.tr();
      case 'UserRole.volunteer':
        return 'volunteer'.tr();
      case 'UserRole.official':
        return 'official'.tr();
      case 'UserRole.analyst':
        return 'analyst'.tr();
      case 'UserRole.admin':
        return 'admin'.tr();
      default:
        return 'user'.tr();
    }
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'app_title'.tr(),
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(Icons.waves, size: 48, color: Colors.blue),
      children: [Text('about_description'.tr())],
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('logout'.tr()),
        content: Text('logout_confirmation'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('cancel'.tr()),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(authServiceProvider).signOut();
              context.go('/login');
            },
            child: Text('logout'.tr()),
          ),
        ],
      ),
    );
  }
}
