import 'package:permission_handler/permission_handler.dart';

Future<bool> checkStoragePermission() async {
  PermissionStatus status;

  // For Android 10+ (API 29+), use Permission.photos
  if (await Permission.photos.isGranted) {
    status = await Permission.photos.status;
  } else {
    status = await Permission.storage.status;
  }

  if (status.isGranted) {
    print('Storage permission granted');
    return true;
  } else if (status.isDenied) {
    print('Storage permission denied');
    openAppSettings();
    /*Get.showSnackbar(
      GetSnackBar(
        snackPosition: SnackPosition.TOP,
        title: "Permission Denied",
        message: "Storage permission is required to access the gallery.",
        titleText: Text(
          "Permission Denied",
          style: TextStyle(
              color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        messageText: Text(
          "Storage permission is required to access the gallery.",
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
        backgroundColor: Color(0xff212E54),
        padding: EdgeInsets.all(15),
        duration: Duration(seconds: 5),
      ),
    );*/
    return false;
  } else if (status.isPermanentlyDenied) {
    print('Storage permission permanently denied');
    openAppSettings();
    return false;
  } else if (status.isRestricted) {
    print('Storage permission is restricted');
    openAppSettings();
    /*Get.showSnackbar(
      GetSnackBar(
        snackPosition: SnackPosition.TOP,
        title: "Permission Denied",
        message: "Storage permission is required to access the gallery.",
        titleText: Text(
          "Permission Denied",
          style: TextStyle(
              color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        messageText: Text(
          "Storage permission is required to access the gallery.",
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
        backgroundColor: Color(0xff212E54),
        padding: EdgeInsets.all(15),
        duration: Duration(seconds: 5),
      ),
    );*/
    return false;
  }
  return false;
}
