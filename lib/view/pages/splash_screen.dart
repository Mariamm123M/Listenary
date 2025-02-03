import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:listenary/view/pages/onboarding.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // Navigate to Onboarding screen after 5 seconds
    Future.delayed(const Duration(seconds: 5), () {
      Get.off(Onboarding());
    });
  }

  @override
  Widget build(BuildContext context) {
    // Get the screen's height and width for responsive scaling
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xff212E54),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TweenAnimationBuilder(
              tween: Tween<double>(begin: 0, end: 1),
              duration: const Duration(seconds: 2),
              builder: (context, double value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.scale(
                    scale: value, // Image scaling animation
                    child: CircleAvatar(
                      radius: screenWidth * 0.25, // Responsive radius (25% of screen width)
                      backgroundImage: const AssetImage("assets/Icons/logo.png"),
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: screenHeight * 0.03), // Responsive spacing
            TweenAnimationBuilder(
              tween: Tween<double>(begin: 0, end: 1),
              duration: const Duration(seconds: 2),
              builder: (context, double value, child) {
                return Opacity(
                  opacity: value,
                  child: Text(
                    "Listenary",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: screenWidth * 0.07, // Responsive font size (7% of screen width)
                      fontWeight: FontWeight.w800,
                      fontFamily: 'Inter',
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
