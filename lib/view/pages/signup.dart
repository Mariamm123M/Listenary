import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController nameController = TextEditingController();

  final AuthService _authService = AuthService();

  bool isObsecure = true;

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("error".tr),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text("ok".tr),
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
              SizedBox(height: screenHeight * 0.04),
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
                      "create_account".tr,
                      style: TextStyle(
                        color: const Color(0XFF212E54),
                        fontSize: screenWidth * 0.055,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Inter',
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.01),
                    Text(
                      "register_to_continue".tr,
                      style: TextStyle(
                        color: const Color(0XFF787878),
                        fontSize: screenWidth * 0.04,
                        fontWeight: FontWeight.w400,
                        fontFamily: 'Inter',
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.035),

                    // Username field
                    buildTextFormField(
                      screenWidth: screenWidth,
                      hint: "username".tr,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "please_enter_name".tr;
                        }
                        return null;
                      },
                      controller: nameController,
                      prefixIcon: Icon(Icons.person, color: Colors.grey),
                    ),
                    SizedBox(height: screenHeight * 0.015),

                    // Email field
                    buildTextFormField(
                      screenWidth: screenWidth,
                      hint: "email".tr,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "please_enter_email".tr;
                        } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                            .hasMatch(value)) {
                          return "enter_valid_email".tr;
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

                    // Password field
                    buildTextFormField(
                      screenWidth: screenWidth,
                      hint: "password".tr,
                      isObsecure: isObsecure,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "please_enter_password".tr;
                        }
                        if (value.length < 6) {
                          return "password_min_length".tr;
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
                    SizedBox(height: screenHeight * 0.015),

                    // Sign Up button
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
                              _showErrorDialog(
                                  context, "email_already_in_use".tr);
                            }
                          }
                        }
                      },
                      child: Text(
                        "sign_up".tr,
                        style: TextStyle(fontFamily: 'Inter'),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.02),

                    Text("or_register_using".tr,  style: TextStyle(
                        color: const Color(0XFF787878),
                        fontSize: screenWidth * 0.04,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Inter',
                      ),),
                    SizedBox(height: screenHeight * 0.01),

                    GestureDetector(
                      onTap: () async {
                        bool success = await _authService.signInWithGoogle();
                        if (success) {
                          Get.offAll(() => const BottomNavBarScreen());
                        } else {
                          _showErrorDialog(context, "google_sign_in_failed".tr);
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'already_have_account'.tr,
                          style: TextStyle(
                            fontSize: screenWidth * 0.032,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Inter',
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Get.to(() => login_page.Login());
                          },
                          child: Text(
                            'sign_in'.tr,
                            style: TextStyle(
                              fontSize: screenWidth * 0.033,
                              fontWeight: FontWeight.w500,
                              color: Colors.blue,
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
