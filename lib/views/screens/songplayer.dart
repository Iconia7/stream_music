import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:project/views/widgets/songmodel.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:http/http.dart' as http;

class SongPlayerScreen extends StatefulWidget {
  final UnifiedSongModel song;
  final List<UnifiedSongModel> playlist;
  final bool isDarkMode;

  const SongPlayerScreen({
    super.key,
    required this.isDarkMode,
    required this.song,
    required this.playlist,
  });

  @override
  // ignore: library_private_types_in_public_api
  _SongPlayerScreenState createState() => _SongPlayerScreenState();
}

class _SongPlayerScreenState extends State<SongPlayerScreen> {
  late final AudioPlayer _audioPlayer;
  int _currentIndex = 0;
  bool _isPlaying = false;
  bool _isShuffle = false;
  bool _isLoop = false;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;

  void playSongFromDashboard(UnifiedSongModel newSong) {
    setState(() {
      _currentIndex =
          widget.playlist.indexWhere((song) => song.id == newSong.id);
      if (_currentIndex == -1) {
        widget.playlist.add(newSong);
        _currentIndex = widget.playlist.length - 1;
      }
    });
    _loadSong();
  }

  Future<String?> _getDirectAudioUrl(String webpageUrl) async {
    final response = await http.get(Uri.parse(webpageUrl));
    if (response.statusCode == 200) {
      final pageContent = response.body;
      final regex = RegExp(r'href="([^"]*\.mp3)"');
      final match = regex.firstMatch(pageContent);
      return match?.group(1); // Return the direct URL if found
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _currentIndex =
        widget.playlist.indexWhere((song) => song.id == widget.song.id);
    if (_currentIndex == -1) _currentIndex = 0;
    _loadSong();

    _audioPlayer.positionStream.listen((position) {
      setState(() {
        _currentPosition = position;
      });
    });

    _audioPlayer.durationStream.listen((duration) {
      setState(() {
        _totalDuration = duration ?? Duration.zero;
      });
    });

    _audioPlayer.playerStateStream.listen((state) {
      setState(() {
        _isPlaying = state.playing;
      });
    });
  }

  Future<void> _loadSong() async {
    final currentSong = widget.playlist[_currentIndex];
    try {
      if (currentSong.isLocal) {
        final uri = Uri.parse(currentSong.uri!);
        await _audioPlayer.setAudioSource(AudioSource.uri(uri));
      } else if (currentSong.uri != null &&
          (currentSong.uri!.contains('youtube.com') ||
              currentSong.uri!.contains('youtu.be'))) {
        final yt = YoutubeExplode();
        final manifest =
            await yt.videos.streamsClient.getManifest(currentSong.uri!);
        final audioStreamInfo = manifest.audioOnly.withHighestBitrate();
        // ignore: unnecessary_null_comparison
        if (audioStreamInfo != null) {
          await _audioPlayer.setUrl(audioStreamInfo.url.toString());
        } else {
          throw Exception("No audio stream found for YouTube video.");
        }
        yt.close();
      } else if (currentSong.uri!.contains('mzukakibao.com')) {
        final directUrl = await _getDirectAudioUrl(currentSong.uri!);
        if (directUrl != null) {
          await _audioPlayer.setUrl(directUrl);
        } else {
          throw Exception("Unable to extract audio URL from the webpage.");
        }
      } else {
        throw Exception("Invalid song URI.");
      }

      await _audioPlayer.play();
    } catch (e) {
      debugPrint("Error loading song: $e");
    }
  }

  void _nextSong() {
    if (_isShuffle) {
      setState(() {
        _currentIndex = (widget.playlist..shuffle())
            .indexOf(widget.playlist[_currentIndex]);
        if (_currentIndex == -1) {
          _currentIndex = 0;
        }
      });
    } else {
      setState(() {
        _currentIndex = (_currentIndex + 1) % widget.playlist.length;
      });
    }
    _loadSong();
  }

  void _previousSong() {
    _currentIndex =
        (_currentIndex - 1 + widget.playlist.length) % widget.playlist.length;
    _loadSong();
  }

  void _togglePlayPause() {
    _isPlaying ? _audioPlayer.pause() : _audioPlayer.play();
  }

  void _toggleShuffle() {
    setState(() {
      _isShuffle = !_isShuffle;
      _audioPlayer.setShuffleModeEnabled(_isShuffle);
    });
  }

  void _toggleLoop() {
    setState(() {
      _isLoop = !_isLoop;
      _audioPlayer.setLoopMode(_isLoop ? LoopMode.one : LoopMode.off);
    });
  }

  void _toggleFavorite() {
    setState(() {
      widget.song.isFavorite = !widget.song.isFavorite;
    });
  }

  void _showQueue() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 400,
          padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.lightBlueAccent,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            boxShadow: [
              BoxShadow(
                // ignore: deprecated_member_use
                color: Colors.black.withOpacity(0.1),
                spreadRadius: 5,
                blurRadius: 10,
              ),
            ],
          ),
          child: Column(
            children: [
              Text(
                'Queue',
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: widget.playlist.length,
                  itemBuilder: (context, index) {
                    final song = widget.playlist[index];
                    return ListTile(
                      contentPadding: EdgeInsets.symmetric(horizontal: 12),
                      leading: Icon(Icons.music_note, color: Colors.black),
                      title: Text(
                        song.title,
                        style: TextStyle(color: Colors.black, fontSize: 18),
                      ),
                      onTap: () {
                        setState(() {
                          _currentIndex = index;
                        });
                        _loadSong();
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentSong = widget.playlist[_currentIndex];
    final elapsed =
        '${_currentPosition.inMinutes.toString().padLeft(2, '0')}:${(_currentPosition.inSeconds % 60).toString().padLeft(2, '0')}';
    final total =
        '${_totalDuration.inMinutes.toString().padLeft(2, '0')}:${(_totalDuration.inSeconds % 60).toString().padLeft(2, '0')}';

    return Scaffold(
      appBar: AppBar(
        title: Text(currentSong.title),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: widget.isDarkMode
                  ? [Colors.grey[900]!, Colors.grey[800]!]
                  : [Colors.lightBlueAccent, Colors.blue],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 30),
            Center(
              child: Container(
                height: 420,
                width: 420,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  image: const DecorationImage(
                    image: AssetImage('assets/images/default.jpeg'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.only(left: 30, right: 8),
              child: Text(
                currentSong.title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 5),
            const Text(
              "Artist Name",
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 150),
            Padding(
              padding: const EdgeInsets.only(left: 8, right: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(
                      widget.song.isFavorite
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: widget.song.isFavorite ? Colors.red : Colors.grey,
                    ),
                    onPressed: _toggleFavorite,
                  ),
                  IconButton(
                    icon: const Icon(Icons.queue_music),
                    onPressed: _showQueue,
                  ),
                ],
              ),
            ),
            Slider(
              value: _currentPosition.inSeconds.toDouble(),
              max: _totalDuration.inSeconds.toDouble(),
              onChanged: (value) {
                _audioPlayer.seek(Duration(seconds: value.toInt()));
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(elapsed, style: const TextStyle(color: Colors.grey)),
                  Text(total, style: const TextStyle(color: Colors.grey)),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: Icon(
                    Icons.shuffle,
                    color: _isShuffle ? Colors.blue : Colors.grey,
                  ),
                  onPressed: _toggleShuffle,
                ),
                IconButton(
                  icon: const Icon(Icons.skip_previous, size: 32),
                  onPressed: _previousSong,
                ),
                IconButton(
                  icon: Icon(
                    _isPlaying
                        ? Icons.pause_circle_filled
                        : Icons.play_circle_filled,
                    size: 48,
                    color: Colors.blue,
                  ),
                  onPressed: _togglePlayPause,
                ),
                IconButton(
                  icon: const Icon(Icons.skip_next, size: 32),
                  onPressed: _nextSong,
                ),
                IconButton(
                  icon: Icon(
                    Icons.repeat,
                    color: _isLoop ? Colors.blue : Colors.grey,
                  ),
                  onPressed: _toggleLoop,
                ),
              ],
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
