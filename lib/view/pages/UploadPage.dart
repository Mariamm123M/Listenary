import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:listenary/services/permissions/camera_permission.dart';
import 'package:listenary/view/pages/UploadImage.dart';
import 'package:listenary/view/pages/UploadLink.dart';
import 'package:listenary/view/pages/upload_text.dart';
import 'ReadingPage.dart';
import 'UploadFile.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class UploadPage extends StatelessWidget {
  const UploadPage({Key? key}) : super(key: key);

  Future<void> _openCamera(BuildContext context) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera);

    if (image != null) {
      try {
        var request = http.MultipartRequest(
          'POST',
          Uri.parse('http://192.168.1.7:5000/upload'),
        );
        request.files.add(await http.MultipartFile.fromPath('file', image.path));
        var response = await request.send();

        if (response.statusCode == 200) {
          final extractedText = await response.stream.bytesToString();
          Get.to(() => ReadingPage(documnetText: extractedText));
        } else {
          print('OCR failed: ${response.statusCode}');
          Get.snackbar("Error", "Failed to extract text.");
        }
      } catch (e) {
        print('Error uploading file: $e');
        Get.snackbar("Error", "Could not connect to server.");
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    // Get the screen size for responsive design
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Scaling factor based on screen size
    double scaleWidth(double size) => size * screenWidth / 375;
    double scaleHeight(double size) => size * screenHeight / 812;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: scaleWidth(16.0), 
            vertical: scaleHeight(16.0),
          ),
          child: Column(
            children: [
              SizedBox(height: scaleHeight(32)),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SvgPicture.asset('assets/Icons/small_cloud.svg'),
                  SizedBox(width: scaleWidth(8)),
                  Text(
                    "Choose an option",
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w800,
                      fontSize: scaleWidth(19), // Scalable font size
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              SizedBox(height: scaleHeight(30)),
              _buildOptionCard(
                context,
                scaleWidth,
                scaleHeight,
                "Upload files",
                'assets/Icons/Pdf.svg',
                () => Get.to(() => UploadFile()),
              ),
              SizedBox(height: scaleHeight(10)),
              _buildOptionCard(
                context,
                scaleWidth,
                scaleHeight,
                "Upload images",
                'assets/Icons/upload2.svg',
                () => Get.to(() => UploadImage()),
              ),
              SizedBox(height: scaleHeight(10)),
              _buildOptionCard(
                context,
                scaleWidth,
                scaleHeight,
                "Type or paste text",
                'assets/Icons/text.svg',
                () => Get.to(() => UploadText()),
              ),
              SizedBox(height: scaleHeight(10)),
              Opacity(
                opacity: 1.0,
                child: GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text("Alert⚠️", textAlign: TextAlign.center),
                            ],
                          ),
                          content: const Text(
                              "Please ensure that the image and its elements are clear before taking the picture"),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () async {
                                Get.back();
                                bool storagePermission =
                                    await checkCameraPermission();
                                storagePermission
                                    ? _openCamera(context)
                                    : Get.back();
                              },
                              child: const Text("Ok"),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    height: scaleHeight(150),
                    padding: EdgeInsets.symmetric(
                      horizontal: scaleWidth(111),
                      vertical: scaleHeight(34),
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(scaleWidth(20)),
                      border: Border.all(color: Colors.grey, width: 1),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SvgPicture.asset('assets/Icons/scan.svg'),
                        SizedBox(height: scaleHeight(3)),
                        Text(
                          "Scan",
                          style: TextStyle(
                            fontSize: scaleWidth(10), // Scalable font size
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: scaleHeight(10)),
              _buildOptionCard(
                context,
                scaleWidth,
                scaleHeight,
                "Type or paste link",
                'assets/Icons/link.svg',
                () => Get.to(() => UploadLink()),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionCard(BuildContext context, double Function(double) scaleWidth,
      double Function(double) scaleHeight, String title, String assetPath, VoidCallback onTap) {
    return Opacity(
      opacity: 1.0,
      child: InkWell(
        onTap: onTap,
        highlightColor: Colors.grey.withAlpha((0.3 * 255).toInt()),
        splashColor: Colors.grey.withAlpha((0.3 * 255).toInt()),
        child: Container(
          width: double.infinity,
          height: scaleHeight(140),
          padding: EdgeInsets.symmetric(
            horizontal: scaleWidth(111),
            vertical: scaleHeight(30),
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(scaleWidth(20)),
            border: Border.all(color: Colors.grey, width: 1),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SvgPicture.asset(assetPath, color: Color(0xff212E54),),
              SizedBox(height: scaleHeight(3)),
              Text(
                title,
                style: TextStyle(
                  fontSize: scaleWidth(10), // Scalable font size
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
