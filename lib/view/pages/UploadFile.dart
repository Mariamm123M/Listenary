
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:listenary/services/permissions/storage_permisson.dart';

class UploadFile extends StatefulWidget {
  const UploadFile({Key? key}) : super(key: key);

  @override
  _UploadFileState createState() => _UploadFileState();
}

class _UploadFileState extends State<UploadFile> {
  String? pickedFilePath;

  Future<void> pickDocument() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      setState(() {
        pickedFilePath = result.files.single.path; // Get the file path
      });
    } else {
      setState(() {
        pickedFilePath = null; // Handle case when no file is picked
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    // double screenHeight = MediaQuery.of(context).size.height;
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
                      Positioned(
                        top: 33,
                        left: 0,
                        right: 0,
                        child: Align(
                          alignment: Alignment.center,
                          child: Image.asset(
                            'assets/Icons/cloud.png',
                            width: 150,
                            height: 150,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 45.62,
                        left: 205,
                        child: Opacity(
                          opacity: 1,
                          child: Transform.rotate(
                            angle: -20.22 * 3.1416 / 180,
                            child: Image.asset(
                              'assets/Icons/Vector (1).png',
                              width: 30,
                              height: 30,
                            ),
                          ),
                        ),
                      ),Positioned(
                        top: 67,
                        left: 238.51,
                        child: Opacity(
                          opacity: 1,
                          child: Transform.rotate(
                            angle: -10.43 * 3.1416 / 180,
                            child: Image.asset(
                              'assets/Icons/pdf.png',
                              width: 30,
                              height: 30,
                            ),
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
                      ),Positioned(
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
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          ListTile(
                                            onTap: () async {
                                              bool storagePermission = await checkStoragePermission();
                                              storagePermission?
                                              pickDocument():
                                              Get.back();
                                            },
                                            leading: Icon(
                                              Icons.folder,
                                              color: Colors.yellow,
                                            ),
                                            title: Text(
                                              "Browse documents",
                                              style: TextStyle(
                                                fontSize: 18,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                          ListTile(
                                            onTap: () {
                                            },
                                            leading: Image.asset(
                                              'assets/Icons/Drive.png',
                                              width: 24,
                                              height: 20,
                                            ),
                                            title: Text(
                                              "Drive",
                                              style: TextStyle(
                                                fontSize: 18,
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
                            child: Text(
                              'Upload',
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
