import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void showDeleteDialog({
  required screenHeight,
  required screenWidth,
  required BuildContext context,
  required VoidCallback onDelete,
  required String desc,
  required String okText, // Text for the OK button
  required String title,
}) {
  AwesomeDialog(
    context: context,
    padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 30),
    dialogType: DialogType.noHeader,
    dismissOnBackKeyPress: true,
    animType: AnimType.rightSlide,
    title: title,
    titleTextStyle: TextStyle(
      color: Color(0xff212E54),
      fontWeight: FontWeight.w700,
      fontSize: screenWidth * 0.045,
      fontFamily: 'Inter',
    ),
    desc: desc,
    descTextStyle: TextStyle(
      color: Color(0xff9B9B9B),
      fontWeight: FontWeight.w700,
      fontSize: screenWidth * 0.04,
      fontFamily: 'Inter',
    ),
    btnOkOnPress: onDelete, // Correct way to handle OK press
    btnOkText: okText, // Text for OK button
    btnOkColor: Color(0xFF212E54), // Optional: customize OK button color
    btnCancelOnPress: () {
      Get.back(); // Closes the dialog
    },
    btnCancelText: "Cancel", // Text for Cancel button
    btnCancelColor: Color(0xff9B9B9B), // Optional: customize Cancel button color
  ).show();
}
