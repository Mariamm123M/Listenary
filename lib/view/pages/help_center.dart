import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

class HelpCenter extends StatefulWidget {
  const HelpCenter({super.key});

  @override
  _HelpCenterState createState() => _HelpCenterState();
}

class _HelpCenterState extends State<HelpCenter> {
  String name = "manal";

  // List of help categories
  final List<String> categories = [
    "General",
    "Audio\n Issues",
    "OCR",
    "AI\n Assistant"
  ];
  final List<String> icons = [
    "assets/Icons/general.svg",
    "assets/Icons/audio.svg",
    "assets/Icons/ocr2.svg",
    "assets/Icons/ai.svg"
  ];

  int _selectedIndex = 0;
  

  // Sample content for each category
  final Map<String, List<String>> faqContent = {
    "General": [
      "What is Listenary?",
      "How to upload a book?",
      "How to use the app to read or listen?"
    ],
    "Audio\n Issues": [
      "Why is the audio not playing?",
      "How to fix skipping issues?",
      "Audio is not synced, how to adjust?"
    ],
    "OCR": [
      "How does OCR work?",
      "Why isn't OCR recognizing my text?",
      "OCR scanning tips"
    ],
    "AI\n Assistant": [
      "What can the AI Assistant do?",
      "How to activate the assistant?",
      "Can the AI assistant read books for me?"
    ]
  };

