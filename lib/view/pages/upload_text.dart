import 'package:clipboard/clipboard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';

class UploadText extends StatefulWidget {
  UploadText({super.key});

  @override
  _UploadTextState createState() => _UploadTextState();
}

class _UploadTextState extends State<UploadText> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final textKey = GlobalKey<FormState>();
  final TextEditingController textController = TextEditingController();
  String uploadedText = "";
  String? selectedSpeaker;

  @override
  void initState() {
    super.initState();
    fetchUserText();
    loadSelectedSpeaker();
  }

  Future<void> loadSelectedSpeaker() async {
    try {
      String userId = _auth.currentUser!.uid;
      DocumentSnapshot doc = await _firestore.collection('users').doc(userId).get();

      if (doc.exists) {
        setState(() {
          selectedSpeaker = doc['selectedSpeaker'] ?? "mark"; // Default to "mark" if not set
        });
      }
    } catch (error) {
      print("Error loading selected speaker: $error");
    }
  }

  Future<void> uploadText() async {
    if (_auth.currentUser == null) {
      print('No authenticated user found');
      return;
    }

    final String userId = _auth.currentUser!.uid;
    final String userText = textController.text.trim();

    if (userText.isNotEmpty) {
      try {
        await _firestore.collection('users').doc(userId).set({
          'text': userText,
        }, SetOptions(merge: true)); // ✅ Merge data instead of overwriting
        Get.snackbar("Success", "Text uploaded successfully",
            backgroundColor: Colors.green, colorText: Colors.white);
        fetchUserText(); // Refresh the displayed text
      } catch (e) {
        print("Error uploading text: $e");
        Get.snackbar("Error", "Failed to upload text",
            backgroundColor: Colors.red, colorText: Colors.white);
      }
    } else {
      Get.snackbar("Error", "Text cannot be empty",
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  Future<void> fetchUserText() async {
    if (_auth.currentUser != null) {
      DocumentSnapshot doc = await _firestore.collection('users').doc(_auth.currentUser!.uid).get();
      setState(() {
        uploadedText = doc['text'] ?? "";
      });
    }
  }

  Future<void> playTextToSpeech(String text) async {
    final String ttsServerUrl = 'http://192.168.1.7:5002/tts'; // Replace with your server IP

    try {
      final response = await http.post(
        Uri.parse(ttsServerUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'text': text,
          'gender': selectedSpeaker == "Leila" ? "female" : "male",
        }),
      );

      print("Server Response: ${response.statusCode}");

      if (response.statusCode == 200) {
        // Get the temporary directory to save the audio file
        final directory = await getTemporaryDirectory();
        final filePath = '${directory.path}/speech.mp3';

        // Save the response body (audio file) to the temporary directory
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);

        print("Audio File Saved: $filePath");

        // Play the audio file
        AudioPlayer audioPlayer = AudioPlayer();
        await audioPlayer.play(DeviceFileSource(filePath));
      } else {
        Get.snackbar("Error", "Failed to convert text to speech",
            backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      print("Error: $e");
      Get.snackbar("Error", "Failed to connect to TTS server",
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: Icon(
            Icons.arrow_back_rounded,
            color: Color(0xff212E54),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.025, vertical: screenHeight * 0.02),
          child: Form(
            key: textKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Input or paste text to listen",
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: screenWidth * 0.05,
                      fontWeight: FontWeight.w700),
                  textAlign: TextAlign.left,
                ),
                SizedBox(height: 16),
                TextFormField(
                  validator: (val) => val!.isEmpty ? "Please Enter text" : null,
                  controller: textController,
                  maxLines: 10,
                  decoration: InputDecoration(
                    hintText: "Enter Text",
                    contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(width: 1, color: Color(0xff949494)),
                    ),
                  ),
                ),
                SizedBox(height: 10),

                Row(
                  children: [
                    SizedBox(width: 15),
                    GestureDetector(
                      child: SvgPicture.asset(
                        "assets/Icons/copy.svg",
                        height: screenHeight * 0.05,
                        width: screenWidth * 0.08,
                        color: Color(0XFF212E54),
                      ),
                      onTap: () {
                        copyText(textController, context);
                      },
                    ),
                  ],
                ),

                SizedBox(height: 10),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start, // Align to the left
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              if (textKey.currentState!.validate()) {
                                uploadText();
                              }
                            },
                            child: Text("Upload Text"),
                          ),
                          SizedBox(height: 20),
                          Text(
                            "Uploaded Text:",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 10),
                          Container(
                            constraints: BoxConstraints(
                              maxHeight: screenHeight * 0.3,
                            ),
                            child: SingleChildScrollView(
                              child: Text(
                                uploadedText,
                                style: TextStyle(fontSize: 14),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 10.0, bottom: 60.0),
                      child: GestureDetector(
                        child: Image.asset(
                          "assets/Icons/Headphones.png",
                          height: 45, width: 45, fit: BoxFit.fill,
                        ),
                        onTap: () {
                          if (uploadedText.isNotEmpty) {
                            playTextToSpeech(uploadedText);
                          } else {
                            Get.snackbar("Error", "No text to play",
                                backgroundColor: Colors.red, colorText: Colors.white);
                          }
                        },
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Future<void> copyText(
    TextEditingController text, BuildContext context) async {
  if (text.text.isNotEmpty) {
    await FlutterClipboard.copy(text.text);
    Get.snackbar(
      "",
      "Text copied to clipboard",
      backgroundColor: Color(0xff212E54),
      messageText: Text(
        "Text copied to clipboard",
        style: TextStyle(color: Colors.white, fontSize: 16, fontFamily: 'Inter'),
      ),
    );
  }
}