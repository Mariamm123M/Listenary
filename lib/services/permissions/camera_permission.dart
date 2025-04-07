import 'package:permission_handler/permission_handler.dart';

Future<bool> checkCameraPermission() async {
  PermissionStatus status = await Permission.camera.request();

  if (status.isGranted) {
    print('Camera permission granted');
    return true;
  } else if (status.isDenied) {
    print('Camera permission denied');
    openAppSettings();
    /*Get.showSnackbar(
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
    );*/
    return false; 
  } else if (status.isPermanentlyDenied) {
    print('Camera permission permanently denied');
    openAppSettings();
    return false; 
  } else if (status.isRestricted) {
    print('Camera permission is restricted');
    openAppSettings();
    /*Get.showSnackbar(
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
    );*/
    return false; 
  } return false;
  }
