import 'package:project/views/widgets/songmodel.dart';

class MiniPlayerState {
  final UnifiedSongModel? currentSong;
  final bool isPlaying;

  MiniPlayerState({
    required this.currentSong,
    required this.isPlaying,
  });

  MiniPlayerState copyWith({
    UnifiedSongModel? currentSong,
    bool? isPlaying,
  }) {
    return MiniPlayerState(
      currentSong: currentSong ?? this.currentSong,
      isPlaying: isPlaying ?? this.isPlaying,
    );
  }
}
