// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:project/views/widgets/songmodel.dart';
import 'package:project/views/screens/songplayer.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  _LibraryScreenState createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  List<UnifiedSongModel> _songs = [];
  final bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _requestPermissionAndLoadSongs();
  }

  Future<void> _requestPermissionAndLoadSongs() async {
    if (await Permission.storage.request().isGranted ||
        await Permission.manageExternalStorage.request().isGranted) {
      await _loadSongs();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Storage permission is required to access songs.'),
        ),
      );
    }
  }

  Future<void> _loadSongs() async {
    try {
      List<String> storagePaths = [
        '/storage/emulated/0', // Internal storage
        '/storage/sdcard1',    // SD card path (may vary by device)
        '/storage/9016-4EF8'   // Alternate SD card path (example)
      ];

      List<UnifiedSongModel> songList = [];

      for (String rootPath in storagePaths) {
        final rootDir = Directory(rootPath);
        if (rootDir.existsSync()) {
          songList.addAll(await _findMp3Files(rootDir));
        }
      }

      setState(() {
        _songs = songList;
      });

      if (_songs.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No MP3 files found.'),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error loading songs: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to load songs. Please try again.'),
        ),
      );
    }
  }

  Future<List<UnifiedSongModel>> _findMp3Files(Directory directory) async {
  List<UnifiedSongModel> songList = [];
  try {
    await for (var entity in directory.list(recursive: false, followLinks: false)) {
      if (entity is File && entity.path.toLowerCase().endsWith('.mp3')) {
        songList.add(UnifiedSongModel(
          id: entity.path.hashCode,
          title: entity.uri.pathSegments.last,
          uri: entity.path,
          isLocal: true,
          isFavorite: false,
        ));
      } else if (entity is Directory) {
        // Skip restricted directories before entering them
        if (!entity.path.contains('/Android/data') && !entity.path.contains('/Android/obb')) {
          songList.addAll(await _findMp3Files(entity)); // Recursive call
        } else {
          debugPrint('Skipping restricted directory: ${entity.path}');
        }
      }
    }
  } catch (e) {
    debugPrint('Error scanning directory ${directory.path}: $e');
  }
  return songList;
}


  Future<void> _refreshSongs() async {
    await _loadSongs();
  }

  void _toggleFavorite(int index) {
    setState(() {
      _songs[index].isFavorite = !_songs[index].isFavorite;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlueAccent,
      body: _songs.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _refreshSongs,
              child: ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: _songs.length,
                itemBuilder: (context, index) {
                  final song = _songs[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 3,
                    child: ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Colors.blue,
                        child: Icon(
                          Icons.music_note,
                          color: Colors.white,
                        ),
                      ),
                      title: Text(
                        song.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      subtitle: const Text("Tap to play"),
                      trailing: IconButton(
                        icon: Icon(
                          song.isFavorite
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: song.isFavorite ? Colors.red : Colors.grey,
                        ),
                        onPressed: () => _toggleFavorite(index),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SongPlayerScreen(
                              isDarkMode: _isDarkMode,
                              song: song,
                              playlist: _songs,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
    );
  }
}
