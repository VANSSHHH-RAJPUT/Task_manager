import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  // Stream of auth state changes
  Stream<User?> get userStream => _auth.authStateChanges();

  // Get current user
  User? get currentUser => _auth.currentUser;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // Sign up with email, password, and full name
  Future<String?> signUp(String email, String password, String fullName) async {
    try {
      _setLoading(true);
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = result.user;
      if (user != null) {
        await user.updateDisplayName(fullName);
        await _firestore.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'fullName': fullName,
          'email': email,
          'createdAt': FieldValue.serverTimestamp(),
        });
        await user.reload();
      }
      _setLoading(false);
      return null;
    } on FirebaseAuthException catch (e) {
      _setLoading(false);
      return _getMessageFromErrorCode(e.code);
    } catch (e) {
      _setLoading(false);
      return "Unexpected error: ${e.toString()}";
    }
  }

  // Login with email and password
  Future<String?> login(String email, String password) async {
    try {
      _setLoading(true);
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      _setLoading(false);
      return null;
    } on FirebaseAuthException catch (e) {
      _setLoading(false);
      return _getMessageFromErrorCode(e.code);
    } catch (e) {
      _setLoading(false);
      return "Unexpected error: ${e.toString()}";
    }
  }

  String _getMessageFromErrorCode(String code) {
    switch (code) {
      case "email-already-in-use":
        return "This email is already registered.";
      case "invalid-email":
        return "The email address is not valid.";
      case "user-not-found":
      case "wrong-password":
      case "invalid-credential":
        return "Invalid email or password.";
      case "user-disabled":
        return "This account has been disabled.";
      case "too-many-requests":
        return "Too many attempts. Please try again later.";
      case "network-request-failed":
        return "Please check your internet connection.";
      default:
        return "Authentication failed. Please try again.";
    }
  }

  // Logout
  Future<void> logout() async {
    await _auth.signOut();
  }
}
