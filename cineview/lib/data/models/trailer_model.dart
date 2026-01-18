class TrailerModel {
  final int movieId;
  final String movieTitle;
  final String? moviePosterPath;
  final String key;
  final String name;
  final String site;
  final String type;

  TrailerModel({
    required this.movieId,
    required this.movieTitle,
    this.moviePosterPath,
    required this.key,
    required this.name,
    required this.site,
    required this.type,
  });

  factory TrailerModel.fromJson(
    Map<String, dynamic> json,
    Map<String, dynamic> movie,
  ) {
    return TrailerModel(
      movieId: movie['id'] ?? 0,
      movieTitle: movie['title'] ?? '',
      moviePosterPath: movie['poster_path'],
      key: json['key'] ?? '',
      name: json['name'] ?? '',
      site: json['site'] ?? '',
      type: json['type'] ?? '',
    );
  }

  String get youtubeUrl => 'https://www.youtube.com/watch?v=$key';
  String get thumbnailUrl => 'https://img.youtube.com/vi/$key/hqdefault.jpg';
  String get thumbnailHQ => 'https://img.youtube.com/vi/$key/maxresdefault.jpg';
}
