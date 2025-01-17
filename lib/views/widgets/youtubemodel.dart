import 'package:project/views/widgets/songmodel.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

Future<List<UnifiedSongModel>> fetchYouTubeSongs(String query) async {
  final yt = YoutubeExplode();
  final searchResults = await yt.search.search(query);
  List<UnifiedSongModel> youtubeSongs = [];

  for (var result in searchResults) {
    // ignore: unnecessary_type_check
    if (result is Video) {
      youtubeSongs.add(UnifiedSongModel(
        id: result.id.hashCode,
        title: result.title,
        uri: result.url,
        isLocal: false,
      ));
    }
  }

  yt.close();
  return youtubeSongs;
}
