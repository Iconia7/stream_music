import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:project/views/widgets/youtube.dart';

class DashboardScreen extends StatefulWidget {
  final bool isDarkMode;

  const DashboardScreen({super.key, required this.isDarkMode});

  @override
  // ignore: library_private_types_in_public_api
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<dynamic> _songs = [];
  List<dynamic> _trendingSongs = [];
  final String apiKey =
      'AIzaSyCdcUp_4_GJhig0hb24NoeSubx75RP9LMM'; // Replace with your API key
  final String baseUrl = 'https://www.googleapis.com/youtube/v3';
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _loadSongsFromYouTube();

    // Set up periodic refresh
    _refreshTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
      _loadSongsFromYouTube();
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadSongsFromYouTube() async {
    try {
      // Fetch trending videos for Kenya
      final trendingUrl =
          '$baseUrl/videos?part=snippet&chart=mostPopular&regionCode=KE&videoCategoryId=10&maxResults=10&key=$apiKey';

      final trendingResponse = await http.get(Uri.parse(trendingUrl));
      if (trendingResponse.statusCode == 200) {
        final data = json.decode(trendingResponse.body);
        setState(() {
          _trendingSongs = data['items'];
        });
      }

      // Fetch new songs globally
      final newSongsUrl =
          '$baseUrl/search?part=snippet&q=latest%20music&type=video&maxResults=10&key=$apiKey';

      final newSongsResponse = await http.get(Uri.parse(newSongsUrl));
      if (newSongsResponse.statusCode == 200) {
        final data = json.decode(newSongsResponse.body);
        setState(() {
          _songs = data['items'];
        });
      }
    } catch (e) {
      debugPrint('Error fetching songs: $e');
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
          // Main Content
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  _buildCarousel(),
                  const SizedBox(height: 20),
                  _buildTrendingSongsSection(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCarousel() {
    return CarouselSlider(
      options: CarouselOptions(
        height: 220,
        autoPlay: true,
        enlargeCenterPage: true,
        enableInfiniteScroll: true,
        viewportFraction: 0.8,
      ),
      items: _songs.map((song) {
        return GestureDetector(
          onTap: () {
            _navigateToSongPlayer(song);
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 8,
                  spreadRadius: 2,
                  offset: const Offset(4, 4),
                ),
              ],
              image: DecorationImage(
                image:
                    NetworkImage(song['snippet']['thumbnails']['high']['url']),
                fit: BoxFit.cover,
              ),
            ),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                padding: const EdgeInsets.all(12),
                width: double.infinity,
                // ignore: deprecated_member_use
                color: Colors.black.withOpacity(0.6),
                child: Text(
                  song['snippet']['title'],
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTrendingSongsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Trending Songs in Kenya",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 10),
          Column(
            children: _trendingSongs.map((song) {
              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 3,
                child: ListTile(
                  leading: Image.network(
                    song['snippet']['thumbnails']['default']['url'],
                    width: 50,
                  ),
                  title: Text(song['snippet']['title']),
                  onTap: () {
                    _navigateToSongPlayer(song);
                  },
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
