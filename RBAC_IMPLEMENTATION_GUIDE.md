# Role-Based Access Control (RBAC) Implementation Guide

## Overview
This guide demonstrates how to implement role-based access control in your Ocean Hazard Reporter Flutter app using Firebase Authentication and Firestore.

## Implementation Summary

### 1. **Firestore Service** (`lib/core/services/firestore_service.dart`)
- Manages user roles in Firestore collection `users/{uid}`
- Handles role creation, updates, and queries
- Provides role-based permission checking

### 2. **Updated User Model** (`lib/models/user_model.dart`)
- Added `volunteer` role to existing roles
- Added Firestore integration with `fromFirestore()` method
- Added role-based permission getters (`canModerate`, `canVerify`, etc.)

### 3. **Enhanced Auth Service** (`lib/core/services/auth_service.dart`)
- **Signup**: Creates user in Firestore with selected role
- **Login**: Fetches user data with role from Firestore
- **Google Sign-in**: Auto-creates users with default `citizen` role

### 4. **Role Providers** (`lib/core/providers/role_provider.dart`)
- `currentUserWithRoleProvider`: Stream of user with role data
- `userPermissionsProvider`: Computed permissions based on role
- Role-specific providers (`isAdminProvider`, `canVerifyProvider`, etc.)

### 5. **Route Guards** (`lib/core/routing/app_router.dart`)
- Role-based route access control
- Automatic redirects based on user role
- Protected routes for admin, verification, analytics

### 6. **UI Components**
- **Role Selector**: Widget for role selection during signup
- **Role-Based Navigation**: Bottom nav and drawer with role filtering
- **Admin Interface**: User management and role assignment
- **Verification Screen**: Officials-only report verification
- **Analytics Screen**: Analysts-only analytics dashboard

## Role Definitions

| Role | Permissions | Default Route |
|------|-------------|---------------|
| **Citizen** | Submit reports, view map, social media | `/report` |
| **Volunteer** | Submit reports, moderate reports | `/dashboard` |
| **Official** | Verify reports, view dashboard | `/dashboard` |
| **Analyst** | View analytics, hotspot trends | `/analytics` |
| **Admin** | Full access, user management | `/admin` |

## Example Usage

### 1. **Signup with Role Selection**
```dart
// In register_screen.dart
final authService = ref.read(authServiceProvider);
await authService.signUpWithEmail(
  email: _emailController.text.trim(),
  password: _passwordController.text,
  fullName: _fullNameController.text.trim(),
  phoneNumber: _phoneController.text.trim(),
  organization: _organizationController.text.trim(),
  role: _selectedRole, // UserRole.citizen, volunteer, etc.
);
```

### 2. **Login with Role Fetch**
```dart
// In login_screen.dart
final authService = ref.read(authServiceProvider);
final userWithRole = await authService.signInWithEmail(
  email: _emailController.text.trim(),
  password: _passwordController.text,
);
// userWithRole now contains role information
```

### 3. **Route Guard Example**
```dart
// In app_router.dart
bool _checkRouteAccess(String route, UserModel user) {
  switch (route) {
    case '/admin':
      return user.isAdmin;
    case '/verification':
      return user.canVerify;
    case '/analytics':
      return user.canViewAnalytics;
    default:
      return true;
  }
}
```

### 4. **UI Filtering Example**
```dart
// In any widget
class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canVerify = ref.watch(canVerifyProvider);
    final userRole = ref.watch(userRoleProvider);
    
    return Column(
      children: [
        if (canVerify) // Only show for officials
          ElevatedButton(
            onPressed: () => context.go('/verification'),
            child: Text('Verify Reports'),
          ),
        
        if (userRole == UserRole.analyst) // Only show for analysts
          ElevatedButton(
            onPressed: () => context.go('/analytics'),
            child: Text('View Analytics'),
          ),
      ],
    );
  }
}
```

### 5. **Admin Role Management**
```dart
// Update user role (admin only)
await FirestoreService.updateUserRole(userId, UserRole.official);

// Check user permissions
final hasAccess = await FirestoreService.hasRole(userId, UserRole.admin);

// Get users by role
final officials = await FirestoreService.getUsersByRole(UserRole.official);
```

## Key Features

### **Automatic Role Assignment**
- New users default to `citizen` role
- Google sign-in users auto-created with `citizen` role
- Only admins can change user roles

### **Permission-Based UI**
- Navigation items show/hide based on role
- Buttons and features filtered by permissions
- Route access controlled by role guards

### **Real-time Role Updates**
- Role changes immediately reflect in UI
- Stream-based providers update automatically
- No app restart required

### **Security**
- Server-side role validation in Firestore rules
- Client-side route guards as first line of defense
- Permission-based API access control

## Firestore Security Rules

Add these rules to your Firestore:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can read their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Only admins can read all users
    match /users/{userId} {
      allow read: if request.auth != null && 
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
    
    // Only admins can update roles
    match /users/{userId} {
      allow update: if request.auth != null && 
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin' &&
        'role' in request.resource.data.diff(resource.data).affectedKeys();
    }
  }
}
```

## Testing the Implementation

### 1. **Test Role-Based Signup**
1. Run the app
2. Go to register screen
3. Select different roles during signup
4. Verify user is created with correct role in Firestore

### 2. **Test Route Guards**
1. Login as different role types
2. Try accessing restricted routes
3. Verify automatic redirects work

### 3. **Test UI Filtering**
1. Login as different roles
2. Check navigation shows/hides appropriate items
3. Verify role-specific screens are accessible

### 4. **Test Admin Functions**
1. Login as admin
2. Go to admin dashboard
3. Test user management and role changes

## Next Steps

1. **Add Firestore Security Rules** (see above)
2. **Test with real Firebase project**
3. **Add role-based API endpoints**
4. **Implement role-based notifications**
5. **Add audit logging for role changes**

## Troubleshooting

### Common Issues:
1. **Role not updating**: Check Firestore security rules
2. **UI not filtering**: Verify providers are being watched
3. **Route access denied**: Check route guard logic
4. **Firestore errors**: Ensure cloud_firestore dependency is added

### Debug Tips:
- Use `ref.watch(userRoleProvider)` to check current role
- Check Firestore console for user documents
- Verify route paths match exactly in router
- Use debug prints to trace permission checks
