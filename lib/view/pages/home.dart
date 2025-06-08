import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:listenary/controller/recent_books_controller.dart';
import 'package:listenary/model/book_model.dart';
import 'package:listenary/view/components/library_card.dart';
import 'package:listenary/view/components/recently_card.dart';
import 'package:listenary/view/components/chracters_dialog.dart';
import 'package:listenary/view/pages/ReadingPage.dart';
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
  Book book = Book(
    booktitle: "Journey to the Deep Sea",
    description:
        "An adventure book about a deep-sea exploration mission and the mysteries of the ocean...",
    pages: 300,
    bookcontent: '''
  

**Black** is not just a color; it is a powerful statement that has influenced art, fashion, psychology, and even history itself. From the earliest civilizations, black was associated with the unknown, the night sky, and the deep mysteries of the universe. Ancient Egyptians used black to symbolize fertility and rebirth because of the rich, black soil left behind after the Nile flooded.

In the world of fashion, black represents sophistication, elegance, and authority. A black suit or a little black dress is considered timeless and appropriate for almost any occasion. Designers often favor black because it provides a neutral background that highlights form, texture, and innovation.

Psychologically, black can evoke a wide range of emotions. It can convey a sense of power, control, and independence, but also sorrow and mourning. In many cultures, people wear black during times of grief, reflecting the solemn respect for those who have passed away. Yet in other settings, black attire can project confidence and strength.

Artists throughout history have understood the emotional weight of black. Renaissance painters used black to create dramatic contrasts known as chiaroscuro, highlighting light and shadow in their masterpieces. Modern artists like Kazimir Malevich pushed the limits of abstraction with works like "Black Square," where black became the subject itself rather than the background.

In literature and film, black often represents the unknown or the sinister. A villain cloaked in black or a dark, abandoned house painted in shades of black immediately sets a chilling tone. Yet, it is important to note that black does not always signify evil — it can also represent protection, mystery, and infinite possibilities.

In nature, black appears in many powerful forms: the glossy feathers of a raven, the volcanic stones of a lava field, the depths of the ocean. These natural examples show that black is far from empty; it is full of texture, movement, and life.

Technology and modern branding have also embraced black for its sleek, minimalist appeal. Many tech companies design their products in black to suggest high-end quality and futuristic design. Black cars, black smartphones, black clothing — all signal a sense of luxury and cutting-edge style.

Ultimately, black is a color of contradictions. It is both the absence of light and a canvas for endless creation. It can represent mourning or celebration, simplicity or complexity, fear or empowerment. No matter where we encounter it — in the natural world, in culture, or in our daily lives — **black** leaves an undeniable impact.

  ''',
    rating: 4.8,
    language: "en",
    bookId: 0,
    author: '',
    bookimageURL: '',
  );
  Book book2 = Book(
    booktitle: "عربي",
    description:
        "An adventure book about a deep-sea exploration mission and the mysteries of the ocean...",
    pages: 300,
    bookcontent: '''
  

لماذا نفتقد المراجع الأكاديمية في المواضيع العلمية باللغة العربية؟ لماذا نفتقد المسؤولية الجماعية أو الرسمية إزاء اللغة العربية؟ من هنا أصل إلى نقطة هامة ، وفي تقديري هي جوهر المسألة : وهي أننا – عامةً – لا نوقّـر لغتنا ، ولا نجلّ أربابها بما يليقون به ، فقد نسمع اللفظ الهزيل الكليل ، وقد نسمع اللاحن تلو اللاحن ( وانتبه في حفلات التأبين – مثلاً ) ، ونمر على ذلك مر الكرام ....بل قد نجد بيننا من يسخر منك إن حاولت أن تنقد لغة هذا الزعيم أو ذاك ، فتصبح أنت الهُـزْأة ، فالسياسيون وشخصيات المجتمع أهم من اللغة وإعرابها... ولا غرابة إذا رأينا - من جهة أخرى - من يحسن عربيته ويبدع فيها، فلا يحظى بأية مزيــة أو ميزة، وبراعته لا تجديه ولن تجزيه شيئًا .... ثم إن بعض المسرحيات تستخدم ألفاظًا عن سابق قصد – لإثارة السخرية اللاذعة من هذه اللغة الفصيحة، فيظهرونها وكأنها التشدق والتفيهق، وما مثـَّله عادل إمام وقوله "ألححت إصرارًا ...وأصررت إلحاحًا" إلا نموذج على ذلك.

  ''',
    rating: 4.8,
    language: "en",
    bookId: 0,
    author: '',
    bookimageURL: '',
  );

  Book book4 = Book(
    booktitle: "Echoes of the Forgotten Forest",
    description:
        "A captivating journey through a mystical forest where forgotten legends awaken and ancient spirits guide the lost.",
    pages: 420,
    bookcontent: '''
**Green** is more than just the color of nature — it is a symbol of renewal, life, balance, and growth. Throughout history, green has represented prosperity, fertility, and hope. In ancient Rome, green was the color of Venus, the goddess of love and gardens. In Islamic cultures, it is associated with paradise and eternal life.

In modern psychology, green is considered a restful and soothing color. Hospitals and therapy rooms often use green tones to promote calmness and healing. The human eye is highly sensitive to green, making it the most restful color for our vision.

Ecologically, green is the banner of sustainability. It is the face of environmental movements, renewable energy campaigns, and global efforts to protect Earth’s resources. The phrase “going green” has become synonymous with responsibility toward nature and future generations.

In art, green has played both positive and mysterious roles. Renaissance artists used rich green pigments made from natural minerals, while Impressionists used vibrant greens to capture the movement of grass, trees, and landscapes.

Culturally, green can have contrasting meanings. In Western contexts, it symbolizes luck (like the four-leaf clover), while in others, it may signal jealousy ("green with envy") or immaturity. The emotional tone of green varies by context and usage.

From currency to traffic lights, green is deeply embedded in modern life as a signal of prosperity, movement, and success. It inspires feelings of freshness, new beginnings, and peace.

Whether in the forest canopy, a jade sculpture, or the soft glow of spring leaves — **green** surrounds us, comforts us, and connects us to the living world.

  ''',
    rating: 4.9,
    language: "en",
    bookId: 1,
    author: '',
    bookimageURL: '',
  );

  Book book3 = Book(
    booktitle: "The Power of Blue",
    description:
        "A brief reflection on the calming and inspiring nature of the color blue.",
    pages: 120,
    bookcontent: '''
**Blue** is the color of sky and sea — open, vast, and free. It brings feelings of calm, peace, and trust. In many cultures, blue is a sacred and protective color.

Artists use blue to paint serenity and imagination. In business, it shows professionalism and reliability. Blue jeans, blue skies, blue oceans — the color is everywhere, reminding us to breathe, reflect, and dream.

Though often quiet, blue holds deep power — it can soothe or inspire, cool or energize. In all its shades, **blue** speaks to the soul.

  ''',
    rating: 4.6,
    language: "en",
    bookId: 2,
    author: '',
    bookimageURL: '',
  );
