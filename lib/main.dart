import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:listenary/controller/favorites_books_controller.dart';
import 'package:listenary/controller/recent_books_controller.dart';
import 'package:listenary/view/pages/help_center.dart';
import 'package:listenary/view/pages/home.dart';
import 'package:listenary/view/pages/login.dart' as login_page;
import 'package:listenary/view/pages/profile.dart';
import 'package:listenary/view/pages/settings.dart';
import 'package:listenary/view/pages/signup.dart' as signup_page;
import 'package:listenary/view/pages/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
 // debugPaintSizeEnabled = true;
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

//File? imageFile;

class MyApp extends StatelessWidget {
    MyApp({super.key});

  FavoriteBooksController favorite_controller = Get.put(FavoriteBooksController(), permanent: true);
  RecentBooksController recent_controller = Get.put(RecentBooksController(), permanent: true);

 
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
            textStyle:  WidgetStatePropertyAll(
              TextStyle(
                fontSize: screenWidth * 0.038,
                fontWeight: FontWeight.w700,
              ),
            ),
            padding:  WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: screenWidth * 0.06, vertical: screenHeight * 0.015)),
            foregroundColor: const WidgetStatePropertyAll(Colors.white), // Text color
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
      home:  Home()/*SplashScreen()*/,
      //initialRoute: "/signup",
      getPages: [
        GetPage(name: "/", page: () => const SplashScreen()),
        GetPage(name: "/login", page: () => const login_page.Login()),
        GetPage(name: "/signup", page: () => const signup_page.SignUp()),
        GetPage(name: "/home", page: () =>  Home()),
        GetPage(name: "/profile", page: () =>  Profile()),
        GetPage(name: "/help", page: () =>  const HelpCenter()),
        GetPage(name: "/settings", page: () =>  const Settings()),
      ],
    );
  }
}
