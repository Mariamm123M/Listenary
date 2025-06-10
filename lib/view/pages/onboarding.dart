import 'dart:core';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class Onboarding extends StatefulWidget {
  const Onboarding({super.key});

  @override
  State<Onboarding> createState() => _OnboardingState();
}

class _OnboardingState extends State<Onboarding> {
  int screenIndex = 0;
  final PageController _pageController = PageController();

  final List<Map<String, String>> textAndImage = [
    {
      "text": "quote_1".tr,
      "image": "assets/Images/onboarding1.svg",
    },
    {
      "text": "quote_2".tr,
      "image": "assets/Images/onboarding2.svg",
    },
  ];

  final List<Map<String, List<String>>> onboardingInstructions = [
    {
      "onboardingInstructions_1": [
        "browse_categories".tr,
        "play_customize".tr,
        "save_manage".tr,
        "access_settings".tr
      ]
    },
    {
      "onboardingInstructions_2": [
        "stay_connected".tr,
        "capture_clear_photo".tr,
        "enable_permissions".tr,
        "check_lighting".tr ,
      ]
    }
  ];

  List<Widget> onboardingScreens = [];

  @override
  void initState() {
    super.initState();
    onboardingScreens = [
      ImageAndText(textAndImage: textAndImage[0]),
      ImageAndText(textAndImage: textAndImage[1]),
      Instructions(instructions: onboardingInstructions[0]["onboardingInstructions_1"]!),
      Instructions(instructions: onboardingInstructions[1]["onboardingInstructions_2"]!),
    ];

    _pageController.addListener(() {
      int newIndex = _pageController.page?.toInt() ?? 0;
      if (newIndex != screenIndex) {
        setState(() {
          screenIndex = newIndex;
        });
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.08, vertical: screenHeight * 0.09),
        child: Column(
          children: [
            buildHeader(screenWidth),
            Expanded(
              child: PageView.builder(
                itemCount: onboardingScreens.length,
                controller: _pageController,
                itemBuilder: (context, i) {
                  return onboardingScreens[i];
                },
              ),
            ),
            SmoothPageIndicator(
              controller: _pageController,
              count: onboardingScreens.length,
              effect: const ExpandingDotsEffect(
                dotWidth: 10.0,
                dotHeight: 10.0,
                expansionFactor: 2.0,
                activeDotColor: Color(0XFF212E54),
                dotColor: Color(0xff9A9D9E),
              ),
            ),
            SizedBox(height: screenHeight * 0.06),
            buildNavigationButtons(screenWidth, screenHeight)
          ],
        ),
      ),
    );
  }

  Widget buildHeader(double screenWidth) {
    return screenIndex != 0
        ? Row(
      children: [
        IconButton(
          onPressed: () {
            setState(() {
              screenIndex--;
              _pageController.previousPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            });
          },
          icon: const Icon(
            Icons.arrow_back_outlined,
            color: Color(0xff212E54),
          ),
        ),
        Text(
          'back'.tr,
          style: TextStyle(
              color: const Color(0XFF212E54),
              fontSize: screenWidth * 0.05,
              fontWeight: FontWeight.w600,
              fontFamily: 'Inter'
          ),
        ),
        const Spacer(),
      ],
    )
        : SizedBox(height: screenWidth * 0.15);
  }

  Widget buildNavigationButtons(screenWidth, screenHeight) {
    return screenIndex < 3
        ? Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        ElevatedButton(
          onPressed: () {
            Get.offAllNamed("login");
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xff9A9D9E),
          ),
          child: Text("skip".tr, style: TextStyle(fontFamily: 'Inter')),
        ),
        ElevatedButton(
          style: ButtonStyle(
            padding: WidgetStatePropertyAll(
                EdgeInsets.symmetric(horizontal: screenWidth * 0.035, vertical: screenHeight * 0.015)),
          ),
          onPressed: () {
            setState(() {
              screenIndex++;
              _pageController.nextPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            });
          },
          child: Row(
            children: [
              Text('next'.tr, style: TextStyle(fontFamily: 'Inter')),
              SizedBox(width: screenWidth * 0.01),
              Icon(
                Icons.arrow_forward,
                color: Colors.white,
              ),
            ],
          ),
        ),
      ],
    )
        : Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        ElevatedButton(
          onPressed: () {
            Get.offAllNamed("/signup");
          },
          child: Text('start'.tr, style: TextStyle(fontFamily: 'Inter')),
        ),
      ],
    );
  }
}

class ImageAndText extends StatelessWidget {
  final Map<String, String> textAndImage;

  const ImageAndText({super.key, required this.textAndImage});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SvgPicture.asset(
          textAndImage["image"]!,
          height: screenWidth * 0.7,
          fit: BoxFit.contain,
        ),
        SizedBox(height: screenHeight * 0.05),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
          child: Text(
            textAndImage["text"]!,
            style: TextStyle(
                color: Color(0xff212E54),
                fontSize: screenWidth * 0.04,
                fontWeight: FontWeight.w600,
                fontFamily: 'Inter'
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}

class Instructions extends StatefulWidget {
  final List<String> instructions;

  const Instructions({super.key, required this.instructions});

  @override
  _InstructionsState createState() => _InstructionsState();
}

class _InstructionsState extends State<Instructions> {
  late List<double> _opacities;
  late List<int> _delays;

  @override
  void initState() {
    super.initState();
    _opacities = List.generate(widget.instructions.length, (_) => 0.0);
    _delays = List.generate(widget.instructions.length, (index) => index * 500);
    _startAnimation();
  }

  void _startAnimation() async {
    for (int i = 0; i < widget.instructions.length; i++) {
      await Future.delayed(Duration(milliseconds: _delays[i]));
      if (mounted) {
        setState(() {
          _opacities[i] = 1.0;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (int i = 0; i < widget.instructions.length ~/ 2; i++)
          AnimatedOpacity(
            opacity: _opacities[i],
            duration: const Duration(seconds: 1),
            curve: Curves.easeInOut,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.01, vertical: screenHeight * 0.01),
              child: Row(
                mainAxisAlignment: i % 2 == 0 ? MainAxisAlignment.start : MainAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xffE1E2E1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      widget.instructions[i],
                      style: TextStyle(
                          fontSize: screenWidth * 0.031,
                          color: Color(0xff212E54),
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Inter'
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ),
                ],
              ),
            ),
          ),
        for (int i = widget.instructions.length ~/ 2; i < widget.instructions.length; i++)
          AnimatedOpacity(
            opacity: _opacities[i],
            duration: const Duration(seconds: 1),
            curve: Curves.easeInOut,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.01, vertical: screenHeight * 0.01),
              child: Row(
                mainAxisAlignment: i % 2 == 0 ? MainAxisAlignment.start : MainAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xffE1E2E1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      widget.instructions[i],
                      style: TextStyle(
                          fontSize: screenWidth * 0.031,
                          color: Color(0xff212E54),
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Inter'
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}