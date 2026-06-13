import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../../models/user_model.dart';
import 'firestore_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<UserModel?> signInWithEmail(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user!;

      // Fetch user data with role from Firestore
      final userWithRole = await FirestoreService.getUserWithRole(user.uid);

      // Update last login time
      await FirestoreService.updateLastLogin(user.uid);

      return userWithRole;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  Future<UserModel?> signUpWithEmail(
    String email,
    String password,
    String fullName, {
    String? phoneNumber,
    String? organization,
    UserRole role = UserRole.citizen,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user!;
      await user.updateDisplayName(fullName);

      // Create user document in Firestore with role
      await FirestoreService.createUserWithRole(
        uid: user.uid,
        email: email,
        fullName: fullName,
        photoUrl: user.photoURL,
        role: role,
        phoneNumber: phoneNumber,
        organization: organization,
      );

      // Return user with role data
      return await FirestoreService.getUserWithRole(user.uid);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  Future<UserModel?> signInWithGoogle() async {
    try {
      UserCredential userCredential;

      if (kIsWeb) {
        userCredential = await _auth.signInWithPopup(GoogleAuthProvider());
      } else {
        userCredential = await _auth.signInWithProvider(GoogleAuthProvider());
      }

      final user = userCredential.user!;

      // Check if user exists in Firestore, if not create with default role
      UserModel? userWithRole = await FirestoreService.getUserWithRole(
        user.uid,
      );

      if (userWithRole == null) {
        // First time Google sign-in, create user with default citizen role
        await FirestoreService.createUserWithRole(
          uid: user.uid,
          email: user.email ?? '',
          fullName: user.displayName,
          photoUrl: user.photoURL,
          role: UserRole.citizen,
        );
        userWithRole = await FirestoreService.getUserWithRole(user.uid);
      } else {
        // Update last login time
        await FirestoreService.updateLastLogin(user.uid);
      }

      return userWithRole;
    } catch (e) {
      throw Exception('Google sign in failed: $e');
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found for that email.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'email-already-in-use':
        return 'The account already exists for that email.';
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'invalid-email':
        return 'The email address is not valid.';
      default:
        return 'An error occurred: ${e.message}';
    }
  }
}
