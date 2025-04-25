import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:listenary/services/permissions/storage_permisson.dart';
import 'package:http/http.dart' as http;
import 'ReadingPage.dart';


class UploadImage extends StatefulWidget {
  const UploadImage({Key? key}) : super(key: key);

  @override
  _UploadImageState createState() => _UploadImageState();
}

class _UploadImageState extends State<UploadImage> {
  File? _image;

  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _image = File(image.path);
      });

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
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Color(0xFF212E54),
          ),
          onPressed: () {
            Get.back();
          },
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              Center(
                child: Container(
                  width: 343,
                  height: 300,
                  margin: const EdgeInsets.only(top: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                    border: Border.all(
                      color: Color(0xFF949494),
                      width: 1,
                    ),
                  ),
                  child: Stack(
                    children: [
                      _image != null
                          ? Positioned(
                        top: 33,
                        left: 0,
                        right: 0,
                        child: Align(
                          alignment: Alignment.center,
                          child: Image.file(
                            _image!, // Display the picked image
                            width: 150,
                            height: 150,
                          ),
                        ),
                      )
                          : Positioned(
                        top: 33,
                        left: 0,
                        right: 0,
                        child: Align(
                          alignment: Alignment.center,
                          child: SvgPicture.asset(
                            'assets/Icons/cloud.svg',
                            width: 150,
                            height: 150,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 183,
                        left: 29,
                        child: Opacity(
                          opacity: 1,
                          child: Text(
                            'Drag and drop to upload',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: screenWidth * 0.045,
                              fontWeight: FontWeight.w700,
                              height: 29.05 / 24,
                              decoration: TextDecoration.none,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 230,
                        left: 121,
                        child: Opacity(
                          opacity: 1,
                          child: ElevatedButton(
                            onPressed: () {
                              showModalBottomSheet(
                                context: context,
                                builder: (context) {
                                  return Container(
                                    height: 160,
                                    color: Color(0xFF212E54),
                                    child: Padding(
                                      padding: const EdgeInsets.all(20.0),
                                      child: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          ListTile(
                                            onTap: () async {
                                              bool storagePermission =
                                              await checkStoragePermission();
                                              storagePermission
                                                  ? _pickImage()
                                                  : Get.back();
                                            },
                                            leading: Image.asset(
                                              'assets/Icons/image.png',
                                              width: 24,
                                              height: 20,
                                            ),
                                            title: Text(
                                              "Select Image from gallery",
                                              style: TextStyle(
                                                fontSize: screenWidth * 0.035,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF212E54),
                              fixedSize: Size(100, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                BorderRadius.all(Radius.circular(20)),
                              ),
                              padding: EdgeInsets.symmetric(horizontal: 0),
                            ),
                            child: Padding(
                              padding:
                              const EdgeInsets.symmetric(horizontal: 10.0),
                              child: Text(
                                'Upload',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                  height: 29.05 / 24,
                                  decoration: TextDecoration.none,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
