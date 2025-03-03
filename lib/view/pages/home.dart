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

  Future<void> _loadProfileImage() async {
    String? userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    final Directory appDir = await getApplicationDocumentsDirectory();
    final Directory userDir = Directory('${appDir.path}/images/$userId');

    if (!userDir.existsSync()) return;

    List<FileSystemEntity> files = userDir.listSync();
    if (files.isNotEmpty) {
      files.sort((a, b) => b.statSync().modified.compareTo(a.statSync().modified));
      setState(() {
        _imagePath = files.first.path;
      });
    }
  }


  @override
  void initState() {
    super.initState();
    _getUserName();
    _loadProfileImage(); // Load the profile image on startup
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

  List<Book> libraryBooks = [
    Book(
        bookimage: AssetImage("assets/Images/book1.png"),
        booktitle: "Here Is Real Magic",
        description: "This is a memoir by magician Nate Staniforth...",
        author: "Nate Staniforth",
        pages: 256,
        bookcontent:
        "In 'Here Is Real Magic,' Nate Staniforth reflects on his life as a magician. He explores the magic of everyday life and how performing magic on stage helped him reconnect with a sense of wonder that we often lose as adults.",
        rating: 5.0,
        audioFilePath: "",
        language: "en"),
    Book(
        bookimage: AssetImage("assets/Images/book2.png"),
        booktitle: "Standing Out",
        description: "This is a career development book...",
        author: "Alex Abramin",
        pages: 162,
        bookcontent:
        "In 'Standing Out,' Alex Abramin offers practical advice for professionals looking to distinguish themselves in their careers. He covers topics like building a personal brand, networking, and developing a unique skill set that sets you apart in a competitive job market.",
        rating: 5.0,
        audioFilePath: "",
        language: "en"),
    Book(
        bookimage: AssetImage("assets/Images/book3.png"),
        booktitle: "The One",
        description: "A sci-fi thriller set in a near-future world...",
        author: "John Marrs",
        pages: 416,
        bookcontent:
        "'The One' follows a group of people who are matched with their supposed perfect partner based on DNA testing. As their relationships unfold, the characters confront the dangers of knowing too much about their fate and question whether they can truly trust science when it comes to love.",
        rating: 5.0,
        audioFilePath: "",
        language: "en"),
    Book(
        bookimage: AssetImage("assets/Images/book4.png"),
        booktitle: "Range",
        description: "This non-fiction book argues that generalists...",
        author: "David Epstein",
        pages: 352,
        bookcontent:
        "In 'Range,' David Epstein makes a compelling argument that breadth of knowledge and experience is more valuable than specialization in many fields. Through examples from sports, science, and business, he shows how generalists tend to excel in unpredictable environments.",
        rating: 5.0,
        audioFilePath: "",
        language: "en"),
    Book(
        bookimage: AssetImage("assets/Images/book5.jpg"),
        booktitle: "Chemistry",
        description: "A novel about an unnamed Chinese-American woman...",
        author: "Weike Wang",
        pages: 224,
        bookcontent:
        "'Chemistry' is a witty, emotional novel about a young scientist grappling with the pressures of academia and family expectations. The protagonist struggles with her identity and her relationships, all while trying to complete her PhD in chemistry.",
        rating: 5.0,
        audioFilePath: "",
        language: "en"),
    Book(
        bookimage: AssetImage("assets/Images/book6.jpg"),
        booktitle: "The Adventures of Sherlock Holmes",
        description: "A collection of twelve short stories featuring...",
        author: "Sir Arthur Conan Doyle",
        pages: 307,
        bookcontent:
        "'The Adventures of Sherlock Holmes' features twelve thrilling cases of the famous detective and his trusty companion, Dr. Watson. From 'A Scandal in Bohemia' to 'The Red-Headed League,' these stories capture the brilliance of Holmes as he unravels complex mysteries.",
        rating: 5.0,
        audioFilePath: "",
        language: "en"),
    Book(
        bookimage: AssetImage("assets/Images/book7.jpg"),
        booktitle: "Pride and Prejudice",
        description: "A classic romantic novel first published in 1813...",
        author: "Jane Austen",
        pages: 432,
        bookcontent:
        "'Pride and Prejudice' is a timeless story of love, class, and misunderstandings. Elizabeth Bennet, one of five sisters, meets the enigmatic Mr. Darcy, and despite initial judgments and obstacles, the two gradually come to realize their deep affection for one another.",
        rating: 5.0,
        audioFilePath: "",
        language: "en"),
    Book(
        bookimage: AssetImage("assets/Images/book8.jpg"),
        booktitle: "Ali Baba and the Forty Thieves",
        description: "A famous folk tale about Ali Baba...",
        author: "Anonymous",
        pages: 30,
        bookcontent:
        "'Ali Baba and the Forty Thieves' is a tale from 'One Thousand and One Nights' about a poor woodcutter who discovers a secret cave full of treasure, guarded by a band of forty thieves. With the help of his clever servant, Morgiana, Ali Baba outwits the thieves and secures his fortune.",
        rating: 5.0,
        audioFilePath: "",
        language: "en"),
    Book(
      booktitle: "The Art Stone",
      author: "Jesse A. Ellis",
      bookimage: AssetImage('assets/Images/TheArtStone.png'),
      rating: 3.4,
      pages: 540,
      language: "ENG",
      description:
      '''the ChatGPT said: The Art of Stone is an exploration of the craftsmanship behind stone artistry, showcasing both traditional and contemporary approaches to sculpting and shaping this unique material. The book highlights the skill and artistry of stoneworkers, focusing on techniques and the creative potential of stone as an artistic medium. It features insights from experts like Alice Minter, Sophie Morris, and Rosie Mills, along with stunning photography and illustrations that capture the beauty and complexity of stone art. ABRAMS BOOKS''',
      bookcontent:
      '''The "Art of Stone" dives into the world of stone artistry, highlighting the history, techniques, and artistry behind the medium. From ancient stone sculptures to modern interpretations, the book provides a comprehensive overview of stone art. The content covers how stone as a material has been used in both traditional and contemporary art, with a special focus on the tools and methods used by stone sculptors to create timeless pieces.''',
    ),
    Book(
      booktitle: "The Art Stone",
      author: "Jesse A. Ellis",
      bookimage: AssetImage('assets/Images/TheArtStone.png'),
      rating: 3.4,
      pages: 540,
      language: "ENG",
      description:
      '''the ChatGPT said: The Art of Stone is an exploration of the craftsmanship behind stone artistry, showcasing both traditional and contemporary approaches to sculpting and shaping this unique material. The book highlights the skill and artistry of stoneworkers, focusing on techniques and the creative potential of stone as an artistic medium. It features insights from experts like Alice Minter, Sophie Morris, and Rosie Mills, along with stunning photography and illustrations that capture the beauty and complexity of stone art. ABRAMS BOOKS''',
      bookcontent:
      '''The "Art of Stone" dives into the world of stone artistry, highlighting the history, techniques, and artistry behind the medium. From ancient stone sculptures to modern interpretations, the book provides a comprehensive overview of stone art. The content covers how stone as a material has been used in both traditional and contemporary art, with a special focus on the tools and methods used by stone sculptors to create timeless pieces.''',
    ),
  ];

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
              expandedHeight: (controller.recentBooks.isEmpty) ? screenWidth *
                  0.52 : screenWidth * 0.88,
              backgroundColor: const Color(0xff212E54),
              title: Row(
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
                    radius: 0.06,
                    screenWidth: screenHeight,
                    imageFile: _imagePath, // Updated image path
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
                          padding:
                          EdgeInsets.only(top: screenWidth * 0.25,
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
                SizedBox(width: 8,),
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
        )
    );
  }
}