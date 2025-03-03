import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:listenary/services/auth_service.dart';
import 'package:listenary/view/components/custom_textformfield.dart';
import 'package:listenary/view/pages/login.dart' as login_page;
import 'package:firebase_auth/firebase_auth.dart';

import '../components/bottom_navigation_bar.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();

  final AuthService _authService = AuthService();

  bool isObsecure = true;

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

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(
          vertical: screenHeight * 0.06,
          horizontal: screenWidth * 0.06,
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              InkWell(
                onTap: () {
                  Get.back();
                },
                child: Row(
                  children: [
                    const Icon(Icons.arrow_back_rounded),
                    SizedBox(width: screenWidth * 0.02),
                    Text(
                      "Back",
                      style: TextStyle(
                        color: const Color(0XFF212E54),
                        fontSize: screenWidth * 0.035,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: screenHeight * 0.01),
              Center(
                child: Image.asset(
                  "assets/Icons/logo.png",
                  width: screenWidth * 0.4,
                  height: screenHeight * 0.2,
                ),
              ),
              Form(
                key: formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Create an Account",
                      style: TextStyle(
                        color: const Color(0XFF212E54),
                        fontSize: screenWidth * 0.055,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Inter',
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.01),
                    Text(
                      "Register to continue",
                      style: TextStyle(
                        color: const Color(0XFF787878),
                        fontSize: screenWidth * 0.04,
                        fontWeight: FontWeight.w400,
                        fontFamily: 'Inter',
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.035),

                    //username field
                    buildTextFormField(
                      screenWidth: screenWidth,
                      hint: "Username",
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Please enter your name";
                        }
                        return null;
                      },
                      controller: nameController,
                      prefixIcon: Icon(Icons.person, color: Colors.grey),
                    ),
                    SizedBox(height: screenHeight * 0.015),


                    // Email Field
                    buildTextFormField(
                      screenWidth: screenWidth,
                      hint: "Email",
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Please enter your email";
                        } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                          return "Enter a valid email";
                        }
                        return null;
                      },
                      controller: emailController,
                      prefixIcon: Image.asset("assets/Icons/email.png"),
                    ),
                    SizedBox(height: screenHeight * 0.015),

                    // Password Field
                    buildTextFormField(
                      screenWidth: screenWidth,
                      hint: "Password",
                      isObsecure: isObsecure,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Please enter password";
                        }
                        if (value.length < 6) {
                          return "Password must be at least 6 characters";
                        }
                        return null;
                      },
                      controller: passwordController,
                      prefixIcon: Image.asset("assets/Icons/Lock.png"),
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            isObsecure = !isObsecure;
                          });
                        },
                        icon: Image.asset("assets/Icons/eye.png"),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.015),

                    // Sign Up Button
                    ElevatedButton(
                      onPressed: () async {
                        if (formKey.currentState!.validate()) {
                          try {
                            await _authService.signUpWithEmail(
                              emailController.text,
                              passwordController.text,
                              nameController.text,
                              context,
                            );
                            Get.offAll(() => const BottomNavBarScreen());
                          } on FirebaseAuthException catch (e) {
                            if (e.code == 'email-already-in-use') {
                              _showErrorDialog(context, "This email is already in use. Please log in.");
                            }
                          }
                        }
                      },
                      child: const Text(
                        "SIGN UP",
                        style: TextStyle(fontFamily: 'Inter'),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.02),

                    Text("or register using"),
                    SizedBox(height: screenHeight * 0.01),

                    GestureDetector(
                      onTap: () async {
                        bool success = await _authService.signInWithGoogle();
                        if (success) {
                          Get.offAll(() => const BottomNavBarScreen());
                        } else {
                          _showErrorDialog(context, "Google Sign-In failed. Please try again.");
                        }
                      },
                      child: Image.asset(
                        "assets/Icons/googl_icon.png",
                        height: screenHeight * 0.045,
                        width: screenWidth * 0.085,
                        fit: BoxFit.fill,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.01),

                    GestureDetector(
                      onTap: () {
                        Get.to(() => login_page.Login());
                      },
                      child: Text("Already have an account?  Sign In"),
                    ),

                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
