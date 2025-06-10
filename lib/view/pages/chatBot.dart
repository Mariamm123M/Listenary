import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';

class ChatBotPage extends StatefulWidget {
  @override
  _ChatBotPageState createState() => _ChatBotPageState();
}

class _ChatBotPageState extends State<ChatBotPage> {
  List<ChatMessage> chatMessages = [];
  bool isRobotVisible = true;
  TextEditingController _controller = TextEditingController();
  bool _isDarkMode = false;
  bool _loading = false;
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Add a welcome message
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _addBotMessage(
          'chat_bot_intro'.tr);
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _addBotMessage(String message, {Map<String, dynamic>? bookData}) {
    setState(() {
      chatMessages.add(ChatMessage(
        text: message,
        isUser: false,
        bookData: bookData,
      ));
    });
    _scrollToBottom();
  }

  void _sendMessage() {
    if (_controller.text.isEmpty) return;

    setState(() {
      chatMessages.add(ChatMessage(
        text: _controller.text,
        isUser: true,
      ));
      isRobotVisible = false;
      searchBook(_controller.text);
      _controller.clear();
    });
    _scrollToBottom();
  }

  Future<void> searchBook(String query) async {
    if (query.trim().isEmpty) {
      print("Please enter a book name");
      return;
    }

    // Replace with your actual server URL
    final url = Uri.parse('http://192.168.1.3:5006/search');
    setState(() {
      _loading = true;
    });

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"query": query.trim()}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _loading = false;
        });
        print("Server response: ${response.body}");

        // Check if the response contains structured book data
        if (data.containsKey("book_data") && data["book_data"] != null) {
          _addBotMessage(data["result"], bookData: data["book_data"]);
        } else {
          _addBotMessage(data["result"]);
        }
      } else {
        setState(() {
          _loading = false;
        });
        _addBotMessage(
           "chat_bot_error".tr);
      }
    } catch (e) {
      setState(() {
        _loading = false;
      });
      _addBotMessage(
          "chat_bot_internet_error".tr);
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: _isDarkMode ? ThemeData.dark() : ThemeData.light(),
      home: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              color: _isDarkMode ? Color(0xffFEC838) : Color(0xFF212E54),
            ),
            onPressed: () {
              Get.back();
            },
          ),
          title: Text(
            'chat_bot'.tr,
            style: TextStyle(
                color: _isDarkMode ? Colors.white : Color(0xFF212E54),
                fontFamily: 'Inter',
                fontWeight: FontWeight.bold,
                fontSize: screenWidth * 0.065),
          ),
          backgroundColor: _isDarkMode ? Color(0xFF212E54) : Colors.white,
          actions: [
            IconButton(
              icon: Icon(
                _isDarkMode ? Icons.light_mode : Icons.dark_mode,
                color: _isDarkMode ? Color(0xffFEC838) : Color(0xff949494),
              ),
              onPressed: () {
                setState(() {
                  _isDarkMode = !_isDarkMode;
                });
              },
            ),
          ],
        ),
        body: Container(
          color: _isDarkMode ? Color(0xFF1A2340) : Colors.grey[100],
          child: Column(
            children: [
              if (isRobotVisible) ...[
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(
                        top: 16.0, left: 16.0, right: 16.0, bottom: 0.0),
                    child: Lottie.asset(
                      'assets/Images/robot.json',
                      width: screenWidth * 0.40,
                      height: screenHeight * 0.40,
                    ),
                  ),
                ),
              ],
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.015,
                      vertical: screenHeight * 0.025),
                  itemCount: chatMessages.length,
                  itemBuilder: (context, index) {
                    // Display messages in reverse order for proper scrolling
                    final messageIndex = chatMessages.length - 1 - index;
                    return _buildMessageItem(
                        chatMessages[messageIndex], screenHeight, screenWidth);
                  },
                ),
              ),
              if (_loading)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _isDarkMode ? Color(0xffFEC838) : Color(0xFF4A80F0),
                      ),
                    ),
                  ),
                ),
              _buildInputArea(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMessageItem(
      ChatMessage message, double screenHeight, double screenWidth) {
    // For user messages, keep the standard display
    if (message.isUser) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: screenHeight * 0.01),
        child: Align(
          alignment: Alignment.centerRight,
          child: Container(
            constraints: BoxConstraints(
              maxWidth: screenWidth * 0.75,
            ),
            padding: EdgeInsets.symmetric(
                vertical: screenHeight * 0.012, horizontal: screenWidth * 0.04),
            decoration: BoxDecoration(
              color: _isDarkMode ? Color(0xFF3A6EA5) : Color(0xFF4A80F0),
              borderRadius: BorderRadius.circular(18).copyWith(
                bottomRight: Radius.circular(0),
                bottomLeft: Radius.circular(18),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: SelectableText(
              message.text,
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'Inter',
                fontSize: screenWidth * 0.045,
              ),
            ),
          ),
        ),
      );
    }

    // For bot messages with book data, create a formatted card
    if (!message.isUser && message.bookData != null) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: screenHeight * 0.015),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Container(
            constraints: BoxConstraints(
              maxWidth: screenWidth * 0.85,
            ),
            decoration: BoxDecoration(
              color: _isDarkMode ? Color(0xFF2D3748) : Colors.white,
              borderRadius: BorderRadius.circular(18).copyWith(
                bottomLeft: Radius.circular(0),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Directionality(
              textDirection: message.bookData!["is_arabic"] == true
                  ? TextDirection.rtl
                  : TextDirection.ltr,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                //textDirection:  message.bookData!["is_arabic"]? TextDirection.rtl: TextDirection.ltr,
                children: [
                  // Book Title as Header
                  if (message.bookData!.containsKey("title") &&
                      message.bookData!["title"].toString().isNotEmpty)
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                          vertical: screenHeight * 0.01,
                          horizontal: screenWidth * 0.015),
                      decoration: BoxDecoration(
                        color:
                            _isDarkMode ? Color(0xFF1D2B3A) : Color(0xFFF0F2F5),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(18),
                          topRight: Radius.circular(18),
                        ),
                      ),
                      child: Text(
                        message.bookData!["title"],
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.bold,
                          fontSize: screenWidth * 0.045,
                          color: _isDarkMode ? Colors.white : Color(0xFF212E54),
                        ),
                      ),
                    ),

                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Author info
                        if (message.bookData!.containsKey("author") &&
                            message.bookData!["author"].toString().isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: RichText(
                              text: TextSpan(
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: screenWidth * 0.045,
                                  color: _isDarkMode
                                      ? Colors.white
                                      : Colors.black87,
                                ),
                                children: [
                                  TextSpan(
                                    text: message.bookData!["is_arabic"]
                                        ? "الكاتب: "
                                        : "Author: ",
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.bold,
                                      fontSize: screenWidth * 0.045,
                                    ),
                                  ),
                                  TextSpan(text: message.bookData!["author"]),
                                ],
                              ),
                            ),
                          ),

                        // Published date if available
                        if (message.bookData!.containsKey("publish_year") &&
                            message.bookData!["publish_year"]
                                .toString()
                                .isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: RichText(
                              text: TextSpan(
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: screenWidth * 0.045,
                                  color: _isDarkMode
                                      ? Colors.white
                                      : Colors.black87,
                                ),
                                children: [
                                  TextSpan(
                                    text: message.bookData!["is_arabic"]
                                        ? "سنة الإصدار: "
                                        : "First Published: ",
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.bold,
                                      fontSize: screenWidth * 0.045,
                                    ),
                                  ),
                                  TextSpan(
                                      text: message.bookData!["publish_year"]
                                          .toString()),
                                ],
                              ),
                            ),
                          ),

                        // Description section
                        if (message.bookData!.containsKey("description") &&
                            message.bookData!["description"]
                                .toString()
                                .isNotEmpty)
                          Padding(
                            padding:
                                const EdgeInsets.only(bottom: 12.0, top: 4.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  message.bookData!["is_arabic"]
                                      ? "الوصف: "
                                      : "Description:",
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.bold,
                                    fontSize: screenWidth * 0.045,
                                    color: _isDarkMode
                                        ? Colors.white
                                        : Colors.black87,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  message.bookData!["description"],
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: screenWidth * 0.042,
                                    color: _isDarkMode
                                        ? Colors.white70
                                        : Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),

                        // Book Cover Image - after description
                        if (message.bookData!.containsKey("cover_url") &&
                            message.bookData!["cover_url"]
                                .toString()
                                .isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12.0),
                            child: Center(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: Image.network(
                                  message.bookData!["cover_url"],
                                  height: 180,
                                  fit: BoxFit.contain,
                                  loadingBuilder:
                                      (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Container(
                                      height: screenHeight * 0.4,
                                      width: screenWidth * 0.25,
                                      color: _isDarkMode
                                          ? Colors.grey[800]
                                          : Colors.grey[300],
                                      child: Center(
                                        child: CircularProgressIndicator(
                                          color: _isDarkMode
                                              ? Color(0xffFEC838)
                                              : Color(0xFF4A80F0),
                                          value: loadingProgress
                                                      .expectedTotalBytes !=
                                                  null
                                              ? loadingProgress
                                                      .cumulativeBytesLoaded /
                                                  loadingProgress
                                                      .expectedTotalBytes!
                                              : null,
                                        ),
                                      ),
                                    );
                                  },
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      height: 0,
                                      width: 0,
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),

                        // Subjects/Categories section
                        if (message.bookData!.containsKey("subjects") &&
                            message.bookData!["subjects"].toString().isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  message.bookData!["is_arabic"]
                                      ? "الأبطال: "
                                      : "Subjects:",
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.bold,
                                    fontSize: screenWidth * 0.045,
                                    color: _isDarkMode
                                        ? Colors.white
                                        : Colors.black87,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  message.bookData!["subjects"],
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: screenWidth * 0.042,
                                    color: _isDarkMode
                                        ? Colors.white70
                                        : Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),

                        // Author bio if available
                        if (message.bookData!.containsKey("author_bio") &&
                            message.bookData!["author_bio"]
                                .toString()
                                .isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  message.bookData!["is_arabic"]
                                      ? "تاريخ حياة الكاتب: "
                                      : "Author Bio:",
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.bold,
                                    fontSize: screenWidth * 0.045,
                                    color: _isDarkMode
                                        ? Colors.white
                                        : Colors.black87,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  message.bookData!["author_bio"],
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: screenWidth * 0.042,
                                    color: _isDarkMode
                                        ? Colors.white70
                                        : Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),

                        // Birth date if available
                        if (message.bookData!.containsKey("birth_date") &&
                            message.bookData!["birth_date"]
                                .toString()
                                .isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: RichText(
                              text: TextSpan(
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: screenWidth * 0.045,
                                  color: _isDarkMode
                                      ? Colors.white
                                      : Colors.black87,
                                ),
                                children: [
                                  TextSpan(
                                    text: message.bookData!["is_arabic"]
                                        ? "تاريخ الميلاد:     "
                                        : "Birth Date:     ",
                                    style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.bold),
                                  ),
                                  TextSpan(
                                      text: message.bookData!["birth_date"]),
                                ],
                              ),
                            ),
                          ),

                        // Death date
                        if (message.bookData!.containsKey("death_date"))
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: RichText(
                              text: TextSpan(
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: screenWidth * 0.045,
                                  color: _isDarkMode
                                      ? Colors.white
                                      : Colors.black87,
                                ),
                                children: [
                                  TextSpan(
                                    text: message.bookData!["is_arabic"]
                                        ? "تاريخ الوفاة:      "
                                        : "Death Date:     ",
                                    style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.bold),
                                  ),
                                  TextSpan(
                                      text: message.bookData!["death_date"]
                                              .toString()
                                              .isNotEmpty
                                          ? message.bookData!["death_date"]
                                          : message.bookData!["is_arabic"]
                                              ? "غير معروف"
                                              : "Unknown"),
                                ],
                              ),
                            ),
                          ),

                        // Other books by author - as bullet points
                        if (message.bookData!
                                .containsKey("other_books_by_author") &&
                            message.bookData!["other_books_by_author"]
                                is List &&
                            (message.bookData!["other_books_by_author"] as List)
                                .isNotEmpty)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                    top: 8.0, bottom: 8.0),
                                child: Text(
                                  message.bookData!["is_arabic"]
                                      ? "كتب أخرى للكاتب: "
                                      : "Other Books by Author:",
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.bold,
                                    fontSize: screenWidth * 0.045,
                                    color: _isDarkMode
                                        ? Colors.white
                                        : Colors.black87,
                                  ),
                                ),
                              ),
                              ...List.generate(
                                (message.bookData!["other_books_by_author"]
                                                as List)
                                            .length >
                                        5
                                    ? 5
                                    : (message.bookData![
                                            "other_books_by_author"] as List)
                                        .length,
                                (index) => Padding(
                                  padding: const EdgeInsets.only(
                                      left: 8.0, bottom: 4.0),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "• ",
                                        style: TextStyle(
                                          fontFamily: 'Inter',
                                          fontSize: screenWidth * 0.042,
                                          fontWeight: FontWeight.bold,
                                          color: _isDarkMode
                                              ? Colors.white70
                                              : Colors.black87,
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          (message.bookData![
                                                      "other_books_by_author"]
                                                  as List)[index]
                                              .toString(),
                                          style: TextStyle(
                                            fontFamily: 'Inter',
                                            fontSize: screenWidth * 0.042,
                                            color: _isDarkMode
                                                ? Colors.white70
                                                : Colors.black87,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    // For regular bot messages without book data
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75,
          ),
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: _isDarkMode ? Color(0xFF2D3748) : Colors.white,
            borderRadius: BorderRadius.circular(18).copyWith(
              bottomLeft: Radius.circular(0),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: SelectableText(
            message.text,
            style: TextStyle(
              fontFamily: 'Inter',
              color: _isDarkMode ? Colors.white : Colors.black87,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: _isDarkMode ? Color(0xFF212E54) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'ask_anything'.tr,
                hintStyle: TextStyle(
                  fontFamily: 'Inter',
                  color: _isDarkMode ? Colors.white70 : Colors.grey[500],
                ),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                filled: true,
                fillColor: _isDarkMode ? Color(0xFF1A2340) : Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(
                    color: _isDarkMode ? Color(0xffFEC838) : Color(0xFF4A80F0),
                    width: 1.5,
                  ),
                ),
              ),
              style: TextStyle(
                fontFamily: 'Inter',
                color: _isDarkMode ? Colors.white : Colors.black87,
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          SizedBox(width: 8),
          Material(
            color: _isDarkMode ? Color(0xffFEC838) : Color(0xFF4A80F0),
            borderRadius: BorderRadius.circular(50),
            child: InkWell(
              borderRadius: BorderRadius.circular(50),
              onTap: _sendMessage,
              child: Container(
                padding: EdgeInsets.all(12),
                child: Icon(
                  Icons.send,
                  color: Colors.white,
                  size: MediaQuery.of(context).size.width * 0.045,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final Map<String, dynamic>? bookData;

  ChatMessage({
    required this.text,
    required this.isUser,
    this.bookData,
  });
}