Book book5 = Book(
  booktitle: "The Light Beyond the Trees",
  description: "A short tale of friendship, mystery, and hope beneath the forest canopy.",
  pages: 98,
  bookcontent: '''
Manal had always dreamed of traveling the world. Since childhood, she would spend hours reading books about distant places, imagining the adventures that awaited her. One summer, she finally decided to take a leap and planned a trip to Europe.

Before her departure, she met with her close friends Mohamed and Ahmed to share her plans. Mohamed, who was working as an architect, encouraged her to follow her dreams and promised to help with anything she might need. Ahmed, on the other hand, was a passionate photographer and offered to document her journey through pictures.

During the trip, Manal visited famous landmarks in Paris, Rome, and Barcelona. She sent postcards to Mohamed and Ahmed, describing her experiences and the fascinating people she met. Mohamed admired her courage and often sketched designs inspired by her stories. Ahmed started compiling a photo album capturing moments from their lives to create a memory book.

Back home, the friends often gathered at their favorite café to catch up. Manal shared her travel tales, Mohamed presented his latest architectural models, and Ahmed showcased his newest photographs. Their friendship was a blend of inspiration, support, and shared dreams.

One day, Manal faced a difficult decision about her career path. Mohamed and Ahmed stood by her side, offering advice and encouragement. Mohamed suggested incorporating art and architecture into her projects, while Ahmed recommended capturing life’s beauty through photography.

Together, they planned a community project to combine their talents — a public space where art, architecture, and photography told stories of their city’s heritage. The project became a symbol of their friendship and dedication to making a difference.

Years later, when people visited the space, they often heard about the trio — Manal, Mohamed, and Ahmed — whose collaboration transformed a dream into reality. Their journey was a testament to the power of friendship, creativity, and believing in oneself.

''',
  rating: 4.8,
  language: "en",
  bookId: 5,
  author: 'Ava Bennett',
  bookimageURL: '',
);

  List<Book> libraryBooks = [];
  bool isLoading = true;

  Future<void> fetchBooks() async {
    try {
      final response = await http.get(
        Uri.parse(
            'http://192.168.1.7:5000/get_books'), // 🔁 Replace with your Flask URL
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
              child: Column(
                children: [
                  Row(
                    children: [
                      Text('Categories',
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
                        Text('Ask Book Expert?',
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
          Get.dialog(
            Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              child: CharctersDialog(book: book5),
            ),
          );

          /* Get.to(() => CharctersDialog(
                book: book4,
              ));*/
          /*ReadingPage(
                book: book3,
              ));*/
          /* Get.to(() => SearchPage())*/;
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
