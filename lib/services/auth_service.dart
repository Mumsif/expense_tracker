import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {

  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  final ValueNotifier<bool> demoModeNotifier = ValueNotifier<bool>(false);

  bool get isDemoMode => demoModeNotifier.value;

  void enterDemoMode() {
    demoModeNotifier.value = true;
  }

  void exitDemoMode() {
    demoModeNotifier.value = false;
  }

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  bool get isAnonymous => (_auth.currentUser?.isAnonymous ?? false) || isDemoMode;

  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _getReadableAuthErrorMessage(e);
    } catch (e) {
      throw 'An unexpected error occurred during sign in. Please try again.';
    }
  }

  Future<UserCredential> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _getReadableAuthErrorMessage(e);
    } catch (e) {
      throw 'An unexpected error occurred during account creation. Please try again.';
    }
  }

  Future<UserCredential> signInAnonymously() async {
    try {
      return await _auth.signInAnonymously();
    } on FirebaseAuthException catch (e) {
      throw _getReadableAuthErrorMessage(e);
    } catch (e) {
      throw 'Failed to sign in as guest. Please check your internet connection.';
    }
  }

  Future<void> sendPasswordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw _getReadableAuthErrorMessage(e);
    } catch (e) {
      throw 'Failed to send password reset email. Please try again.';
    }
  }

  Future<void> signOut() async {
    demoModeNotifier.value = false;
    try {
      await _auth.signOut();
    } catch (e) {
      throw 'Failed to sign out: $e';
    }
  }

  String _getReadableAuthErrorMessage(FirebaseAuthException e) {
    debugPrint('FirebaseAuthException [${e.code}]: ${e.message}');

    switch (e.code) {
      case 'user-not-found':
        return 'No account found with this email address. Please sign up first.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password. Please verify your credentials.';
      case 'email-already-in-use':
        return 'An account with this email address already exists. Please sign in instead.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'weak-password':
        return 'The chosen password is too weak. Please use at least 6 characters.';
      case 'user-disabled':
        return 'This account has been disabled. Please contact support.';
      case 'too-many-requests':
        return 'Too many failed attempts. Please wait a few minutes before trying again.';
      case 'operation-not-allowed':
        return 'Email/Password sign-in is disabled in your Firebase Console. Please enable it under Authentication > Sign-in method.';
      case 'network-request-failed':
        return 'Network connection failed. Please check your internet connection.';
      case 'internal-error':
        final msg = e.message ?? '';
        if (msg.contains('CONFIGURATION_NOT_FOUND') ||
            msg.toLowerCase().contains('configuration')) {
          return 'Firebase Authentication is not activated yet for this project. Please open Firebase Console > Authentication > Sign-in method, and turn ON "Email/Password".';
        }
        return 'Internal Firebase error: ${msg.isNotEmpty ? msg : "Check your connection and Firebase Console configuration."}';
      case 'configuration-not-found':
        return 'Firebase Authentication is not activated yet for this project. Please open Firebase Console > Authentication > Sign-in method, and turn ON "Email/Password".';
      default:
        return e.message ?? 'Authentication failed (${e.code}). Please try again.';
    }
  }
}
