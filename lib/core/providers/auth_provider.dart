import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../services/auth_service.dart';
import '../../models/user_model.dart';
import '../services/api_service.dart';

final authProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

final currentUserProvider = Provider<UserModel?>((ref) {
  final authState = ref.watch(authProvider);
  return authState.when(
    data: (user) => user != null ? UserModel.fromFirebaseUser(user) : null,
    loading: () => null,
    error: (_, __) => null,
  );
});

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

// Keep ApiService auth header in sync with Firebase ID token
final authTokenSyncProvider = Provider<void>((ref) {
  ref.listen(authProvider, (previous, next) async {
    next.when(
      data: (user) async {
        if (user != null) {
          final token = await user.getIdToken();
          ApiService.setAuthToken(token ?? '');
        } else {
          ApiService.clearAuthToken();
        }
      },
      loading: () {},
      error: (_, __) {
        ApiService.clearAuthToken();
      },
    );
  });
});
