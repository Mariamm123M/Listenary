import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:listenary/model/book_model.dart';
import 'package:listenary/view/pages/BookDetailScreen.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  List<Book> books = [
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

  List<Book> searchResults = [];
  List<Book> visitedBooks = [];
  String query = '';

  void _searchBooks(String query) {
    final results = books.where((book) {
      return book.booktitle.toLowerCase().contains(query.toLowerCase());
    }).toList();

    setState(() {
      this.query = query;
      searchResults = results;
    });
  }

  void _addToHistory(Book book) {
    if (!visitedBooks.contains(book)) {
      setState(() {
        visitedBooks.add(book);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color themeColor = Color(0xFF212E54);

    return Scaffold(
      backgroundColor: themeColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
            onPressed: () {
              Get.back();
            },
            icon: Icon(Icons.arrow_back_outlined, color: Colors.white)),
        title: Text(
          'Search Books',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: themeColor,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              onChanged: (query) => _searchBooks(query),
              decoration: InputDecoration(
                hintText: 'Search for a book...',
                hintStyle: TextStyle(color: Colors.white70),
                prefixIcon: Icon(Icons.search, color: Colors.white70),
                filled: true,
                fillColor: themeColor.withAlpha(25),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
              ),
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(height: 20),
            Expanded(
              child: query.isEmpty
                  ? _buildHistorySection()
                  : searchResults.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.warning,
                                  size: 100, color: Colors.white70),
                              SizedBox(height: 10),
                              Text(
                                "No results found.",
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        )
                      : GridView.builder(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 0.7,
                          ),
                          itemCount: searchResults.length,
                          itemBuilder: (context, index) {
                            final book = searchResults[index];
                            return GestureDetector(
                              onTap: () {
                                _addToHistory(book);
                                Get.to(() => BookDetailScreen(book: book));
                              },
                              child: Card(
                                color: themeColor.withAlpha(25),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                elevation: 5,
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Expanded(
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.vertical(
                                          top: Radius.circular(15),
                                        ),
                                        child: Image(
                                          image: book.bookimage,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            book.booktitle,
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            book.author,
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.white70,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          SizedBox(height: 8),
                                          Row(
                                            children: [
                                              Icon(Icons.star,
                                                  color: Colors.amber,
                                                  size: 16),
                                              SizedBox(width: 4),
                                              Text(
                                                book.rating.toString(),
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.white),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistorySection() {
    return visitedBooks.isEmpty
        ? Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "No Books yet",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
                SizedBox(width: 8),
                Icon(
                  Icons.menu_book_sharp,
                  color: Colors.white70,
                  size: 20,
                ),
              ],
            ),
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Recently Viewed",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        visitedBooks.clear();
                      });
                    },
                    child: Text(
                      "Clear ",
                      style: TextStyle(
                        color: Color(0xFFFEC838),
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: visitedBooks.map((book) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BookDetailScreen(book: book),
                          ),
                        );
                      },
                      child: Container(
                        width: 120,
                        margin: EdgeInsets.only(right: 10),
                        child: Column(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image(
                                image: book.bookimage,
                                height: 150,
                                fit: BoxFit.cover,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              book.booktitle,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          );
  }
}
