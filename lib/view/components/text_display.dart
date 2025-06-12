import 'dart:async';
import 'dart:io';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:listenary/controller/highlightedController.dart';
import 'package:listenary/controller/notesController.dart';
import 'package:listenary/controller/searchController.dart' as my_search;
import 'package:listenary/model/book_model.dart';
import 'package:listenary/model/noteModel.dart';
import 'package:listenary/view/components/definition_overlay.dart';
import 'package:listenary/view/components/executions.dart';
import 'package:listenary/view/components/myNotes.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TextDisplay extends StatefulWidget {
  final bool isDarkMode;
  final int currentSentenceIndex;
  final List<String> sentences;
  final String selectedFontFamily;
  final FontWeight selectedFontWeight;
  final TextDecoration selectedFontDecoration;
  final FontStyle selectedFontStyle;
  final double screenWidth;
  final double screenHeight;
  final ScrollController scrollController;
  final double scaleFactor;
  final String? highlightedWord;
  final Book? book;

  const TextDisplay({
    super.key,
    this.book,
    required this.isDarkMode,
    required this.scaleFactor,
    required this.scrollController,
    required this.screenHeight,
    required this.screenWidth,
    required this.currentSentenceIndex,
    required this.sentences,
    required this.selectedFontDecoration,
    required this.selectedFontFamily,
    required this.selectedFontStyle,
    required this.selectedFontWeight,
    this.highlightedWord,
  });

  @override
  State<TextDisplay> createState() => _TextDisplayState();
}

class _TextDisplayState extends State<TextDisplay> {
  User? user;
  String cleanedWord = "";
  List<String> definitions = [];
  bool isLoading = false;
  final Map<int, Note> notesMap = {};
  final DefinitionOverlayController overlayController = DefinitionOverlayController();
  final highlightController = Get.find<HighlightController>();
  final mynoteController = Get.find<NoteController>();
  final searchController = Get.find<my_search.MySearchController>();
  Color selectedColor = Colors.blue;
  
  // Fixed variable declarations
  StreamSubscription? _notesSubscription;
  StreamSubscription? _bookNotesSubscription;
  StreamSubscription? _authStateSubscription;
  bool _isLoadingNotes = false;

