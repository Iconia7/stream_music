import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';

class MusicController extends GetxController {
  final AudioPlayer _audioPlayer = AudioPlayer();

  var currentSongTitle = ''.obs;
  var currentSongImage = ''.obs;
  var isPlaying = false.obs;

  Future<void> playSong({
    required String title,
    required String image,
    String? url,
    String? filePath,
  }) async {
    try {
      currentSongTitle.value = title;
      currentSongImage.value = image;

      if (url != null) {
        await _audioPlayer.setUrl(url);
      } else if (filePath != null) {
        if (filePath.startsWith('assets/')) {
          await _audioPlayer.setAsset(filePath);
        } else {
          await _audioPlayer.setFilePath(filePath);
        }
      } else {
        throw 'No valid source for the song';
      }

      _audioPlayer.play();
      isPlaying.value = true;
    } catch (e) {
      Get.snackbar('Error', 'Failed to play the song: $e');
    }
  }

  void togglePlayPause() {
    if (_audioPlayer.playing) {
      _audioPlayer.pause();
    } else {
      _audioPlayer.play();
    }
    isPlaying.value = _audioPlayer.playing;
  }

  @override
  void onClose() {
    _audioPlayer.dispose();
    super.onClose();
  }
}