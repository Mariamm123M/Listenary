import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:listenary/controller/recent_books_controller.dart';
import 'package:listenary/model/book_model.dart';
import 'package:listenary/view/components/library_card.dart';
import 'package:listenary/view/components/recently_card.dart';
import 'package:listenary/view/pages/SearchPage.dart';
import 'package:listenary/view/pages/profile.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import '../components/profile_image.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  String name = "User";
  String? _imagePath;

  List<Book> libraryBooks = [];
  bool isLoading = true;

  Future<void> fetchBooks() async {
    try {
      final response = await http.get(
        Uri.parse('http://192.168.1.7:5000/get_books'), // 🔁 Replace with your Flask URL
      );
      if (response.statusCode == 200) {
        List data = jsonDecode(response.body);
        setState(() {
          libraryBooks = data.map((book) => Book.fromJson(book)).toList();
          isLoading = false;
        });
        print(libraryBooks);
      } else {
        print('Failed to load books. Status code: ${response.statusCode}');
        setState(() => isLoading = false);
      }
    } catch (e) {
      print("Error fetching books: $e");
      setState(() => isLoading = false);
    }
  }

  Future<void> _loadProfileImage() async {
    String? userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    final Directory appDir = await getApplicationDocumentsDirectory();
    final Directory userDir = Directory('${appDir.path}/images/$userId');

    if (!userDir.existsSync()) return;

    List<FileSystemEntity> files = userDir.listSync();
    if (files.isNotEmpty) {
      files.sort(
          (a, b) => b.statSync().modified.compareTo(a.statSync().modified));
      setState(() {
        _imagePath = files.first.path;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _getUserName();
    _loadProfileImage();
    fetchBooks();
  }

  void _getUserName() {
    User? user = FirebaseAuth.instance.currentUser;
    setState(() {
      name = user?.displayName ?? "User";
      image = user?.photoURL; // Fetch user profile picture URL
    });
  }

  String? image;

  List<String> categories = [
    "All",
    "Drama",
    "Romantic",
    "Science fiction",
    "Children",
    "Comedy",
    "Crime",
    "Horror",
    "Biography",
    "History"
  ];

  String selectedCategory = "All";



  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      key: scaffoldKey,
      drawer: Profile(),
      body: CustomScrollView(
        slivers: [
          GetX<RecentBooksController>(builder: (controller) {
            return SliverAppBar(
              
              automaticallyImplyLeading: false,
              pinned: true,
              expandedHeight: (controller.recentBooks.isEmpty)
                  ? screenWidth * 0.52
                  : screenWidth * 0.88,
              backgroundColor: const Color(0xff212E54),
              title: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Hello, ${name.capitalize!}",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: screenWidth * 0.045,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    ProfileImage(
                      radius: 0.035,
                      number: 0.16,
                      screenWidth: screenHeight,
                      imageFile: _imagePath, // Updated image path
                      onTap: () {
                        scaffoldKey.currentState?.openDrawer();
                      },
                    ),
                  ],
                ),
              ),
              flexibleSpace: FlexibleSpaceBar(
                background: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Color(0xff212E54),
                    ),
                    child: Padding(
                        padding: EdgeInsets.only(left: screenWidth * 0.045),
                        child: (controller.recentBooks.isEmpty)
                            ? Padding(
                                padding: EdgeInsets.only(
                                    top: screenWidth * 0.25,
                                    right: screenWidth * 0.02),
                                child: Column(
                                  children: [
                                    searchBar(screenWidth, screenHeight),
                                    SizedBox(
                                      height: screenWidth * 0.05,
                                    ),
                                    Text(
                                        "No recent books, Start reading new one!",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: screenWidth * 0.032,
                                            fontWeight: FontWeight.w800)),
                                  ],
                                ),
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(
                                        top: kToolbarHeight + 40,
                                        right: screenWidth * 0.02),
                                    child: searchBar(screenWidth, screenHeight),
                                  ),
                                  SizedBox(height: screenWidth * 0.034),
                                  Row(
                                    children: [
                                      Text(
                                        "Continue",
                                        style: TextStyle(
                                          fontSize: screenWidth * 0.04,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Image.asset("assets/Icons/book.png"),
                                    ],
                                  ),
                                  SizedBox(height: screenWidth * 0.03),
                                  SizedBox(
                                    height: screenWidth * 0.37,
                                    child: ListView.separated(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: controller.recentBooks.length,
                                      itemBuilder: (context, i) {
                                        return RecentlyCard(
                                            book: controller.recentBooks[i]);
                                      },
                                      separatorBuilder: (context, i) =>
                                          const SizedBox(width: 16),
                                    ),
                                  ),
                                ],
                              )),
                  ),
                ),
              ),
            );
          }),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(screenWidth * 0.025),
              child: Text('Categories',
                  style: TextStyle(
                      fontSize: screenWidth * 0.045,
                      fontWeight: FontWeight.w600,
                      color: Colors.black)),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: screenWidth * 0.1,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedCategory = categories[index];
                      });
                    },
                    child: Container(
                      alignment: Alignment.center,
                      margin: const EdgeInsets.only(left: 16),
                      padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.03,
                          vertical: screenHeight * 0.0022),
                      decoration: BoxDecoration(
                        color: selectedCategory == categories[index]
                            ? const Color(0xffFEC838)
                            : Colors.white,
                        border: Border.all(
                            color: const Color(0xffFEC838), width: 2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        categories[index],
                        style: TextStyle(
                            fontSize: screenWidth * 0.043,
                            fontWeight: FontWeight.bold,
                            color: Colors.black),
                      ),
                    ),
                  );
                },
                separatorBuilder: (context, index) => const SizedBox(width: 1),
              ),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.all(screenHeight * 0.02),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 0.62,
              ),
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int i) {
                  return LibraryCard(book: libraryBooks[i]);
                },
                childCount: libraryBooks.length,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget searchBar(double screenWidth, double screenHeight) {
    return GestureDetector(
        onTap: () {
          //navigate to search page
          Get.to(() => SearchPage());
        },
        child: Container(
          decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.white, width: 1),
              borderRadius: BorderRadius.all(Radius.circular(35))),
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.02, vertical: screenHeight * 0.012),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(
                  Icons.search,
                  color: Color(0xff212E54),
                ),
                SizedBox(
                  width: 8,
                ),
                Text(
                  "Search",
                  style: TextStyle(
                    color: Color(0xff212E54),
                    fontSize: screenWidth * 0.032,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
