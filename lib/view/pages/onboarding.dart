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
      "text":
          "Reading is a conversation. All books talk, but a good book listens as well.",
      "image": "assets/Images/onboarding1.png",
    },
    {
      "text":
          "Read the best books first, or you may not have a chance to read them at all.",
      "image": "assets/Images/onboarding2.png",
    },
  ];

  final List<Map<String, List<String>>> onboardingInstructions = [
    {
      "onboardingInstructions_1": [
        "Browse categories to\n find your next read",
        "Play & Customize\nPress play and adjust playback settings",
        "Save & Manage\nBookmark points and add notes",
        "Access Settings\nExplore accessibility and account options"
      ]
    },
    {
      "onboardingInstructions_2": [
        "Stay Connected",
        "Capture a Clear Photo",
        "Enable Permissions",
        "Check Lighting"
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

    // Add listener to update page index manually
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
    _pageController
        .dispose(); // Dispose of the controller when no longer needed
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
              controller:
                  _pageController, // Pass the same controller to the indicator
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
            buildNavigationButtons(screenWidth, screenHeight )
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
                "Back",
                style: TextStyle(
                  color: const Color(0XFF212E54),
                  fontSize: screenWidth * 0.05,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Inter'
                ),
              ),
              const Spacer(),
              if (screenIndex > 1)
                InkWell(
                  child: SvgPicture.asset("assets/Icons/volume.svg",color: Color(0xff212E54)),
                  onTap: () {},
                ),
            ],
          )
        : SizedBox(height: screenWidth * 0.15);
  }

  Widget buildNavigationButtons(screenWidth, screenHeight ) {
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
                child: const Text("Skip", style: TextStyle(fontFamily: 'Inter'),),
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
                    Text("Next", style: TextStyle(fontFamily: 'Inter'),),
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
                child: const Text("Start", style: TextStyle(fontFamily: 'Inter'),),
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
      mainAxisAlignment:
          MainAxisAlignment.center, // Centering the content vertically
      children: [
        Image.asset(
          textAndImage["image"]!,
          height:screenWidth * 0.7,
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
  late List<double> _opacities; // List to hold opacity values
  late List<int> _delays; // List to define delay for each instruction

  @override
  void initState() {
    super.initState();
    _opacities = List.generate(widget.instructions.length,
        (_) => 0.0); // Initially, all opacities are 0
    _delays = List.generate(widget.instructions.length,
        (index) => index * 500); // Delay for each item (500ms)
    _startAnimation();
  }

  // Function to animate opacity for each instruction
  void _startAnimation() async {
    for (int i = 0; i < widget.instructions.length; i++) {
      await Future.delayed(Duration(
          milliseconds: _delays[i])); // Delay before showing the next item
      if (mounted) {
        setState(() {
          _opacities[i] = 1.0; // Fade in the instruction
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
              padding:
                  EdgeInsets.symmetric(horizontal: screenWidth * 0.01, vertical: screenHeight * 0.01),
              child: Row(
                mainAxisAlignment: i % 2 == 0
                    ? MainAxisAlignment.start
                    : MainAxisAlignment.end,
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
                        fontSize: screenWidth * 0.025,
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
        Image.asset("assets/Icons/onboarding_center.png"),
        for (int i = widget.instructions.length ~/ 2;
            i < widget.instructions.length;
            i++)
          AnimatedOpacity(
            opacity: _opacities[i],
            duration: const Duration(seconds: 1),
            curve: Curves.easeInOut,
            child: Padding(
              padding:
                   EdgeInsets.symmetric(horizontal: screenWidth * 0.01, vertical: screenHeight * 0.01),
              child: Row(
                mainAxisAlignment: i % 2 == 0
                    ? MainAxisAlignment.start
                    : MainAxisAlignment.end,
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
                        fontSize: screenWidth * 0.025,
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