  @override
  void initState() {
    super.initState();
    _initializeAuth();
    WidgetsBinding.instance.addPostFrameCallback((_) {
    print('📱 Post frame callback executed');
    _debugFullAuthState(); // Add this debug call
    _initializeAuth();
    getCurrentUserId() ;
  });
  }

void getCurrentUserId() {
  User? user = FirebaseAuth.instance.currentUser;

  if (user != null) {
    String uid = user.uid;
    print("User ID: $uid");
  } else {
    print("No user is currently signed in.");
  }
}
  // Replace your _initializeAuth with this version:
void _initializeAuth() {
  print('🔐 Starting _initializeAuth');
  
  // Check immediately first
  User? immediateUser = FirebaseAuth.instance.currentUser;
  print('Immediate user check: ${immediateUser?.email ?? 'NULL'}');
  
  if (immediateUser != null) {
    print('✅ User found immediately, setting up...');
    if (mounted) {
      setState(() {
        user = immediateUser;
      });
      _initializeAfterAuth();
    }
    return; // Exit early if user is found
  }
  
  // Set up auth state listener
  print('👂 Setting up auth state listener...');
  _authStateSubscription = FirebaseAuth.instance.authStateChanges().listen((User? currentUser) {
    print('🔄 Auth state changed to: ${currentUser?.email ?? 'No user'}');
    print('🆔 User UID: ${currentUser?.uid ?? 'No UID'}');
    
    if (mounted) {
      setState(() {
        user = currentUser;
      });
      
      if (currentUser != null) {
        print('✅ User authenticated, initializing...');
        _initializeAfterAuth();
      } else {
        print('❌ User not authenticated');
        _handleUnauthenticatedUser();
      }
    }
  });
  
  // Also try with a delay in case Firebase needs time
  Timer(Duration(milliseconds: 500), () {
    User? delayedUser = FirebaseAuth.instance.currentUser;
    print('🕐 Delayed user check: ${delayedUser?.email ?? 'NULL'}');
    
    if (delayedUser != null && user == null && mounted) {
      print('🎯 Found user after delay!');
      setState(() {
        user = delayedUser;
      });
      _initializeAfterAuth();
    }
  });
}

// Add this method to manually trigger auth check (for testing)
void manualAuthCheck() {
  print('🔧 Manual auth check triggered');
  _debugFullAuthState();
  
  // Force check current user
  User? manualUser = FirebaseAuth.instance.currentUser;
  if (manualUser != null && mounted) {
    print('🎯 Manual check found user: ${manualUser.email}');
    setState(() {
      user = manualUser;
    });
    _initializeAfterAuth();
  } else {
    print('❌ Manual check found no user');
  }
}
void _debugFullAuthState() async {
  print('🔍 === FULL AUTHENTICATION DEBUG ===');
  
  // 1. Check Firebase Auth instance
  print('Firebase Auth instance: ${FirebaseAuth.instance}');
  print('Firebase App: ${FirebaseAuth.instance.app}');
  
  // 2. Check current user immediately
  User? currentUser = FirebaseAuth.instance.currentUser;
  print('Current user (immediate): ${currentUser?.email ?? 'NULL'}');
  print('Current user UID (immediate): ${currentUser?.uid ?? 'NULL'}');
  
  // 3. Wait and check again
  await Future.delayed(Duration(seconds: 1));
  currentUser = FirebaseAuth.instance.currentUser;
  print('Current user (after 1s delay): ${currentUser?.email ?? 'NULL'}');
  print('Current user UID (after 1s delay): ${currentUser?.uid ?? 'NULL'}');
  
  // 4. Check auth state stream
  print('Setting up auth state listener...');
  FirebaseAuth.instance.authStateChanges().take(1).listen((User? user) {
    print('Auth state stream result: ${user?.email ?? 'NULL'}');
    print('Auth state stream UID: ${user?.uid ?? 'NULL'}');
  });
  
  // 5. Check user state stream
  FirebaseAuth.instance.userChanges().take(1).listen((User? user) {
    print('User changes stream result: ${user?.email ?? 'NULL'}');
    print('User changes stream UID: ${user?.uid ?? 'NULL'}');
  });
  
  // 6. Check if user is signed in differently
  print('Checking all possible auth states...');
  
  // 7. Try to reload user
  if (currentUser != null) {
    try {
      await currentUser.reload();
      User? reloadedUser = FirebaseAuth.instance.currentUser;
      print('After reload - User: ${reloadedUser?.email ?? 'NULL'}');
      print('After reload - UID: ${reloadedUser?.uid ?? 'NULL'}');
    } catch (e) {
      print('Reload failed: $e');
    }
  }
  
  print('=== END DEBUG ===');
}
  void _initializeAfterAuth() {
    print('Initializing after authentication...');
    print('Current user: ${user?.email}');
    print('User UID: ${user?.uid}');
    
    // Initialize search
    searchController.initializeSearch(widget.sentences);
    searchController.attachToScrollController(widget.scrollController);

    // Load notes after initialization
    _initializeNotes();

    // Set up listeners
    _notesSubscription = mynoteController.temporaryNotes.listen((_) {
      if (mounted) {
        _loadNotes();
      }
    });

    if (widget.book != null) {
      _bookNotesSubscription = widget.book!.notes.listen((_) {
        if (mounted) {
          _loadNotes();
        }
      });
    }
  }

