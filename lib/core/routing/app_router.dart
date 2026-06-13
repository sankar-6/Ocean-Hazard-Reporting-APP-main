import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';

import '../providers/auth_provider.dart';
import '../providers/role_provider.dart';
import '../../models/user_model.dart';
import '../widgets/custom_app_bar.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/dashboard/screens/dashboard_screen.dart';
import '../../features/reporting/screens/report_incident_screen.dart';
import '../../features/reporting/screens/report_list_screen.dart';
import '../../features/map/screens/map_screen.dart';
import '../../features/social_media/screens/social_media_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/admin/screens/admin_dashboard_screen.dart';
import '../../features/admin/screens/user_management_screen.dart';
import '../../features/verification/screens/verification_screen.dart';
import '../../features/analytics/screens/analytics_screen.dart';
import '../../features/settings/screens/settings_screen.dart';
import '../../features/reporting/screens/report_details_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);
  final userWithRole = ref.watch(currentUserWithRoleProvider);

  return GoRouter(
    initialLocation: '/splash',
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final isLoggedIn = authState.when(
        data: (user) => user != null,
        loading: () => false,
        error: (_, __) => false,
      );

      final isLoggingIn =
          state.matchedLocation == '/login' ||
          state.matchedLocation == '/register' ||
          state.matchedLocation == '/splash';

      // If not logged in and not on auth routes, redirect to login
      if (!isLoggedIn && !isLoggingIn) return '/login';

      // If logged in and on auth routes, redirect based on role
      if (isLoggedIn && isLoggingIn) {
        return userWithRole.when(
          data: (user) => _getDefaultRouteForUser(user),
          loading: () => '/splash', // Stay on splash while loading
          error: (_, __) => '/dashboard', // Fallback to dashboard on error
        );
      }

      // Check role-based access for protected routes
      if (isLoggedIn) {
        return userWithRole.when(
          data: (user) {
            if (user != null) {
              final hasAccess = _checkRouteAccess(state.matchedLocation, user);
              if (!hasAccess) {
                return '/unauthorized';
              }
            }
            return null; // Allow access
          },
          loading: () => null, // Allow access while loading
          error: (_, __) => '/login', // If error, go back to login
        );
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: '/report',
        builder: (context, state) => const ReportIncidentScreen(),
      ),
      GoRoute(
        path: '/report/create',
        builder: (context, state) => const ReportIncidentScreen(),
      ),
      GoRoute(
        path: '/report/:id',
        builder: (context, state) {
          final reportId = state.pathParameters['id']!;
          return ReportDetailsScreen(reportId: reportId);
        },
      ),
      GoRoute(
        path: '/reports',
        builder: (context, state) => const ReportListScreen(),
      ),
      GoRoute(path: '/map', builder: (context, state) => const MapScreen()),
      GoRoute(
        path: '/social',
        builder: (context, state) => const SocialMediaScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),

      // Admin routes
      GoRoute(
        path: '/admin',
        builder: (context, state) => const AdminDashboardScreen(),
      ),
      GoRoute(
        path: '/admin/users',
        builder: (context, state) => const UserManagementScreen(),
      ),

      // Verification routes (Officials only)
      GoRoute(
        path: '/verification',
        builder: (context, state) => const VerificationScreen(),
      ),

      // Analytics routes (Analysts only)
      GoRoute(
        path: '/analytics',
        builder: (context, state) => const AnalyticsScreen(),
      ),

      // Moderation routes (Volunteers only)
      GoRoute(
        path: '/moderation',
        builder: (context, state) => Scaffold(
          appBar: DetailAppBar(title: 'moderation_coming_soon'.tr()),
          body: Center(child: Text('moderation_coming_soon'.tr())),
        ),
      ),

      // Additional admin routes
      GoRoute(
        path: '/admin/settings',
        builder: (context, state) => Scaffold(
          appBar: DetailAppBar(title: 'admin_settings'.tr()),
          body: Center(child: Text('admin_settings_coming_soon'.tr())),
        ),
      ),

      // Error/Unauthorized route
      GoRoute(
        path: '/unauthorized',
        builder: (context, state) => Scaffold(
          appBar: DetailAppBar(title: 'unauthorized'.tr()),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.block, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  'access_denied'.tr(),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text('insufficient_permissions'.tr()),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => context.go('/dashboard'),
                  child: Text('go_to_dashboard'.tr()),
                ),
              ],
            ),
          ),
        ),
      ),
    ],
  );
});

// Helper function to get default route based on user role
String _getDefaultRouteForUser(UserModel? user) {
  if (user == null) return '/login';

  switch (user.role) {
    case UserRole.citizen:
      return '/dashboard'; // Citizens get main dashboard
    case UserRole.volunteer:
      return '/dashboard'; // Volunteers get main dashboard with moderation access
    case UserRole.official:
      return '/dashboard'; // Officials get main dashboard with verification access
    case UserRole.analyst:
      return '/analytics'; // Analysts see analytics dashboard first
    case UserRole.admin:
      return '/admin'; // Admins see admin dashboard first
  }
}

// Helper function to check if user has access to a route
bool _checkRouteAccess(String route, UserModel user) {
  // Universal routes that all authenticated users can access
  const universalRoutes = {'/profile', '/settings', '/dashboard'};

  if (universalRoutes.contains(route)) return true;

  // Role hierarchy: Admin > Official/Analyst > Volunteer > Citizen
  // Higher roles inherit permissions from lower roles

  // Role-specific route access with hierarchy
  switch (route) {
    // Admin-only routes (highest privilege)
    case '/admin':
    case '/admin/users':
    case '/admin/settings':
      return user.isAdmin;

    // Official routes (Officials + Admins)
    case '/verification':
      return user.canVerify; // Official or Admin

    // Analyst routes (Analysts + Admins)
    case '/analytics':
      return user.canViewAnalytics; // Analyst or Admin

    // Volunteer routes (Volunteers + Officials + Admins)
    case '/moderation':
      return user.canModerate; // Volunteer, Official, or Admin

    // Citizen routes (All authenticated users)
    case '/report':
      return true; // All users can report

    // Shared routes (All authenticated users)
    case '/map':
    case '/social':
    case '/reports':
      return true; // All authenticated users

    // Auth routes (should not be accessed when logged in)
    case '/login':
    case '/register':
    case '/splash':
      return false; // These should be handled by redirect logic

    default:
      return false; // Deny access to unknown routes
  }
}
