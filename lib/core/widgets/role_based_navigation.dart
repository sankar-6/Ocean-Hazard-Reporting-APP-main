import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/role_provider.dart';
import '../providers/auth_provider.dart';
import '../../models/user_model.dart';

class RoleBasedBottomNavigation extends ConsumerWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const RoleBasedBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userPermissions = ref.watch(userPermissionsProvider);
    final userRole = ref.watch(userRoleProvider);

    if (userPermissions == null || userRole == null) {
      return const SizedBox.shrink();
    }

    final navigationItems = _getNavigationItems(userRole, userPermissions);

    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      items: navigationItems
          .map(
            (item) => BottomNavigationBarItem(
              icon: Icon(item.icon),
              activeIcon: Icon(item.activeIcon ?? item.icon),
              label: item.label,
            ),
          )
          .toList(),
    );
  }

  List<NavigationItem> _getNavigationItems(
    UserRole role,
    UserPermissions permissions,
  ) {
    final items = <NavigationItem>[];

    // All users can access these
    items.add(
      NavigationItem(
        icon: Icons.home_outlined,
        activeIcon: Icons.home,
        label: 'dashboard',
        route: '/dashboard',
      ),
    );

    // Role-specific items
    switch (role) {
      case UserRole.citizen:
        items.addAll([
          NavigationItem(
            icon: Icons.add_alert_outlined,
            activeIcon: Icons.add_alert,
            label: 'report',
            route: '/report',
          ),
          NavigationItem(
            icon: Icons.map_outlined,
            activeIcon: Icons.map,
            label: 'map',
            route: '/map',
          ),
          NavigationItem(
            icon: Icons.list_outlined,
            activeIcon: Icons.list,
            label: 'all_reports',
            route: '/reports',
          ),
        ]);
        break;

      case UserRole.volunteer:
        items.addAll([
          NavigationItem(
            icon: Icons.add_alert_outlined,
            activeIcon: Icons.add_alert,
            label: 'report',
            route: '/report',
          ),
          NavigationItem(
            icon: Icons.verified_user_outlined,
            activeIcon: Icons.verified_user,
            label: 'moderate',
            route: '/moderation',
          ),
          NavigationItem(
            icon: Icons.map_outlined,
            activeIcon: Icons.map,
            label: 'map',
            route: '/map',
          ),
          NavigationItem(
            icon: Icons.list_outlined,
            activeIcon: Icons.list,
            label: 'all_reports',
            route: '/reports',
          ),
        ]);
        break;

      case UserRole.official:
        items.addAll([
          NavigationItem(
            icon: Icons.verified_user_outlined,
            activeIcon: Icons.verified_user,
            label: 'verify',
            route: '/verification',
          ),
          NavigationItem(
            icon: Icons.map_outlined,
            activeIcon: Icons.map,
            label: 'map',
            route: '/map',
          ),
          NavigationItem(
            icon: Icons.list_outlined,
            activeIcon: Icons.list,
            label: 'all_reports',
            route: '/reports',
          ),
        ]);
        break;

      case UserRole.analyst:
        items.addAll([
          NavigationItem(
            icon: Icons.analytics_outlined,
            activeIcon: Icons.analytics,
            label: 'analytics_dashboard',
            route: '/analytics',
          ),
          NavigationItem(
            icon: Icons.map_outlined,
            activeIcon: Icons.map,
            label: 'map',
            route: '/map',
          ),
          NavigationItem(
            icon: Icons.trending_up_outlined,
            activeIcon: Icons.trending_up,
            label: 'social',
            route: '/social',
          ),
        ]);
        break;

      case UserRole.admin:
        items.addAll([
          NavigationItem(
            icon: Icons.admin_panel_settings_outlined,
            activeIcon: Icons.admin_panel_settings,
            label: 'admin',
            route: '/admin',
          ),
          NavigationItem(
            icon: Icons.people_outlined,
            activeIcon: Icons.people,
            label: 'user_management',
            route: '/admin/users',
          ),
          NavigationItem(
            icon: Icons.map_outlined,
            activeIcon: Icons.map,
            label: 'map',
            route: '/map',
          ),
          NavigationItem(
            icon: Icons.analytics_outlined,
            activeIcon: Icons.analytics,
            label: 'analytics_dashboard',
            route: '/analytics',
          ),
        ]);
        break;
    }

    return items;
  }
}

