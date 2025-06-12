import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:listenary/services/permissions/camera_permission.dart';
import 'package:listenary/services/permissions/storage_permisson.dart';
import 'package:listenary/view/components/awesome_dialog.dart';
import 'package:listenary/view/components/profile_image.dart';
import 'package:listenary/view/pages/login.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import '../../services/auth_service.dart';

class Profile extends StatefulWidget {
  final VoidCallback? onClose;
  const Profile({super.key, this.onClose});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  String name = "User".tr;
  String? _imagePath;
  final ImagePicker _picker = ImagePicker();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final String downloadLink =
      "https://drive.google.com/file/d/1-Tq5LabMnNnniPUrDiufRbdSaXYm4NSL/view?usp=sharing"; // Replace with your link

  @override
  void initState() {
    super.initState();
    _getUserName();
    _loadProfileImage();
  }

  void _getUserName() {
    User? user = _auth.currentUser;
    setState(() {
      name = user?.displayName ?? "User".tr;
    });
  }

  Future<void> _loadProfileImage() async {
    String? userId = _auth.currentUser?.uid;
    if (userId == null) return;

    final Directory appDir = await getApplicationDocumentsDirectory();
    final Directory userDir = Directory('${appDir.path}/images/$userId');

    if (!userDir.existsSync()) return;

    List<FileSystemEntity> files = userDir.listSync();
    if (files.isNotEmpty) {
      files.sort((a, b) => b.statSync().modified.compareTo(a.statSync().modified));
      setState(() {
        _imagePath = files.first.path;
      });
    }
  }

  Future<void> _saveProfileImage(File imageFile) async {
    String? userId = _auth.currentUser?.uid;
    if (userId == null) return;

    final Directory appDir = await getApplicationDocumentsDirectory();
    final Directory userDir = Directory('${appDir.path}/images/$userId');

    if (!userDir.existsSync()) {
      userDir.createSync(recursive: true);
    }

    final String newPath = '${userDir.path}/${DateTime.now().millisecondsSinceEpoch}.png';
    final File newImage = await imageFile.copy(newPath);

    setState(() {
      _imagePath = newImage.path;
    });
  }

