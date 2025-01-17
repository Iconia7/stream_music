// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class YouTubePlayerWidget extends StatefulWidget {
  final String videoId;
  final String? title;

  // ignore: use_super_parameters
  const YouTubePlayerWidget({
    Key? key,
    required this.videoId,
    this.title,
  }) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _YouTubePlayerWidgetState createState() => _YouTubePlayerWidgetState();
}

class _YouTubePlayerWidgetState extends State<YouTubePlayerWidget> {
  late YoutubePlayerController _controller;
  bool _isFullScreen = false;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId: widget.videoId,
      flags: YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
      ),
    );

    _controller.addListener(() {
      if (_controller.value.isFullScreen && !_isFullScreen) {
        _enterFullScreen();
      } else if (!_controller.value.isFullScreen && _isFullScreen) {
        _exitFullScreen();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _enterFullScreen() {
    setState(() {
      _isFullScreen = true;
    });
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  void _exitFullScreen() {
    setState(() {
      _isFullScreen = false;
    });
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlueAccent,
      appBar: _isFullScreen
          ? null
          : AppBar(
              backgroundColor: Colors.lightBlueAccent,
              elevation: 0,
              title: Text(
                widget.title ?? "YouTube Player",
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
              centerTitle: true,
              leading: IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
      body: YoutubePlayerBuilder(
        player: YoutubePlayer(
          controller: _controller,
          showVideoProgressIndicator: true,
          progressIndicatorColor: Colors.red,
          bottomActions: [
            CurrentPosition(),
            SizedBox(width: 8.0),
            ProgressBar(isExpanded: true),
            SizedBox(width: 8.0),
            RemainingDuration(),
            FullScreenButton(),
          ],
          onReady: () => print("YouTube Player is ready."),
          onEnded: (metaData) => print("Video has ended: ${metaData.videoId}"),
        ),
        builder: (context, player) {
          return Column(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(_isFullScreen ? 0 : 24),
                  child: player,
                ),
              ),
              if (!_isFullScreen)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 10),
                      Text(
                        widget.title ?? "Enjoy Watching!",
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "Explore more videos like this by browsing your favorites.",
                        style: TextStyle(fontSize: 16, color: Colors.black),
                      ),
                      SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: () => print("Share video clicked!"),
                        icon: Icon(Icons.share),
                        label: Text("Share Video"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                              vertical: 12, horizontal: 20),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
