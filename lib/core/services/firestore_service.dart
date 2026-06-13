import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/user_model.dart';

class FirestoreService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _usersCollection = 'users';

  // Create user document with role on signup
  static Future<void> createUserWithRole({
    required String uid,
    required String email,
    required String? fullName,
    required String? photoUrl,
    UserRole role = UserRole.citizen,
    String? phoneNumber,
    String? organization,
  }) async {
    try {
      final userData = {
        'id': uid,
        'email': email,
        'fullName': fullName,
        'photoUrl': photoUrl,
        'role': role.toString().split('.').last,
        'phoneNumber': phoneNumber,
        'organization': organization,
        'createdAt': FieldValue.serverTimestamp(),
        'lastLoginAt': FieldValue.serverTimestamp(),
        'isVerified': false,
        'isActive': true,
      };

      await _firestore
          .collection(_usersCollection)
          .doc(uid)
          .set(userData, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to create user profile: $e');
    }
  }

  // Get user data with role from Firestore
  static Future<UserModel?> getUserWithRole(String uid) async {
    try {
      final doc = await _firestore
          .collection(_usersCollection)
          .doc(uid)
          .get();

      if (!doc.exists) {
        return null;
      }

      final data = doc.data()!;
      return UserModel.fromFirestore(data);
    } catch (e) {
      throw Exception('Failed to fetch user data: $e');
    }
  }

  // Update user role (admin only)
  static Future<void> updateUserRole(String uid, UserRole newRole) async {
    try {
      await _firestore
          .collection(_usersCollection)
          .doc(uid)
          .update({
        'role': newRole.toString().split('.').last,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update user role: $e');
    }
  }

  // Update user last login time
  static Future<void> updateLastLogin(String uid) async {
    try {
      await _firestore
          .collection(_usersCollection)
          .doc(uid)
          .update({
        'lastLoginAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      // Don't throw error for this, it's not critical
      print('Failed to update last login: $e');
    }
  }

  // Get all users (admin only)
  static Future<List<UserModel>> getAllUsers() async {
    try {
      final querySnapshot = await _firestore
          .collection(_usersCollection)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => UserModel.fromFirestore(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch users: $e');
    }
  }

  // Check if user has specific role
  static Future<bool> hasRole(String uid, UserRole role) async {
    try {
      final user = await getUserWithRole(uid);
      return user?.role == role;
    } catch (e) {
      return false;
    }
  }

  // Check if user has any of the specified roles
  static Future<bool> hasAnyRole(String uid, List<UserRole> roles) async {
    try {
      final user = await getUserWithRole(uid);
      return user != null && roles.contains(user.role);
    } catch (e) {
      return false;
    }
  }

  // Get users by role
  static Future<List<UserModel>> getUsersByRole(UserRole role) async {
    try {
      final querySnapshot = await _firestore
          .collection(_usersCollection)
          .where('role', isEqualTo: role.toString().split('.').last)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => UserModel.fromFirestore(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch users by role: $e');
    }
  }

  // Update user profile
  static Future<void> updateUserProfile(String uid, Map<String, dynamic> updates) async {
    try {
      await _firestore
          .collection(_usersCollection)
          .doc(uid)
          .update({
        ...updates,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update user profile: $e');
    }
  }

  // Delete user (admin only)
  static Future<void> deleteUser(String uid) async {
    try {
      await _firestore
          .collection(_usersCollection)
          .doc(uid)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete user: $e');
    }
  }
}
