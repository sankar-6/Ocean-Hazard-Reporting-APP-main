import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/auth_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/widgets/adaptive_back_scope.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_stats.dart';
import '../widgets/profile_menu.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);

    return AdaptiveBackScope(
      popRoute: '/dashboard',
      child: Scaffold(
      appBar: DetailAppBar(
        title: 'Profile',
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.go('/settings'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Header
            ProfileHeader(user: user),
            
            const SizedBox(height: 24),
            
            // Profile Stats
            ProfileStats(user: user),
            
            const SizedBox(height: 24),
            
            // Profile Menu
            ProfileMenu(user: user),
            
            const SizedBox(height: 24),
            
            // Logout Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    ref.read(authServiceProvider).signOut();
                    context.go('/login');
                  },
                  icon: const Icon(Icons.logout),
                  label: const Text('Logout'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.dangerColor,
                    side: BorderSide(color: AppTheme.dangerColor),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 32),
          ],
        ),
      ),
      ),
    );
  }
}