class RoleBasedDrawer extends ConsumerWidget {
  const RoleBasedDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userWithRole = ref.watch(currentUserWithRoleProvider);
    final userPermissions = ref.watch(userPermissionsProvider);

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // User header
          userWithRole.when(
            data: (user) => _buildUserHeader(context, user),
            loading: () => const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (_, __) => const DrawerHeader(
              decoration: BoxDecoration(color: Colors.red),
              child: Center(child: Text('Error loading user')),
            ),
          ),

          // Navigation items
          if (userPermissions != null) ...[
            _buildNavigationItem(
              context,
              icon: Icons.home_outlined,
              title: 'dashboard',
              route: '/dashboard',
            ),

            if (userPermissions.canSubmitReports)
              _buildNavigationItem(
                context,
                icon: Icons.add_alert_outlined,
                title: 'report_hazard',
                route: '/report',
              ),

            if (userPermissions.canModerateReports)
              _buildNavigationItem(
                context,
                icon: Icons.verified_user_outlined,
                title: 'moderate',
                route: '/moderation',
              ),

            if (userPermissions.canVerifyReports)
              _buildNavigationItem(
                context,
                icon: Icons.verified_outlined,
                title: 'verify',
                route: '/verification',
              ),

            if (userPermissions.canViewAnalytics)
              _buildNavigationItem(
                context,
                icon: Icons.analytics_outlined,
                title: 'analytics_dashboard',
                route: '/analytics',
              ),

            if (userPermissions.canManageUsers)
              _buildNavigationItem(
                context,
                icon: Icons.admin_panel_settings_outlined,
                title: 'admin_dashboard',
                route: '/admin',
              ),

            _buildNavigationItem(
              context,
              icon: Icons.map_outlined,
              title: 'map',
              route: '/map',
            ),

            _buildNavigationItem(
              context,
              icon: Icons.social_distance_outlined,
              title: 'social',
              route: '/social',
            ),

            _buildNavigationItem(
              context,
              icon: Icons.list_outlined,
              title: 'all_reports',
              route: '/reports',
            ),

            const Divider(),

            _buildNavigationItem(
              context,
              icon: Icons.person_outlined,
              title: 'profile',
              route: '/profile',
            ),

            _buildNavigationItem(
              context,
              icon: Icons.settings_outlined,
              title: 'settings',
              route: '/settings',
            ),

            const Divider(),

            _buildLogoutItem(context, ref),
          ],
        ],
      ),
    );
  }

  Widget _buildUserHeader(BuildContext context, UserModel? user) {
    return UserAccountsDrawerHeader(
      accountName: Text(user?.fullName ?? 'User'),
      accountEmail: Text(user?.email ?? ''),
      currentAccountPicture: CircleAvatar(
        backgroundColor: Theme.of(context).primaryColor,
        child: Text(
          (user?.fullName?.isNotEmpty == true
              ? user!.fullName![0].toUpperCase()
              : 'U'),
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      decoration: BoxDecoration(color: Theme.of(context).primaryColor),
    );
  }

  Widget _buildNavigationItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String route,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () {
        Navigator.pop(context);
        context.go(route);
      },
    );
  }

  Widget _buildLogoutItem(BuildContext context, WidgetRef ref) {
    return ListTile(
      leading: const Icon(Icons.logout),
      title: const Text('Logout'),
      onTap: () async {
        Navigator.pop(context);
        final authService = ref.read(authServiceProvider);
        await authService.signOut();
      },
    );
  }
}

class NavigationItem {
  final IconData icon;
  final IconData? activeIcon;
  final String label;
  final String route;

  NavigationItem({
    required this.icon,
    this.activeIcon,
    required this.label,
    required this.route,
  });
}
