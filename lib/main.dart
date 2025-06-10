import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:listenary/controller/favorites_books_controller.dart';
import 'package:listenary/controller/highlightedController.dart';
import 'package:listenary/controller/notesController.dart';
import 'package:listenary/controller/recent_books_controller.dart';
import 'package:listenary/controller/searchController.dart';
import 'package:listenary/view/pages/help_center.dart';
import 'package:listenary/view/pages/home.dart';
import 'package:listenary/view/pages/login.dart' as login_page;
import 'package:listenary/view/pages/profile.dart';
import 'package:listenary/view/pages/settings.dart';
import 'package:listenary/view/pages/signup.dart' as signup_page;
import 'package:listenary/view/pages/splash_Screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,  // Ensure this is set
  );
  runApp(MyApp());
}


//File? imageFile
class MyApp extends StatelessWidget {
  MyApp({super.key});

  FavoriteBooksController favorite_controller =
      Get.put(FavoriteBooksController(), permanent: true);
  RecentBooksController recent_controller =
      Get.put(RecentBooksController(), permanent: true);
  HighlightController highlightController = Get.put(HighlightController());
  final searchController = Get.put(MySearchController());
  final noteController = Get.put(NoteController());

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Listenary',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Inter',
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            textStyle: WidgetStatePropertyAll(
              TextStyle(
                fontFamily: 'Inter',
                fontSize: screenWidth * 0.038,
                fontWeight: FontWeight.w700,
              ),
            ),
            padding: WidgetStatePropertyAll(EdgeInsets.symmetric(
                horizontal: screenWidth * 0.06,
                vertical: screenHeight * 0.015)),
            foregroundColor:
                const WidgetStatePropertyAll(Colors.white), // Text color
            backgroundColor: const WidgetStatePropertyAll(
              Color(0XFF212E54),
            ), // Button background color
            shape: WidgetStatePropertyAll(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ),
      ),
      home: SplashScreen(), 
      //initialRoute: "/signup",
      getPages: [
        GetPage(name: "/", page: () => const SplashScreen()),
        GetPage(name: "/login", page: () => const login_page.Login()),
        GetPage(name: "/signup", page: () => const signup_page.SignUp()),
        GetPage(name: "/home", page: () => Home()),
        GetPage(name: "/profile", page: () => Profile()),
        GetPage(name: "/help", page: () => const HelpCenter()),
        GetPage(name: "/settings", page: () => const Settings()),
      ],
    );
  }
}
