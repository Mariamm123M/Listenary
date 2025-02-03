import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:listenary/view/components/custom_textformfield.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  var formKey = GlobalKey<FormState>();

  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController username = TextEditingController();

  bool isObsecure = true;

  final RegExp usernameRegex =
      RegExp(r'^[A-Za-z ]+$'); // regex to make username containing only alphabet

  @override
  Widget build(BuildContext context) {
    // Get device width and height
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final screenWidth = mediaQuery.size.width;

   
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(
          vertical: screenHeight * 0.05, // 4% of the screen height
          horizontal: screenWidth * 0.06, // 6% of the screen width
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: screenWidth * 0.03,),
              Center(
                  child: Image.asset(
                "assets/Icons/logo.png",
                width: screenWidth * 0.4, // 40% of the screen width
                height: screenHeight * 0.2, // 20% of the screen height
              )),
              Form(
                key: formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Create an Account",
                      style: TextStyle(
                        color: const Color(0XFF212E54),
                        fontSize:screenWidth * 0.05, // Scaled font size
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Inter',
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.01), // 1% of the screen height
                    Text(
                      "Register to continue",
                      style: TextStyle(
                        color: const Color(0XFF787878),
                        fontSize: screenWidth * 0.04,
                        fontWeight: FontWeight.w400,
                        fontFamily: 'Inter',
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.035), // 6% of the screen height
                    buildTextFormField(
                      screenWidth: screenWidth,
                      hint: "User Name",
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Please enter username";
                        } else if (!usernameRegex.hasMatch(value) ||
                            value.length > 20) {
                          return "Enter valid username";
                        }
                        return null;
                      },
                      controller: username,
                      prefixIcon: Image.asset("assets/Icons/user.png"),
                    ),
                    SizedBox(height: screenHeight * 0.015),
                    buildTextFormField(
                      screenWidth: screenWidth,
                      hint: "Email",
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Please enter email";
                        } else if (!value.contains("@")) {
                          return "Please enter valid email";
                        }
                        return null;
                      },
                      controller: email,
                      prefixIcon: Image.asset("assets/Icons/email.png"),
                    ),
                    SizedBox(height: screenHeight * 0.015),
                    buildTextFormField(
                      screenWidth: screenWidth,
                      hint: "Password",
                      isObsecure: isObsecure,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Please enter password";
                        }
                        if (value.length < 6) {
                          return "Please enter valid password";
                        }
                        return null;
                      },
                      controller: password,
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
                    SizedBox(height: screenHeight * 0.03), // 6% of the screen height
                  ElevatedButton(
                    onPressed: () async {
                      if (formKey.currentState!.validate()) {
                        try {
                          final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
                            email: email.text,
                            password: password.text,
                          );

                          // Navigate to login only if signup is successful
                          Get.toNamed("login");
                          Navigator.of(context).pushReplacementNamed("home");
                        } on FirebaseAuthException catch (e) {
                          if (e.code == 'weak-password') {
                            print('The password provided is too weak.');
                          } else if (e.code == 'email-already-in-use') {
                            print('The account already exists for that email.');
                          }
                        } catch (e) {
                          print(e);
                        }
                      }
                    },
                    child: Text(
                      "SIGN UP",
                      style: TextStyle(fontFamily: 'Inter'),
                    ),
                  ),


                    SizedBox(height: screenHeight * 0.02), // 4% of the screen height
                    Text(
                      "or register using",
                      style: TextStyle(
                        color: const Color(0XFF787878),
                        fontSize: screenWidth * 0.04,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Inter',
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    GestureDetector(
                      onTap: () {
                        // sign in with google
                      },
                      child: Image.asset(
                        "assets/Icons/googl_icon.png",
                        height: screenHeight * 0.045, // 5% of the screen height
                        width: screenWidth * 0.085, // 8% of the screen width
                        fit: BoxFit.fill,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.004),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Already have an account?",
                          style: TextStyle(
                            fontSize: screenWidth * 0.032,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Inter',
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Get.toNamed("login");
                          },
                          child: Text(
                            "Sign In",
                            style: TextStyle(
                              fontSize: screenWidth * 0.033,
                              fontWeight: FontWeight.w500,
                              color: const Color(0XFF212E54),
                              fontFamily: 'Inter',
                            ),
                          ),
                        ),
                      ],
                    )
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