  // Corresponding answers for FAQ questions
  final Map<String, List<List<String>>> faqAnswers = {
    "General": [
      ["Listenary lets you upload and listen to books using OCR or file uploads.", "You Can Translate, Summarize and take notes of each book.", "There is Ai Assistant helps you through your journey."],
      ["To upload, go to 'Upload' icon in the bottom", "Select a file, or scan with your camera.","Remember to allow storage permission"],
      ["After uploading, press 'Play' to listen or 'Read' to view on-screen."]
    ],
    "Audio\n Issues": [
      ["Check your volume settings.","Check internet connection.","If nothing works, Try to refresh the app."],
      ["Download books for offline listening to prevent skipping."],
      ["Adjust the audio sync in playback settings."]
    ],
    "OCR": [
      ["OCR is machine learning algorithm that converts text from images into editable text."],
      ["Make sure the image is clear and well-lit for best results."],
      ["Try take images in good lighting.", "Avoid obstructions like fingers, objects or watermarks", "Crop the image to focus on the text", "For better performance try using high resolution images", "For files, multiple languages and special characters distract the OCR so it will give you inaccurate text", "Consider the size and format of the text."]
    ],
    "AI Assistant": [
      ["The AI helps you use the app.", "It can also read books.", "It answers all your questions about the app."],
      ["Activate it by tapping the mic on the screen", "Or you can say 'Hey'."],
      ["Yes, the AI can read books aloud—just say 'Read'."]
    ]
  };

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final screenWidth = mediaQuery.size.width;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: Color(0xff212E54),
          ),
        ),
        centerTitle: true,
        title: Text(
          'Help Center',
          style: TextStyle(
              color: Color(0xff212E54),
              fontSize: screenWidth * 0.05,
              fontWeight: FontWeight.w800, fontFamily: 'Inter'),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: screenWidth * 0.032),
            child: InkWell(
              child: SvgPicture.asset("assets/Icons/volume.svg"),
              onTap: () {},
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Hi $name, We're Here To Help You",
                style: TextStyle(
                    color: Colors.black,
                    fontSize: screenWidth * 0.04,
                    fontWeight: FontWeight.bold, fontFamily: 'Inter'),
              ),
              SizedBox(
                height: screenWidth * 0.02,
              ),
              // Category Tabs
              Container(
                height: screenHeight * 0.15,
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 8),
                child: ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  itemBuilder: (context, i) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedIndex = i;
                        });
                      },
                      child: Container(
                        width: screenWidth * 0.22,
                        margin: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.012, vertical: screenHeight * 0.012),
                        padding: EdgeInsets.symmetric(
                           horizontal: screenWidth * 0.014, vertical: screenHeight * 0.008),
                        decoration: BoxDecoration(
                            color: _selectedIndex == i
                                ? const Color(0xff212E54)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            border:
                                Border.all(color: Color(0xff949494), width: 3)),
                        child: Column(
                          children: [
                            SvgPicture.asset(
                              icons[i],
                              color: _selectedIndex == i
                                  ? Colors.white
                                  : const Color(0xff212E54),
                              height: screenHeight * 0.038,
                            ),
                            SizedBox(height: screenHeight * 0.002),
                            Text(
                              categories[i],
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: _selectedIndex == i
                                      ? Colors.white
                                      : const Color(0xff212E54),
                                  fontSize: screenWidth * 0.022,
                                  fontWeight: FontWeight.w800, fontFamily: 'Inter'),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              // FAQ List
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: faqContent[categories[_selectedIndex]]?.length ?? 0,
                itemBuilder: (context, index) {
                  return Card(
                    margin:
                       EdgeInsets.symmetric(horizontal: screenWidth * 0.025, vertical: screenHeight * 0.01),
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                      side: const BorderSide(color: Color(0xffFEC838), width: 2),
                    ),
                    child: ExpansionTile(
                      collapsedIconColor: Color(0xff9B9B9B),
                      iconColor: Color(0xff9B9B9B),
                      tilePadding: EdgeInsets.symmetric(horizontal:  screenWidth * 0.03, vertical: screenHeight * 0.005),
                      childrenPadding:
                          EdgeInsets.symmetric(horizontal: screenWidth * 0.045, vertical: screenHeight * 0.004),
                      title: Text(
                        faqContent[categories[_selectedIndex]]?[index] ?? '',
                        style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize:screenWidth * 0.035, fontFamily: 'Inter'),
                      ),
                      //answers for each question
                      children: faqAnswers[categories[_selectedIndex]]?[index]
                              .map(
                                (answer) => Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "• ",
                                          style: TextStyle(
                                            fontSize: screenWidth * 0.03,
                                            color: Color(0xff9B9B9B),
                                            fontFamily: 'Inter'
                                          ),
                                        ),
                                        Expanded(
                                          child: Text(
                                            answer,
                                            style: TextStyle(
                                              color: Color(0xff9B9B9B),
                                              fontSize:  screenWidth * 0.03,
                                              fontWeight: FontWeight.w500,
                                              fontFamily: 'Inter'
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                        height: screenHeight * 0.003), // Add space after each answer
                                  ],
                                ),
                              )
                              .toList() ??
                          [],
                    ),
                  );
                },
              ),
              SizedBox(
                height: screenHeight * 0.025
              ),
              Text(
                "Still Have a Question?",
                style: TextStyle(
                    color: Colors.black,
                    fontSize:  screenWidth * 0.045,
                    fontWeight: FontWeight.bold, fontFamily: 'Inter'),
              ),
              Text(
                "You Can Contact Us with:",
                style: TextStyle(
                    color: Color(0xff9B9B9B),
                    fontSize: screenWidth * 0.035,
                    fontWeight: FontWeight.bold, fontFamily: 'Inter'),
              ),
              SizedBox(height: screenHeight * 0.025),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  card(
                    screenHeight: screenHeight,
                    screenWidth: screenWidth,
                      icon: "assets/Icons/send_email.svg",
                      text: "Send email",
                      onTap: () {}),
                  SizedBox(width: screenWidth * 0.04),
                  card(
                    screenHeight: screenHeight,
                    screenWidth: screenWidth,
                      icon: "assets/Icons/phone.svg", text: "Phone", onTap: () {}),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  // Helper function to create card widget
  Widget card({
    required screenWidth,
    required screenHeight,
    required String icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: screenWidth * 0.3,
        padding:  EdgeInsets.symmetric(horizontal: screenWidth * 0.025, vertical: screenHeight * 0.02),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Color(0xffE9E9E9))),
        child: Column(
          children: [
            SvgPicture.asset(
              icon,
              color: Color(0xff212E54),
              height: screenWidth * 0.08,
              width: screenWidth * 0.08,
            ),
            SizedBox(height: screenHeight * 0.018),
            Text(
              text,
              style: TextStyle(
                color: Color(0xff212E54),
                fontSize: screenWidth * 0.025,
                fontWeight: FontWeight.w600,
                fontFamily: 'Inter'
              ),
            )
          ],
        ),
      ),
    );
  }
}

