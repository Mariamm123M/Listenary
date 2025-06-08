import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:listenary/services/auth_service.dart';
import 'package:listenary/view/components/custom_textformfield.dart';

import '../components/bottom_navigation_bar.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  bool isObsecure = true;

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
                    Icon(
                      Icons.arrow_back_rounded,
                      size: screenWidth * 0.05,
                    ),
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
                      "Welcome Back",
                      style: TextStyle(
                        color: const Color(0XFF212E54),
                        fontSize: screenWidth * 0.055,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Inter',
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.01),
                    Text(
                      "Sign In to continue",
                      style: TextStyle(
                        color: const Color(0XFF787878),
                        fontSize: screenWidth * 0.04,
                        fontWeight: FontWeight.w400,
                        fontFamily: 'Inter',
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.035),

                    // Email Field
                    buildTextFormField(
                      screenWidth: screenWidth,
                      hint: "Email",
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Please enter your email";
                        } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                            .hasMatch(value)) {
                          return "Enter a valid email";
                        }
                        return null;
                      },
                      controller: emailController,
                      prefixIcon: Image.asset(
                        "assets/Icons/email.png",
                        height: screenHeight * 0.003,
                        width: screenWidth * 0.003,
                      ),
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
                      prefixIcon: Image.asset(
                        "assets/Icons/lock.png",
                        height: screenHeight * 0.003,
                        width: screenWidth * 0.003,
                      ),
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            isObsecure = !isObsecure;
                          });
                        },
                        icon: SvgPicture.asset("assets/Icons/eye.svg"),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.03),

                    // Sign In Button
                    ElevatedButton(
                      onPressed: () async {
                        if (formKey.currentState!.validate()) {
                          await _authService.signInWithEmail(
                            emailController.text,
                            passwordController.text,
                            context,
                          );
                          Get.offAll(() => const BottomNavBarScreen());
                        }
                      },
                      child: const Text(
                        "SIGN IN",
                        style: TextStyle(fontFamily: 'Inter'),
                      ),
                    ),

                    SizedBox(height: screenHeight * 0.02),

                    Text(
                      "or Sign In using",
                      style: TextStyle(
                        color: const Color(0XFF787878),
                        fontSize: screenWidth * 0.04,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Inter',
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.015),

                    // Google Sign-In
                    GestureDetector(
                      onTap: () async {
                        bool success = await _authService.signInWithGoogle();
                        if (success) {
                          Get.offAll(() =>
                              const BottomNavBarScreen()); // Navigate after Google sign-in
                        }
                      },
                      child: SvgPicture.asset(
                        "assets/Icons/googl_icon.svg",
                        height: screenHeight * 0.045,
                        width: screenWidth * 0.085,
                        fit: BoxFit.fill,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.01),

                    // Sign Up Option
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don’t have an account?",
                          style: TextStyle(
                            fontSize: screenWidth * 0.032,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Inter',
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Get.toNamed("signup");
                          },
                          child: Text(
                            "Sign Up",
                            style: TextStyle(
                              fontSize: screenWidth * 0.033,
                              fontWeight: FontWeight.w500,
                              color: const Color(0XFF212E54),
                              fontFamily: 'Inter',
                            ),
                          ),
                        ),
                      ],
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
