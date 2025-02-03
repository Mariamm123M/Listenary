import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

Future<bool> checkStoragePermission() async {
  PermissionStatus status = await Permission.storage.request();

  if (status.isGranted) {
    print('Storage permission granted');
    return true;
  } else if (status.isDenied) {
    // Permission denied, show a snackbar
    print('Storage permission denied');
    Get.showSnackbar(
      GetSnackBar(
        snackPosition: SnackPosition.TOP,
        title: "Permission Denied",
        message: "Storage permission is required to proceed.",
        titleText: Text(
          "Permission Denied",
          style: TextStyle(
              color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        messageText: Text(
          "Storage permission is required to proceed.",
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
        backgroundColor: Color(0xff212E54),
        padding: EdgeInsets.all(15),
        duration: Duration(seconds: 5),
      ),
    );
    return false; 
  } else if (status.isPermanentlyDenied) {
    print('Storage permission permanently denied');
    openAppSettings();
    return false; 
  } else if (status.isRestricted) {
    print('Storage permission is restricted');
    Get.showSnackbar(
      GetSnackBar(
        snackPosition: SnackPosition.TOP,
        title: "Permission Denied",
        message: "Storage permission is required to proceed.",
        titleText: Text(
          "Permission Denied",
          style: TextStyle(
              color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        messageText: Text(
          "Storage permission is required to proceed.",
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
        backgroundColor: Color(0xff212E54),
        padding: EdgeInsets.all(15),
        duration: Duration(seconds: 5),
      ),
    );
    return false; 
  }
  return false;
}
