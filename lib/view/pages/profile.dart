import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:listenary/services/permissions/camera_permission.dart';
import 'package:listenary/services/permissions/storage_permisson.dart';
import 'package:listenary/view/components/awesome_dialog.dart';
import 'package:listenary/view/components/profile_image.dart';
import 'package:listenary/view/pages/onboarding.dart';
import 'package:share_plus/share_plus.dart';

class Profile extends StatefulWidget {
  const Profile({
    super.key,
  });

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  String name = "manal";
  File? _imgFile;
  final ImagePicker _picker = ImagePicker();

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final String downloadLink =
      "https://drive.google.com/file/d/1-Tq5LabMnNnniPUrDiufRbdSaXYm4NSL/view?usp=sharing"; // Replace this with your link

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
                radius: 0.44,
                screenWidth: screenWidth,
                imageFile: _imgFile?.path, // Pass the image path
                color: Color(0xff949494),
                onTap: () {
                  //view profile image
                },
                child: Stack(children: [
                  Positioned(
                      child: FloatingActionButton(
                    backgroundColor: Colors.white,
                    mini: true,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25)),
                    onPressed: () async {
                      await showModalBottomSheet(
                          context: context,
                          builder: (context) => bottomSheet(screenHeight: screenHeight, screenWidth: screenWidth));
                    },
                    child: Icon(
                      Icons.add,
                      color: Color(0xff212E54),
                    ),
                  )),
                ])),
            SizedBox(
              height: screenHeight * 0.01,
            ),
            Text(
              name.capitalize!,
              style: TextStyle(
                  color: Color(0xff212E54),
                  fontSize: screenWidth * 0.045,
                  fontWeight: FontWeight.w800),
            ),
            SizedBox(
              height: screenHeight * 0.015,
            ),
            Divider(
              color: Color(0xff3C3C3C),
              thickness: 1,
            ),
            SizedBox(
              height: screenHeight * 0.015,
            ),
            line(
                screenHeight: screenHeight,
                screenWidth: screenWidth,
                icon: Icons.settings,
                text: "Settings",
                onTap: () {
                  Get.toNamed("settings");
                }),
            SizedBox(
              height: screenHeight * 0.015,
            ),
            line(
                screenHeight: screenHeight,
                screenWidth: screenWidth,
                icon: Icons.help,
                text: "Help Center",
                onTap: () {
                  Get.toNamed("help");
                }),
            SizedBox(
              height: screenHeight * 0.015,
            ),
            line(
                screenHeight: screenHeight,
                screenWidth: screenWidth,
                icon: Icons.share_outlined,
                text: "Share app",
                onTap: () {
                  Share.share('Download my app here: $downloadLink');
                }),
            SizedBox(
              height: screenHeight * 0.015,
            ),
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
                        //logout function
                        Get.offAll(() => Onboarding());
                      });
                })
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
            color: Color(0xff212E54),
            fontSize: screenWidth * 0.045,
            fontWeight: FontWeight.w600),
      ),
      leading: Icon(
        icon,
        color: Color(0xff212E54),
        size: 35,
      ),
    );
  }

  void takePhoto({required ImageSource source}) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _imgFile = File(pickedFile.path);
      });
    }
  }

  Widget bottomSheet({required double screenHeight, required screenWidth}) {
    return Container(
      height: screenHeight * 0.2,
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.025, vertical: screenHeight * 0.01),
      decoration: BoxDecoration(
          color: Color(0xff212E54),
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(15), topRight: Radius.circular(15))),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text(
          "choose option to change profile photo",
          style: TextStyle(
              color: Colors.white,
              fontSize: screenWidth * 0.035,
              fontWeight: FontWeight.w700,
              fontFamily: 'Inter'),
        ),
        SizedBox(
          height: 10,
        ),
        Row(
          children: [
            Expanded(
              child: ListTile(
                title: Text(
                  "Camera",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: screenWidth * 0.035,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Inter'),
                ),
                leading: Icon(
                  Icons.camera,
                  color: Colors.white,
                  size: 30,
                ),
                onTap: () async {
                  bool cameraPermission = await checkCameraPermission();
                  cameraPermission
                      ? takePhoto(source: ImageSource.camera)
                      : Get.back();
                },
              ),
            ),
            SizedBox(
              width: screenWidth * 0.04,
            ),
            Expanded(
              child: ListTile(
                title: Text(
                  "Gallery",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: screenHeight * 0.02,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Inter'),
                ),
                leading: SvgPicture.asset(
                  "assets/Icons/gallery.svg",
                  color: Colors.white,
                  height: 30,
                  width: 30,
                ),
                onTap: () async {
                  bool storagePermission = await checkStoragePermission();
                  storagePermission
                      ? takePhoto(source: ImageSource.gallery)
                      : Get.back();
                },
              ),
            ),
          ],
        )
      ]),
    );
  }
}
