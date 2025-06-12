import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:listenary/controller/recent_books_controller.dart';
import 'package:listenary/model/book_model.dart';
import 'package:listenary/view/components/chracters_dialog.dart';
import 'package:listenary/view/components/library_card.dart';
import 'package:listenary/view/components/recently_card.dart';
import 'package:listenary/view/pages/chatBot.dart';
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
Book book = Book(
  bookId: 2,
  booktitle: "Humans: A Deep Dive into Human Nature",
  author: "Nour Abdullah",
  bookimageURL: "https://example.com/images/human_nature.jpg",
  rating: 4.8,
  pages: 512,
  language: "English",
  description:
      "This comprehensive book takes a profound journey into the emotional, psychological, and philosophical makeup of what it means to be human. "
      "It explores how identity is formed, how emotions shape our experiences, and how society influences our behavior. "
      "Each chapter is carefully structured to unpack complex human experiences in a relatable and thought-provoking manner.",
  bookcontent:
      "Chapter 1: The Roots of Identity\n"
      "From the moment we are born, we begin to form a sense of who we are. Our identity is not static—it evolves with every experience and interaction. "
      "This chapter examines how culture, upbringing, trauma, and environment contribute to our understanding of self.\n\n"
      
      "Chapter 2: Emotional Intelligence\n"
      "Understanding and managing emotions is critical to our relationships and personal growth. This chapter delves into the science of emotional regulation, "
      "empathy, and the connection between emotional health and decision-making.\n\n"
      
      "Chapter 3: The Human Condition\n"
      "To be human is to struggle, to question, to hope. This chapter reflects on the philosophical inquiries that have followed humanity for centuries—"
      "from the search for purpose to the inevitability of mortality.\n\n"
      
      "Chapter 4: Social Mirrors\n"
      "We are shaped by the people around us. This chapter explores social dynamics, peer pressure, community belonging, and how feedback from others can enhance or distort self-perception.\n\n"
      
      "Chapter 5: Beyond the Self\n"
      "Can we rise above ego and personal gain? This final chapter challenges the reader to think of humanity as a collective and asks: what does it mean to live for others as much as for ourselves?\n\n"
      
      "Conclusion:\n"
      "Understanding human nature is a lifelong journey, one that invites curiosity, compassion, and courage. This book is only the beginning of that path.",
  audioFilePath: "https://example.com/audio/deep_dive_humans.mp3",
  category: "Psychology & Philosophy",
);

  List<String> categories = [
    "drama".tr,
    "romantic".tr,
    "science_fiction".tr,
    "children".tr,
    "comedy".tr,
    "crime".tr,
    "horror".tr,
    "biography".tr,
    "history".tr
  ];
  String? selectedCategory;
void getCurrentUserId() {
  User? user = FirebaseAuth.instance.currentUser;

  if (user != null) {
    String uid = user.uid;
    print("User ID: $uid");
  } else {
    print("No user is currently signed in.");
  }
}
  Future<void> fetchBooks() async {
    try {
      final response = await http.get(
        Uri.parse('http://192.168.1.15:5000/get_books'),
      );
      if (response.statusCode == 200) {
        List data = jsonDecode(response.body);
        setState(() {
          libraryBooks = data
              .map((bookJson) => Book.fromJson(bookJson))
              .toList();
          isLoading = false;
        });
      } else {
        print('Failed to load books. Status code: ${response.statusCode}');
        setState(() => isLoading = false);
      }
    } catch (e) {
      print("Error fetching books: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _getUserName();
    _loadProfileImage();
    fetchBooks();
    getCurrentUserId() ;

  }

  void _getUserName() {
    User? user = FirebaseAuth.instance.currentUser;
    setState(() {
      name = user?.displayName ?? "User";
    });
  }

  Future<void> _loadProfileImage() async {
    String? userId = FirebaseAuth.instance.currentUser?.uid;
    final Directory appDir = await getApplicationDocumentsDirectory();
    final Directory userDir = Directory('${appDir.path}/images/$userId');

    if (!userDir.existsSync()) return;

    List<FileSystemEntity> files = userDir.listSync();
    if (files.isNotEmpty) {
      files.sort((a, b) =>
          b.statSync().modified.compareTo(a.statSync().modified));
      setState(() {
        _imagePath = files.first.path;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    final List<Book> filteredBooks = selectedCategory == null
        ? libraryBooks
        : libraryBooks.where((book) {
            final category = book.category.toLowerCase() ?? '';
            return category == selectedCategory!.toLowerCase();
          }).toList();

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
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'hello'.tr + '${name.capitalize!}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: screenWidth * 0.045,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  ProfileImage(
                    radius: 0.03,
                    number: 0.15,
                    screenWidth: screenHeight,
                    imageFile: _imagePath,
                    onTap: () {
                      scaffoldKey.currentState?.openDrawer();
                    },
                  ),
                ],
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
                                  top: screenWidth * 0.3,
                                  right: screenWidth * 0.02),
                              child: Column(
                                children: [
                                  searchBar(screenWidth, screenHeight),
                                  SizedBox(height: screenWidth * 0.05),
                                  Text(
                                      "no_recent_books".tr,
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: screenWidth * 0.032,
                                        fontWeight: FontWeight.w800),
                                  ),
                                ],
                              ),
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
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
                                      "continue".tr,
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
                            ),
                    ),
                  ),
                ),
              ),
            );
          }),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(screenWidth * 0.025),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text('categories'.tr,
                          style: TextStyle(
                              fontSize: screenWidth * 0.045,
                              fontWeight: FontWeight.w600,
                              color: Colors.black)),
                    ],
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  GestureDetector(
                    onTap: (){
                      Get.to(() => ChatBotPage());
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        SvgPicture.asset(
                          'assets/Icons/chatbot.svg',
                          color: Color(0xffFEC838),
                        ),
                        SizedBox(
                          width: 8,
                        ),
                        Text('Ask_Book_Expert?'.tr,
                            style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: screenWidth * 0.032,
                                fontWeight: FontWeight.w600,
                                color: Colors.blueAccent[400])),
                      ],
                    ),
                  )
                ],
              ),
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
                        if (selectedCategory == categories[index]) {
                          selectedCategory = null;
                        } else {
                          selectedCategory = categories[index];
                        }
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
                separatorBuilder: (context, index) =>
                    const SizedBox(width: 1),
              ),
            ),
          ),
          isLoading
              ? SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 50.0),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                )
              : SliverPadding(
                  padding: EdgeInsets.all(screenHeight * 0.02),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      childAspectRatio: 0.62,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (BuildContext context, int i) {
                        return LibraryCard(book: filteredBooks[i]);
                      },
                      childCount: filteredBooks.length,
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
      Get.dialog(
                        Dialog(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                          child: CharctersDialog(book: book),
                        ),);
       /* Get.to(() => SearchPage());*/
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.white, width: 1),
          borderRadius: const BorderRadius.all(Radius.circular(35)),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.02,
              vertical: screenHeight * 0.012),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Icon(Icons.search, color: Color(0xff212E54)),
              const SizedBox(width: 8),
              Text(
                  "search".tr,
                style: TextStyle(
                  color: const Color(0xff212E54),
                  fontSize: screenWidth * 0.032,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
