import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:listenary/services/permissions/camera_permission.dart';
import 'package:listenary/services/permissions/storage_permisson.dart';
import 'package:listenary/view/components/awesome_dialog.dart';
import 'package:listenary/view/components/profile_image.dart';
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
  String name = "User";
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
      name = user?.displayName ?? "User";
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
      Get.snackbar("Error", "Storage permission denied");
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
      Get.snackbar("Error", "Camera permission denied");
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
            toolbarTitle: 'Image profile cropping',
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
      Get.snackbar("Error", "Failed to process image: $e");
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
              radius: 0.3,//0.18 difference
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
              text: "Settings",
              onTap: () {
                Get.toNamed("settings");
              },
            ),
            SizedBox(height: 5),
            line(
              screenHeight: screenHeight,
              screenWidth: screenWidth,
              icon: Icons.help,
              text: "Help Center",
              onTap: () {
                Get.toNamed("help");
              },
            ),
            SizedBox(height: 3),
            line(
              screenHeight: screenHeight,
              screenWidth: screenWidth,
              icon: Icons.share_outlined,
              text: "Share app",
              onTap: () {
                Share.share('Download my app here: $downloadLink');
              },
            ),
            SizedBox(height: 3),
            line(
              screenHeight: screenHeight,
              screenWidth: screenWidth,
              icon: Icons.logout_sharp,
              text: "Log out",
              onTap: () {
                showDeleteDialog(
                  context: context,
                  screenHeight: screenHeight,
                  screenWidth: screenWidth,
                  okText: "Log Out",
                  title: "Logging Out",
                  desc: "Are you sure you want to Log Out from Listenary?",
                  onDelete: () {
                    AuthService().signOut(context);
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
          const Text(
            "Choose option to change profile photo",
            style: TextStyle(
                color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 1),
          Row(
            children: [
              Expanded(
                child: ListTile(
                  title: const Text("Camera",
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
                  title: const Text("Gallery",
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
              title: const Text("Delete Profile Image",
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