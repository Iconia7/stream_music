class UnifiedSongModel {
  final dynamic id; // Can be either int or String
  final String title;
  final String? artist;
  final String? album;
  final String? uri; // Path for local songs or URL for online songs
  final bool isLocal;
  bool isFavorite; // Distinguishes between local and online songs

  UnifiedSongModel({
    required this.id,
    required this.title,
    this.artist,
    this.album,
    this.uri,
    required this.isLocal,
    this.isFavorite = false,
  });
}
