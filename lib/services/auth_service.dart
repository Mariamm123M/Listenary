import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:listenary/view/pages/home.dart';
import 'package:listenary/view/pages/login.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Sign in with Email & Password
  Future<void> signInWithEmail(String email, String password, BuildContext context) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      Get.offAll(() => const Home());
    } on FirebaseAuthException catch (e) {
      _showErrorDialog(context, e.message ?? "An error occurred");
    }
  }

  // Sign up with Email & Password
  Future<void> signUpWithEmail(String email, String password, String name, BuildContext context) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(email: email, password: password);

      await userCredential.user!.updateDisplayName(name); // Set display name

      Get.offAll(() => const Home());
    } on FirebaseAuthException catch (e) {
      _showErrorDialog(context, e.message ?? "An error occurred");
    }
  }


  // Sign in with Google
  Future<bool> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return false; // User canceled sign-in

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      await _auth.signInWithCredential(credential);
      return true; // Success
    } catch (e) {
      print("Google Sign-In Error: $e");
      return false; // Failed sign-in
    }
  }
//.......
  // Sign out
  Future<void> signOut(BuildContext context) async {
    await _auth.signOut();
    await GoogleSignIn().signOut();
    Get.offAll(() => const Login());
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Error"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }
}
