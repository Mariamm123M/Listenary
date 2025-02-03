import 'package:permission_handler/permission_handler.dart';

Future<bool> checkMicrophonePermission() async {
  PermissionStatus status = await Permission.microphone.request();

  if (status.isGranted) {
    // Permission granted, return the provided child widget
    print('Microphone permission granted');
    return true;
  } else if (status.isDenied) {
    // Permission denied, show a snackbar
    print('Microphone permission denied');
    return false; // Return an empty widget or any fallback widget
  } else if (status.isPermanentlyDenied) {
    // Permission permanently denied, open app settings
    print('Microphone permission permanently denied');
    openAppSettings();
    return false; // Return an empty widget or any fallback widget
  } else if (status.isRestricted) {
    // Permission is restricted (e.g., parental controls)
    print('Microphone permission is restricted');
    return false; // Return an empty widget or any fallback widget
  } return false;
  }
