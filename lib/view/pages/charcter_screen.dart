import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CharacterScreen extends StatefulWidget {
  final String storyText;

  const CharacterScreen({Key? key, required this.storyText}) : super(key: key);

  @override
  _CharacterScreenState createState() => _CharacterScreenState();
}

class _CharacterScreenState extends State<CharacterScreen> {
  List<Map<String, dynamic>> _characters = [];
  bool _loading = true;
  String _error = '';

  /*// English test story with clear main characters
 final String testStory = """
In the coastal city of Alexandria, Mariam Al-Farsi was known as the most skilled healer, 
using ancient remedies passed down from her grandmother. Her childhood friend Omar Ibn Khattab, 
now the city's chief guard, often protected her clinic from thieves and vandals.

One stormy night, a wounded stranger named Hamza Al-Masri arrived at Mariam's doorstep, 
carrying secrets about a coming invasion. Omar, suspicious of the newcomer, 
insisted on interrogating him but Mariam saw the goodness in his eyes.

As tensions rose in the city, the trio discovered they shared a connection to the 
mysterious Order of the Crescent. Hamza revealed his true identity as a prince in exile, 
while Omar's loyalty was tested when asked to choose between duty and friendship.

Mariam's healing skills became crucial when the city was struck by a mysterious plague, 
and the three worked together to uncover the conspiracy behind both the plague and the 
impending invasion, forging an unbreakable bond in the process.
""";*/
  @override
  void initState() {
    super.initState();
    // Use either the passed storyText or our test story
    _fetchCharacters();
  }

  Future<void> _fetchCharacters() async {
    setState(() {
      _loading = true;
      _error = '';
    });

    try {
      final url = Uri.parse('http://192.168.1.3:5000/extract_characters');
      final response = await http.post(
        url,
        body: json.encode(
            {'text': widget.storyText.isNotEmpty ? widget.storyText : ""}),
        headers: {'Content-Type': 'application/json'},
      ).timeout(Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['characters'] is List) {
          setState(() {
            _characters = List<Map<String, dynamic>>.from(data['characters']);
          });
        } else {
          throw "Invalid response format";
        }
      } else {
        throw "Request failed with status: ${response.statusCode}";
      }
    } catch (e) {
      setState(() {
        _error = 'Error: $e\n\nShowing test data instead';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  String _getRoleEmoji(String role) {
    switch (role.toLowerCase()) {
      case 'main':
        return '🌟';
      case 'antagonist':
        return '👿';
      case 'important':
        return '👑';
      case 'supporting':
        return '💫';
      default:
        return '🧑';
    }
  }

  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'main':
        return Colors.blue;
      case 'antagonist':
        return Colors.red;
      case 'important':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Main Characters'),
        backgroundColor: Color(0xFFFEC838),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFEC838), Colors.white],
          ),
        ),
        child: _loading
            ? Center(child: CircularProgressIndicator())
            : _error.isNotEmpty
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_error, textAlign: TextAlign.center),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _fetchCharacters,
                        child: Text('Retry'),
                      )
                    ],
                  )
                : _characters.isEmpty
                    ? Center(child: Text('No characters found'))
                    : Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                          ),
                          Expanded(
                            child: ListView.builder(
                              itemCount: _characters.length,
                              itemBuilder: (context, index) {
                                final character = _characters[index];
                                final role = character['role'] ?? '';
                                return Card(
                                  margin: EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 8),
                                  elevation: 5,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              _getRoleEmoji(role),
                                              style: TextStyle(fontSize: 24),
                                            ),
                                            SizedBox(width: 10),
                                            Expanded(
                                              child: Text(
                                                character['name'] ?? 'Unknown',
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFF212E54),
                                                ),
                                              ),
                                            ),
                                            Chip(
                                              label: Text(
                                                '${character['mentions'] ?? 0}',
                                                style: TextStyle(
                                                    color: Colors.white),
                                              ),
                                              backgroundColor:
                                                  _getRoleColor(role),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          'Role: ${role.toUpperCase()}',
                                          style: TextStyle(
                                            fontStyle: FontStyle.italic,
                                            color: _getRoleColor(role),
                                          ),
                                        ),
                                        SizedBox(height: 12),
                                        Text(
                                          character['summary'] ??
                                              'No summary available',
                                          style: TextStyle(fontSize: 14),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: ElevatedButton(
                              onPressed: () {
                                Get.back();
                              },
                              child: Text('Back to book'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF212E54),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 40, vertical: 15),
                              ),
                            ),
                          ),
                        ],
                      ),
      ),
    );
  }
}
