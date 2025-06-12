// Settings.dart:

import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:listenary/view/components/profile_image.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:listenary/view/components/animation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserSettings {
  final String language; // "English" or "Arabic"
  final bool notificationsEnabled;

  UserSettings({
    required this.language,
    required this.notificationsEnabled,
  });

  Map<String, dynamic> toMap() {
    return {
      'language': language,
      'notificationsEnabled': notificationsEnabled,
    };
  }

  factory UserSettings.fromMap(Map<String, dynamic> map) {
    return UserSettings(
      language: map['language'] ?? 'English',
      notificationsEnabled: map['notificationsEnabled'] ?? true,
    );
  }
}

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> saveUserSettings(UserSettings settings) async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).set(
              settings.toMap(),
              SetOptions(merge: true),
            );
      } else {
        print('User is null');
      }
    } catch (e) {
      print('Error saving user settings: $e');
    }
  }

  Future<UserSettings?> getUserSettings() async {
    User? user = _auth.currentUser;
    if (user == null) return null;
    DocumentSnapshot doc =
        await _firestore.collection('users').doc(user.uid).get();
    if (doc.exists) {
      return UserSettings.fromMap(doc.data() as Map<String, dynamic>);
    }
    return null;
  }

  Stream<UserSettings> userSettingsStream() {
    User? user = _auth.currentUser;
    if (user == null) {
      return Stream.value(
          UserSettings(language: 'English', notificationsEnabled: true));
    }

    return _firestore
        .collection('users')
        .doc(user.uid)
        .snapshots()
        .map((snapshot) {
      if (snapshot.exists) {
        return UserSettings.fromMap(snapshot.data() as Map<String, dynamic>);
      }
      return UserSettings(language: 'English', notificationsEnabled: true);
    });
  }

  Future<void> updateUserSettings(UserSettings settings) async {
    User? user = _auth.currentUser;
    if (user == null) return;

    await _firestore.collection('users').doc(user.uid).update(settings.toMap());
  }
}

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirestoreService _firestoreService = FirestoreService();
  User? _user;
  String name = "User";
  String? profileImage;
  String? _imagePath;
  bool notificationsEnabled = true;
  int selectedSpeaker = 0; // Default to 0

  void _loadUserSettings() async {
    UserSettings? settings = await _firestoreService.getUserSettings();
    if (settings != null) {
      setState(() {
        selectedLanguage = settings.language;
        notificationsEnabled = settings.notificationsEnabled;
      });
    }
  }

  Future<void> saveUserSettings() async {
    final userSettings = UserSettings(
      language: selectedLanguage,
      notificationsEnabled: notificationsEnabled,
    );
    await _firestoreService.saveUserSettings(userSettings);
  }

  Future<void> _loadProfileImage() async {
    String? userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    final Directory appDir = await getApplicationDocumentsDirectory();
    final Directory userDir = Directory('${appDir.path}/images/$userId');

    if (!userDir.existsSync()) return;

    List<FileSystemEntity> files = userDir.listSync();
    if (files.isNotEmpty) {
      files.sort(
          (a, b) => b.statSync().modified.compareTo(a.statSync().modified));
      setState(() {
        _imagePath = files.first.path;
      });
    }
  }

  List<Map<String, String>> speakers = [
    {"profile": "assets/Images/male.jpg", "name": "mark", "gender": "male"},
    {
      "profile": "assets/Images/female.jpeg",
      "name": "leila",
      "gender": "female"
    }
  ];
  String selectedLanguage = "English";

  @override
  void initState() {
    super.initState();
    loadSelectedLanguage();
    _user = _auth.currentUser;
    if (_user != null) {
      _loadUserSettings();
    }
    _getUserData();
    _loadProfileImage();
  }

  void loadSelectedLanguage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? lang = prefs.getString('language') ?? 'en';
    setState(() {
      selectedLanguage = lang == 'en' ? 'English' : 'Arabic';
    });
  }

  void _getUserData() {
    User? user = FirebaseAuth.instance.currentUser;
    setState(() {
      name = user?.displayName ?? "User";
      profileImage = user?.photoURL;
    });
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final screenWidth = mediaQuery.size.width;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff212E54),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
            size: 25,
          ),
          onPressed: () {
            Get.back();
          },
        ),
      ),
      body: Stack(
        children: [
          Container(
            height: double.infinity,
            width: double.infinity,
            decoration: BoxDecoration(color: Colors.white),
          ),
          Container(
            height: 345,
            decoration: BoxDecoration(
                color: const Color(0xff212E54),
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(15),
                    bottomRight: Radius.circular(15))),
            child: Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.03,
                  vertical: screenHeight * 0.002),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.settings,
                      color: Colors.white, size: screenWidth * 0.1),
                  SizedBox(width: screenWidth * 0.03),
                  Text(
                    "settings".tr,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: screenWidth * 0.055,
                        fontWeight: FontWeight.w800),
                  )
                ],
              ),
            ),
          ),
          Positioned(
            top: 75,
            right: 25,
            left: 25,
            bottom: 75,
            child: Container(
              height: 600,
              width: 340,
              decoration: BoxDecoration(
                  color: Color(0xffF2EFEF),
                  borderRadius: BorderRadius.all(
                    Radius.circular(15),
                  )),
              child: Padding(
                padding: const EdgeInsets.only(left: 20, top: 24),
                child: ListView(
                  children: [
                    Row(
                      children: [
                        ProfileImage(
                            radius: 0.1,
                            number: 0.14,
                            screenWidth: screenWidth,
                            imageFile:
                                _imagePath, // Use the latest locally stored image
                            color: Color(0xff3C3C3C),
                            onTap: () {
                              //view user profile
                            }),
                        SizedBox(width: screenWidth * 0.035),
                        Text(name.capitalize!,
                            style: TextStyle(
                                color: Color(0xff3C3C3C),
                                fontSize: screenWidth * 0.06,
                                fontWeight: FontWeight.w800,
                                fontFamily: 'Inter'))
                      ],
                    ),
                    SizedBox(
                      height: screenHeight * 0.01,
                    ),
                    Divider(),
                    feature(
                      fontSize: 0.045,
                      screenWidth: screenWidth,
                      context,
                      image: "assets/Icons/Accessibilty.svg",
                      text: "accessibility_features".tr,
                      children: [
                        feature(context,
                            fontSize: 0.037,
                            screenWidth: screenWidth,
                            text: "custom_voice_profiles".tr,
                            children: [
                              Speakers(
                                speakers: speakers,
                                ttsText: 'hello_name_excited'.tr,
                              )
                            ]),
                        feature(context,
                            fontSize: 0.037,
                            screenWidth: screenWidth,
                            text: "language".tr,
                            icon: Icons.translate,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  buildCustomRadioButton(
                                      screenHeight: screenHeight,
                                      screenWidth: screenWidth,
                                      selectedCategory: selectedLanguage,
                                      category: "English",
                                      displayText: "english".tr,
                                      onSelect: (category) async {
                                        //change to Engish theme
                                        setState(() {
                                          selectedLanguage = category;
                                        });
                                        Get.updateLocale(const Locale('en'));

                                        SharedPreferences prefs =
                                            await SharedPreferences
                                                .getInstance();
                                        prefs.setString('language', 'en');

                                        saveUserSettings();
                                      }),
                                  buildCustomRadioButton(
                                      screenHeight: screenHeight,
                                      screenWidth: screenWidth,
                                      category: "Arabic",
                                      displayText: "arabic".tr,
                                      selectedCategory: selectedLanguage,
                                      onSelect: (category) async {
                                        //change to Arabic theme
                                        setState(() {
                                          selectedLanguage = category;
                                        });
                                        Get.updateLocale(const Locale('ar'));

                                        SharedPreferences prefs =
                                            await SharedPreferences
                                                .getInstance();
                                        prefs.setString('language', 'ar');
                                        print(
                                            'Language saved as: ${prefs.getString('language')}');

                                        saveUserSettings();
                                      })
                                ],
                              )
                            ])
                      ],
                    ),
                    feature(context,
                        fontSize: 0.045,
                        screenWidth: screenWidth,
                        text: "notifications".tr,
                        image: "assets/Icons/Notification.svg",
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              buildCustomRadioButton(
                                  screenHeight: screenHeight,
                                  screenWidth: screenWidth,
                                  selectedCategory:
                                      notificationsEnabled ? "On" : "Off",
                                  category: "On",
                                  displayText: "on".tr,
                                  onSelect: (category) {
                                    //save the value of the notification to on
                                    setState(() {
                                      notificationsEnabled = category == "On";
                                    });
                                    saveUserSettings();
                                  }),
                              buildCustomRadioButton(
                                  screenHeight: screenHeight,
                                  screenWidth: screenWidth,
                                  category: "Off",
                                  displayText: "off".tr,
                                  selectedCategory:
                                      notificationsEnabled ? "On" : "Off",
                                  onSelect: (category) {
                                    //save the value of the notification to on
                                    setState(() {
                                      notificationsEnabled = category == "On";
                                    });
                                    saveUserSettings();
                                  })
                            ],
                          )
                        ])
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Theme feature(BuildContext context,
      {required double screenWidth,
      String? image = "",
      IconData? icon,
      required String text,
      required List<Widget> children,
      required double fontSize}) {
    return Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent, // Removes the divider between items
          splashColor: Colors.transparent, // Removes splash effect
          highlightColor: Colors.transparent, // Removes highlight effect
        ),
        child: ExpansionTile(
          leading: icon == null
              ? image!.isNotEmpty
                  ? SvgPicture.asset(image)
                  : null
              : Icon(
                  icon,
                  color: Color(0xff3C3C3C),
                ),
          showTrailingIcon: false,
          title: Text(
            text,
            style: TextStyle(
                color: Color(0xff3C3C3C),
                fontSize: screenWidth * fontSize,
                fontWeight: FontWeight.w500),
          ),
          childrenPadding: EdgeInsets.only(left: screenWidth * 0.08),
          children: children,
        ));
  }

  Widget buildCustomRadioButton({
    required screenHeight,
    required screenWidth,
    required String category,
    required String selectedCategory,
    required Function(String) onSelect,
    required String displayText,
  }) {
    return GestureDetector(
      onTap: () {
        onSelect(category);
      },
      child: Row(
        children: [
          selectedCategory == category
              ? SvgPicture.asset("assets/Icons/checked.svg",
                  color: Color(0xff212E54),
                  height: screenHeight * 0.025,
                  width: screenWidth * 0.015)
              : Container(
                  width: screenHeight * 0.06,
                  height: screenWidth * 0.05,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Color(0xff212E54),
                      width: 2,
                    ),
                  )),
          SizedBox(width: screenWidth * 0.025),
          Text(
            displayText,
            style: TextStyle(
              fontSize: screenWidth * 0.025,
              color: selectedCategory == category
                  ? Color(0xff212E54)
                  : Colors.black,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class Speakers extends StatefulWidget {
  final List<Map<String, String>> speakers;
  final String ttsText;
  const Speakers({super.key, required this.speakers, required this.ttsText});

  @override
  State<Speakers> createState() => _SpeakersState();
}

class _SpeakersState extends State<Speakers> {
  int selectedSpeaker = 0;
  int? playedVoice;
  bool isPlaying = false;
  final AudioPlayer player = AudioPlayer();
  bool isLoading = false;
  final Map<int, String> _voiceFilePaths = {};
  List<Color> colors = [
    Color(0xff5356FF),
    Color(0xff3572EF),
    Color(0xff3ABEF9),
    Color(0xffA7E6FF)
  ];
  List<int> duration = [900, 700, 600, 800, 500];
  String? _lastTtsText; // Track last used text to detect changes

  @override
  void initState() {
    super.initState();
    player.onPlayerStateChanged.listen((PlayerState state) {
      if (state == PlayerState.completed) {
        setState(() {
          isPlaying = false;
          playedVoice = null;
        });
      }
    });
    _lastTtsText = widget.ttsText;
    // No need to pre-generate files since we generate on play
  }

  void didUpdateWidget(Speakers oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.ttsText != widget.ttsText) {
      setState(() {
        _voiceFilePaths.clear(); // Clear cache when text changes
        _lastTtsText = widget.ttsText;
      });
    }
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  Future<String?> _getVoiceFilePath(int index) async {
    final dir = await getTemporaryDirectory();
    final filePath = '${dir.path}/speaker_$index.mp3';
    return filePath;
  }

  Future<void> _fetchAndSaveVoice(int index) async {
    setState(() {
      isLoading = true;
    });

    try {
      final speaker = widget.speakers[index];
      final gender = speaker["gender"]?.toLowerCase() ?? "male";
      final name = speaker["name"] ?? "Speaker";

      final response = await http.post(
        Uri.parse('http://192.168.1.4:5002/tts'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'text': widget.ttsText,
          'gender': gender,
          'speaker_name': name,
        }),
      );

      if (response.statusCode == 200) {
        final dir = await getTemporaryDirectory();
        final filePath = '${dir.path}/speaker_$index.mp3';
        final file = File(filePath);
        if (await file.exists()) {
          await file.delete(); // Delete old file to ensure fresh audio
        }
        await file.writeAsBytes(response.bodyBytes);
        setState(() {
          _voiceFilePaths[index] = filePath;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Failed to fetch voice for ${speaker["name"]}: ${response.statusCode}'),
          ),
        );
        print('Failed to fetch TTS audio: ${response.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error generating voice: $e')),
      );
      print('Error in TTS playback: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _playVoice(int index) async {
    await player.stop();

    // Always fetch new audio, ignoring existing files
    await _fetchAndSaveVoice(index);

    if (_voiceFilePaths[index] != null) {
      try {
        await player.play(DeviceFileSource(_voiceFilePaths[index]!));
        setState(() {
          playedVoice = index;
          isPlaying = true;
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error playing voice: $e')),
        );
        print('Error playing audio: $e');
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No voice file available for this speaker')),
      );
    }
  }

  Future<void> saveSelectedSpeaker(int index) async {
    try {
      String userId = FirebaseAuth.instance.currentUser!.uid;
      String selectedVoice = widget.speakers[index]["name"] ?? "Voice1";

      await FirebaseFirestore.instance.collection("users").doc(userId).update({
        "selectedSpeaker": selectedVoice,
      });
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving speaker: $error')),
      );
      print("Error saving speaker: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final screenWidth = mediaQuery.size.width;

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: screenHeight * 0.16,
        maxWidth: screenWidth * 0.55,
      ),
      child: ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        itemCount: widget.speakers.length,
        separatorBuilder: (BuildContext context, int index) {
          return SizedBox(height: screenHeight * 0.01);
        },
        itemBuilder: (BuildContext context, int index) {
          return InkWell(
            onTap: () async {
              setState(() {
                selectedSpeaker = index;
              });
              await saveSelectedSpeaker(index);
            },
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  width: 2,
                  color: selectedSpeaker == index
                      ? const Color(0xff212E54)
                      : const Color(0xff9B9B9B),
                ),
                borderRadius: const BorderRadius.all(Radius.circular(10)),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.025,
                  vertical: screenHeight * 0.0002,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Image.asset(
                          widget.speakers[index]["profile"]!,
                          width: screenWidth * 0.07,
                          height: screenHeight * 0.07,
                        ),
                        SizedBox(width: screenWidth * 0.035),
                        Text(
                          widget.speakers[index]["name"]!.tr,
                          style: TextStyle(
                            color: selectedSpeaker == index
                                ? const Color(0xff212E54)
                                : const Color(0xff3C3C3C),
                            fontSize: screenWidth * 0.03,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    playedVoice == index && isPlaying
                        ? Container(
                            width: 50,
                            height: 25,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: List.generate(
                                  4,
                                  (index) => VisualComponent(
                                      width: 5,
                                      duration: duration[index % 4],
                                      color: colors[index % 4])),
                            ),
                          )
                        : Image.asset("assets/Icons/voice.png"),
                    playedVoice == index && isLoading 
                        ? CircularProgressIndicator()
                        : IconButton(
                            onPressed: () async {
                              if (playedVoice == index && isPlaying) {
                                await player.pause();
                                setState(() {
                                  isPlaying = false;
                                });
                              } else {
                                await _playVoice(index);
                              }
                            },
                            icon: Icon(
                              playedVoice == index && isPlaying
                                  ? Icons.pause
                                  : Icons.play_arrow,
                              size: screenWidth * 0.08,
                              color: const Color(0xff212E54),
                            ),
                          ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