  Future<void> pickImageFromGallery() async {
    bool hasPermission = await checkStoragePermission();
    if (!hasPermission) {
      Get.snackbar("Error".tr, "Storage permission denied".tr);
      return;
    }

    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      await _processImage(File(image.path));
    }
  }

  Future<void> _takePhotoWithCamera() async {
    bool hasPermission = await checkCameraPermission();
    if (!hasPermission) {
      Get.snackbar("Error".tr, "Camera permission denied".tr);
      return;
    }

    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      await _processImage(File(image.path));
    }
  }

  Future<void> _processImage(File imageFile) async {
    try {
      CroppedFile? cropped = await ImageCropper().cropImage(
        sourcePath: imageFile.path,
        aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
        compressQuality: 100,
        maxHeight: 700,
        maxWidth: 700,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Image profile cropping'.tr,
            backgroundColor: const Color(0xff212E54),
            toolbarColor: const Color(0xff212E54),
            toolbarWidgetColor: Colors.white,
            aspectRatioPresets: [CropAspectRatioPreset.square],
          ),
        ],
      );

      if (cropped != null) {
        await _saveProfileImage(File(cropped.path));
      } else {
        await _saveProfileImage(imageFile);
      }
    } catch (e) {
      Get.snackbar("Error".tr, "Failed to process image: $e".tr);
    }
  }

  Future<void> _deleteProfileImage() async {
    String? userId = _auth.currentUser?.uid;
    if (userId == null) return;

    final Directory appDir = await getApplicationDocumentsDirectory();
    final Directory userDir = Directory('${appDir.path}/images/$userId');

    if (userDir.existsSync()) {
      userDir.deleteSync(recursive: true);
    }

    setState(() {
      _imagePath = null;
    });
  }

  // Fixed logout method - UPDATED VERSION WITHOUT SUCCESS MESSAGE
  Future<void> _performLogout() async {
    try {
      print('=== LOGOUT PROCESS STARTED ===');
      
      // Show loading dialog
      Get.dialog(
        const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xff212E54)),
          ),
        ),
        barrierDismissible: false,
      );

      // Sign out from Firebase
      await FirebaseAuth.instance.signOut();
      print('Firebase Auth signed out');

      // Sign out from Google (if user signed in with Google)
      try {
        await GoogleSignIn().signOut();
        print('Google Sign In signed out');
      } catch (e) {
        print('Google signout error (might be normal if not signed in with Google): $e');
      }

      // Close loading dialog
      if (Get.isDialogOpen == true) {
        Get.back();
      }

      // Navigate to login screen
      Get.offAll(() => const Login());
      print('Navigation to Login completed');

    } catch (e) {
      print('LOGOUT ERROR: $e');
      
      // Close loading dialog if open
      if (Get.isDialogOpen == true) {
        Get.back();
      }
      
      Get.snackbar(
        "Error",
        "Failed to log out: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final screenWidth = mediaQuery.size.width;

    return Drawer(
      child: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.025, vertical: screenHeight * 0.07),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ProfileImage(
              radius: 0.3, //0.18 difference
              screenWidth: screenWidth,
              imageFile: _imagePath, // Load saved image
              color: const Color(0xff949494),
              onTap: () {},
              child: Stack(
                children: [
                  Positioned(
                    child: FloatingActionButton(
                      backgroundColor: Colors.white,
                      mini: true,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25)),
                      onPressed: () async {
                        await showModalBottomSheet(
                          context: context,
                          builder: (context) => bottomSheet(
                              screenHeight: screenHeight,
                              screenWidth: screenWidth),
                        );
                      },
                      child: const Icon(
                        Icons.add,
                        color: Color(0xff212E54),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 2),
            Text(
              name.capitalize!,
              style: TextStyle(
                  color: const Color(0xff212E54),
                  fontSize: screenWidth * 0.045,
                  fontWeight: FontWeight.w800),
            ),
            SizedBox(height: 5),
            const Divider(color: Color(0xff3C3C3C), thickness: 1),
            SizedBox(height: screenHeight * 0.015),
            line(
              screenHeight: screenHeight,
              screenWidth: screenWidth,
              icon: Icons.settings,
              text: "Settings".tr,
              onTap: () {
                Get.toNamed("settings");
              },
            ),
            SizedBox(height: 5),
            line(
              screenHeight: screenHeight,
              screenWidth: screenWidth,
              icon: Icons.help,
              text: "Help Center".tr,
              onTap: () {
                Get.toNamed("help");
              },
            ),
            SizedBox(height: 3),
            line(
              screenHeight: screenHeight,
              screenWidth: screenWidth,
              icon: Icons.share_outlined,
              text: "Share app".tr,
              onTap: () {
                Share.share('Download my app here: $downloadLink'.tr);
              },
            ),
            SizedBox(height: 3),
            line(
              screenHeight: screenHeight,
              screenWidth: screenWidth,
              icon: Icons.logout_sharp,
              text: "Log out".tr,
              onTap: () {
                // Show confirmation dialog
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text(
                        "Logging Out".tr,
                        style: const TextStyle(
                          color: Color(0xff212E54),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      content: Text(
                        "Are you sure you want to Log Out from Listenary?".tr,
                        style: const TextStyle(color: Color(0xff212E54)),
                      ),
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Get.back(); // Close dialog
                          },
                          child: Text(
                            "Cancel".tr,
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            Get.back(); // Close dialog first
                            await _performLogout(); // Then perform logout
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xff212E54),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            "Log Out".tr,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget line({
    required screenHeight,
    required screenWidth,
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      title: Text(
        text,
        style: TextStyle(
            color: const Color(0xff212E54),
            fontSize: screenWidth * 0.045,
            fontWeight: FontWeight.w600),
      ),
      leading: Icon(icon, color: const Color(0xff212E54), size: 35),
    );
  }

  Widget bottomSheet({required double screenHeight, required screenWidth}) {
    return Container(
      height: screenHeight * 0.28,
      width: double.infinity,
      padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.025, vertical: screenHeight * 0.01),
      decoration: const BoxDecoration(
          color: Color(0xff212E54),
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(15), topRight: Radius.circular(15))),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Choose option to change profile photo".tr,
            style: TextStyle(
                color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 1),
          Row(
            children: [
              Expanded(
                child: ListTile(
                  title: Text("Camera".tr,
                      style: TextStyle(color: Colors.white, fontSize: 14)),
                  leading: const Icon(Icons.camera, color: Colors.white, size: 30),
                  onTap: () async {
                    await _takePhotoWithCamera();
                    Get.back();
                  },
                ),
              ),
              Expanded(
                child: ListTile(
                  title: Text("Gallery".tr,
                      style: TextStyle(color: Colors.white, fontSize: 14)),
                  leading: SvgPicture.asset("assets/Icons/gallery.svg",
                      color: Colors.white, height: 30, width: 30),
                  onTap: () async {
                    await pickImageFromGallery();
                    Get.back();
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListTile(
              title: Text("Delete Profile Image".tr,
                  style: TextStyle(color: Colors.white, fontSize: 14)),
              leading: Icon(Icons.delete, color: Colors.white, size: 30),
              onTap: () async {
                await _deleteProfileImage();
                Get.back();
              },
            ),
          ),
        ],
      ),
    );
  }
}