import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/role_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/widgets/language_selector.dart';
import '../../../models/user_model.dart';
import '../widgets/dashboard_card.dart';
import '../widgets/quick_report_button.dart';
import '../widgets/recent_reports_list.dart';
import '../widgets/hazard_alerts_banner.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: MainAppBar(
        title: 'app_title'.tr(),
        actions: [
          const CompactLanguageSelector(),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // TODO: Navigate to notifications
            },
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
                  break;
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'profile',
                child: Row(
                  children: [
                    const Icon(Icons.person_outline),
                    const SizedBox(width: 8),
                    Text('profile'.tr()),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    const Icon(Icons.settings_outlined),
                    const SizedBox(width: 8),
                    Text('settings'.tr()),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    const Icon(Icons.logout),
                    const SizedBox(width: 8),
                    Text('logout'.tr()),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: const _DashboardBody(),
    );
  }
}

// Separate widget to handle stream watching
class _DashboardBody extends ConsumerWidget {
  const _DashboardBody();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userWithRole = ref.watch(currentUserWithRoleProvider);

    if (userWithRole.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (userWithRole.hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text('error'.tr()),
            const SizedBox(height: 8),
            Text(userWithRole.error.toString()),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Refresh the provider
                ref.invalidate(currentUserWithRoleProvider);
              },
              child: Text('retry'.tr()),
            ),
          ],
        ),
      );
    }

    final user = userWithRole.value;
    if (user == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return _buildRoleBasedDashboard(context, user);
  }

  Widget _buildRoleBasedDashboard(BuildContext context, UserModel user) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Role-specific Welcome Section
          _buildWelcomeSection(context, user),

          const SizedBox(height: 24),

          // Hazard Alerts Banner
          const HazardAlertsBanner(),

          const SizedBox(height: 24),

          // Role-specific Quick Actions
          _buildQuickActions(context, user),

          const SizedBox(height: 32),

          // Role-specific Statistics
          _buildStatistics(context, user),

          const SizedBox(height: 32),

          // Recent Reports
          Text(
            'recent_reports'.tr(),
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          const RecentReportsList(),

          const SizedBox(height: 100), // Bottom padding for FAB
        ],
      ),
    );
  }

  String _getRoleWelcomeMessage(UserRole role) {
    switch (role) {
      case UserRole.citizen:
        return 'citizen_welcome'.tr();
      case UserRole.volunteer:
        return 'volunteer_welcome'.tr();
      case UserRole.official:
        return 'official_welcome'.tr();
      case UserRole.analyst:
        return 'analyst_welcome'.tr();
      case UserRole.admin:
        return 'admin_welcome'.tr();
    }
  }

  Widget _buildWelcomeSection(BuildContext context, UserModel user) {
    final welcomeMessage = _getRoleWelcomeMessage(user.role);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.oceanBlue, AppTheme.deepBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'welcome_back'.tr(),
            style: const TextStyle(fontSize: 16, color: Colors.white70),
          ),
          Text(
            user.fullName ?? 'user'.tr(),
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            welcomeMessage,
            style: const TextStyle(fontSize: 14, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, UserModel user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'quick_actions'.tr(),
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        _buildQuickActionsGrid(context, user),
      ],
    );
  }

  Widget _buildQuickActionsGrid(BuildContext context, UserModel user) {
    final actions = _getRoleSpecificActions(context, user.role);

    return Column(
      children: [
        // First row
        Row(
          children: [
            if (actions.isNotEmpty) ...[
              Expanded(child: actions[0]),
              if (actions.length >= 2) const SizedBox(width: 16),
            ],
            if (actions.length >= 2) Expanded(child: actions[1]),
          ],
        ),
        if (actions.length > 2) ...[
          const SizedBox(height: 16),
          // Second row
          Row(
            children: [
              if (actions.length >= 3) ...[
                Expanded(child: actions[2]),
                if (actions.length >= 4) const SizedBox(width: 16),
              ],
              if (actions.length >= 4) Expanded(child: actions[3]),
            ],
          ),
        ],
        if (actions.length > 4) ...[
          const SizedBox(height: 16),
          // Third row
          Row(
            children: [
              if (actions.length >= 5) ...[
                Expanded(child: actions[4]),
                if (actions.length >= 6) const SizedBox(width: 16),
              ],
              if (actions.length >= 6) Expanded(child: actions[5]),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildStatistics(BuildContext context, UserModel user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'statistics'.tr(),
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        _buildStatisticsGrid(context, user),
      ],
    );
  }

  Widget _buildStatisticsGrid(BuildContext context, UserModel user) {
    final stats = _getRoleSpecificStats(user.role);

    return Column(
      children: [
        // First row
        Row(
          children: [
            if (stats.isNotEmpty) ...[
              Expanded(child: stats[0]),
              if (stats.length >= 2) const SizedBox(width: 16),
            ],
            if (stats.length >= 2) Expanded(child: stats[1]),
          ],
        ),
        if (stats.length > 2) ...[
          const SizedBox(height: 16),
          // Second row
          Row(
            children: [
              if (stats.length >= 3) ...[
                Expanded(child: stats[2]),
                if (stats.length >= 4) const SizedBox(width: 16),
              ],
              if (stats.length >= 4) Expanded(child: stats[3]),
            ],
          ),
        ],
      ],
    );
  }

  List<Widget> _getRoleSpecificActions(BuildContext context, UserRole role) {
    switch (role) {
      case UserRole.citizen:
        return [
          QuickReportButton(
            icon: Icons.add_alert,
            title: 'report_hazard'.tr(),
            subtitle: 'report_new_hazard'.tr(),
            onTap: () => context.go('/report'),
            color: AppTheme.dangerColor,
          ),
          QuickReportButton(
            icon: Icons.map_outlined,
            title: 'view_map'.tr(),
            subtitle: 'see_all_reports'.tr(),
            onTap: () => context.go('/map'),
            color: AppTheme.primaryColor,
          ),
          QuickReportButton(
            icon: Icons.list_alt,
            title: 'all_reports'.tr(),
            subtitle: 'browse_all_reports'.tr(),
            onTap: () => context.go('/reports'),
            color: AppTheme.successColor,
          ),
        ];

      case UserRole.volunteer:
        return [
          QuickReportButton(
            icon: Icons.add_alert,
            title: 'report_hazard'.tr(),
            subtitle: 'report_new_hazard'.tr(),
            onTap: () => context.go('/report'),
            color: AppTheme.dangerColor,
          ),
          QuickReportButton(
            icon: Icons.verified_user_outlined,
            title: 'moderate_reports'.tr(),
            subtitle: 'review_pending_reports'.tr(),
            onTap: () => context.go('/moderation'),
            color: AppTheme.warningColor,
          ),
          QuickReportButton(
            icon: Icons.map_outlined,
            title: 'view_map'.tr(),
            subtitle: 'see_all_reports'.tr(),
            onTap: () => context.go('/map'),
            color: AppTheme.primaryColor,
          ),
          QuickReportButton(
            icon: Icons.list_alt,
            title: 'all_reports'.tr(),
            subtitle: 'browse_all_reports'.tr(),
            onTap: () => context.go('/reports'),
            color: AppTheme.successColor,
          ),
        ];

      case UserRole.official:
        return [
          QuickReportButton(
            icon: Icons.add_alert,
            title: 'report_hazard'.tr(),
            subtitle: 'report_new_hazard'.tr(),
            onTap: () => context.go('/report'),
            color: AppTheme.dangerColor,
          ),
          QuickReportButton(
            icon: Icons.verified_outlined,
            title: 'verify_reports'.tr(),
            subtitle: 'verify_pending_reports'.tr(),
            onTap: () => context.go('/verification'),
            color: AppTheme.primaryColor,
          ),
          QuickReportButton(
            icon: Icons.map_outlined,
            title: 'view_map'.tr(),
            subtitle: 'see_all_reports'.tr(),
            onTap: () => context.go('/map'),
            color: AppTheme.primaryColor,
          ),
          QuickReportButton(
            icon: Icons.list_alt,
            title: 'all_reports'.tr(),
            subtitle: 'browse_all_reports'.tr(),
            onTap: () => context.go('/reports'),
            color: AppTheme.successColor,
          ),
        ];

      case UserRole.analyst:
        return [
          QuickReportButton(
            icon: Icons.analytics_outlined,
            title: 'analytics_dashboard'.tr(),
            subtitle: 'view_analytics'.tr(),
            onTap: () => context.go('/analytics'),
            color: AppTheme.primaryColor,
          ),
          QuickReportButton(
            icon: Icons.trending_up_outlined,
            title: 'hotspot_trends'.tr(),
            subtitle: 'view_hotspot_trends'.tr(),
            onTap: () => context.go('/analytics'),
            color: AppTheme.warningColor,
          ),
          QuickReportButton(
            icon: Icons.map_outlined,
            title: 'view_map'.tr(),
            subtitle: 'see_all_reports'.tr(),
            onTap: () => context.go('/map'),
            color: AppTheme.primaryColor,
          ),
          QuickReportButton(
            icon: Icons.social_distance_outlined,
            title: 'social_media'.tr(),
            subtitle: 'monitor_social_trends'.tr(),
            onTap: () => context.go('/social'),
            color: AppTheme.warningColor,
          ),
        ];

      case UserRole.admin:
        return [
          QuickReportButton(
            icon: Icons.admin_panel_settings_outlined,
            title: 'admin_dashboard'.tr(),
            subtitle: 'manage_system'.tr(),
            onTap: () => context.go('/admin'),
            color: AppTheme.dangerColor,
          ),
          QuickReportButton(
            icon: Icons.people_outlined,
            title: 'user_management'.tr(),
            subtitle: 'manage_users'.tr(),
            onTap: () => context.go('/admin/users'),
            color: AppTheme.primaryColor,
          ),
          QuickReportButton(
            icon: Icons.analytics_outlined,
            title: 'analytics_dashboard'.tr(),
            subtitle: 'view_analytics'.tr(),
            onTap: () => context.go('/analytics'),
            color: AppTheme.warningColor,
          ),
          QuickReportButton(
            icon: Icons.map_outlined,
            title: 'view_map'.tr(),
            subtitle: 'see_all_reports'.tr(),
            onTap: () => context.go('/map'),
            color: AppTheme.primaryColor,
          ),
        ];
    }
  }

  List<Widget> _getRoleSpecificStats(UserRole role) {
    switch (role) {
      case UserRole.citizen:
        return [
          DashboardCard(
            title: 'total_reports'.tr(),
            value: '1,247',
            icon: Icons.report_outlined,
            color: AppTheme.primaryColor,
            trend: '+12%',
            trendUp: true,
          ),
          DashboardCard(
            title: 'active_alerts'.tr(),
            value: '23',
            icon: Icons.warning_outlined,
            color: AppTheme.dangerColor,
            trend: '+5%',
            trendUp: true,
          ),
        ];

      case UserRole.volunteer:
        return [
          DashboardCard(
            title: 'total_reports'.tr(),
            value: '1,247',
            icon: Icons.report_outlined,
            color: AppTheme.primaryColor,
            trend: '+12%',
            trendUp: true,
          ),
          DashboardCard(
            title: 'pending_moderation'.tr(),
            value: '15',
            icon: Icons.verified_user_outlined,
            color: AppTheme.warningColor,
            trend: '+3%',
            trendUp: true,
          ),
          DashboardCard(
            title: 'active_alerts'.tr(),
            value: '23',
            icon: Icons.warning_outlined,
            color: AppTheme.dangerColor,
            trend: '+5%',
            trendUp: true,
          ),
          DashboardCard(
            title: 'verified_today'.tr(),
            value: '8',
            icon: Icons.verified_outlined,
            color: AppTheme.successColor,
            trend: '+15%',
            trendUp: true,
          ),
        ];

      case UserRole.official:
        return [
          DashboardCard(
            title: 'total_reports'.tr(),
            value: '1,247',
            icon: Icons.report_outlined,
            color: AppTheme.primaryColor,
            trend: '+12%',
            trendUp: true,
          ),
          DashboardCard(
            title: 'pending_verification'.tr(),
            value: '8',
            icon: Icons.verified_outlined,
            color: AppTheme.warningColor,
            trend: '+2%',
            trendUp: true,
          ),
          DashboardCard(
            title: 'active_alerts'.tr(),
            value: '23',
            icon: Icons.warning_outlined,
            color: AppTheme.dangerColor,
            trend: '+5%',
            trendUp: true,
          ),
          DashboardCard(
            title: 'verified_today'.tr(),
            value: '12',
            icon: Icons.verified_outlined,
            color: AppTheme.successColor,
            trend: '+18%',
            trendUp: true,
          ),
        ];

      case UserRole.analyst:
        return [
          DashboardCard(
            title: 'analytics_insights'.tr(),
            value: '45',
            icon: Icons.analytics_outlined,
            color: AppTheme.primaryColor,
            trend: '+8%',
            trendUp: true,
          ),
          DashboardCard(
            title: 'hotspot_trends'.tr(),
            value: '12',
            icon: Icons.trending_up_outlined,
            color: AppTheme.warningColor,
            trend: '+22%',
            trendUp: true,
          ),
          DashboardCard(
            title: 'social_posts'.tr(),
            value: '156',
            icon: Icons.social_distance,
            color: AppTheme.warningColor,
            trend: '+8%',
            trendUp: true,
          ),
          DashboardCard(
            title: 'total_reports'.tr(),
            value: '1,247',
            icon: Icons.report_outlined,
            color: AppTheme.primaryColor,
            trend: '+12%',
            trendUp: true,
          ),
        ];

      case UserRole.admin:
        return [
          DashboardCard(
            title: 'system_users'.tr(),
            value: '2,456',
            icon: Icons.people_outlined,
            color: AppTheme.primaryColor,
            trend: '+5%',
            trendUp: true,
          ),
          DashboardCard(
            title: 'total_reports'.tr(),
            value: '1,247',
            icon: Icons.report_outlined,
            color: AppTheme.primaryColor,
            trend: '+12%',
            trendUp: true,
          ),
          DashboardCard(
            title: 'active_alerts'.tr(),
            value: '23',
            icon: Icons.warning_outlined,
            color: AppTheme.dangerColor,
            trend: '+5%',
            trendUp: true,
          ),
          DashboardCard(
            title: 'verified_today'.tr(),
            value: '8',
            icon: Icons.verified_outlined,
            color: AppTheme.successColor,
            trend: '+15%',
            trendUp: true,
          ),
        ];
    }
  }
}
