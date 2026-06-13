import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../services/firestore_service.dart';
import '../../models/user_model.dart';

// Provider for current user with role data
final currentUserWithRoleProvider = StreamProvider<UserModel?>((ref) {
  final auth = FirebaseAuth.instance;

  return auth
      .authStateChanges()
      .distinct() // Only emit when auth state actually changes
      .asyncMap((user) async {
        if (user != null) {
          try {
            // Add a small delay to prevent rapid successive calls
            await Future.delayed(const Duration(milliseconds: 100));
            return await FirestoreService.getUserWithRole(user.uid);
          } catch (e) {
            print('Error fetching user role: $e');
            return null;
          }
        } else {
          return null;
        }
      });
});

// Provider for user role
final userRoleProvider = Provider<UserRole?>((ref) {
  final userWithRole = ref.watch(currentUserWithRoleProvider);
  return userWithRole.when(
    data: (user) => user?.role,
    loading: () => null,
    error: (_, __) => null,
  );
});

// Provider for role-based permissions
final userPermissionsProvider = Provider<UserPermissions?>((ref) {
  final userWithRole = ref.watch(currentUserWithRoleProvider);
  return userWithRole.when(
    data: (user) => user != null ? UserPermissions.fromUser(user) : null,
    loading: () => null,
    error: (_, __) => null,
  );
});

// Provider for checking specific roles
final hasRoleProvider = Provider.family<bool, UserRole>((ref, role) {
  final userRole = ref.watch(userRoleProvider);
  return userRole == role;
});

// Provider for checking multiple roles
final hasAnyRoleProvider = Provider.family<bool, List<UserRole>>((ref, roles) {
  final userRole = ref.watch(userRoleProvider);
  return userRole != null && roles.contains(userRole);
});

// Provider for admin users
final isAdminProvider = Provider<bool>((ref) {
  final userRole = ref.watch(userRoleProvider);
  return userRole == UserRole.admin;
});

// Provider for officials (including admin)
final isOfficialProvider = Provider<bool>((ref) {
  final userRole = ref.watch(userRoleProvider);
  return userRole == UserRole.official || userRole == UserRole.admin;
});

// Provider for analysts (including admin)
final isAnalystProvider = Provider<bool>((ref) {
  final userRole = ref.watch(userRoleProvider);
  return userRole == UserRole.analyst || userRole == UserRole.admin;
});

// Provider for volunteers (including admin)
final isVolunteerProvider = Provider<bool>((ref) {
  final userRole = ref.watch(userRoleProvider);
  return userRole == UserRole.volunteer || userRole == UserRole.admin;
});

// Provider for users who can moderate
final canModerateProvider = Provider<bool>((ref) {
  final userRole = ref.watch(userRoleProvider);
  return userRole == UserRole.volunteer ||
      userRole == UserRole.official ||
      userRole == UserRole.admin;
});

// Provider for users who can verify reports
final canVerifyProvider = Provider<bool>((ref) {
  final userRole = ref.watch(userRoleProvider);
  return userRole == UserRole.official || userRole == UserRole.admin;
});

// Provider for users who can view analytics
final canViewAnalyticsProvider = Provider<bool>((ref) {
  final userRole = ref.watch(userRoleProvider);
  return userRole == UserRole.analyst || userRole == UserRole.admin;
});

// Provider for all users (admin only)
final allUsersProvider = FutureProvider<List<UserModel>>((ref) async {
  final isAdmin = ref.watch(isAdminProvider);
  if (!isAdmin) {
    throw Exception('Unauthorized: Admin access required');
  }
  return await FirestoreService.getAllUsers();
});

// Provider for users by role
final usersByRoleProvider = FutureProvider.family<List<UserModel>, UserRole>((
  ref,
  role,
) async {
  final isAdmin = ref.watch(isAdminProvider);
  if (!isAdmin) {
    throw Exception('Unauthorized: Admin access required');
  }
  return await FirestoreService.getUsersByRole(role);
});

// Helper class for role-based permissions
class UserPermissions {
  final bool canSubmitReports;
  final bool canModerateReports;
  final bool canVerifyReports;
  final bool canViewDashboard;
  final bool canViewAnalytics;
  final bool canManageUsers;
  final bool canViewSocialMedia;
  final bool canViewMap;

  const UserPermissions({
    required this.canSubmitReports,
    required this.canModerateReports,
    required this.canVerifyReports,
    required this.canViewDashboard,
    required this.canViewAnalytics,
    required this.canManageUsers,
    required this.canViewSocialMedia,
    required this.canViewMap,
  });

  factory UserPermissions.fromUser(UserModel user) {
    return UserPermissions(
      canSubmitReports: true, // All users can submit reports
      canModerateReports: user.canModerate,
      canVerifyReports: user.canVerify,
      canViewDashboard: true, // All users can view dashboard
      canViewAnalytics: user.canViewAnalytics,
      canManageUsers: user.isAdmin,
      canViewSocialMedia: true, // All users can view social media
      canViewMap: true, // All users can view map
    );
  }

  // Get allowed routes based on permissions
  List<String> getAllowedRoutes() {
    final routes = <String>['/dashboard', '/profile', '/settings'];

    if (canViewMap) routes.add('/map');
    if (canViewSocialMedia) routes.add('/social');
    if (canSubmitReports) routes.add('/report');
    if (canViewDashboard) routes.add('/reports');
    if (canModerateReports) routes.add('/moderation');
    if (canVerifyReports) routes.add('/verification');
    if (canViewAnalytics) routes.add('/analytics');
    if (canManageUsers) routes.add('/admin');

    return routes;
  }
}
