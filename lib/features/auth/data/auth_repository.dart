import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: kIsWeb ? '606100022692-1hk85qdmivha2oud9h6qhg6q2nnumor2.apps.googleusercontent.com' : null,
  );

  // --- Local Auth (Email/Password) ---

  Future<void> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      print("Login error: $e");
      rethrow;
    }
  }

  Future<void> signup(String name, String email, String password) async {
    try {
      // Create user in Firebase
      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email, 
        password: password
      );

      // Update Display Name
      if (userCredential.user != null) {
        await userCredential.user!.updateDisplayName(name);
        await userCredential.user!.reload(); // Reload to apply changes locally
      }
    } catch (e) {
      print("Signup error: $e");
      rethrow;
    }
  }

  // --- Google Sign In (Firebase) ---

  Future<User?> signInWithGoogle() async {
    try {
      print("Starting Google Sign-In flow...");
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        print("Google Sign-In cancelled by user (googleUser is null).");
        return null;
      }
      print("Google User obtained: ${googleUser.email}");

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      print("Google Auth obtained. AccessToken: ${googleAuth.accessToken != null}, IdToken: ${googleAuth.idToken != null}");

      // Create a new credential
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google User Credential
      print("Signing in to Firebase with credential...");
      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      print("Firebase Sign-In successful. User: ${userCredential.user?.uid}");
      return userCredential.user;
    } catch (e, stackTrace) {
      print("Error signing in with Google: $e");
      print("Stack trace: $stackTrace");
      return null;
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // --- Common Methods ---

  // --- Common Methods ---

  Future<void> logout() async {
    // Sign out from Firebase and Google
    await _auth.signOut();
    await _googleSignIn.signOut();
  }

  Future<bool> checkAuthStatus() async {
    // Check Firebase Auth
    return _auth.currentUser != null;
  }

  Future<Map<String, dynamic>?> getUserProfile() async {
    // Check Firebase User
    final firebaseUser = _auth.currentUser;
    if (firebaseUser != null) {
      return {
        'name': firebaseUser.displayName ?? 'User',
        'email': firebaseUser.email,
        'photoUrl': firebaseUser.photoURL,
        'joinedAt': firebaseUser.metadata.creationTime?.toIso8601String(),
      };
    }
    return null;
  }
  
  Stream<User?> get authStateChanges => _auth.authStateChanges();
}