  void _handleUnauthenticatedUser() {
    // You can customize this based on your app's flow
    print('User is not authenticated - consider redirecting to login');
    
    // Option 1: Show a snackbar
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please log in to access notes'),
          backgroundColor: Colors.red,
        ),
      );
    }
    
    // Option 2: Redirect to login (uncomment if needed)
    // Get.offNamed('/login');
    
    // Option 3: Just initialize without user-dependent features
    searchController.initializeSearch(widget.sentences);
    searchController.attachToScrollController(widget.scrollController);
    _loadNotes(); // This will only load temporary notes
  }

  Future<void> _initializeNotes() async {
    if (user != null && widget.book != null) {
      await fetchNotesForBook();
    }
    _loadNotes();
  }

  Future<void> fetchNotesForBook() async {
    print('Starting fetchNotesForBook...');
    
    // Check prerequisites
    if (user == null) {
      print('Error: User is null, cannot fetch notes');
      return;
    }
    print('User ID: ${user!.uid}');
    
    if (widget.book == null) {
      print('Error: Book is null, cannot fetch notes');
      return;
    }
    print('Book ID: ${widget.book!.bookId}');
    print('Book Title: ${widget.book!.booktitle}');
    
    if (_isLoadingNotes) {
      print('Warning: Already loading notes, skipping...');
      return;
    }

    setState(() {
      _isLoadingNotes = true;
    });

    try {
      // Construct and log the URL
      final url = 'http://192.168.1.15:5001/api/notes?userId=${user!.uid}&bookId=${widget.book!.bookId}';
      print('Making request to: $url');
      
      final stopwatch = Stopwatch()..start();
      
      final response = await http.get(
        Uri.parse(url),
      ).timeout(const Duration(seconds: 10));
      
      stopwatch.stop();
      print('Request completed in ${stopwatch.elapsedMilliseconds}ms');
      print('Response status code: ${response.statusCode}');
      print('Response headers: ${response.headers}');
      
      if (response.statusCode == 200) {
        print('Successful response received');
        print('Raw response body: ${response.body}');
        print('Response body length: ${response.body.length} characters');
        
        try {
          final List data = json.decode(response.body);
          print('JSON decoded successfully');
          print('Number of items in response: ${data.length}');
          
          // Log each item in the response
          for (int i = 0; i < data.length; i++) {
            print('Item $i: ${data[i]}');
          }
          
          final notes = data.map((e) {
            try {
              final note = Note.fromJson(e);
              print('Successfully parsed note: ${note.noteContent} at sentence ${note.sentenceIndex}');
              return note;
            } catch (parseError) {
              print('Error parsing note item: $e');
              print('Parse error: $parseError');
              rethrow;
            }
          }).toList();
          
          print('Successfully parsed ${notes.length} notes from server');
          
          // Log details of each parsed note
          for (int i = 0; i < notes.length; i++) {
            final note = notes[i];
            print('Note $i:');
            print('  Content: "${note.noteContent}"');
            print('  Sentence Index: ${note.sentenceIndex}');
            print('  Color: ${note.color}');
            print('  Book ID: ${note.bookId}');
            print('  User ID: ${note.userId}');
            print('  Is Pinned: ${note.isPinned}');
          }
          
          if (mounted) {
            print('Widget is mounted, updating book notes...');
            
            // Log current state before update
            print('Current book.notes count: ${widget.book!.notes.length}');
            
            // Update book notes
            widget.book!.notes.assignAll(notes);
            
            print('Book notes updated successfully');
            print('New book.notes count: ${widget.book!.notes.length}');
            
            setState(() {
              _loadNotes(); // Load notes into the map after fetching
              _isLoadingNotes = false;
            });
            
            print('State updated and _loadNotes() called');
          } else {
            print('Warning: Widget not mounted, skipping state update');
          }
        } catch (jsonError) {
          print('JSON decode error: $jsonError');
          print('Response body that failed to decode: ${response.body}');
          rethrow;
        }
      } else {
        print('HTTP Error - Status Code: ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception('Failed to load notes: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception in fetchNotesForBook: $e');
      print('Exception type: ${e.runtimeType}');
      
      if (e is TimeoutException) {
        print('Request timed out after 10 seconds');
      } else if (e is SocketException) {
        print('Network connection error');
      } else if (e is FormatException) {
        print('JSON format error');
      }
      
      if (mounted) {
        setState(() {
          _isLoadingNotes = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load notes: ${e.toString()}')),
        );
      }
    }
    
    print('fetchNotesForBook completed');
  }

  Future<void> saveNoteToServer(Note note, String userId) async {
    try {
      final response = await http.post(
        Uri.parse('http://192.168.1.15:5001/api/notes'),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "userId": userId,
          "bookId": note.bookId,
          "booktitle": note.booktitle,
          "sentenceIndex": note.sentenceIndex,
          "noteContent": note.noteContent,
          "color": note.color.value.toRadixString(16),
          "isPinned": note.isPinned,
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception("Server returned ${response.statusCode}");
      }
      
      debugPrint("Note saved successfully to server");
    } catch (e) {
      debugPrint("Error saving note: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save note: ${e.toString()}')),
        );
      }
      rethrow;
    }
  }


  @override
  void dispose() {
    _notesSubscription?.cancel();
    _bookNotesSubscription?.cancel();
    _authStateSubscription?.cancel();
    super.dispose();
  }

  void _loadNotes() {
    debugPrint('Loading notes into map...');
    
    // Clear existing notes
    notesMap.clear();

    // Load book notes if available
    if (widget.book != null) {
      debugPrint('Loading ${widget.book!.notes.length} book notes');
      for (final note in widget.book!.notes) {
        notesMap[note.sentenceIndex] = note;
        debugPrint('Loaded book note at sentence ${note.sentenceIndex}: ${note.noteContent}');
      }
    }

    // Load temporary notes (these override book notes if same sentence)
    debugPrint('Loading ${mynoteController.temporaryNotes.length} temporary notes');
    for (final note in mynoteController.temporaryNotes) {
      notesMap[note.sentenceIndex] = note;
      debugPrint('Loaded temp note at sentence ${note.sentenceIndex}: ${note.noteContent}');
    }
    
    debugPrint('Total notes in map: ${notesMap.length}');
    
    // Force rebuild to show notes
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _saveNote(Note note) async {
    if (note.noteContent.isEmpty) return;

    debugPrint('Saving note: ${note.noteContent} at sentence ${note.sentenceIndex}');

    try {
      if (user != null && widget.book != null) {
        // Save to server first
        await saveNoteToServer(note, user!.uid);
        
        if (mounted) {
          // Update book notes
          widget.book!.notes.removeWhere((n) => n.sentenceIndex == note.sentenceIndex);
          widget.book!.notes.add(note);
          
          // Update local map and UI
          setState(() {
            notesMap[note.sentenceIndex] = note;
          });
          
          debugPrint('Note saved to book and updated in UI');
        }
      } else {
        // Save as temporary note
        mynoteController.saveNote(note);
        if (mounted) {
          setState(() {
            notesMap[note.sentenceIndex] = note;
          });
        }
        debugPrint('Note saved as temporary note');
      }
    } catch (e) {
      debugPrint('Error saving note: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save note: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _deleteNote(int sentenceIndex) async {
  debugPrint('Deleting note at sentence $sentenceIndex');

  try {
    if (user != null && widget.book != null) {
      // Fix: Use JSON body + headers
      final response = await http.delete(
        Uri.parse('http://192.168.1.15:5001/api/notes'),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "userId": user!.uid,
          "bookId": widget.book!.bookId,
          "sentenceIndex": sentenceIndex,
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200 || response.statusCode == 404) {
        widget.book!.notes.removeWhere((note) => note.sentenceIndex == sentenceIndex);
      } else {
        throw Exception("Failed to delete note from server: ${response.statusCode}");
      }
    } else {
      // Delete temporary note
      mynoteController.deleteNote(sentenceIndex);
    }

    setState(() {
      notesMap.remove(sentenceIndex);
    });

    debugPrint('Note deleted successfully');
  } catch (e) {
    debugPrint('Error deleting note: $e');
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete note: ${e.toString()}')),
      );
    }
  }
}

  // Helper method to check if a word position contains a search match
  bool _isInMatchRange(int sentenceIndex, int wordStartPos, int wordEndPos) {
    if (!searchController.isSearching.value ||
        searchController.searchTerm.value.isEmpty) {
      return false;
    }
    String currentWord = searchController.sentences[sentenceIndex]
        .substring(
            wordStartPos.clamp(
                0, searchController.sentences[sentenceIndex].length),
            wordEndPos.clamp(
                0, searchController.sentences[sentenceIndex].length))
        .toLowerCase();

    String searchTermLower = searchController.searchTerm.value.toLowerCase();

    return currentWord.contains(searchTermLower) ||
        searchTermLower.contains(currentWord);
  }

  // Helper method to check if a position is in the current match
  bool _isInCurrentMatch(int sentenceIndex, int wordStartPos, int wordEndPos) {
    if (searchController.matchIndexes.isEmpty) return false;

    final currentMatch =
        searchController.matchIndexes[searchController.currentMatchIndex.value];
    if (currentMatch.sentenceIndex != sentenceIndex) return false;

    return (wordStartPos <= currentMatch.endPos &&
        wordEndPos >= currentMatch.startPos);
  }

  Color _getWordColor(String word, int sentenceIndex, int wordPosition) {
    int wordStartPos = wordPosition;
    int wordEndPos = wordPosition + word.length;

    if (searchController.isSearching.value &&
        _isInMatchRange(sentenceIndex, wordStartPos, wordEndPos) &&
        sentenceIndex == widget.currentSentenceIndex) {
      return Colors.blue;
    }

    if (word.toLowerCase() == widget.highlightedWord?.toLowerCase()) {
      return Colors.blue;
    } else if (sentenceIndex == widget.currentSentenceIndex) {
      return const Color(0xffFEC838);
    } else if (searchController.isSearching.value &&
        _isInMatchRange(sentenceIndex, wordStartPos, wordEndPos)) {
      return Colors.blue;
    }

    return Colors.grey.shade600;
  }

  Color? _getWordBackground(String word, int sentenceIndex, int wordPosition) {
    int wordStartPos = wordPosition;
    int wordEndPos = wordPosition + word.length;

    if (searchController.isSearching.value &&
        _isInCurrentMatch(sentenceIndex, wordStartPos, wordEndPos)) {
      return Colors.blue[200];
    }

    return null;
  }

  Future<void> _showNoteDialog({
    required BuildContext context,
    required int sentenceIndex,
    required Function(String noteText, Color pinColor) onSave,
    String? initialValue,
  }) async {
    TextEditingController noteController = TextEditingController(
      text: initialValue?.isNotEmpty == true ? initialValue : '',
    );
    
    Color initialColor = notesMap[sentenceIndex]?.color ?? Colors.blue;
    
    await showDialog(
      context: context,
      builder: (context) {
        Color localSelectedColor = initialColor;

        return StatefulBuilder(builder: (context, setDialogState) {
          return AlertDialog(
            icon: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (notesMap.containsKey(sentenceIndex))
                  IconButton(
                    icon: Icon(
                      Icons.delete,
                      color: Colors.grey[700],
                      size: widget.screenWidth * 0.05,
                    ),
                    onPressed: () {
                      _deleteNote(sentenceIndex);
                      Get.back();
                    },
                  ),
              ],
            ),
            backgroundColor: Colors.white,
            title: Text(
              notesMap.containsKey(sentenceIndex) ? "Edit Note" : "Add a Note",
              style: TextStyle(fontSize: widget.screenWidth * 0.04),
            ),
            actionsPadding:
                EdgeInsets.symmetric(vertical: widget.screenHeight * 0.015),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: noteController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintStyle: TextStyle(color: Color(0xff212E54)),
                    hintText: notesMap.containsKey(sentenceIndex)
                        ? null
                        : "Write your note here",
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(35),
                        borderSide: BorderSide(color: Colors.grey, width: 2)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(35),
                        borderSide: BorderSide(color: Colors.grey, width: 2)),
                  ),
                ),
                SizedBox(height: widget.screenHeight * 0.03),
                Row(
                  children: [
                    Text(
                      "Note color: ",
                      style: TextStyle(
                          fontSize: widget.screenWidth * 0.025,
                          fontWeight: FontWeight.bold),
                    ),
                    ...[
                      Colors.blue,
                      Colors.red,
                      Colors.green,
                      Colors.orange,
                      Colors.purple,
                      Colors.amber,
                    ].map((color) {
                      return GestureDetector(
                        onTap: () {
                          setDialogState(() {
                            localSelectedColor = color;
                          });
                        },
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: 4),
                          width: widget.screenWidth * 0.052,
                          height: widget.screenWidth * 0.052,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: localSelectedColor == color
                                  ? Colors.grey
                                  : Colors.transparent,
                              width: 3.5,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ],
            ),
            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    style: ButtonStyle(
                      padding: WidgetStatePropertyAll(EdgeInsets.symmetric(
                          horizontal: widget.screenWidth * 0.03,
                          vertical: widget.screenHeight * 0.012)),
                      backgroundColor: const WidgetStatePropertyAll(
                        Colors.grey,
                      ),
                    ),
                    onPressed: () => Get.back(),
                    child: Text(
                      "Cancel",
                      style: TextStyle(fontSize: widget.screenWidth * 0.025),
                    ),
                  ),
                  ElevatedButton(
                    style: ButtonStyle(
                      padding: WidgetStatePropertyAll(EdgeInsets.symmetric(
                          horizontal: widget.screenWidth * 0.035,
                          vertical: widget.screenHeight * 0.012)),
                    ),
                    onPressed: () {
                      if (noteController.text.trim().isNotEmpty) {
                        onSave(noteController.text.trim(), localSelectedColor);
                      }
                      Get.back();
                    },
                    child: Text(
                      "Save",
                      style: TextStyle(fontSize: widget.screenWidth * 0.025),
                    ),
                  ),
                ],
              ),
            ],
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) async {
        if (searchController.isSearching.value) {
          searchController.close();
          return;
        }
        Get.back();
      },
      child: Obx(() {
        return CustomScrollView(
          controller: widget.scrollController,
          slivers: [
            if (searchController.isSearching.value)
              SliverAppBar(
                leadingWidth: widget.screenWidth * 0.5,
                titleSpacing: 0,
                backgroundColor: Colors.white,
                surfaceTintColor: Colors.transparent,
                flexibleSpace: Container(
                    color:
                        widget.isDarkMode ? Color(0xFF212E54) : Colors.white),
                forceElevated: true,
                elevation: 0,
                pinned: true,
                centerTitle: true,
                leading: Row(
                  children: [
                    IconButton(
                      iconSize: widget.screenWidth * 0.038,
                      color:
                          widget.isDarkMode ? Colors.white : Color(0xFF212E54),
                      icon: Icon(Icons.arrow_back),
                      onPressed: searchController.previousMatch,
                    ),
                    Obx(
                      () => Text(
                        '${searchController.currentMatchIndex.value + 1} of ${searchController.matchIndexes.length}',
                        style: TextStyle(
                            fontSize: widget.screenWidth * 0.038,
                            color: widget.isDarkMode
                                ? Colors.white
                                : Color(0xFF212E54)),
                      ),
                    ),
                    IconButton(
                      iconSize: widget.screenWidth * 0.038,
                      icon: Icon(Icons.arrow_forward),
                      color:
                          widget.isDarkMode ? Colors.white : Color(0xFF212E54),
                      onPressed: searchController.nextMatch,
                    ),
                  ],
                ),
                title: Container(
                  width: widget.screenWidth * 0.5,
                  color: widget.isDarkMode ? Color(0xFF212E54) : Colors.white,
                  padding: EdgeInsets.all(8),
                  child: TextField(
                    controller: searchController.textController,
                    onChanged: (value) {
                      searchController.updateSearchTerm(value);
                    },
                    decoration: InputDecoration(
                      hintText: 'Search...',
                      hintStyle: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: widget.isDarkMode
                              ? Colors.white
                              : Color(0xFF212E54)),
                      border: InputBorder.none,
                    ),
                    style: TextStyle(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
                actions: [
                  IconButton(
                    icon: Icon(Icons.close),
                    iconSize: widget.screenWidth * 0.045,
                    color: widget.isDarkMode ? Colors.white : Color(0xFF212E54),
                    onPressed: searchController.close,
                  )
                ],
              ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, sentenceIndex) {
                  String sentence = widget.sentences[sentenceIndex];
                  List<String> words = sentence.split(' ');
                  bool isRTLText = isRTL(sentence);
                  
                  return Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: widget.screenWidth * 0.0095,
                        vertical: widget.screenHeight * 0.003),
                    child: IntrinsicWidth(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        textDirection:
                            isRTLText ? TextDirection.rtl : TextDirection.ltr,
                        children: [
                          // For RTL, put the pin first
                          if (isRTLText && notesMap.containsKey(sentenceIndex))
                            IconButton(
                              icon: SvgPicture.asset(
                                "assets/Icons/pin.svg",
                                color: notesMap[sentenceIndex]!.color,
                                height: widget.screenWidth * 0.07,
                                width: widget.screenWidth * 0.07,
                              ),
                              onPressed: () => _showNoteDialog(
                                initialValue:
                                    notesMap[sentenceIndex]?.noteContent,
                                context: context,
                                sentenceIndex: sentenceIndex,
                                onSave: (noteText, pinColor) {
                                  final newNote = Note(
                                    userId: user?.uid ?? '', 
                                    bookId: widget.book?.bookId.toString() ?? 'unknown',
                                    booktitle: widget.book?.booktitle ?? 'Temporary Note',
                                    noteContent: noteText,
                                    color: pinColor,
                                    sentenceIndex: sentenceIndex,
                                    isPinned: false, 
                                  );
                                  _saveNote(newNote);
                                },
                              ),
                            ),
                          Flexible(
                            child: Obx(
                              () => RichText(
                                textDirection: isRTLText
                                    ? TextDirection.rtl
                                    : TextDirection.ltr,
                                text: TextSpan(
                                  children:
                                      _buildTextSpans(sentence, sentenceIndex),
                                ),
                              ),
                            ),
                          ),
                          // For LTR, put the pin after
                          if (!isRTLText && notesMap.containsKey(sentenceIndex))
                            IconButton(
                              icon: SvgPicture.asset(
                                "assets/Icons/pin.svg",
                                color: notesMap[sentenceIndex]!.color,
                                height: widget.screenWidth * 0.07,
                                width: widget.screenWidth * 0.07,
                              ),
                              onPressed: () => _showNoteDialog(
                                initialValue:
                                    notesMap[sentenceIndex]?.noteContent,
                                context: context,
                                sentenceIndex: sentenceIndex,
                                onSave: (noteText, pinColor) {
                                  final newNote = Note(
                                    userId: user?.uid ?? '', 
                                    bookId: widget.book?.bookId.toString() ?? 'unknown',
                                    booktitle: widget.book?.booktitle ??
                                        'Temporary Note',
                                    noteContent: noteText,
                                    color: pinColor,
                                    sentenceIndex: sentenceIndex,
                                    isPinned: false, 
                                  );
                                  _saveNote(newNote);
                                },
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
                childCount: widget.sentences.length,
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(height: widget.screenHeight * 0.5),
            ),
          ],
        );
      }),
    );
  }

  List<InlineSpan> _buildTextSpans(String sentence, int sentenceIndex) {
    List<InlineSpan> spans = [];
    List<String> words = sentence.split(' ');
    int currentPosition = 0;

    for (int i = 0; i < words.length; i++) {
      String word = words[i];
      int wordPosition = currentPosition;

      spans.add(
        TextSpan(
          text: "$word",
          style: TextStyle(
              fontSize: widget.screenWidth * 0.05 * widget.scaleFactor,
              fontFamily: widget.selectedFontFamily,
              fontStyle: widget.selectedFontStyle,
              fontWeight: widget.selectedFontWeight,
              decoration: widget.selectedFontDecoration,
              backgroundColor:
                  _getWordBackground(word, sentenceIndex, wordPosition),
              color: _getWordColor(word, sentenceIndex, wordPosition)),
          recognizer: TapGestureRecognizer()
            ..onTapDown = (details) async {
              final tapPosition = details.globalPosition;
              final selectedOption = await showMenu<String>(
                context: context,
                position: RelativeRect.fromLTRB(
                  tapPosition.dx,
                  tapPosition.dy,
                  tapPosition.dx,
                  tapPosition.dy,
                ),
                items: [
                  PopupMenuItem(
                    value: 'define',
                    child: Text(
                      'Define "${word.replaceAll(RegExp(r'[^\w\s\u0621-\u064A]'), '')}"',
                      style: TextStyle(
                          fontSize: widget.screenWidth * 0.038,
                          fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  PopupMenuItem(
                    value: 'note',
                    child: Text(
                      'Leave a note',
                      style: TextStyle(
                        fontSize: widget.screenWidth * 0.038,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              );

              if (selectedOption == 'define') {
                if (overlayController.isShowing) return;
                overlayController.show(
                  context: context,
                  isLoading: true,
                  position: tapPosition,
                  screenHeight: widget.screenHeight,
                  screenWidth: widget.screenWidth,
                  cleanedWord:
                      word.replaceAll(RegExp(r'[^\w\s\u0621-\u064A]'), ''),
                  definitions: [],
                  selectedFontFamily: widget.selectedFontFamily,
                  wordLang: isArabic(word),
                  onDismiss: () {
                    isLoading = false;
                  },
                );
                definitions =
                    await fetchDefinition(word, wordLang: isArabic(word));
                overlayController.dismiss();
                overlayController.show(
                  context: context,
                  isLoading: false,
                  position: tapPosition,
                  screenHeight: widget.screenHeight,
                  screenWidth: widget.screenWidth,
                  cleanedWord:
                      word.replaceAll(RegExp(r'[^\w\s\u0621-\u064A]'), ''),
                  definitions: definitions,
                  selectedFontFamily: widget.selectedFontFamily,
                  wordLang: isArabic(word),
                  onDismiss: () {},
                );
              } else if (selectedOption == 'note') {
                _showNoteDialog(
                  initialValue: notesMap[sentenceIndex]?.noteContent,
                  context: context,
                  sentenceIndex: sentenceIndex,
                  onSave: (noteText, pinColor) {
                    final newNote = Note(
                      userId: user?.uid ?? '', 
                      bookId: widget.book?.bookId.toString() ?? 'unknown',
                      booktitle: widget.book?.booktitle ?? 'Temporary Note',
                      noteContent: noteText,
                      color: pinColor,
                      sentenceIndex: sentenceIndex,
                      isPinned: false, 
                    );
                    _saveNote(newNote);
                  },
                );
              }
            },
        ),
      );

      currentPosition += word.length;

      if (i < words.length - 1) {
        spans.add(TextSpan(
          text: " ",
          style: TextStyle(
            fontSize: widget.screenWidth * 0.05 * widget.scaleFactor,
            fontFamily: widget.selectedFontFamily,
            fontStyle: widget.selectedFontStyle,
            fontWeight: widget.selectedFontWeight,
            decoration: widget.selectedFontDecoration,
          ),
        ));
        currentPosition += 1;
      }
    }

    return spans;
  }
}

bool isRTL(String text) {
  return RegExp(r'[\u0600-\u06FF]').hasMatch(text);
}