import 'package:flutter/material.dart';
import 'package:project/views/widgets/audiomanager.dart';
import 'package:project/views/widgets/miniplayerstate.dart';

class MiniPlayer extends StatelessWidget {
  final ValueNotifier<MiniPlayerState> miniPlayerNotifier;

  // ignore: use_key_in_widget_constructors
  const MiniPlayer({required this.miniPlayerNotifier});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<MiniPlayerState>(
      valueListenable: miniPlayerNotifier,
      builder: (context, state, child) {
        if (state.currentSong == null) return SizedBox.shrink();

        return Container(
          color: Colors.grey[900],
          child: ListTile(
            leading: Icon(Icons.music_note, color: Colors.white),
            title: Text(state.currentSong!.title, style: TextStyle(color: Colors.white)),
            trailing: IconButton(
              icon: Icon(state.isPlaying ? Icons.pause : Icons.play_arrow, color: Colors.white),
              onPressed: () async {
                final player = AudioManager.audioPlayer;
                if (state.isPlaying) {
                  await player.pause();
                  miniPlayerNotifier.value = state.copyWith(isPlaying: false);
                } else {
                  await player.resume();
                  miniPlayerNotifier.value = state.copyWith(isPlaying: true);
                }
              },
            ),
          ),
        );
      },
    );
  }
}
