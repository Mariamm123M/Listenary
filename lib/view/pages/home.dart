import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:listenary/controller/recent_books_controller.dart';
import 'package:listenary/model/book_model.dart';
import 'package:listenary/view/components/library_card.dart';
import 'package:listenary/view/components/recently_card.dart';
import 'package:listenary/view/pages/ReadingPage.dart';
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
  Book book = Book(
  booktitle: "Journey to the Deep Sea",
  description: "An adventure book about a deep-sea exploration mission and the mysteries of the ocean...",
  pages: 300,
  bookcontent: '''
    Page 1: The sky was a brilliant shade of blue, and the sun gleamed brightly over the vast expanse of the ocean. The ship set sail on its journey into the depths, where light could not reach and the human eye could not perceive the mysteries below. Onboard, a team of scientists was eager to uncover the secrets of the sea, diving into an adventure like no other. The atmosphere was filled with excitement and anticipation, as each crew member imagined what they might encounter beneath the waves.

    Page 2: After hours of sailing, the ship reached the designated point for the dive. The crew prepared the submarine that would carry them into the ocean's deep. Below the surface, marine creatures moved gracefully, their vibrant colors and strange forms captivating the scientists. One of them pointed out a peculiar creature, unlike anything they'd ever seen before—part fish, part octopus. This discovery marked only the beginning of their extraordinary findings.

    Page 3: As the submarine descended deeper into the abyss, the darkness became more oppressive. Yet, thanks to the bright lights aboard the vessel, the team could still see the fascinating life around them. Suddenly, a massive sea creature appeared in front of them, its size far exceeding anything they had expected. Hearts raced. Was this creature dangerous, or merely curious? Questions raced through their minds as the thrill of discovery grew stronger.

    Page 4: The team decided to follow the massive creature at a safe distance, documenting its movements. It swam with a slow, deliberate grace, seemingly unbothered by the submarine. As they ventured further into the deep, strange and unfamiliar species began to appear—giant jellyfish that pulsed with light, bioluminescent fish that flickered like stars in the black waters. The mysteries of the deep continued to unfold before their eyes, and with each discovery came new questions.

    Page 5: Hours passed as the submarine delved further into the ocean's depths, revealing a world that few had ever seen. The pressure outside was immense, but the crew inside remained safe, fascinated by the incredible sights before them. They encountered underwater caves, shimmering with unknown minerals, and schools of glowing fish that moved as one, creating patterns in the darkness. The adventure was far from over, but one thing was certain: the ocean held more secrets than anyone could have imagined.
  ''',
  rating: 4.8,
  language: "en", 
  bookId: 0, 
  author: '', bookimageURL: '',
);
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
