import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:listenary/view/pages/home.dart';
import 'package:listenary/view/pages/login.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Sign in with Email & Password
  Future<bool> signInWithEmail(String email, String password, BuildContext context) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      // Don't navigate here, let the calling widget handle navigation
      return true; // Return success
    } on FirebaseAuthException catch (e) {
      _showErrorDialog(context, e.message ?? "An error occurred");
      return false; // Return failure
    } catch (e) {
      _showErrorDialog(context, "An unexpected error occurred");
      return false; // Return failure
    }
  }

  // Sign up with Email & Password
  Future<bool> signUpWithEmail(String email, String password, BuildContext context) async {
    try {
      await _auth.createUserWithEmailAndPassword(email: email, password: password);
      // Don't navigate here, let the calling widget handle navigation
      return true; // Return success
    } on FirebaseAuthException catch (e) {
      _showErrorDialog(context, e.message ?? "An error occurred");
      return false; // Return failure
    } catch (e) {
      _showErrorDialog(context, "An unexpected error occurred");
      return false; // Return failure
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
      return true; // Return success
    } catch (e) {
      // You might want to show an error here too, but since there's no context parameter,
      // you could use Get.snackbar instead
      Get.snackbar(
        "Error", 
        "Google sign-in failed",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false; // Return failure
    }
  }

  Future<void> signOut(BuildContext context) async {
    try {
      print('Simple logout started...');  
      
      await _auth.signOut();
      await GoogleSignIn().signOut();
      
      print('Logout completed, navigating...');
      
      // Use different navigation approach
      Get.offAllNamed('/login'); // Make sure '/login' route exists in your GetPages
      
      // Or use this alternative:
      // Navigator.of(context).pushAndRemoveUntil(
      //   MaterialPageRoute(builder: (context) => const Login()),
      //   (route) => false,
      // );
      
    } catch (e) {
      print('Simple logout error: $e');
      Get.snackbar("Error", "Logout failed: $e");
    }
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