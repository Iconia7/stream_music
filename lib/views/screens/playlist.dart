import 'package:flutter/material.dart';

class PlaylistScreen extends StatelessWidget {
  // Mock playlist data
  final List<Map<String, dynamic>> playlists = [
    {
      'name': 'Favorites',
      'image': 'assets/images/Song 1.jpeg',
      'songs': [
        {'title': 'Song 1', 'artist': 'Artist 1'},
        {'title': 'Song 2', 'artist': 'Artist 2'},
        {'title': 'Song 3', 'artist': 'Artist 3'},
      ],
    },
    {
      'name': 'Rock Hits',
      'image': 'assets/images/Song 2.jpeg',
      'songs': [
        {'title': 'Rock Song 1', 'artist': 'Rock Artist 1'},
        {'title': 'Rock Song 2', 'artist': 'Rock Artist 2'},
      ],
    },
    {
      'name': 'Chill Vibes',
      'image': 'assets/images/Album 1.jpeg',
      'songs': [
        {'title': 'Chill Song 1', 'artist': 'Chill Artist 1'},
        {'title': 'Chill Song 2', 'artist': 'Chill Artist 2'},
        {'title': 'Chill Song 3', 'artist': 'Chill Artist 3'},
      ],
    },
  ];

  PlaylistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Playlists"),
        backgroundColor: Colors.deepPurpleAccent,
      ),
      body: ListView.builder(
        itemCount: playlists.length,
        itemBuilder: (context, index) {
          final playlist = playlists[index];
          return PlaylistItem(
            name: playlist['name'],
            image: playlist['image'],
            songs: playlist['songs'],
            onTap: () {
              // Navigate to the playlist details screen
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PlaylistDetailScreen(playlist: playlist),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class PlaylistItem extends StatelessWidget {
  final String name;
  final String image;
  final List songs;
  final VoidCallback onTap;

  const PlaylistItem({super.key, required this.name, required this.image, required this.songs, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        margin: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: ListTile(
          contentPadding: EdgeInsets.all(12),
          leading: CircleAvatar(
            radius: 30,
            backgroundImage: AssetImage(image),
          ),
          title: Text(name, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          subtitle: Text("${songs.length} songs", style: TextStyle(fontSize: 14, color: Colors.grey)),
          trailing: Icon(Icons.arrow_forward_ios),
        ),
      ),
    );
  }
}

class PlaylistDetailScreen extends StatelessWidget {
  final Map<String, dynamic> playlist;

  const PlaylistDetailScreen({super.key, required this.playlist});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(playlist['name']),
        backgroundColor: Colors.deepPurpleAccent,
      ),
      body: ListView.builder(
        itemCount: playlist['songs'].length,
        itemBuilder: (context, index) {
          final song = playlist['songs'][index];
          return ListTile(
            title: Text(song['title']),
            subtitle: Text(song['artist']),
            onTap: () {
              // Handle song tap, e.g., navigate to the song player screen
              // Navigator.push(...);
            },
          );
        },
      ),
    );
  }
}