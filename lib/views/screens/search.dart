import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:project/views/widgets/youtube.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _searchResults = [];
  bool _isLoading = false;
  String? _errorMessage;

  final String apiKey =
      'AIzaSyCdcUp_4_GJhig0hb24NoeSubx75RP9LMM'; // Replace with your actual YouTube API key
  final String baseUrl = 'https://www.googleapis.com/youtube/v3';

  Future<void> _searchYouTubeVideos(String query) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final searchUrl =
          '$baseUrl/search?part=snippet&q=$query&type=video&maxResults=10&key=$apiKey';

      final response = await http.get(Uri.parse(searchUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _searchResults = data['items'];
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to load search results.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error fetching results: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _navigateToSongPlayer(dynamic song) {
    final videoId = song['id'] is Map ? song['id']['videoId'] : song['id'];
    if (videoId != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => YouTubePlayerWidget(videoId: videoId),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlueAccent,
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search for videos...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: BorderSide.none,
                ),
              ),
              onSubmitted: (query) {
                if (query.isNotEmpty) {
                  _searchYouTubeVideos(query);
                }
              },
            ),
          ),

          // Loading Indicator
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),

          // Error Message
          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            ),

          // Search Results
          Expanded(
            child: _searchResults.isEmpty && !_isLoading
                ? const Center(
                    child: Text(
                      'No results found. Try searching for another video!',
                      style: TextStyle(color: Colors.white),
                    ),
                  )
                : ListView.builder(
                    itemCount: _searchResults.length,
                    itemBuilder: (context, index) {
                      final video = _searchResults[index];
                      // ignore: unused_local_variable
                      final videoId =
                          video['id']['videoId']; // Extract video ID
                      final videoTitle =
                          video['snippet']['title']; // Extract title
                      final thumbnailUrl = video['snippet']['thumbnails']
                          ['default']['url']; // Extract thumbnail

                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 8.0,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        elevation: 4,
                        child: ListTile(
                          leading: Image.network(
                            thumbnailUrl,
                            width: 50,
                            fit: BoxFit.cover,
                          ),
                          title: Text(
                            videoTitle,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          trailing: const Icon(
                            Icons.play_arrow,
                            color: Colors.blue,
                          ),
                          onTap: () {
                            _navigateToSongPlayer(video);
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
